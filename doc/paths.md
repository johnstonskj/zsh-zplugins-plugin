# custom

Path handing functions.

## Overview

Plugin standard sub-directory paths.

## Index

* [@zplugins_register_bin_dir](#zpluginregisterbindir)
* [@zplugins_unregister_bin_dir](#zpluginunregisterbindir)
* [@zplugins_register_function_dir](#zpluginregisterfunctiondir)
* [@zplugins_unregister_function_dir](#zpluginunregisterfunctiondir)
* [@zplugins_add_to_path](#zpluginaddtopath)
* [@zplugins_remove_from_path](#zpluginremovefrompath)
* [@zplugins_add_to_fpath](#zpluginaddtofpath)
* [@zplugins_remove_from_fpath](#zpluginremovefromfpath)

## standard

Plugin standard sub-directory paths.

### @zplugins_register_bin_dir

Register the plugin's `bin` sub-directory, if it exists, as described in
[binaries-directory](https://wiki.zshell.dev/community/zsh_plugin_standard#binaries-directory)

#### Arguments

* **$1** (string): The plugin's name.

### @zplugins_unregister_bin_dir

#### Arguments

* **$1** (string): The plugin's name.

### @zplugins_register_function_dir

Register the plugin's `function` sub-directory, if it exists, as described in
[binaries-directory](https://wiki.zshell.dev/community/zsh_plugin_standard#functions-directory).

#### Arguments

* **$1** (string): The plugin's name.

### @zplugins_unregister_function_dir

#### Arguments

* **$1** (string): The plugin's name.

### @zplugins_add_to_path

Plugin custom paths.

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (path): Directory path to add to `path`

### @zplugins_remove_from_path

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (path): Directory path to remove from `path`

### @zplugins_add_to_fpath

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (path): Directory path to add to `fpath`

### @zplugins_remove_from_fpath

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (path): Directory path to remove from `fpath`

