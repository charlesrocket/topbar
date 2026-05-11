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

```qml
import Quickshell
import QtQuick

import qs.topbar

ShellRoot {
    TopBar {}
    Wallpaper {}
}
```

Use `Settings.qml` in the Quickshell's root to override the TopBar's configuration ([example](https://github.com/charlesrocket/dotfiles/blob/3392fd9fba04580e1139b0ec84a9c63502659220/.config/quickshell/Settings.qml)).

### IPC

See `quickshell ipc call show` for all available commands.
