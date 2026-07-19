# TopBar

An interactive bar and desktop environment for [Quickshell](https://quickshell.org/).

**Features**:

* responsive widgets
* dashboard
* app launcher
* notifications
* preferences
* logout panel
* lock screen
* wallpapers
* osd
* power modes

## Requirements

1. Wayland compositor (Mango/Hyprland)
2. Quickshell
3. Nerd fonts

## Installation

1. Add a submodule to the configuration repository (that mirrors `$HOME`):

```
git submodule add https://github.com/charlesrocket/topbar .config/quickshell/topbar
```

2. Install the library

```
cd .config/quickshell/topbar
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
doas cmake --install build
rm -rf build
```

## Usage

`quickshell -c topbar`

### IPC

See `quickshell -c topbar ipc call show` for all available commands.

## Contributing

Patches are accepted via [Codeberg](https://codeberg.org/charlesrocket/topbar/) or e-mail.
