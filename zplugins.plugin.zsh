# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# Plugin Name: zplugins
# Description: Zsh plugin to provide standard plugin functionality for plugin development.
# Repository: https://github.com/johnstonskj/zsh-zplugins-plugin
# Version: 0.1.0
# License: MIT AND Apache-2.0
#
# Rather than rely on global variables as described in
# https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
# settings for this plugin itself and those it manages are stored in the zstyle
# system.
# 
# | Context                 | Style          | Type    | Default   | Comment                                              |
# | ----------------------- | ------------   | ------- | --------- | ---------------------------------------------------- |
# |`:zplugins`              | `as-manager`   | boolean | 'no'      | determines if the plugin acts as a plugin manager.   |
# |`:zplugins:plugins:NAME` | `plugin-dir`   | string  | `${0:h}`  | the directory the plugin is sourced from.            |
# |`:zplugins:plugins:NAME` | `plugin-file`  | string  | `${0:t}`  | the file the plugin is sourced from.                 |
# |`:zplugins:plugins:NAME` | `functions`    | array   | `()`      | a list of all functions defined by the plugin.       |
# |`:zplugins:plugins:NAME` | `aliases`      | array   | `()`      | a list of all aliases defined by the plugin.         |
# |`:zplugins:plugins:NAME` | `path`         | array   | `()`      | a list of additional directories to add to `PATH`.   |
# |`:zplugins:plugins:NAME` | `fpath`        | array   | `()`      | a list of additional directories to add to `FPATH`.  |
# |`:zplugins:plugins:NAME` | `old-VARNAME`  | string  | `''`      | saved value of environment variable named `VARNAME`. |
#
# Public variables:
#
# * `ZPLUGINS_USE_AS_MANAGER`; if set to `yes`, `true`, or `1` the plugin
#   will act as a limited plugin manager.
#

############################################################################
# Standard Setup Behavior
############################################################################

# In a plugin use `@zplugins_normalize_zero $"{0}"` to get a normalized path.
0="${ZERO:-${${0:#${ZSH_ARGZERO}}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-${PWD}/$0}"

ZPLUGINS_CTX=":zplugins"
ZPLUGINS_PLUGINS_CTX="${ZPLUGINS_CTX}:plugins"

typeset -A PLUGIN
PLUGIN[_PATH]="${0}"
PLUGIN[_NAME]="${${PLUGIN[_PATH]:t}%%.*}"
PLUGIN[_CONTEXT]="${ZPLUGINS_PLUGINS_CTX}:${PLUGIN[_NAME]}"
PLUGIN[_MODULE_PATH]="${PLUGIN[_PATH]:h}"

############################################################################
# Source the log sub-module first
############################################################################

source "${PLUGIN[_MODULE_PATH]}/zplugins/log.zsh"

.zplugins_log_trace '' "plugin globals $(.zplugins_logfmt_assoc_array PLUGIN)"

############################################################################
# Sub-Modules
############################################################################

source "${PLUGIN[_MODULE_PATH]}/zplugins/functions.zsh"

source "${PLUGIN[_MODULE_PATH]}/zplugins/aliases.zsh"

source "${PLUGIN[_MODULE_PATH]}/zplugins/context.zsh"

source "${PLUGIN[_MODULE_PATH]}/zplugins/env.zsh"

source "${PLUGIN[_MODULE_PATH]}/zplugins/fields.zsh"

source "${PLUGIN[_MODULE_PATH]}/zplugins/manager.zsh"

source "${PLUGIN[_MODULE_PATH]}/zplugins/paths.zsh"

source "${PLUGIN[_MODULE_PATH]}/zplugins/registry.zsh"

############################################################################
# Plugin Lifecycle Functions
############################################################################

zplugins_plugin_init() {
    builtin emulate -L zsh

    .zplugins_manager_init

    # Finally, register the plugin.
    @zplugin_register ${PLUGIN[_NAME]} "${PLUGIN[_PATH]}"
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_plugin_init

zplugins_plugin_unload() {
    builtin emulate -L zsh

    .zplugins_log_debug ${PLUGIN[_NAME]} 'remove from registered plugins first'
    @zplugins_unregister ${PLUGIN[_NAME]}

    .zplugins_log_debug ${PLUGIN[_NAME]} 'remove all remembered functions and aliases'
    @zplugins_unfunction_all ${PLUGIN[_NAME]}
    @zplugin_unalias_all ${PLUGIN[_NAME]}

    .zplugins_log_debug ${PLUGIN[_NAME]} 'remove the plugins global state variable'
    unset ZPLUGINS

    unfunction zplugins_plugin_unload
}

############################################################################
# Plugin Initialization
############################################################################

zplugins_plugin_init
.zplugins_log_trace ${PLUGIN[_NAME]} 'initialization complete'

true