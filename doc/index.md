# zplugins

Zsh plugin to provide standard plugin functionality for plugin development.

## Overview

A very bare-bones Zsh plugin manager which can be used as a set of plugin utilities or as a framework.

### Plugin State Management

Rather than rely on global variables as described in
[standard-plugins-hash](https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash)
settings for this plugin itself and those it manages are stored in the zstyle
system.

| Context                 | Style          | Type    | Default   | Comment                                              |
| ----------------------- | ------------   | ------- | --------- | ---------------------------------------------------- |
|`:zplugins`              | `as-manager`   | boolean | 'no'      | determines if the plugin acts as a plugin manager.   |
|`:zplugins:plugins:NAME` | `plugin-dir`   | string  | `${0:h}`  | the directory the plugin is sourced from.            |
|`:zplugins:plugins:NAME` | `plugin-file`  | string  | `${0:t}`  | the file the plugin is sourced from.                 |
|`:zplugins:plugins:NAME` | `dependencies` | array   | `()`      | a list of plugin names that NAME depends upon.       |
|`:zplugins:plugins:NAME` | `functions`    | array   | `()`      | a list of all functions defined by the plugin.       |
|`:zplugins:plugins:NAME` | `aliases`      | array   | `()`      | a list of all aliases defined by the plugin.         |
|`:zplugins:plugins:NAME` | `path`         | array   | `()`      | a list of additional directories to add to `PATH`.   |
|`:zplugins:plugins:NAME` | `fpath`        | array   | `()`      | a list of additional directories to add to `FPATH`.  |
|`:zplugins:plugins:NAME` | `old-VARNAME`  | string  | `''`      | saved value of environment variable named `VARNAME`. |

### Variables

* **zplugins**: An array of strings of the form `name[=path]|` where plugin names are
required, however the path may be left empty **if** the plugin conforms to naming
conventions and exists in the directory `ZPLUGINS_PLUGIN_HOME`.
* **ZPLUGINS_ONLY_MODULES**: A space-speparated list of module names to be loaded instead
of the default (all). For advanced usage only.
* **ZPLUGINS_PLUGIN_HOME**: A path to a directory to act as the root for plugin sources
without explicit paths.
* **ZPLUGINS_USE_AS_MANAGER**: If set to `yes`, `true`, or `1` the plugin
will act as a limited plugin manager.

### Modules

* [aliases](./modules/aliases.md)
* [context](./modules/context.md)
* [env](./modules/env.md)
* [fields](./modules/fields.md)
* [functions](./modules/functions.md)
* [load](./modules/load.md)
* [log](./modules/log.md)
* [manager](./modules/manager.md)
* [paths](./modules/paths.md)


