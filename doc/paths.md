# Module paths

Path handing functions.

## Overview

Plugin directory and file paths.

## Index

* [@zplugins_plugin_dir](#zpluginsplugindir)
* [@zplugins_plugin_file](#zpluginspluginfile)
* [@zplugins_register_bin_dir](#zpluginsregisterbindir)
* [@zplugins_unregister_bin_dir](#zpluginsunregisterbindir)
* [@zplugins_plugin_bin_dir](#zpluginspluginbindir)
* [@zplugins_register_function_dir](#zpluginsregisterfunctiondir)
* [@zplugins_unregister_function_dir](#zpluginsunregisterfunctiondir)
* [@zplugins_plugin_functions_dir](#zpluginspluginfunctionsdir)
* [@zplugins_add_to_path](#zpluginsaddtopath)
* [@zplugins_add_to_path_if_exists](#zpluginsaddtopathifexists)
* [@zplugins_remove_from_path](#zpluginsremovefrompath)
* [@zplugins_add_to_fpath](#zpluginsaddtofpath)
* [@zplugins_add_to_fpath_if_exists](#zpluginsaddtofpathifexists)
* [@zplugins_remove_from_fpath](#zpluginsremovefromfpath)

## plugin

Plugin directory and file paths.

### @zplugins_plugin_dir

#### Arguments

* **$1** (string): The plugin's directory.

#### Output on stdout

* The plugin's fully qualified directory path.

### @zplugins_plugin_file

#### Arguments

* **$1** (string): The plugin's file name.

#### Output on stdout

* The plugin's main file name.

## bin-dir

Plugin standard `bin` sub-directory path.

### @zplugins_register_bin_dir

Register the plugin's `bin` sub-directory, if it exists, as described in
[binaries-directory](https://wiki.zshell.dev/community/zsh_plugin_standard#binaries-directory)

#### Arguments

* **$1** (string): The plugin's name.

### @zplugins_unregister_bin_dir

#### Arguments

* **$1** (string): The plugin's name.

### @zplugins_plugin_bin_dir

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (boolean): Whether to create the directory if it doesn't exist.

#### Output on stdout

* The plugin's `bin` sub-directory path.

## function-dir

Plugin standard `functions` sub-directory path.

### @zplugins_register_function_dir

Register the plugin's `function` sub-directory, if it exists, as described in
[binaries-directory](https://wiki.zshell.dev/community/zsh_plugin_standard#functions-directory).

#### Arguments

* **$1** (string): The plugin's name.

### @zplugins_unregister_function_dir

#### Arguments

* **$1** (string): The plugin's name.

### @zplugins_plugin_functions_dir

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (boolean): Whether to create the directory if it doesn't exist.

#### Output on stdout

* The plugin's `functions` sub-directory path.

## custom

Plugin custom paths.

### @zplugins_add_to_path

Add a directory to a plugin-managed path variable. This **only** adds the
directory once, any subsequent calls to add the same directory will be no-ops. If the directory
is added, the plugin's context for the path variable will be updated to reflect the change.

If the directory doesn't exist, the third parameter can be used to specify that it should be
created.

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (path): Directory path to add to `path`
* **$3** (boolean): Whether to create the directory if it doesn't exist.

### @zplugins_add_to_path_if_exists

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (path): Directory path to add to `path`
* **$3** (boolean): Whether to create the directory if it doesn't exist.

### @zplugins_remove_from_path

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (path): Directory path to remove from `path`

### @zplugins_add_to_fpath

Add a directory to a plugin-managed function path variable. This **only** adds the
directory once, any subsequent calls to add the same directory will be no-ops. If the directory
is added, the plugin's context for the path variable will be updated to reflect the change.

If the directory doesn't exist, the third parameter can be used to specify that it should be
created.

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (path): Directory path to add to `fpath`
* **$3** (boolean): Whether to create the directory if it doesn't exist.

### @zplugins_add_to_fpath_if_exists

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (path): Directory path to add to `fpath`
* **$3** (boolean): Whether to create the directory if it doesn't exist.

### @zplugins_remove_from_fpath

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (path): Directory path to remove from `fpath`

