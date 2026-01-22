# registry

Plugin registry functions.

## Overview

[Standard Plugins Hash](https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash)

### Optional keyword arguments

* `fpath <PATH>`; add PATH to the fpath; no functions are autoloaded from this path.
* `path <PATH>`; add PATH to the path.
* `save <VARNAME>`; save the content of VARNAME in the `_OLD_VARNAME` variable.

## Index

* [@zplugin_register](#zpluginregister)
* [@zplugin_unregister](#zpluginunregister)
* [@zplugins_all_plugin_names](#zpluginsallpluginnames)
* [@zplugin_is_registered](#zpluginisregistered)

### @zplugin_register

[Standard Plugins Hash](https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash)

### Optional keyword arguments

* `fpath <PATH>`; add PATH to the fpath; no functions are autoloaded from this path.
* `path <PATH>`; add PATH to the path.
* `save <VARNAME>`; save the content of VARNAME in the `_OLD_VARNAME` variable.

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (path): The plugin's main file path.

### @zplugin_unregister

#### Arguments

* **$1** (string): The name of a registered plugin.

### @zplugins_all_plugin_names

_Function has no arguments._

#### Output on stdout

* Space-separated list of plugin names *directly* managed by `zplugins`.

### @zplugin_is_registered

#### Arguments

* **$1** (string): The plugin's name.

#### Exit codes

* **0**: Named plugin is registered.
* **1**: Named plugin is **not** registered.

