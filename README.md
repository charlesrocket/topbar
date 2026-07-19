# TopBar
[![CI](https://codeberg.org/charlesrocket/topbar/badges/workflows/ci.yml/badge.svg?branch=trunk)](https://codeberg.org/charlesrocket/topbar/actions)
[![CD](https://codeberg.org/charlesrocket/topbar/badges/workflows/cd.yml/badge.svg?branch=trunk)](https://codeberg.org/charlesrocket/topbar/actions)

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
4. Qt6
5. CMake
6. Ninja

## Installation

```
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
cmake --install build
```

## Usage

`quickshell -c topbar`

### IPC

See `quickshell -c topbar ipc call show` for all available commands.

## Contributing

Patches are accepted via [Codeberg](https://codeberg.org/charlesrocket/topbar/) or e-mail.
