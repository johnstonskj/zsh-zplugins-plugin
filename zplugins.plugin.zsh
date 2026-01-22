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
# * **ZPLUGINS_ONLY_MODULES**: A space-speparated list of module names to be loaded instead
#     of the default (all). For advanced usage only.
# * **ZPLUGINS_USE_AS_MANAGER**: If set to `yes`, `true`, or `1` the plugin
#     will act as a limited plugin manager.
#
# ### Modules
#
# * [aliases](aliases.md)
# * [context](context.md)
# * [env](env.md)
# * [fields](fields.md)
# * [functions](functions.md)
# * [load](load.md)
# * [log](log.md)
# * [manager](manager.md)
# * [paths](paths.md)
# * [registry](registry.md)
#

############################################################################
# @section setup
# @brief Standard path and variable setup.
#

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
# @section logging
# @brief Source the log sub-module first.
#

source "${PLUGIN[_MODULE_PATH]}/zplugins/log.zsh"

.zplugins_log_trace '' "plugin globals $(.zplugins_logfmt_assoc_array PLUGIN)"

############################################################################
# @section modules
# @brief Load the rest of the modules.
#

declare -a zplugins_only=( ${ZPLUGINS_ONLY_MODULES} )

if [[ ${#zplugins_only} -gt 0 ]]; then
    .zplugins_log_trace '' "loading only ( ${zplugins_only[*]} ) modules"
fi

if [[ ${#zplugins_only} -eq 0 || ${zplugin_sonly[(ie)functions]} -le ${#zplugins_only} ]]; then
    source "${PLUGIN[_MODULE_PATH]}/zplugins/functions.zsh"
fi

if [[ ${#zplugins_only} -eq 0 || ${zplugin_sonly[(ie)aliases]} -le ${#zplugins_only} ]]; then
    source "${PLUGIN[_MODULE_PATH]}/zplugins/aliases.zsh"

fi

if [[ ${#zplugins_only} -eq 0 || ${zplugin_sonly[(ie)context]} -le ${#zplugins_only} ]]; then
    source "${PLUGIN[_MODULE_PATH]}/zplugins/context.zsh"

fi

if [[ ${#zplugins_only} -eq 0 || ${zplugin_sonly[(ie)env]} -le ${#zplugins_only} ]]; then
    source "${PLUGIN[_MODULE_PATH]}/zplugins/env.zsh"

fi

if [[ ${#zplugins_only} -eq 0 || ${zplugin_sonly[(ie)fields]} -le ${#zplugins_only} ]]; then
    source "${PLUGIN[_MODULE_PATH]}/zplugins/fields.zsh"

fi

if [[ ${#zplugins_only} -eq 0 || ${zplugin_sonly[(ie)manager]} -le ${#zplugins_only} ]]; then
    source "${PLUGIN[_MODULE_PATH]}/zplugins/manager.zsh"

fi

if [[ ${#zplugins_only} -eq 0 || ${zplugin_sonly[(ie)paths]} -le ${#zplugins_only} ]]; then
    source "${PLUGIN[_MODULE_PATH]}/zplugins/paths.zsh"

fi

if [[ ${#zplugins_only} -eq 0 || ${zplugin_sonly[(ie)registry]} -le ${#zplugins_only} ]]; then
    source "${PLUGIN[_MODULE_PATH]}/zplugins/registry.zsh"
fi

unset zplugins_only

############################################################################
# @section lifecycle
# @brief Plugin lifecycle functions.
#

# @internal
zplugins_plugin_init() {
    builtin emulate -L zsh

    .zplugins_manager_init

    # Finally, register the plugin.
    @zplugin_register ${PLUGIN[_NAME]} "${PLUGIN[_PATH]}"
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_plugin_init

# @internal
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
# @section initialization
# @brief Final plugin initialization.
#

zplugins_plugin_init
.zplugins_log_trace ${PLUGIN[_NAME]} 'initialization complete'

true