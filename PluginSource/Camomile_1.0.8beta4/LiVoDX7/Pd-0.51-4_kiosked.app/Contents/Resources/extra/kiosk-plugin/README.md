KIOSK mode for Pure Data
========================


KIOSK mode allows you to enable one or more of the following features

-  hiding the main Pd-window
-  disabling the menu bar in the patch window
-  making a patch window to be shown at fullscreen
-  setting a window name for the patch window (independent of the patch name)
-  prevent closing of patch windows (using Alt-F4, clicking on the "Close Window" icon, et al.)
-  quit Pd when a patch window is closed
-  disable the (right click) context menu
-  disable key-bindings (like Ctrl-N)
-  prevent scroll bars from appearing, even if the patch content does not fit on a single window

You can enable/disable the parts you want to by editing a kiosk.cfg file.
This config file is searched for in the working directory of Pd,
and (if not found) in the plugin directory of the kiosk-plugin
(usually `~/.local/lib/pd/extra/kiosk-plugin/`)


# INSTALLATION
Typically, you can install `kiosk-plugin` via Pd's built-in package manager.
Just navigate to "Help" -> "Find Externals...", enter *kiosk-plugin* (followed by <kbd>⏎ Enter</kbd>),
and click on the latest and greatest sarch result to install it.

To *manually* install the plugin, copy this directory to `~/.local/lib/pd/extra/kiosk-plugin/`
or similar, depending on your OS).
The plugin will be automatically loaded, the next time you start Pd.

# CONFIGURATION
There are many options to fine tune the `kiosk-plugin`, so by default it doesn't do *anything*.
In order to enable one ore more options, edit the `kiosk.cfg` file, that comes with examples of all available settings.
Lines beginning with `#` are ignored.

The configuration file is read once at startup and applies to all windows.
It is first searched for at the start-up path (e.g. if you start Pd by double-clicking on a `.pd` file,
this is typically the path where this patch file resides), and - lacking such a file - besides the `kiosk-plugin.tcl` file
(that is: in the installation path of the plugin).


| setting              | default | description                                                                                      |
|----------------------|---------|--------------------------------------------------------------------------------------------------|
| `HideMain`           | `False` | hide the main window (Pd-console)                                                                |
| `ShowMenuMain`       | `True`  | show the menu of the main window (if visible)                                                    |
| `GeometryMain`       | (unset) | force a size/position on the main window                                                         |
| `WindowTitleMain`    | (unset) | the title of the main window (if visible)                                                        |
| `KioskNewWindow`     | `False` | should new windows by kioskified (by default only windows that are open on startup are effected) |
| `FullScreen`         | `False` | put window(s) in full-screen mode?                                                               |
| `ShowMenu`           | `True`  | show the menu                                                                                    |
| `WindowTitle`        | (unset) | set a fixed window title for patch-windows                                                       |
| `WindowDynamicTitle` | (unset) | set a dynamic window title (see `kiosk.cfg` for an example)                                      |
| `PreventClose`       | `False` | prevent patch windows from being closed via the window-manager                                   |
| `QuitOnClose`        | `False` | quit Pd, if a kioskified window is being closed                                                  |
| `HidePopup`          | `False` | disable the right-click context menu                                                             |
| `QuitBinding`        | `True`  | (Do not) quit Pd with the <kbd>Ctrl</kbd>+<kbd>q</kbd> shortcut                                  |
| `Bindings`           | `True`  | Enable/Disable all shortcuts                                                                     |
| `ScrollBars`         | `True`  | Enable/Disable scrollbars if the patch content exceeds the window size                           |



# PREREQUISITES
gui-plugins only work with Pd>=0.43


# AUTHOR
[IOhannes m zmölnig](https://git.iem.at/zmoelnig/)
(though the fullscreen part was copied from András Murányi's "fullscreen" plugin)
