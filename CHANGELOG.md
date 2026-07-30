# Changelog

All notable changes to this project will be documented in this file.

## [0.3.1] - 2026-07-30

### Bug Fixes

- Colorize tray icons on hover
- Fix `timeouts` types
- Reset singletons
- Set `distributor`
- Edit `distributor` print

### Build

- Set `PROJECT_PLATFORM`

## [0.3.0] - 2026-07-26

### Bug Fixes

- Move `Version`
- Use local devd module
- Use single `Devd` instance
- Check `mNotifier`
- Connect devd directly
- Improve blur detection
- Reposition toast icon
- Move notifications toast
- Use implicit sizes in toasts
- Improve toast actions
- Change `Weather` border color
- Drop implicit source dimensions
- Fully utilize toast surface
- Set close button background
- Edit toast messages
- Disable bar when hidden
- Disable widgets before lock
- Ensure current date is valid
- Update default wallpaper
- Remove old imports
- Move root file
- Drop `defaultWallpaper`
- Link settings
- Set `NativeTextRendering`
- `topbar` -> `bar`
- Drop qml file
- Update imports
- Remove `qtypes`
- Gate `QWaylandScreen` call
- Import `QT_VERSION_CHECK`
- Drop `default`
- Reimport `qMin`
- Drop `QOverload`
- Gate FreeBSD calls
- Add `qstring`
- Update `version`
- Add `QtGlobal`
- Reimplement images
- Fix `Version` strings
- Improve layout
- Adjust layout

### Documentation

- Add `Contributing`
- Update usage
- Update settings file
- Remove qml settings
- Update installation
- Update requirements
- Add badges

### Features

- Animate calendar
- Add player toasts
- Use `topbar/settings.json`
- Add `configWatch`
- Add `session.timeouts`

### Miscellaneous tasks

- Update default values
- Ignore `.cache`
- Drop `.qmlls.ini`

### Operations

- Bump actions/checkout from 6 to 7
- Move pull request template
- Add release job
- More `release` job
- Downgrade runner
- Update `release` job
- Add `yaml` job
- Add `cxx` job
- Fix format command
- Install qt packages
- Install `wayland-scanner`
- Install qt wayland tools
- Install `parallel`
- Rename cxx job
- Add `test` job
- Update `release`

### Refactor

- Use literal operator
- Improve constants
- Drop const casts
- Fix `oss` lints

### Styling

- Drop newline

### Testing

- Add `instance`

### Build

- Fix fallback version string
- Check dirty state
- Move `devd` module
- Fix devd module description
- Install config in xdg path
- Set module version
- Set xdg directory
- Add modules
- Add `ENABLE_PCH`
- Set distributor
- Edit messages
- Fix `qtwaylandscanner`
- Fix target links
- Enable `SYSTEM` on FreeBSD
- Add FreeBSD gates
- Fix bsd check
- Watch plugin files
- Set qt project
- Update direnv command
- Reorganize modules
- Add `qsocketnotifier` to pch
- Set versions
- Move pch import
- Fix `CMAKE_RUNTIME_OUTPUT_DIRECTORY`
- Add `PCH` option
- Indicate offline configuration
- Make `git` soft dependency

## [0.2.0] - 2026-05-17

### Bug Fixes

- Remove network button cursor shape
- Mute with red level
- Set width
- Adjust action text size
- Do not use `netif-restart`
- Center toast icon
- Improve container tracking
- Drop progress bar
- Adjust title position
- Improve device icon handling
- Drop rectangle border
- Handle rapid calls
- Use vertical tab bar
- Center tab bar buttons
- Improve layout
- Adjust switch placement
- Rewrite window button
- Add dropdown gap
- Adjust separator
- Mipmap icons
- Hide `closeButton`
- Update volume calls
- Connect playback position
- Use floating config window
- Adjust dropdown timing
- Align system properties
- Reorder `States` imports
- Update dpms commands
- Update `logout` command
- Update default workspaces
- Handle window close event
- Adjust dynamic border
- Align workspace icons
- Switch to `activeToplevel.title`
- Reposition icons
- Update `currentTime`
- Add system tray rectangle
- Adjust tray container height
- Switch to `mipmap`
- Disable `smooth`
- Correct `netifRestart` command
- Filter floating windows
- Add `blur` toggle
- Update `session` values
- Adjust desktop blur
- Change `WlrLayer`
- Move notifications into panel
- Change toast height
- Eco mode in fullscreen
- Edit info messages
- Set version
- Set mount point
- Resolve type warnings

### Documentation

- Update feature list
- Update compositors
- Edit submodule command description
- Add library installation

### Features

- Add notifications
- Add icons
- Add timeout bar
- Write to `Settings.qml`
- Add mango support
- Add tag zero
- Add system tray menus
- Add `blurredBackground`
- Add desktop blur
- Add `DWL` module
- Add `OSS` module
- Add `Networking` module
- Add `shadows` option
- Add `shadows` option
- Add `System` module
- Add `jails`
- Add `cpuCores`

### Miscellaneous tasks

- Ignore cmake output
- Add linter settings

### Operations

- Add `wallpaper` label
- Add `preferences` label
- Add `notifications` label
- Set `plugin` label

### Refactor

- Move hyprland widgets
- Comment `DynamicFrame`
- Update connection state

### Styling

- Fix formatting
- Fix version formatting

### Build

- Move cmake functions
- Drop `GuiPrivate`
- Drop `WaylandClientPrivate`
- Add library options

## [0.1.0] - 2026-02-18

### Bug Fixes

- Drop string import
- Drop redundant `visible` setting
- Do not depend on external scripts
- Set separator color
- Set `WindowTitle` duration
- Add `HoverFrame.radius` property
- Set `HyprLang` colors
- Redefine `HyprWorkspaces.names`
- Bind `WindowTitle.fontFamily`
- Set eco mode background
- Drop `Battery` todo
- Update `colPurple` comment
- Update power button property
- Do not watch `randomValue`
- Adjust weather icon size
- Offload system tray in eco mode
- Expand bar surface
- Convert `AudioDevices` into a dropdown
- Adjust `AudioDevices` dropdown
- Convert audio sliders to dropdowns
- Adjust audio widget spacing
- Adjust desktop animation
- Update weather icon
- Set eco mode background
- Rename colors
- Use config properties
- Use native rendering
- Update inactive desktop color
- Update colors
- Use border color
- Move `expandPath()`
- Adjust `passwordBox` shadow
- Automate separator visibility
- Set `CenterSection` width
- Correct `AudioDevices` animation property
- Correct `general`/`bar` properties
- Resolve spilling window title
- Adjust bar width
- Adjust shadows
- Resolve conflicting handlers
- Change font weight
- Improve colors
- `unhide` -> `reveal`
- Adjust `clearButton`
- Move workspaces
- Add config validation
- Set cursor shape
- Reposition widgets
- Drop `widgets` import
- Lock screen disables the bar
- Disable bar sections after screen lock
- Show muted stated
- Improve shadows
- Connect to root
- Fix dropdown background
- Correct path positions
- Improve curves
- Move dropdown shape
- Adjust borders
- Resolve stacking issue
- Improve focus/button handling
- Add placeholder
- Improve temps widget
- Wrap album cover
- Trim mail status
- Adjust temperature threshold
- Adjust calendar spacing
- Adjust container position
- Set active cursor shape
- Add placeholder animation
- Drop cursor shapes
- Fix dropdown timer
- Resolve container pushdown

### Documentation

- Add readme
- Add `Usage`
- Add description
- Comment global shortcut
- Update comments
- Update `Usage`
- Add wallpaper
- Update example
- Update features
- Comment `colBgE`
- Add modes
- Add ipc
- Fix ipc description
- Update top description
- Add requirements
- Add `nerd-fonts`
- Add launcher
- Add Preferences
- Add changelog

### Features

- Add system tray
- Add system stats option
- Add config
- Add `Wallpaper.qml`
- Add `bar.hidden()`
- Add `Logout`
- Add logout background color setting
- Add `Config.emptyWindowTitle`
- Add `LockScreen`
- Add `lockWallpaper`
- Add user icon
- Add `username`/`icon` option
- Add shadows
- Add widget options
- Wrap `Bluetooth`/`Network`
- Wrap `Battery`
- Wrap `Workspaces`
- Add `bar.title`
- Add osd
- Add navigation keys
- Add `audio` target
- Add launcher
- Improve info row
- Add bar visibility calls
- Add config panel
- Add control buttons
- Add clock
- Add battery widget
- Add widget options
- Add battery colors
- Add `general.borderWidth`
- Add dashboard
- Add height animation

### Miscellaneous tasks

- Add license
- Comment `defaultWallpaper`

### Operations

- Add dependabot
- Set templates
- Add labeler
- Add `release` job

### Refactor

- Move widgets
- Move `Dropdown`
- Drop root import
- Use eco mode state directly
- Rearrange widgets
- Group config properties
- Move bar components
- Move helper components
- `extraPadding` -> `padding`
- Define `Bar`
- Use `ColAnim`
- `logout` -> `session`
- Extract `UserImage`
- Move `Audio`

### Styling

- Fix formatting


