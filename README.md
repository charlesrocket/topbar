# TopBar

An interactive bar for [Quickshell](https://quickshell.org/).

## Features

* responsive widgets
* logout panel
* lock screen
* wallpapers

## Installation

Add a submodule to the configuration repository:

```
git submodule add https://github.com/charlesrocket/topbar .config/quickshell/topbar
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

Use `Settings.qml` in the Quickshell's root to override the TopBar's configuration ([example](https://github.com/charlesrocket/dotfiles/blob/7873d1918971c4db578fb655b6a840a80c6a88ec/.config/quickshell/Settings.qml)).
