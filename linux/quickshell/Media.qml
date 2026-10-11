pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

// Shared music state: the active MPRIS player (Spotify, spotify_player,
// browsers...), its synced lyrics from LRCLIB and the lyrics overlay settings.
Singleton {
    id: root

    // Prefer whatever is playing; otherwise the first player around
    readonly property var player: Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null
    readonly property string title: player?.trackTitle ?? ""
    readonly property string artist: player?.trackArtist ?? ""
    readonly property real position: player?.position ?? 0

    // Lyrics: [{ time: seconds, text }] sorted by time
    property var lyrics: []
    property string lyricsStatus: "idle"   // idle | loading | ready | missing
    readonly property int currentLine: lineAt(position + 0.25)

    // Song panel under the bar's music icon
    property bool panelOpen: false

    // ---- Shuffle, repeat, volume and like -----------------------------------
    // spotify_player exposes none of these over MPRIS, so for it they go
    // through its own CLI (which talks to the running app); any other player
    // uses MPRIS.

    readonly property bool isSpotifyPlayer: (player?.dbusName ?? "").indexOf("spotify_player") !== -1
    property var spotifyState: ({ shuffle: false, repeat: "off", volume: 0 })

    readonly property bool shuffleAvailable: isSpotifyPlayer || (player?.shuffleSupported ?? false)
    readonly property bool shuffleOn: isSpotifyPlayer ? spotifyState.shuffle : (player?.shuffle ?? false)
    readonly property bool repeatAvailable: isSpotifyPlayer || (player?.loopSupported ?? false)
    // "off" | "all" | "one"
    readonly property string repeatMode: isSpotifyPlayer
        ? ({ off: "off", context: "all", track: "one" })[spotifyState.repeat] ?? "off"
        : player?.loopState === MprisLoopState.Track ? "one"
        : player?.loopState === MprisLoopState.Playlist ? "all" : "off"
    readonly property bool volumeAvailable: isSpotifyPlayer || (player?.volumeSupported ?? false)
    readonly property real volume: isSpotifyPlayer ? spotifyState.volume / 100 : (player?.volume ?? 0)

    function spotifyCommand(args) {
        Quickshell.execDetached(["spotify_player", ...args]);
        stateRefresh.restart();
    }

    function toggleShuffle() {
        if (isSpotifyPlayer) spotifyCommand(["playback", "shuffle"]);
        else player.shuffle = !player.shuffle;
    }

    // off -> all -> one -> off, the order spotify_player also uses
    function cycleRepeat() {
        if (isSpotifyPlayer) {
            spotifyCommand(["playback", "repeat"]);
        } else {
            player.loopState = repeatMode === "off" ? MprisLoopState.Playlist
                : repeatMode === "all" ? MprisLoopState.Track : MprisLoopState.None;
        }
    }

    function setVolume(fraction) {
        const value = Math.max(0, Math.min(1, fraction));
        if (isSpotifyPlayer) spotifyCommand(["playback", "volume", String(Math.round(value * 100))]);
        else player.volume = value;
    }

    // Liking is a Spotify feature, so it only exists for spotify_player
    function like(unlike) {
        spotifyCommand(unlike ? ["like", "--unlike"] : ["like"]);
    }

    Process {
        id: spotifyStateQuery
        command: ["spotify_player", "get", "key", "playback"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    root.spotifyState = {
                        shuffle: !!d.shuffle_state,
                        repeat: d.repeat_state ?? "off",
                        volume: d.device?.volume_percent ?? 0
                    };
                } catch (e) {}
            }
        }
    }

    // State refresh while the panel is open, and right after an action
    Timer {
        interval: 2000
        repeat: true
        triggeredOnStart: true
        running: root.panelOpen && root.isSpotifyPlayer
        onTriggered: spotifyStateQuery.running = true
    }
    Timer {
        id: stateRefresh
        interval: 500
        onTriggered: spotifyStateQuery.running = true
    }

    // Overlay
    property bool lyricsVisible: false
    property bool editing: false
    property rect overlayGeometry: Qt.rect(80, 120, 520, 160)

    function lineAt(seconds) {
        let low = 0, high = lyrics.length - 1, found = -1;
        while (low <= high) {
            const mid = (low + high) >> 1;
            if (lyrics[mid].time <= seconds) { found = mid; low = mid + 1; } else { high = mid - 1; }
        }
        return found;
    }

    // MPRIS does not push position updates. positionChanged() only re-estimates
    // from the last known position and elapsed time (no D-Bus call), so polling
    // is cheap.
    Timer {
        interval: 200
        repeat: true
        running: !!root.player?.isPlaying && (root.lyricsVisible || root.panelOpen)
        onTriggered: root.player.positionChanged()
    }

    // ---- LRCLIB -------------------------------------------------------------

    readonly property string trackKey: `${artist}\n${title}`
    onTrackKeyChanged: fetchDelay.restart()

    // Players change title and artist one after the other; wait for both
    Timer {
        id: fetchDelay
        interval: 400
        onTriggered: root.fetchLyrics()
    }

    function parseLrc(text) {
        const lines = [];
        // A line may carry several timestamps ("[00:12.00][01:30.50]chorus").
        // Qt's JS engine has no String.matchAll, hence the exec() loop.
        const stamp = /\[(\d+):(\d+(?:\.\d+)?)\]/g;
        for (const raw of (text || "").split("\n")) {
            const words = raw.replace(/\[\d+:\d+(?:\.\d+)?\]/g, "").trim();
            stamp.lastIndex = 0;
            let match;
            while ((match = stamp.exec(raw)) !== null)
                lines.push({ time: Number(match[1]) * 60 + Number(match[2]), text: words });
        }
        return lines.sort((a, b) => a.time - b.time);
    }

    function request(url, onDone) {
        const xhr = new XMLHttpRequest();
        xhr.onreadystatechange = () => {
            if (xhr.readyState !== XMLHttpRequest.DONE) return;
            let body = null;
            try { body = xhr.status === 200 ? JSON.parse(xhr.responseText) : null; } catch (e) {}
            onDone(body);
        };
        xhr.open("GET", url);
        xhr.send();
    }

    function fetchLyrics() {
        lyrics = [];
        if (title === "") { lyricsStatus = "idle"; return; }
        lyricsStatus = "loading";
        const key = trackKey;
        const query = `track_name=${encodeURIComponent(title)}&artist_name=${encodeURIComponent(artist)}`;
        const length = player?.lengthSupported && player.length > 0 ? player.length : 0;
        const duration = length > 0 ? `&duration=${Math.round(length)}` : "";
        // Lyrics timed for another version of the song (radio edit, remaster...)
        // drift out of sync, so only accept a matching duration
        const sameVersion = item => length === 0 || !item.duration || Math.abs(item.duration - length) <= 3;

        const accept = body => {
            if (key !== trackKey) return false; // the song changed meanwhile
            if (body?.syncedLyrics) {
                lyrics = parseLrc(body.syncedLyrics);
                lyricsStatus = "ready";
                return true;
            }
            return false;
        };

        // Exact match first, then a search for anything with synced lyrics
        request(`https://lrclib.net/api/get?${query}${duration}`, body => {
            if (accept(body)) return;
            request(`https://lrclib.net/api/search?${query}`, results => {
                const synced = (results || []).find(item => item.syncedLyrics && sameVersion(item));
                if (!accept(synced) && key === trackKey) lyricsStatus = "missing";
            });
        });
    }

    // ---- Overlay settings, kept across restarts -------------------------------

    readonly property string settingsPath: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/quickshell/lyrics.json"

    function saveSettings() {
        const g = overlayGeometry;
        settingsFile.setText(JSON.stringify({ visible: lyricsVisible, x: g.x, y: g.y, width: g.width, height: g.height }));
    }

    FileView {
        id: settingsFile
        path: root.settingsPath
        atomicWrites: true
        onLoaded: {
            try {
                const s = JSON.parse(text());
                root.lyricsVisible = !!s.visible;
                root.overlayGeometry = Qt.rect(s.x, s.y, s.width, s.height);
            } catch (e) {}
        }
    }

    Process {
        running: true
        command: ["mkdir", "-p", root.settingsPath.replace(/\/[^/]+$/, "")]
    }

    // `qs ipc call lyrics toggle | edit` (Cmd+Shift+L / Cmd+Shift+K)
    IpcHandler {
        target: "lyrics"
        function toggle(): void {
            root.lyricsVisible = !root.lyricsVisible;
            if (!root.lyricsVisible) root.editing = false;
            root.saveSettings();
        }
        function edit(): void {
            if (!root.lyricsVisible) root.lyricsVisible = true;
            root.editing = !root.editing;
            if (!root.editing) root.saveSettings();
        }
    }
}
