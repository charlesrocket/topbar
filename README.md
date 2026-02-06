# TopBar

An interactive bar for [Quickshell](https://quickshell.org/).

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

Use `Settings.qml` in the Quickshell's root to override the TopBar's configuration ([example](https://github.com/charlesrocket/dotfiles/blob/cac89b66e82bc8d9c55359f9024bd5faf80a29dd/.config/quickshell/Settings.qml)).
