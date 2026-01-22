# env

Restore the state of the variable `VARNAME` from the global state variable `_OLD_VARNAME`.

## Overview

Normalize the value of the `$0` variable as described in
[zero-handling](https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling).

## Index

* [@zplugins_normalize_zero](#zpluginsnormalizezero)
* [@zplugins_envvar_save](#zpluginsenvvarsave)
* [@zplugins_envvar_restore](#zpluginsenvvarrestore)

### @zplugins_normalize_zero

Normalize the value of the `$0` variable as described in
[zero-handling](https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling).

#### Example

```bash
0="$(@zplugin_normalize_zero "${0}")"
```

#### Arguments

* **$1** (string): The plugin's name.

#### Output on stdout

* The normalized path value.

### @zplugins_envvar_save

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (string): Name of the environment variable to save.

### @zplugins_envvar_restore

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (string): Name of the environment variable to restore.

#### Variables set

* NAME

