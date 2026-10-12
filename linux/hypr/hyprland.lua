-- Minimal Hyprland config. Wiki: https://wiki.hypr.land/Configuring/Start/

------------------
---- MONITORS ----
------------------

-- Any other monitor: preferred mode, placed automatically, scale 1
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- LG 4K monitor: scale 2 (1920x1080 logical, but sharp)
hl.monitor({
    output   = "desc:LG Electronics LG ULTRAFINE 602RMHRA6665",
    mode     = "3840x2160@60",
    position = "auto",
    scale    = 2,
})

-- Built-in screen: 1080p @120Hz, scale 1.25 (~1536x864 logical).
-- Turns off when the lid closes with an external monitor connected, moving
-- every workspace to the external one. Without one, logind suspends.
local LAPTOP = "eDP-1"

local function readLidClosed()
    local f = io.open("/proc/acpi/button/lid/LID0/state")
    if not f then return false end
    local state = f:read("*a")
    f:close()
    return state:find("closed") ~= nil
end

local lidClosed = readLidClosed()

local function hasExternalMonitor()
    for _, m in ipairs(hl.get_monitors()) do
        if m.name ~= LAPTOP then return true end
    end
    return false
end

local function applyLaptopMonitor()
    if lidClosed and hasExternalMonitor() then
        hl.monitor({ output = LAPTOP, disabled = true })
    else
        hl.monitor({
            output   = LAPTOP,
            disabled = false, -- needed to re-enable it while running
            mode     = "1920x1080@120",
            position = "0x0",
            scale    = 1.25,
        })
    end
end

applyLaptopMonitor()

hl.bind("switch:on:Lid Switch",  function() lidClosed = true;  applyLaptopMonitor() end, { locked = true })
hl.bind("switch:off:Lid Switch", function() lidClosed = false; applyLaptopMonitor() end, { locked = true })
-- Re-evaluate on monitor hotplug (e.g. unplugging the external monitor
-- with the lid closed turns the built-in screen back on)
hl.on("monitor.added",   applyLaptopMonitor)
hl.on("monitor.removed", applyLaptopMonitor)


------------------
---- PROGRAMS ----
------------------

local terminal    = "wezterm"
local fileManager = "wezterm start -- yazi"
local menu        = "qs ipc call launcher toggle"  -- Quickshell launcher

hl.on("hyprland.start", function ()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
    hl.exec_cmd("qs")  -- Quickshell: bar and the rest of the desktop shell
    -- Per-app keyd overrides (linux/keyd/app.conf); needs the user in the keyd
    -- group. A systemd user service, so it comes back if it ever dies.
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY && systemctl --user restart keyd-application-mapper")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Theme colors from the shared theme files (switched with the `theme` command,
-- which reloads this config)
local function readThemeFile(path)
    local colors = {}
    local f = io.open(path)
    if not f then return colors end
    for line in f:lines() do
        local key, value = line:match('^(%w[%w_]*)%s*=%s*"#(%x+)"')
        if key then colors[key] = value end
    end
    f:close()
    return colors
end

local function readLine(path, fallback)
    local f = io.open(path)
    if not f then return fallback end
    local line = f:read("*l")
    f:close()
    return line or fallback
end

local themeState = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")) .. "/theme"
local themesDir  = os.getenv("HOME") .. "/.config/themes"
local theme = readThemeFile(themesDir .. "/palettes/" .. readLine(themeState .. "/name", "neon") .. ".toml")
for key, value in pairs(readThemeFile(themesDir .. "/blacks/" .. readLine(themeState .. "/black", "soft") .. ".toml")) do
    theme[key] = value
end

-- Minimal: no gaps, thin borders, no rounding or shadows; soft blur only
-- for translucent windows (the terminal)
hl.config({
    general = {
        gaps_in     = 0,
        gaps_out    = 0,
        border_size = 1,
        layout      = "dwindle",
        col = {
            -- A palette may set its own border color; otherwise the accent
            active_border   = "rgb(" .. (theme.border or theme.accent or "4aa5f0") .. ")",
            inactive_border = "rgb(" .. (theme.surface or "2c2c2f") .. ")",
        },
    },
    decoration = {
        rounding = 0,
        shadow   = { enabled = false },
        blur     = { enabled = true, size = 5, passes = 2 },
    },
    animations = {
        enabled = true,
    },
    dwindle = {
        preserve_split = true,
    },
    misc = {
        force_default_wallpaper = 0,    -- plain background, no Hyprland wallpapers
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
    },
    -- XWayland: no compositor scaling (avoids blurry apps)
    xwayland = {
        force_zero_scaling = true,
    },
})


-- Animations: everything off except the slide when switching workspaces
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
hl.animation({ leaf = "global",     enabled = false })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "easeOutQuint", style = "slide" })


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.config({
    gestures = {
        workspace_swipe_create_new = false,
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})


---------------------
---- KEYBINDINGS ----
---------------------

-- macOS style: keyd turns physical Alt into Cmd. Cmd keys that keyd does not
-- translate to Ctrl (copy, paste, etc.) arrive here as SUPER.
local cmd = "SUPER"

-- Cmd+Q quits the whole app like macOS. Closing the window is not enough:
-- tray apps (Discord, Steam, Spotify...) just hide and keep running. SIGTERM
-- (not SIGKILL) still lets the app save its state and exit cleanly.
-- Exception: apps whose windows share one process with more than that window.
-- All WezTerm windows are one process, and Quickshell windows (e.g. Notes) are
-- the desktop shell itself (bar, notifications, launcher). Killing them would
-- take everything down, so Cmd+Q only closes the focused window there.
local sharedProcessApps = {
    ["org.wezfurlong.wezterm"] = true,
    ["org.quickshell"] = true,
}

local function quitActiveApp()
    local w = hl.get_active_window()
    if not w or not w.pid or w.pid <= 1 then return end
    if sharedProcessApps[w.class] then
        hl.dispatch(hl.dsp.window.close())
        return
    end
    hl.exec_cmd("kill -TERM " .. w.pid)
end

-- Cmd+Option+Esc: force quit (macOS shortcut) for apps that hang and ignore
-- SIGTERM. Unsaved work is lost.
local function forceQuitActiveApp()
    local w = hl.get_active_window()
    if not w or not w.pid or w.pid <= 1 then return end
    -- Never the shell: that would kill the bar and everything with it
    if w.class == "org.quickshell" then
        hl.dispatch(hl.dsp.window.close())
        return
    end
    hl.exec_cmd("kill -KILL " .. w.pid)
end

hl.bind(cmd .. " + RETURN",    hl.dsp.exec_cmd(terminal))
hl.bind(cmd .. " + SPACE",     hl.dsp.exec_cmd(menu))              -- Cmd+Space: launcher
hl.bind(cmd .. " + Q",         quitActiveApp)                      -- Cmd+Q: quit app
hl.bind(cmd .. " + ALT + Escape", forceQuitActiveApp)              -- Cmd+Option+Esc: force quit
hl.bind(cmd .. " + TAB",       hl.dsp.window.cycle_next())         -- Cmd+Tab: next window
hl.bind("ALT + TAB",           hl.dsp.window.cycle_next())         -- Alt+Tab: way out of games, where Alt is plain Alt
hl.bind(cmd .. " + E",         hl.dsp.exec_cmd(fileManager))
hl.bind(cmd .. " + G",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(cmd .. " + J",         hl.dsp.layout("togglesplit"))
hl.bind(cmd .. " + M",         hl.dsp.window.fullscreen())
hl.bind(cmd .. " + period",    hl.dsp.exec_cmd("qs ipc call bar toggle"))
-- Cmd+Ctrl+Q: lock the screen (same shortcut as macOS)
hl.bind(cmd .. " + CTRL + Q",  hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
hl.bind(cmd .. " + SHIFT + Q", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- Cmd+F3: show desktop (macOS style). Hides the current workspace's windows
-- in a special workspace; pressing it again brings them back to the active
-- workspace (workspace ids may have shifted meanwhile, see compaction below).
local hiddenWindows = {}

local function toggleShowDesktop()
    if #hiddenWindows > 0 then
        local active = hl.get_active_workspace()
        local target = active and active.id or 1
        for _, h in ipairs(hiddenWindows) do
            hl.dispatch(hl.dsp.window.move({ workspace = target, window = "address:" .. h.address, follow = false }))
        end
        hiddenWindows = {}
        return
    end
    local ws = hl.get_active_workspace()
    if not ws then return end
    for _, w in ipairs(hl.get_windows({ workspace = ws.id })) do
        table.insert(hiddenWindows, { address = w.address })
        hl.dispatch(hl.dsp.window.move({ workspace = "special:desktop", window = "address:" .. w.address, follow = false }))
    end
end

hl.bind(cmd .. " + F3", toggleShowDesktop)

-- Cmd+Shift+L: show/hide synced lyrics; Cmd+Shift+K: move/resize them
hl.bind(cmd .. " + SHIFT + L", hl.dsp.exec_cmd("qs ipc call lyrics toggle"))
hl.bind(cmd .. " + SHIFT + K", hl.dsp.exec_cmd("qs ipc call lyrics edit"))

-- Cmd+Shift+M: spotify_player (Spotify in the terminal) as a scratchpad. It lives in the special
-- workspace "music", so hiding it keeps the music playing.
local function toggleMusic()
    local running = false
    for _, w in ipairs(hl.get_windows()) do
        if w.class == "spotify_player" then running = true break end
    end
    if not running then
        hl.exec_cmd("wezterm start --class spotify_player -- spotify_player")
    end
    hl.dispatch(hl.dsp.workspace.toggle_special("music"))
end

-- On the first open the scratchpad is shown before the window exists, so the
-- window gets the keyboard focus as soon as it appears
hl.on("window.open", function(w)
    if w and w.class == "spotify_player" then
        hl.dispatch(hl.dsp.focus({ window = "address:" .. w.address }))
    end
end)
hl.bind(cmd .. " + SHIFT + M", toggleMusic)

-- Cmd+Shift+V: launcher in clipboard history mode
hl.bind(cmd .. " + SHIFT + V", hl.dsp.exec_cmd("qs ipc call launcher open clipboard"))

-- Screenshots: saved to ~/Pictures/Screenshots and copied to the clipboard
--   Print          -> area (select with the mouse; Esc cancels)
--   Shift + Print  -> full screen (current monitor)
--   Cmd + Print    -> active window
local shotDir = os.getenv("HOME") .. "/Pictures/Screenshots"

local function screenshot(mode)
    local file = shotDir .. "/" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".png"
    local grim
    if mode == "area" then
        grim = 'g=$(slurp) || exit 0; grim -g "$g"'
    elseif mode == "window" then
        local w = hl.get_active_window()
        if not w then return end
        grim = string.format('grim -g "%d,%d %dx%d"', w.at.x, w.at.y, w.size.x, w.size.y)
    else
        local m = hl.get_active_monitor()
        grim = m and ("grim -o " .. m.name) or "grim"
    end
    hl.exec_cmd(string.format(
        'mkdir -p "%s" && %s "%s" && wl-copy < "%s" && hyprctl notify 5 2500 0 "Screenshot saved and copied"',
        shotDir, grim, file, file))
end

hl.bind("Print",               function() screenshot("area")   end)
hl.bind("SHIFT + Print",       function() screenshot("screen") end)
hl.bind(cmd .. " + Print",     function() screenshot("window") end)

-- Desktops (macOS-style spaces): desktops 1..N always exist, even when
-- empty, and are only created or deleted explicitly. Ids stay gapless and the
-- numbering is global across monitors.
--   Ctrl+Option+N  new desktop at the end
--   Ctrl+Q or Ctrl+Option+W  delete the current desktop (its windows move to
--                  the previous one). Plain Ctrl+W is left alone: nvim splits
--                  and the shell's delete-word need it. Inside games keyd sends
--                  Ctrl untouched, so none of these fire (linux/keyd/app.conf).
--   Ctrl+[0-9] / Ctrl+Shift+[0-9]  go to / move window to desktop N, creating
--                  desktops up to N when it does not exist yet
--   Ctrl+Left/Right                previous / next desktop
local desktopCount = 0

-- The desktop count lives in a state file so it survives config reloads
-- and restarts (macOS keeps spaces across reboots too)
local stateDir  = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")) .. "/hypr"
local stateFile = stateDir .. "/desktops"

local function readSavedCount()
    local f = io.open(stateFile)
    if not f then return nil end
    local n = tonumber(f:read("*l"))
    f:close()
    return n
end

local function saveCount()
    os.execute('mkdir -p "' .. stateDir .. '"')
    local f = io.open(stateFile, "w")
    if f then
        f:write(tostring(desktopCount), "\n")
        f:close()
    end
end

local function normalWorkspaces()
    local list = {}
    for _, ws in ipairs(hl.get_workspaces()) do
        if not ws.special and ws.id > 0 then table.insert(list, ws) end
    end
    table.sort(list, function(a, b) return a.id < b.id end)
    return list
end

-- Persistent rules are only ever added. Deleting a desktop rewrites the
-- saved count and reloads the config instead of disabling a rule: disabled
-- rules linger and bars keep showing them as ghost desktops.
local function addDesktop()
    desktopCount = desktopCount + 1
    hl.workspace_rule({ workspace = tostring(desktopCount), persistent = true })
    return desktopCount
end

do
    local highest = 1
    for _, ws in ipairs(normalWorkspaces()) do highest = math.max(highest, ws.id) end
    local target = readSavedCount() or highest
    for _ = 1, math.max(target, 1) do addDesktop() end
end

local function currentDesktop()
    local ws = hl.get_active_workspace()
    return ws and ws.id or 1
end

local function goToDesktop(n)
    if n >= 1 and n <= desktopCount then
        hl.dispatch(hl.dsp.focus({ workspace = n }))
    end
end

local function newDesktop()
    goToDesktop(addDesktop())
    saveCount()
end

local function deleteDesktop()
    if desktopCount <= 1 then return end
    local current = currentDesktop()
    if current < 1 or current > desktopCount then return end

    -- Windows of the deleted desktop go to the previous one (or the next one
    -- when deleting the first); everything above shifts down by one
    local destination = current > 1 and current - 1 or 1
    local function moveAll(from, to)
        for _, w in ipairs(hl.get_windows({ workspace = from })) do
            hl.dispatch(hl.dsp.window.move({ workspace = to, window = "address:" .. w.address, follow = false }))
        end
    end
    if current == 1 then
        moveAll(2, 1)
        for id = 3, desktopCount do moveAll(id, id - 1) end
    else
        moveAll(current, destination)
        for id = current + 1, desktopCount do moveAll(id, id - 1) end
    end

    goToDesktop(destination)
    desktopCount = desktopCount - 1
    saveCount()
    hl.exec_cmd("hyprctl reload")
end

-- Makes sure desktops 1..n exist (Ctrl+5 with three desktops adds 4 and 5)
local function ensureDesktop(n)
    if n <= desktopCount then return end
    while desktopCount < n do addDesktop() end
    saveCount()
end

hl.bind("CTRL + ALT + N", newDesktop)
hl.bind("CTRL + ALT + W", deleteDesktop)
-- keyd turns physical Ctrl+Q into Super+F13, which xkb names XF86Tools
hl.bind("SUPER + XF86Tools", deleteDesktop)

-- Global so bars and scripts can drive desktops: hyprctl eval 'Desktops.new()'
Desktops = {
    new    = newDesktop,
    delete = deleteDesktop,
    goTo   = function(n) ensureDesktop(n); goToDesktop(n) end,
    count  = function() return desktopCount end,
}

-- A workspace that appears beyond the last desktop (e.g. an app opening on
-- workspace 8) is renumbered to the next desktop instead of leaving a gap.
-- It is renumbered first and only then made a desktop, one per event: adding
-- the rule first created that workspace, the renumbering then failed, and every
-- new workspace re-triggered this handler (it once grew to 145 desktops).
hl.on("workspace.created", function()
    hl.timer(function()
        for _, ws in ipairs(normalWorkspaces()) do
            if ws.id > desktopCount then
                local target = desktopCount + 1
                if ws.id ~= target then
                    hl.dispatch(hl.dsp.workspace.change_id({ workspace = ws.id, id = target }))
                    hl.dispatch(hl.dsp.workspace.rename({ workspace = target, name = tostring(target) }))
                end
                addDesktop()
                saveCount()
                return
            end
        end
    end, { timeout = 50, type = "oneshot" })
end)

-- keyd turns physical Ctrl+N into Super+Ctrl+N, leaving Cmd+N for app tabs
for i = 1, 10 do
    local key = i % 10
    hl.bind("SUPER + CTRL + " .. key, function()
        ensureDesktop(i)
        goToDesktop(i)
    end)
    hl.bind("SUPER + CTRL + SHIFT + " .. key, function()
        ensureDesktop(i)
        hl.dispatch(hl.dsp.window.move({ workspace = i }))
    end)
end

-- Ctrl+arrows (macOS style): keyd turns physical Ctrl+arrows into
-- Super+Ctrl+arrows so they never collide with Option+arrows (sent as Ctrl+arrows)
hl.bind("SUPER + CTRL + left",  function() goToDesktop(currentDesktop() - 1) end)
hl.bind("SUPER + CTRL + right", function() goToDesktop(currentDesktop() + 1) end)

-- Option+h/j/k/l: move focus between windows; Option+Shift+h/j/k/l: move the
-- window. keyd sends the physical Win key (Option) as Alt.
local directions = { h = "left", j = "down", k = "up", l = "right" }
for key, direction in pairs(directions) do
    hl.bind("ALT + " .. key,         hl.dsp.focus({ direction = direction }))
    hl.bind("ALT + SHIFT + " .. key, hl.dsp.window.move({ direction = direction }))
end

hl.bind(cmd .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(cmd .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(cmd .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(cmd .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- Media keys
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })
-- Brightness has no change event to listen to, so the binds announce it to the OSD
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+ && qs ipc call osd brightness"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%- && qs ipc call osd brightness"), { locked = true, repeating = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


----------------------
---- WINDOW RULES ----
----------------------

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    -- Fixes XWayland drag issues
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Blur behind the translucent lyrics box. The lyrics layer covers the whole
-- screen; ignore_alpha limits the blur to its visible part (the box).
hl.layer_rule({
    name  = "blur-lyrics",
    match = { namespace = "^qs-music-lyrics$" },
    blur  = true,
    ignore_alpha = 0.1,
})

-- spotify_player opens straight into its scratchpad (Cmd+Shift+M)
hl.window_rule({
    name      = "music-scratchpad",
    match     = { class = "^spotify_player$" },
    workspace = "special:music",
    float     = true,
    size      = { 1100, 700 },
    center    = true,
})

-- Notes (opened from the launcher) as a centered floating window
hl.window_rule({
    name   = "float-notes",
    match  = { title = "^Notes$" },
    float  = true,
    size   = { 920, 600 },
    center = true,
})

-- btop (opened from the bar's usage summary) as a centered floating window
hl.window_rule({
    name  = "float-btop",
    match = { class = "^btop$" },
    float  = true,
    size   = { 1200, 750 },
    center = true,
})

-- Bluetooth manager (opened from the bar) as a centered floating window
hl.window_rule({
    name  = "float-bluetui",
    match = { class = "^bluetui$" },
    float  = true,
    size   = { 900, 550 },
    center = true,
})
