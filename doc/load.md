# load

Plugin loading functions.

## Overview

* From a bare-bones plugin manager.
* From the `zplugins` variable.

## Index

* [@zplugins_load_all_from_sheldon](#zpluginsloadallfromsheldon)
* [@zplugins_load_all](#zpluginsloadall)
* [@zplugins_plugin_load](#zpluginspluginload)
* [@zplugins_plugin_unload](#zpluginspluginunload)
* [@zplugins_is_loaded](#zpluginsisloaded)
* [@zplugins_loaded_plugin_names](#zpluginsloadedpluginnames)

### @zplugins_load_all_from_sheldon

_Function has no arguments._

### @zplugins_load_all

_Function has no arguments._

### @zplugins_plugin_load

#### Arguments

* **$1** (path): Path to plugin file or directory.
* **$2** (string): The plugin's (optional).

### @zplugins_plugin_unload

#### Arguments

* **$1** (string): The name of a loaded plugin.

### @zplugins_is_loaded

#### Arguments

* **$1** (string): The plugin's name.

#### Exit codes

* **0**: Named plugin is registered.
* **1**: Named plugin is **not** registered.

### @zplugins_loaded_plugin_names

_Function has no arguments._

#### Output on stdout

* Space-separated list of plugin names *directly* managed by `zplugins`.

