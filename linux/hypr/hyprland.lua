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
            -- Never a fixed 0x0: the external monitor is already there, and
            -- two overlapping monitors mix up the cursor, focus and workspaces
            position = "auto",
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
        -- Only windows with the "immediate" rule (games) may tear; see below
        allow_tearing = true,
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

-- 3-finger swipe up / down: open / close the desktop overview (Mission
-- Control style); sideways it switches desktops
hl.gesture({
    fingers   = 3,
    direction = "up",
    action    = function() hl.exec_cmd("qs ipc call overview open") end,
})
hl.gesture({
    fingers   = 3,
    direction = "down",
    action    = function() hl.exec_cmd("qs ipc call overview close") end,
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

-- Apps whose window is not the process that owns the app. Steam's window
-- belongs to steamwebhelper: killing it makes Steam start a new one, so the
-- window "reopens by itself". These get the app's own quit command instead.
local quitCommands = {
    ["steam"] = "steam -shutdown",
}

local function quitActiveApp()
    local w = hl.get_active_window()
    if not w or not w.pid or w.pid <= 1 then return end
    if quitCommands[w.class] then
        hl.exec_cmd(quitCommands[w.class])
        return
    end
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
hl.bind(cmd .. " + CTRL + F",  hl.dsp.window.fullscreen())         -- Cmd+Ctrl+F: fullscreen (macOS)
hl.bind(cmd .. " + period",    hl.dsp.exec_cmd("qs ipc call bar toggle"))
-- Cmd+Ctrl+Q: lock the screen (same shortcut as macOS)
hl.bind(cmd .. " + CTRL + Q",  hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
hl.bind(cmd .. " + SHIFT + Q", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- Window management (macOS / Rectangle style), for any window: a maximized one
-- is restored first and a tiled one becomes floating (Cmd+G puts it back in
-- the tiling). Cmd+Option combos need the [cmd+opt] layer in keyd, since
-- Cmd+arrows and Option+arrows already move the text cursor in apps.
--   Cmd+Option+arrows  half of the screen
--   Cmd+Option+Enter   maximize, keeping the bar / restore
--   Cmd+Option+C       center
--   Cmd+Option+= / -   bigger / smaller, keeping the center
--   Cmd+M              minimize; restore from the bar's minimized list

-- Area of the focused monitor not covered by bars, in layout coordinates
local function usableArea()
    local m = hl.get_active_monitor()
    if not m then return nil end
    local r = m.reserved or {}
    local top, bottom = r.top or 0, r.bottom or 0
    local left, right = r.left or 0, r.right or 0
    return {
        x = m.x + left,
        y = m.y + top,
        w = m.width / m.scale - left - right,
        h = m.height / m.scale - top - bottom,
    }
end

-- Puts the window at an exact position and size; any window can take this
local function placeWindow(w, x, y, width, height)
    local target = "address:" .. w.address
    -- Hyprland ignores moves and resizes while maximized or fullscreen
    if (w.fullscreen or 0) ~= 0 then
        hl.dispatch(hl.dsp.window.fullscreen({ mode = w.fullscreen == 1 and "maximized" or "fullscreen", action = "unset", window = target }))
    end
    if not w.floating then
        hl.dispatch(hl.dsp.window.float({ action = "enable", window = target }))
    end
    hl.dispatch(hl.dsp.window.resize({ x = math.floor(width), y = math.floor(height), window = target }))
    hl.dispatch(hl.dsp.window.move({ x = math.floor(x), y = math.floor(y), window = target }))
end

local function snapWindow(side)
    local w, a = hl.get_active_window(), usableArea()
    if not w or not a then return end
    local rect = ({
        left  = { a.x,           a.y,           a.w / 2, a.h },
        right = { a.x + a.w / 2, a.y,           a.w / 2, a.h },
        up    = { a.x,           a.y,           a.w,     a.h / 2 },
        down  = { a.x,           a.y + a.h / 2, a.w,     a.h / 2 },
    })[side]
    placeWindow(w, rect[1], rect[2], rect[3], rect[4])
end

local function centerWindow()
    local w, a = hl.get_active_window(), usableArea()
    if not w or not a then return end
    -- A floating window keeps its size; anything else gets a comfortable one
    local width, height = a.w * 0.7, a.h * 0.75
    if w.floating and (w.fullscreen or 0) == 0 then width, height = w.size.x, w.size.y end
    placeWindow(w, a.x + (a.w - width) / 2, a.y + (a.h - height) / 2, width, height)
end

-- Grows (step > 0) or shrinks the window around its center, within the screen
local function resizeWindow(step)
    local w, a = hl.get_active_window(), usableArea()
    if not w or not a then return end
    local width = math.max(320, math.min(a.w, w.size.x + step * 60))
    local height = math.max(200, math.min(a.h, w.size.y + step * 40))
    local cx, cy = w.at.x + w.size.x / 2, w.at.y + w.size.y / 2
    local x = math.max(a.x, math.min(a.x + a.w - width, cx - width / 2))
    local y = math.max(a.y, math.min(a.y + a.h - height, cy - height / 2))
    placeWindow(w, x, y, width, height)
end

local function minimizeWindow()
    if not hl.get_active_window() then return end
    hl.dispatch(hl.dsp.window.move({ workspace = "special:minimized", follow = false }))
end

-- Brings a minimized window back to the current desktop. Global so the bar's
-- minimized list can call it: hyprctl eval 'Windows.restore("0x...")'
Windows = {
    snap = snapWindow,
    center = centerWindow,
    resize = resizeWindow,
    minimize = minimizeWindow,
    restore = function(address)
        local ws = hl.get_active_workspace()
        local target = "address:" .. address
        hl.dispatch(hl.dsp.window.move({ workspace = ws and ws.id or 1, window = target, follow = false }))
        hl.dispatch(hl.dsp.focus({ window = target }))
    end,
}

for side, key in pairs({ left = "left", right = "right", up = "up", down = "down" }) do
    hl.bind(cmd .. " + ALT + " .. key, function() snapWindow(side) end)
end
hl.bind(cmd .. " + ALT + RETURN", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(cmd .. " + ALT + C",      centerWindow)
hl.bind(cmd .. " + ALT + equal",  function() resizeWindow(1) end,  { repeating = true })
hl.bind(cmd .. " + ALT + minus",  function() resizeWindow(-1) end, { repeating = true })
hl.bind(cmd .. " + M",            minimizeWindow)

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

-- A workspace that appears beyond the last desktop WITH WINDOWS (e.g. an app
-- opening on workspace 8) is renumbered to the next desktop instead of leaving
-- a gap. Empty ones are left alone: Hyprland creates one for every monitor
-- that turns on (opening the lid), and adopting it made Hyprland create
-- another, in a loop (it reached 145 and later 101 desktops). The cooldown
-- also ignores the events caused by our own renumbering.
local adoptCooldownUntil = 0

hl.on("workspace.created", function()
    hl.timer(function()
        if os.time() < adoptCooldownUntil then return end
        for _, ws in ipairs(normalWorkspaces()) do
            if ws.id > desktopCount and ws.windows > 0 then
                adoptCooldownUntil = os.time() + 2
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
-- Ctrl+Up / Ctrl+Down: open / close the desktop overview (macOS Mission
-- Control); keyd sends them as Super+Ctrl+Up / Down
hl.bind("SUPER + CTRL + up",   hl.dsp.exec_cmd("qs ipc call overview open"))
hl.bind("SUPER + CTRL + down", hl.dsp.exec_cmd("qs ipc call overview close"))
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

-- Blur behind the desktop overview
hl.layer_rule({
    name  = "blur-overview",
    match = { namespace = "^overview$" },
    blur  = true,
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

-- Counter-Strike 2 always opens fullscreen. Cmd+Ctrl+F can't do it in-game:
-- keyd leaves Alt as plain Alt inside games (linux/keyd/app.conf)
hl.window_rule({
    name       = "fullscreen-cs2",
    match      = { class = "^cs2$" },
    fullscreen = true,
})

-- Games present frames immediately (tearing) instead of waiting for vsync.
-- The monitor is 60 Hz, so otherwise every game is stuck at 60 FPS no matter
-- what its own FPS limit says.
hl.window_rule({
    name      = "tearing-games",
    match     = { class = "^(cs2|steam_app_[0-9]+)$" },
    immediate = true,
})

-- Games are played at 1080p. While one is open, the monitor it is on drops to
-- 1920x1080 at scale 1, so the game's fullscreen is the real screen mode
-- instead of a 1080p image scaled by XWayland onto 4K, and the 4 GB GPU does
-- not also hold 4K desktop buffers (running out of VRAM crashed CS2). Closing
-- the last game reloads the config, which restores the normal monitor rules.
local GAME_MODE = "1920x1080@60"
local gameClasses = { "^cs2$", "^steam_app_%d+$" }
local gameMonitor = nil  -- monitor switched to GAME_MODE, while a game runs

local function isGame(w)
    if not w or not w.class then return false end
    for _, pattern in ipairs(gameClasses) do
        if w.class:match(pattern) then return true end
    end
    return false
end

local function updateGameDisplay()
    local game
    for _, w in ipairs(hl.get_windows()) do
        if isGame(w) then game = w break end
    end
    if game and not gameMonitor then
        local m = game.monitor or hl.get_active_monitor()
        -- A 1080p screen (the laptop's) already fits the game
        if not m or m.width <= 1920 then return end
        gameMonitor = m.description ~= "" and ("desc:" .. m.description) or m.name
        hl.monitor({ output = gameMonitor, mode = GAME_MODE, position = "auto", scale = 1 })
    elseif not game and gameMonitor then
        gameMonitor = nil
        hl.exec_cmd("hyprctl reload")
    end
end

-- Delayed so a closing window is already gone from the window list
local function scheduleGameDisplayUpdate()
    hl.timer(updateGameDisplay, { timeout = 200, type = "oneshot" })
end

hl.on("window.open",    scheduleGameDisplayUpdate)
hl.on("window.class",   scheduleGameDisplayUpdate)  -- some games set it late
hl.on("window.destroy", scheduleGameDisplayUpdate)
-- A config reload (theme switch, deleted desktop) re-applies the normal
-- rules; switch back if a game is still running (once they are applied)
scheduleGameDisplayUpdate()
