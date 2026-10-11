-- Config minima de Hyprland. Wiki: https://wiki.hypr.land/Configuring/Start/

------------------
---- MONITORS ----
------------------

-- Cualquier otro monitor: resolucion preferida, a la derecha, escala 1
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- Monitor LG 4K: escala 2 (se ve como 1920x1080 logicos, pero nitido)
hl.monitor({
    output   = "desc:LG Electronics LG ULTRAFINE 602RMHRA6665",
    mode     = "3840x2160@60",
    position = "auto",
    scale    = 2,
})

-- Pantalla interna: 1080p @120Hz, escala 1.25 (~1536x864 logicos)
-- Se apaga al cerrar la tapa si hay un monitor externo conectado;
-- todos los workspaces pasan al externo. Sin externo, logind suspende.
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
            disabled = false, -- necesario para reactivarla en caliente
            mode     = "1920x1080@120",
            position = "0x0",
            scale    = 1.25,
        })
    end
end

applyLaptopMonitor()

hl.bind("switch:on:Lid Switch",  function() lidClosed = true;  applyLaptopMonitor() end, { locked = true })
hl.bind("switch:off:Lid Switch", function() lidClosed = false; applyLaptopMonitor() end, { locked = true })
-- Re-evaluar al conectar/desconectar monitores (p.ej. desconectar el
-- externo con la tapa cerrada vuelve a encender la interna)
hl.on("monitor.added",   applyLaptopMonitor)
hl.on("monitor.removed", applyLaptopMonitor)


------------------
---- PROGRAMS ----
------------------

local terminal    = "wezterm"
local fileManager = "wezterm start -- yazi"
local menu        = "hyprlauncher"

hl.on("hyprland.start", function ()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    -- Per-app keyd overrides (linux/keyd/app.conf); needs the user in the keyd group
    hl.exec_cmd("keyd-application-mapper -d")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Minimo: sin gaps, bordes finos, sin redondeo ni sombras; blur suave solo
-- para ventanas transparentes (la terminal)
hl.config({
    general = {
        gaps_in     = 0,
        gaps_out    = 0,
        border_size = 1,
        layout      = "dwindle",
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
        force_default_wallpaper = 0,    -- fondo liso, sin wallpapers de Hyprland
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
    },
    -- XWayland: sin escalado por compositor (evita apps borrosas)
    xwayland = {
        force_zero_scaling = true,
    },
})


-- Animaciones: todo apagado salvo el deslizamiento al cambiar de escritorio
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

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})


---------------------
---- KEYBINDINGS ----
---------------------

-- Estilo macOS: keyd convierte Alt fisico en Cmd. Las teclas que keyd no
-- traduce a Ctrl (copiar, pegar, etc.) llegan aqui como SUPER.
local cmd = "SUPER"

hl.bind(cmd .. " + RETURN",    hl.dsp.exec_cmd(terminal))
hl.bind(cmd .. " + SPACE",     hl.dsp.exec_cmd(menu))              -- Cmd+Space: lanzador
hl.bind(cmd .. " + Q",         hl.dsp.window.close())              -- Cmd+Q: cerrar ventana
hl.bind(cmd .. " + TAB",       hl.dsp.window.cycle_next())         -- Cmd+Tab: siguiente ventana
hl.bind(cmd .. " + E",         hl.dsp.exec_cmd(fileManager))
hl.bind(cmd .. " + G",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(cmd .. " + J",         hl.dsp.layout("togglesplit"))
hl.bind(cmd .. " + M",         hl.dsp.window.fullscreen())
hl.bind(cmd .. " + period",    hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))
hl.bind(cmd .. " + SHIFT + Q", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- Cmd+F3: mostrar escritorio (estilo macOS). Oculta las ventanas del
-- workspace actual en un workspace especial; repetir las devuelve.
local hiddenWindows = {}

local function toggleShowDesktop()
    if #hiddenWindows > 0 then
        for _, h in ipairs(hiddenWindows) do
            hl.dispatch(hl.dsp.window.move({ workspace = h.workspace, window = "address:" .. h.address, follow = false }))
        end
        hiddenWindows = {}
        return
    end
    local ws = hl.get_active_workspace()
    if not ws then return end
    for _, w in ipairs(hl.get_windows({ workspace = ws.id })) do
        table.insert(hiddenWindows, { address = w.address, workspace = ws.id })
        hl.dispatch(hl.dsp.window.move({ workspace = "special:desktop", window = "address:" .. w.address, follow = false }))
    end
end

hl.bind(cmd .. " + F3", toggleShowDesktop)

-- Cmd+Shift+V: clipboard history picker
hl.bind(cmd .. " + SHIFT + V", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/clipboard-picker.sh"))

-- Capturas: se guardan en ~/Pictures/Screenshots y se copian al portapapeles
--   Impr Pant         -> recorte de area (seleccion con el mouse; Esc cancela)
--   Shift + Impr Pant -> pantalla completa (monitor actual)
--   Cmd + Impr Pant   -> ventana activa
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
        'mkdir -p "%s" && %s "%s" && wl-copy < "%s" && hyprctl notify 5 2500 0 "Captura guardada y copiada"',
        shotDir, grim, file, file))
end

hl.bind("Print",               function() screenshot("area")   end)
hl.bind("SHIFT + Print",       function() screenshot("screen") end)
hl.bind(cmd .. " + Print",     function() screenshot("window") end)

-- Ctrl+[0-9]: go to workspace; Ctrl+Shift+[0-9]: move window (macOS-style).
-- keyd turns physical Ctrl+N into Super+Ctrl+N, leaving Cmd+N for app tabs.
for i = 1, 10 do
    local key = i % 10
    hl.bind("SUPER + CTRL + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + CTRL + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Ctrl+flechas (estilo macOS): keyd convierte el Ctrl fisico + flechas en
-- Super+Ctrl+flechas para no chocar con Option+flechas (que envia Ctrl+flechas)
hl.bind("SUPER + CTRL + left",  hl.dsp.focus({ workspace = "r-1" }))
hl.bind("SUPER + CTRL + right", hl.dsp.focus({ workspace = "r+1" }))

hl.bind(cmd .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(cmd .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(cmd .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(cmd .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- Teclas multimedia
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
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
    -- Arregla problemas de arrastre con XWayland
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

-- Bluetooth manager (opened from Waybar) as a centered floating window
hl.window_rule({
    name  = "float-bluetui",
    match = { class = "^bluetui$" },
    float  = true,
    size   = { 900, 550 },
    center = true,
})
