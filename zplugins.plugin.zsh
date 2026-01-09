# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# Plugin Name: zplugins
# Description: A Zsh plugin to provide standard plugin functionality for plugin development.
# Repository: https://github.com/johnstonskj/zsh-zplugins-plugin
#
# Public variables:
#
# * `ZPLUGINS`; plugin-defined global associative array with the following keys:
#   * `_FUNCTIONS`; a list of all functions defined by the plugin.
#   * `_PLUGIN_DIR`; the directory the plugin is sourced from.
#   * `_PLUGINS`; the list of all registered plugins.
#

############################################################################
# Standard Setup Behavior
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

############################################################################
# Plugin Global Variables
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
declare -gA ZPLUGINS
ZPLUGINS[_PLUGIN_DIR]="${0:h}"
ZPLUGINS[_FUNCTIONS]=""
ZPLUGINS[_PLUGINS]=""

############################################################################
# Track Plugin Functions
# └─ Note: this has to be first so that it can be used by everything below.
############################################################################

@zplugin_remember_fn() {
    builtin emulate -L zsh

    local plugin_global="${1:u}"
    local fn_name="${2}"

    if [[ " ${${(P)plugin_global}[_FUNCTIONS]} " != *" ${fn_name} "* ]]; then
        eval "${plugin_global}[_FUNCTIONS]=\"${${(P)plugin_global}[_FUNCTIONS]} ${fn_name}\""
    fi
}
@zplugin_remember_fn zplugins @zplugin_remember_fn

############################################################################
# Plugin Global Variable Helpers
############################################################################

@zplugin_declare_global() {
    builtin emulate -L zsh

    local plugin_global="${1:u}"
    local plugin_dir="${2:h}"

    # See https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
    declare -gA ${plugin_global}
    eval "${plugin_global}[_PLUGIN_DIR]"="${plugin_dir}"

    shift 2
    while (( $# > 0 )); do
        local item="${1}"
        case "${item}" in
            aliases)
                eval "${plugin_global}[_ALIASES]"=''
                ;;
            functions)
                eval "${plugin_global}[_FUNCTIONS]"=''
                ;;
            bin_dir)
                eval "${plugin_global}[_BIN_DIR]"="${plugin_dir}/bin"
                ;;
            function_dir)
                eval "${plugin_global}[_FN_DIR]"="${plugin_dir}/functions"
                ;;
        esac
        shift
    done
}
@zplugin_remember_fn zplugins @zplugin_declare_global

@zplugin_save_global() {
    builtin emulate -L zsh

    local plugin_global="${1:u}"
    local global_name="${2}"

    eval "${plugin_global}[_OLD_${global_name}]"="${(P)global_name}"
}
@zplugin_remember_fn zplugins @zplugin_save_global

@zplugin_restore_global() {
    builtin emulate -L zsh

    local plugin_global="${1:u}"
    local global_name="${2}"

    eval "${global_name}"="${plugin_global}[_OLD_${global_name}]"
}
@zplugin_remember_fn zplugins @zplugin_restore_global

############################################################################
# Plugin State Functions
############################################################################

@zplugin_install_dir() {
    builtin emulate -L zsh

    local plugin_global="${1:u}"

    printf '%s' "${(P)${plugin_global}[_PLUGIN_DIR]}"
}
@zplugin_remember_fn zplugins @zplugin_install_dir

@zplugin_functions_dir() {
    builtin emulate -L zsh

    local plugin_global="${1:u}"

    printf '%s' "${(P)${plugin_global}[_FN_DIR]}"
}
@zplugin_remember_fn zplugins @zplugin_functions_dir

@zplugin_bin_dir() {
    builtin emulate -L zsh

    local plugin_global="${1:u}"

    printf '%s' "${(P)${plugin_global}[_BIN_DIR]}"
}
@zplugin_remember_fn zplugins @zplugin_bin_dir

############################################################################
# Track Plugin Functions
############################################################################

@zplugin_unfunction_all() {
    builtin emulate -L zsh

    local plugin_global="${1:u}"
    local fn_list="${${(P)plugin_global}[_FUNCTIONS]}"

    local fn_name
    for fn_name in ${(s:,:)fn_list}; do
        whence -w "${fn_name}" &> /dev/null && unfunction ${fn_name}
    done
}
@zplugin_remember_fn zplugins @zplugin_unfunction_all

############################################################################
# Track Plugin Aliases
############################################################################

@zplugin_define_alias() {
    builtin emulate -L zsh

    local plugin_global="${1:u}"
    local alias_name="${2}"
    local alias_value="${3}"

    alias ${alias_name}=${alias_value}

    if [[ " ${${(P)plugin_global}[_ALIASES]} " != *" ${alias_name} "* ]]; then
        eval "${plugin_global}[_ALIASES]"="${${(P)plugin_global}[_ALIASES]} ${alias_name}"
    fi
}
@zplugin_remember_fn zplugins @zplugin_define_alias

@zplugin_unalias_all() {
    builtin emulate -L zsh

    local plugin_global="${1:u}"
    local alias_list="${${(P)plugin_global}[_ALIASES]}"

    local alias_name
    for alias_name in ${(s:,:)alias_list}; do
        unalias ${alias_name}
    done
}
@zplugin_remember_fn zplugins @zplugin_unalias_all

############################################################################
# Plugin Registration
############################################################################

@zplugin_register() {
    builtin emulate -L zsh

    local plugin_name="${1}"

    if [[ " ${ZPLUGINS[_PLUGINS]} " != *" ${plugin_name} "* ]]; then
        ZPLUGINS[_PLUGINS]="${ZPLUGINS[_PLUGINS]} ${plugin_name}"
    fi
}
@zplugin_remember_fn zplugins @zplugin_register

@zplugin_unregister() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    
    ZPLUGINS[_PLUGINS]="${ZPLUGINS[_PLUGINS]/ ${plugin_name}/}"
}
@zplugin_remember_fn zplugins @zplugin_unregister

@zplugin_is_registered() {
    builtin emulate -L zsh

    local plugin_name="${1}"

    [[ " ${ZPLUGINS[_PLUGINS]} " == *" ${plugin_name} "* ]]
}
@zplugin_remember_fn zplugins @zplugin_is_registered

############################################################################
# Plugin Lifecycle Functions
############################################################################

zplugins_plugin_init() {
    builtin emulate -L zsh

    # Initialization code can go here.
}

@zplugin_remember_fn zplugins @zplugins_plugin_init

zplugins_plugin_unload() {
    builtin emulate -L zsh

    @zplugin_unfunction_all foo
    @zplugin_unalias_all foo

    unset ZPLUGINS

    unfunction zplugins_plugin_unload
}

############################################################################
# Plugin Initialization
############################################################################

zplugins_plugin_init

true