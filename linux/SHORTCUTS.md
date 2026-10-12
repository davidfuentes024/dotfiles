# Desktop shortcuts (Linux)

The keyboard is macOS-style through keyd (`linux/etc/keyd/default.conf`):

| Physical key | Acts as |
| --- | --- |
| Alt | **Cmd**: Cmd+letter is Ctrl+letter for apps (copy, paste, tabs...) |
| Win | **Option**: Option+arrows / Backspace move and delete by word |
| Caps Lock | Esc (and Esc is Caps Lock) |

Inside games (Steam/Proton, CS2, gamescope) Ctrl and Alt are plain Ctrl and
Alt, so none of the shortcuts below fire there, except Ctrl+arrows and Alt+Tab.

## Apps and system

| Key | Action |
| --- | --- |
| Cmd+Space | Launcher: apps (e.g. "Notes"); `=` calculator, `/` files, `:` theme, font and black, `>` power, `;` clipboard |
| Cmd+Shift+V | Clipboard history |
| Cmd+Enter | Terminal (WezTerm) |
| Cmd+E | File manager (yazi) |
| Cmd+Q | Quit the app (only closes the window for WezTerm and shell windows such as Notes) |
| Cmd+Option+Esc | Force quit |
| Cmd+Ctrl+Q | Lock the screen |
| Cmd+Shift+Q | Log out |
| Cmd+. | Show / hide the bar |
| Print / Shift+Print / Cmd+Print | Screenshot of an area / the screen / the window (saved and copied) |

## Desktops

| Key | Action |
| --- | --- |
| Ctrl+Up or 3-finger swipe up | Overview of every desktop with live window previews: click a window or desktop to go there, `+` for a new one, 1-9 to jump |
| Ctrl+Down, 3-finger swipe down or Esc | Close the overview |
| Ctrl+1..9 | Go to desktop N (created if it does not exist) |
| Ctrl+Shift+1..9 | Move the window to desktop N |
| Ctrl+Left / Right | Previous / next desktop (also a 3-finger swipe sideways) |
| Ctrl+Option+N | New desktop at the end |
| Ctrl+Q or Ctrl+Option+W | Delete the current desktop (its windows go to the previous one) |
| Cmd+F3 | Show the desktop (hide its windows; again to bring them back) |

In the bar: click a desktop to go there, right click to delete it, `+` to add one.

## Windows

| Key | Action |
| --- | --- |
| Option+h/j/k/l | Focus the window left / down / up / right |
| Option+Shift+h/j/k/l | Move the window left / down / up / right |
| Cmd+Option+Left / Right / Up / Down | Half of the screen |
| Cmd+Option+Enter | Maximize, keeping the bar / restore |
| Cmd+Option+C | Center |
| Cmd+Option+= / - | Bigger / smaller around the center (hold to repeat) |
| Cmd+M | Minimize; restore from the bar's minimized count |
| Cmd+Ctrl+F | Fullscreen |
| Cmd+G | Floating on / off (puts a snapped window back in the tiling) |
| Cmd+J | Side by side / stacked split |
| Cmd+Tab, Alt+Tab | Next window |
| Cmd+drag, Cmd+right drag | Move, resize with the mouse |

The Cmd+Option shortcuts work on any window: a maximized one is restored
first and a tiled one becomes floating.

## Bar

| Item | Click | Right click |
| --- | --- | --- |
| Usage (CPU, RAM, temperature, GPU) | btop | |
| Local IP | Copy it | |
| Wi-Fi | Networks, connect, password | |
| Bluetooth | Devices, scan and pair | On / off |
| Volume | Output, input, volume, mic mute (scroll: volume) | Mute |
| Bell | Do Not Disturb | |
| Music note | Song panel: progress, controls, shuffle, repeat, like, volume | |
| Minimized count | List; click one to restore it | |

## Music

| Key | Action |
| --- | --- |
| Cmd+Shift+M | spotify_player (scratchpad; music keeps playing when hidden) |
| Cmd+Shift+L | Show / hide floating synced lyrics |
| Cmd+Shift+K | Move / resize the lyrics box |
| Media keys | Play / pause, next, previous |

Inside spotify_player: see `shared/spotify-player/SHORTCUTS.md`.

## Terminal (WezTerm)

| Key | Action |
| --- | --- |
| Cmd+T / Cmd+W | New tab / close pane or tab |
| Cmd+1..9 | Go to tab N |
| Cmd+Shift+[ / ] | Previous / next tab |
| Cmd+D / Cmd+Shift+D | Split side by side / stacked |
| Cmd+[ / ] | Previous / next pane |
| Cmd+C / Cmd+V | Copy / paste (system clipboard; in nvim, Cmd+C copies the visual selection) |
| Cmd+K / Cmd+F | Clear / search |
| Cmd+= / - / 0 | Font size |

## Notes

Open "Notes" from the launcher (each launch opens another window).
Cmd+N new note, Cmd+F search, Esc close. Notes save while typing.
