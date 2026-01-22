# custom

Path handing functions.

## Overview

Plugin standard sub-directory paths.

## Index

* [@zplugin_register_bin_dir](#zpluginregisterbindir)
* [@zplugin_unregister_bin_dir](#zpluginunregisterbindir)
* [@zplugin_register_function_dir](#zpluginregisterfunctiondir)
* [@zplugin_unregister_function_dir](#zpluginunregisterfunctiondir)
* [@zplugin_add_to_path](#zpluginaddtopath)
* [@zplugin_remove_from_path](#zpluginremovefrompath)
* [@zplugin_add_to_fpath](#zpluginaddtofpath)
* [@zplugin_remove_from_fpath](#zpluginremovefromfpath)

## standard

Plugin standard sub-directory paths.

### @zplugin_register_bin_dir

Register the plugin's `bin` sub-directory, if it exists, as described in
[binaries-directory](https://wiki.zshell.dev/community/zsh_plugin_standard#binaries-directory)

#### Arguments

* **$1** (string): The plugin's name.

### @zplugin_unregister_bin_dir

#### Arguments

* **$1** (string): The plugin's name.

### @zplugin_register_function_dir

Register the plugin's `function` sub-directory, if it exists, as described in
[binaries-directory](https://wiki.zshell.dev/community/zsh_plugin_standard#functions-directory).

#### Arguments

* **$1** (string): The plugin's name.

### @zplugin_unregister_function_dir

#### Arguments

* **$1** (string): The plugin's name.

### @zplugin_add_to_path

Plugin custom paths.

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (path): Directory path to add to `path`

### @zplugin_remove_from_path

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (path): Directory path to remove from `path`

### @zplugin_add_to_fpath

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (path): Directory path to add to `fpath`

### @zplugin_remove_from_fpath

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (path): Directory path to remove from `fpath`

