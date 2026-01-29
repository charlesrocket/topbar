# TopBar

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
}

```

Use `Settings.qml` in the Quickshell's root to override TopBar settings ([example](https://github.com/charlesrocket/dotfiles/blob/8758ed0c44b8e59ab683001378f6a1a09721afc4/.config/quickshell/Settings.qml)).
