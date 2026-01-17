# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# Plugin Name: zplugins
# Description: Zsh plugin to provide standard plugin functionality for plugin development.
# Repository: https://github.com/johnstonskj/zsh-zplugins-plugin
# Version: 0.1.0
# License: MIT AND Apache-2.0
#
# Public variables:
#
# * `ZPLUGINS`; plugin-defined global associative array with the following keys:
#   * `_FUNCTIONS`; a list of all functions defined by the plugin.
#   * `_PLUGIN_DIR`; the directory the plugin is sourced from.
#   * `_PLUGIN_FILE`; the file in _PLUGIN_DIR the plugin is sourced from.
#   * `_PLUGINS`; the list of all registered plugins.
#   * `_AS_MANAGER`; determines if the plugin acts as a plugin manager.
# * `ZPLUGINS_USE_AS_MANAGER`; if set to a non-empty value the plugin will act as
#   a limited plugin manager.
#

############################################################################
# Standard Setup Behavior
############################################################################

# In a plugin use `@zplugin_normalize_zero $"{0}"` to get a normalized path.
0="${ZERO:-${${0:#${ZSH_ARGZERO}}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-${PWD}/$0}"

############################################################################
# Plugin Global Variables
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
declare -gA ZPLUGINS
ZPLUGINS[_PLUGIN_DIR]="${0:h}"
ZPLUGINS[_PLUGIN_FILE]="${0:t}"
ZPLUGINS[_FUNCTIONS]=''
ZPLUGINS[_AS_MANAGER]="${ZPLUGINS_USE_AS_MANAGER}"
ZPLUGINS[_PLUGINS]=''

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

@zplugin_normalize_zero() {
    builtin emulate -L zsh

    local zero="${1}"

    # See https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
    zero="${ZERO:-${${zero:#${ZSH_ARGZERO}}:-${(%):-%N}}}"
    printf '%s' "${${(M)zero:#/*}:-${PWD}/${zero}}"
}

@zplugin_declare_global() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local plugin_global="${plugin_name:u}"
    local plugin_dir="${2:h}"
    local plugin_file="${2:t}"

    # See https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
    declare -gA ${plugin_global}
    
    eval "${plugin_global}[_PLUGIN_DIR]"="${plugin_dir}"
    eval "${plugin_global}[_PLUGIN_FILE]"="${plugin_file}"
    eval "${plugin_global}[_ALIASES]"=''
    eval "${plugin_global}[_FUNCTIONS]"=''

    shift 2
    while (( $# > 0 )); do
        local item="${1}"
        case "${item}" in
            path)
                shift
                @zplugin_add_to_path "${plugin_name}" "${1}"
                ;;
            fpath)
                shift
                @zplugin_add_to_fpath "${plugin_name}" "${1}"
                ;;
            save)
                shift
                @zplugin_save_global "${plugin_name}" "${1}"
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

@zplugin_plugin_dir() {
    builtin emulate -L zsh

    local plugin_global="${1:u}"

    printf '%s' "${(P)${plugin_global}[_PLUGIN_DIR]}"
}
@zplugin_remember_fn zplugins @zplugin_plugin_dir

@zplugin_plugin_file() {
    builtin emulate -L zsh

    local plugin_global="${1:u}"

    printf '%s' "${(P)${plugin_global}[_PLUGIN_FILE]}"
}
@zplugin_remember_fn zplugins @zplugin_plugin_file

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

.zplugin_comment_field() {
    builtin emulate -L zsh

    local plugin_global="${1:u}"
    local plugin_path="${(P)${plugin_global}[_PLUGIN_DIR]}/${(P)${plugin_global}[_PLUGIN_FILE]}"
    local field_name="${2}"

    local field_value=$(grep -m 1 -E "^#[ \\t]+${field_name}:" "${plugin_path}" | cut -d':' -f2-)
    if $?; then
        printf '%s' "${field_value//^[[:space:]]+|[[:space:]]+$//}"
    else
        printf ''
    fi
}
@zplugin_remember_fn zplugins .zplugin_comment_field

@zplugin_short_description() {
    builtin emulate -L zsh

    .zplugin_comment_field zplugins Description
}
@zplugin_remember_fn zplugins @zplugin_short_description

@zplugin_repository() {
    builtin emulate -L zsh

    .zplugin_comment_field zplugins Repository
}
@zplugin_remember_fn zplugins @zplugin_repository

@zplugin_homepage() {
    builtin emulate -L zsh

    .zplugin_comment_field zplugins Homepage
}
@zplugin_remember_fn zplugins @zplugin_homepage

@zplugin_version() {
    builtin emulate -L zsh

    .zplugin_comment_field zplugins Version
}
@zplugin_remember_fn zplugins @zplugin_version

@zplugin_license() {
    builtin emulate -L zsh

    .zplugin_comment_field zplugins License
}
@zplugin_remember_fn zplugins @zplugin_license

############################################################################
# Plugin Path Functions
############################################################################

############################################################################
# Track Plugin Functions
############################################################################

@zplugin_unfunction_all() {
    builtin emulate -L zsh

    local plugin_global="${1:u}"
    local fn_list="${${(P)plugin_global}[_FUNCTIONS]}"

    if [[ -n "${fn_list}" ]]; then
        local fn_name
        for fn_name in ${(s:,:)fn_list}; do
            whence -w "${fn_name}" &> /dev/null && unfunction ${fn_name}
        done
    fi
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

    if [[ -n "${alias_list}" ]]; then
        local alias_name
        for alias_name in ${(s:,:)alias_list}; do
            unalias ${alias_name}
        done
    fi
}
@zplugin_remember_fn zplugins @zplugin_unalias_all

############################################################################
# Plugin Custom Paths
############################################################################

@zplugin_add_to_path() {
    local plugin_name="${1}"
    local plugin_global="${plugin_name:u}"
    local dir="${2}"
    if [[ -n "${dir}" && ${path[(i)${dir}]} -gt ${#path} ]]; then
        eval "${plugin_global}[_PATH]"="${plugin_global}[_PATH]:${dir}"
        path+=( "${dir}" )
        export PATH
    fi
}

@zplugin_remove_from_path() {
    local plugin_name="${1}"
    local plugin_global="${plugin_name:u}"
    local dir="${2}"
    if [[ ${path[(i)${dir}]} -le ${#path} ]]; then
        eval "${plugin_global}[_PATH]"="${plugin_global}[_PATH]:${dir}"
        path=( "${(@)path:#${dir}}" )
        export PATH
    fi
}

@zplugin_add_to_fpath() {
    local plugin_name="${1}"
    local plugin_global="${plugin_name:u}"
    local dir="${2}"
    if [[ -n "${dir}" && "${fpath[(i)${dir}]}" > "${#fpath}" ]]; then
        eval "${plugin_global}[_FPATH]"="${plugin_global}[_FPATH]:${dir}"
        fpath+=( "${dir}" )
        export FPATH
    fi
}

@zplugin_remove_from_fpath() {
    local plugin_name="${1}"
    local plugin_global="${plugin_name:u}"
    local dir="${2}"
    if [[ ${path[(i)${dir}]} -le ${#path} ]]; then
        eval "${plugin_global}[_FPATH]"="${plugin_global}[_FPATH]:${dir}"
        fpath=( "${(@)path:#${dir}}" )
        export FPATH
    fi
}

############################################################################
# Plugin Registration
############################################################################

@zplugin_register_bin_dir() {
    local plugin_name="${1}"
    local plugin_global="${plugin_name:u}"
    local bin_dir="${${(P)plugin_global}[_PLUGIN_DIR]}/bin"
    if [[ -d "${bin_dir}" && ${path[(i)${bin_dir}]} -gt ${#path} ]]; then
        path+=( "${bin_dir}" )
        export PATH
    fi
}

@zplugin_unregister_bin_dir() {
    local plugin_name="${1}"
    local plugin_global="${plugin_name:u}"
    local bin_dir="${${(P)plugin_global}[_PLUGIN_DIR]}/bin"
    if [[ -d "${bin_dir}" && ${path[(i)${bin_dir}]} -le ${#path} ]]; then
        path=( "${(@)path:#${bin_dir}}" )
        export PATH
    fi
}

@zplugin_register_function_dir() {
    local plugin_name="${1}"
    local plugin_global="${plugin_name:u}"
    function_dir="${${(P)plugin_global}[_PLUGIN_DIR]}/functions"
    if [[ -d "${function_dir}" && ${fpath[(i)${function_dir}]} -gt ${#fpath} ]]; then
        fpath+=( "${function_dir}" )
        export FPATH

        # Autoload functions from the functions directory.
        for fn_name in ${function_dir}/*(N.:t); do
            autoload -Uz ${fn_name}
            @zplugin_remember_fn ${plugin_name} ${fn_name}
        done
    fi
}

@zplugin_unregister_function_dir() {
    local plugin_name="${1}"
    local plugin_global="${plugin_name:u}"
    local function_dir="${${(P)plugin_global}[_PLUGIN_DIR]}/functions"
    if [[ -d "${function_dir}" && ${fpath[(i)${function_dir}]} -le ${#fpath} ]]; then
        fpath=( "${(@)fpath:#${function_dir}}" )
        export FPATH
    fi
}

@zplugin_register() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local plugin_global="${plugin_name:u}"
    local fn_name bin_dir function_dir add_path

    if [[ " ${ZPLUGINS[_PLUGINS]} " != *" ${plugin_name} "* ]]; then
        # Add bin directory to path if exists.
        @zplugin_register_bin_dir ${plugin_name}

        # Add functions directory to fpath if exists.
        @zplugin_register_function_dir ${plugin_name}

        # Add to the list of registered plugins, do this last.
        ZPLUGINS[_PLUGINS]="${ZPLUGINS[_PLUGINS]} ${plugin_name}"

        if [[ -n "ZPLUGINS[_AS_MANAGER]" ]]; then
            # If we are the plugin manager then update this.
            zsh_loaded_plugins="${ZPLUGINS[_PLUGINS]}"
        fi
    fi
}
@zplugin_remember_fn zplugins @zplugin_register

@zplugin_unregister() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local plugin_global="${plugin_name:u}"
    local bin_dir function_dir rem_path
    
    if [[ ${plugin_name} == zplugins && -n "${ZPLUGINS[_AS_MANAGER]}" ]]; then
        # If we *are* the plugin manager then do not remove the plugin.
        :
    elif [[ " ${ZPLUGINS[_PLUGINS]} " != *" ${plugin_name} "* ]]; then
        # Remove from the list of registered plugins, do this first.
        ZPLUGINS[_PLUGINS]="${ZPLUGINS[_PLUGINS]/ ${plugin_name}/}"

        if [[ -n "ZPLUGINS[_AS_MANAGER]" ]]; then
            # If we are the plugin manager then update this.
            zsh_loaded_plugins="${ZPLUGINS[_PLUGINS]}"
        fi

        # Remove all remembered functions.
        @zplugin_unfunction_all ${plugin_name}
        
        # Remove all remembered aliases.
        @zplugin_unalias_all ${plugin_name}

        # Remove bin directory from path if it exists.
        @zplugin_unregister_bin_dir

        # Remove custom directories from path.
        for rem_path in ${(ps/:/)${${(P)plugin_global}[_PATH]}}; do
            @zplugin_remove_from_path "${rem_path}"
        done

        # Remove functions directory from fpath if it exists.
        @zplugin_unregister_function_dir

        # Remove custom directories from fpath.
        for rem_path in ${(ps/:/)${${(P)plugin_global}[_FPATH]}}; do
            @zplugin_remove_from_fpath "${rem_path}"
        done

        # Remove the global data variable, do this last.
        unset ${plugin_global}
    fi
}
@zplugin_remember_fn zplugins @zplugin_unregister

@zplugin_is_registered() {
    builtin emulate -L zsh

    local plugin_name="${1}"

    if [[ -n "ZPLUGINS[_AS_MANAGER]" ]]; then
        # If we are the plugin manager then check this.
        return [[ " ${ZPLUGINS[_PLUGINS]} " == *" ${plugin_name} "* ]]
    else
        return [[ " ${zsh_loaded_plugins[*]} " == *" ${plugin_name} "* ]]
    fi
}
@zplugin_remember_fn zplugins @zplugin_is_registered

############################################################################
# Plugin Lifecycle Functions
############################################################################

zplugins_plugin_init() {
    builtin emulate -L zsh

    # Initialization code can go here.
    if [[ (! -v zsh_loaded_plugins && ! -v PMSPEC) || -n "${ZPLUGINS[_AS_MANAGER]}" ]]; then
        ZPLUGINS[_AS_MANAGER]="Yes"
        typeset -ga zsh_loaded_plugins
        typeset -g PMSPEC="fbis"
    fi

    # Finally, register the plugin.
    @zplugin_register zplugins
}
@zplugin_remember_fn zplugins @zplugins_plugin_init

zplugins_plugin_unload() {
    builtin emulate -L zsh

    # Remove from registered plugins first.
    @zplugins_unregister zplugins

    # Remove all remembered functions and aliases.
    @zplugin_unfunction_all zplugins
    @zplugin_unalias_all zplugins

    # Remove the plugins global state variable.
    unset ZPLUGINS

    unfunction zplugins_plugin_unload
}

############################################################################
# Plugin Initialization
############################################################################

zplugins_plugin_init

true