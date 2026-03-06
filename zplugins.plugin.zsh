# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name zplugins
# @brief Zsh plugin to provide standard plugin functionality for plugin development.
# @repository https://github.com/johnstonskj/zsh-zplugins-plugin
# @version 0.1.0
# @license MIT AND Apache-2.0
#
# @description
#
# A very bare-bones Zsh plugin manager which can be used as a set of plugin utilities or as a framework.
#
# ### Plugin State Management
#
# Rather than rely on global variables as described in
# [standard-plugins-hash](https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash)
# settings for this plugin itself and those it manages are stored in the zstyle
# system.
# 
# | Context                 | Style          | Type    | Default   | Comment                                              |
# | ----------------------- | ------------   | ------- | --------- | ---------------------------------------------------- |
# |`:zplugins`              | `as-manager`   | boolean | 'no'      | determines if the plugin acts as a plugin manager.   |
# |`:zplugins:plugins:NAME` | `plugin-dir`   | string  | `${0:h}`  | the directory the plugin is sourced from.            |
# |`:zplugins:plugins:NAME` | `plugin-file`  | string  | `${0:t}`  | the file the plugin is sourced from.                 |
# |`:zplugins:plugins:NAME` | `dependencies` | array   | `()`      | a list of plugin names that NAME depends upon.       |
# |`:zplugins:plugins:NAME` | `functions`    | array   | `()`      | a list of all functions defined by the plugin.       |
# |`:zplugins:plugins:NAME` | `aliases`      | array   | `()`      | a list of all aliases defined by the plugin.         |
# |`:zplugins:plugins:NAME` | `path`         | array   | `()`      | a list of additional directories to add to `PATH`.   |
# |`:zplugins:plugins:NAME` | `fpath`        | array   | `()`      | a list of additional directories to add to `FPATH`.  |
# |`:zplugins:plugins:NAME` | `old-VARNAME`  | string  | `''`      | saved value of environment variable named `VARNAME`. |
#
# ### Variables
#
# * **zplugins**: An array of strings of the form `name[=path]|` where plugin names are
#     required, however the path may be left empty **if** the plugin conforms to naming
#     conventions and exists in the directory `ZPLUGINS_PLUGIN_HOME`.
# * **ZPLUGINS_ONLY_MODULES**: A space-speparated list of module names to be loaded instead
#     of the default (all). For advanced usage only.
# * **ZPLUGINS_PLUGIN_HOME**: A path to a directory to act as the root for plugin sources
#     without explicit paths.
# * **ZPLUGINS_USE_AS_MANAGER**: If set to `yes`, `true`, or `1` the plugin
#     will act as a limited plugin manager.
#
# ### Modules
#
# * [aliases](./modules/aliases.md)
# * [context](./modules/context.md)
# * [env](./modules/env.md)
# * [fields](./modules/fields.md)
# * [functions](./modules/functions.md)
# * [load](./modules/load.md)
# * [log](./modules/log.md)
# * [manager](./modules/manager.md)
# * [paths](./modules/paths.md)
#

###################################################################################################
# @section setup
# @description Standard path and variable setup.
#

# In a plugin use `@zplugins_normalize_zero $"{0}"` to get a normalized path.
0="${ZERO:-${${0:#${ZSH_ARGZERO}}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-${PWD}/$0}"

typeset -gA ZPLUGINS
ZPLUGINS[_PATH]="${0}"
ZPLUGINS[_MODULE_PATH]="${ZPLUGINS[_PATH]:h}/modules"

typeset -ga zplugins=()
typeset -g ZPLUGINS_ONLY_MODULES=${ZPLUGINS_ONLY_MODULES:-}
typeset -g ZPLUGINS_PLUGIN_HOME=${ZPLUGINS_PLUGIN_HOME:-${XDG_DATA_HOME:-${HOME}/.local/share}/plugins}
typeset -g ZPLUGINS_USE_AS_MANAGER=${ZPLUGINS_USE_AS_MANAGER:-no}

###################################################################################################
# @section logging
# @description Source the log sub-module first.
#

source "${ZPLUGINS[_MODULE_PATH]}/log.zsh"

.zplugins_log_trace zplugins "plugin globals $(.zplugins_logfmt_assoc_array ZPLUGINS)"

###################################################################################################
# @section modules
# @description Load the rest of the modules.
#

declare -a zplugins_only=( ${ZPLUGINS_ONLY_MODULES} )

if [[ ${#zplugins_only} -eq 0 || ${zplugin_sonly[(ie)functions]} -le ${#zplugins_only} ]]; then
    source "${ZPLUGINS[_MODULE_PATH]}/functions.zsh"
fi

if [[ ${#zplugins_only} -eq 0 || ${zplugin_sonly[(ie)aliases]} -le ${#zplugins_only} ]]; then
    source "${ZPLUGINS[_MODULE_PATH]}/aliases.zsh"

fi

if [[ ${#zplugins_only} -eq 0 || ${zplugin_sonly[(ie)context]} -le ${#zplugins_only} ]]; then
    source "${ZPLUGINS[_MODULE_PATH]}/context.zsh"

fi

if [[ ${#zplugins_only} -eq 0 || ${zplugin_sonly[(ie)env]} -le ${#zplugins_only} ]]; then
    source "${ZPLUGINS[_MODULE_PATH]}/env.zsh"

fi

if [[ ${#zplugins_only} -eq 0 || ${zplugin_sonly[(ie)fields]} -le ${#zplugins_only} ]]; then
    source "${ZPLUGINS[_MODULE_PATH]}/fields.zsh"

fi

if [[ ${#zplugins_only} -eq 0 || ${zplugin_sonly[(ie)load]} -le ${#zplugins_only} ]]; then
    source "${ZPLUGINS[_MODULE_PATH]}/load.zsh"
fi

if [[ ${#zplugins_only} -eq 0 || ${zplugin_sonly[(ie)manager]} -le ${#zplugins_only} ]]; then
    source "${ZPLUGINS[_MODULE_PATH]}/manager.zsh"

fi

if [[ ${#zplugins_only} -eq 0 || ${zplugin_sonly[(ie)paths]} -le ${#zplugins_only} ]]; then
    source "${ZPLUGINS[_MODULE_PATH]}/paths.zsh"

fi

unset zplugins_only

###################################################################################################
# @section lifecycle
# @description Plugin lifecycle functions.
#

# @internal
zplugins_plugin_init() {
    builtin emulate -L zsh

    .zplugins_manager_init
}

# @internal
zplugins_plugin_unload() {
    builtin emulate -L zsh

    unset ZPLUGINS
}
