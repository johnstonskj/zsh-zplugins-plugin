# Module load

Plugin loading and unloading functions.

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

TBD

_Function has no arguments._

#### See also

* [@zplugins_plugin_load](#zpluginspluginload)

### @zplugins_load_all

Load all plugins in the global array `zplugins`. This allows a similar experience to other
plugin managers such as Oh-my-Zsh that use a global `plugins` array.

_Function has no arguments._

#### See also

* [@zplugins_plugin_load](#zpluginspluginload)

### @zplugins_plugin_load

Load a plugin given a path and name. The path may be the the plugin's root file, or the directory
containing the root file, and the name may be optional. The table below shows the **valid**
combinations.

| arg-1     | arg-2 | path                       | name          |
|-----------|-------|----------------------------|---------------|
| file-path | name  | file-path                  | name          |
| file-path | ''    | file-path                  | {file-path:t} |
| dir-path  | name  | dir-path/{name}.plugin.zsh | name          |

Loading a plugin has a number of automatic registration activities, specifically:

1. Initialize the plugin's context in Zstyle.
2. Parse header fields from the plugin's source file into the context.
3. Check for any dependencies declared previously and determine if they are already loaded.
4. Add the plugin's `bin` directory to `$PATH` if it exists.
5. Add the plugin's `functions` directory to `$FPATH` if it exists.
6. Remember all functions in the `functions` directory, if it exists.
7. Add to the loaded plugin list.

#### Arguments

* **$1** (path): Path to plugin file or directory.
* **$2** (string): The plugin's name (optional).

#### Exit codes

* **0**: Named plugin was loaded successfully.
* **1**: Invalid parameters.
* **2**: Invalid plugin file.

#### See also

* [@zplugins_register_bin_dir](paths.md#zpluginsregisterbindir)
* [@zplugins_register_function_dir](paths.md#zpluginsregisterfunctiondir)
* [@zplugins_remember_fn](functions.md#zpluginsrememberfn)

### @zplugins_plugin_unload

Unload the named plugin. This unwinds all the automatic registration actions.

1. Call the plugin's `_unload` function.
2. Call `unfunction` for all remembered plugin functions.
3. Call `unalias` for all defined plugin aliases.
4. Remove the plugin's `bin` directory from `$PATH`.
5. Remove any plugin custom path entries from `$PATH`.
6. Remove the plugin's `functions` directory from `$FPATH`.
7. Remove any plugin custom function path entries from `$FPATH`.
8. Remove plugin from loaded plugin list.

#### Arguments

* **$1** (string): The name of a loaded plugin to unload.

#### Exit codes

* **0**: Named plugin was unloaded successfully.
* **1**: Cannot unload the plugin `zplugins` _if_ it is acting as plugin manager.
* **2**: Plugin has no context data.

#### See also

* [@zplugins_unfunction_all](functions.md#zpluginsunfunctionall)
* [@zplugins_unalias_all](aliases.md#zpluginsunaliasall)
* [@zplugins_unregister_bin_dir](paths.md#zpluginsunregisterbindir)
* [@zplugins_remove_from_path](paths.md#zpluginsremovefrompath)
* [@zplugins_unregister_function_dir](paths.md#zpluginsunregisterfunctiondir)
* [@zplugins_remove_from_fpath](paths.md#zpluginsremovefrom_path)

### @zplugins_is_loaded

Determine whether a named plugin is loaded.

#### Example

```bash
if @zplugins_is_loaded myplugin; then
    echo "myplugin is loaded"
else
    echo "myplugin is not loaded"
fi
```

#### Arguments

* **$1** (string): The plugin's name.

#### Exit codes

* **0**: Named plugin is registered.
* **1**: Named plugin is **not** registered.

#### See also

* [@zplugins_is_loaded](#zpluginsisloaded)

### @zplugins_loaded_plugin_names

Return an array of plugin names as a string.

#### Example

```bash
typeset -s name_str="$(@zplugins_loaded_plugin_names)"
typeset -a names=( ${(z)name_str} )
echo "Loaded plugins: ${(j:, :)names}."
```

_Function has no arguments._

#### Output on stdout

* Space-separated list of plugin names _directly_ managed by `zplugins`.

#### See also

* [@zplugins_is_loaded](#zpluginsisloaded)

