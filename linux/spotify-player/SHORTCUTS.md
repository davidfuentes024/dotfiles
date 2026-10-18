# spotify_player shortcuts

Open or hide the player with **Cmd+Shift+M** (Hyprland scratchpad, music keeps
playing while hidden). Inside, **Cmd+<key>** arrives as **Ctrl+<key>** (keyd).

Defaults come from spotify_player; the ones marked *custom* are set in
`keymap.toml`. Press `?` inside the app for the full, searchable list.

The mouse only works on the progress bar (click to seek) and the volume
(scroll) inside the app; for everything else with the mouse, use the bar's
music panel (see the last section).

## Not available

Spotify no longer lets third-party apps open its own generated playlists
(DJ, Daily Mixes, Discover Weekly, "Your Top Songs" Wrapped lists) or song
radio / recommendations. Your most played tracks (Cmd+T) still work. To play
the DJ, start it in the phone app and pick the `spotify-player` device.

## Pages

| Key | Action |
| --- | --- |
| **Cmd+F** | Search all of Spotify (*custom*). Type, Enter, then `Tab` to move between tracks / albums / artists / playlists |
| **Cmd+L** | Library: playlists, albums, artists (*custom*) |
| **Cmd+U** | Queue, "up next" (*custom*) |
| **Cmd+T** | Your most played tracks (*custom*; also `g t`) |
| **Cmd+Y** | Liked songs (*custom*; also `g y`) |
| `g r` | Recently played |
| `g b` | Browse (categories) |
| `l` | Lyrics of the current song |
| `g space` | The playlist or album that is playing |
| `Backspace` | Back to the previous page |
| `?` | Help: every command and key |

## Playback

| Key | Action |
| --- | --- |
| `Space` | Play / pause |
| `n` / `p` | Next / previous track |
| **Cmd+S** | Shuffle on / off |
| **Cmd+R** | Repeat: off → track → context |
| `=` or `+` / `-` | Volume up / down 5% (`=` is *custom*; the mouse wheel works too) |
| `m` or `_` | Mute / unmute (`m` is *custom*) |
| `>` / `<` | Seek forward / back |
| `^` | Back to the start of the track |
| `.` | Play a random track from the current list |
| `f` | Like / unlike the playing song (*custom*) |
| `D` | Choose the playback device (this app, phone, speakers...) |

## Lists

| Key | Action |
| --- | --- |
| `j` / `k` or arrows | Move down / up |
| `g g` / `G` | First / last item |
| `Page Down` / `Page Up` | One page down / up |
| `Enter` | Play the selected item |
| `Tab` / `Shift+Tab` | Next / previous panel |
| `/` | Filter the current list (does not search Spotify; use Cmd+F) |
| `Z` | Add the selected item to the queue |
| `P` | Add the selected item to a playlist (*custom*) |
| `L` | Like / unlike the selected item (*custom*) |
| `N` | Create a new playlist |
| `g A` / `g B` | Go to the selected item's artist / album (*custom*) |
| `g a` | All actions for the selected item (follow, copy link, delete from playlist...) |
| `a` | Actions for the playing track |
| `s t` / `s a` / `s d` | Sort tracks by title / artist / duration (`s r` reverses) |

## Elsewhere in the desktop

| Key | Action |
| --- | --- |
| Media keys | Play / pause, next, previous (any player) |
| Bar music icon | Song panel, mouse friendly: progress (click to seek), previous / play / next, shuffle, repeat, like (right click: unlike) and a volume bar (click, drag or scroll) |
| **Cmd+Shift+L** | Show / hide floating synced lyrics |
| **Cmd+Shift+K** | Move / resize the lyrics box |
| `q` | Quit spotify_player (stops the music) |
