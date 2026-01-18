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

# In a plugin use `@zplugin_normalize_zero $"{0}"` to get a normalized path.
0="${ZERO:-${${0:#${ZSH_ARGZERO}}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-${PWD}/$0}"

############################################################################
# Track Plugin Functions
# └─ Note: this has to be first so that it can be used by everything below.
############################################################################

@zplugin_remember_fn() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local fn_name="${2}"
    local fn_list

    zstyle -a :zstyle:plugins:${plugin_name} functions plugin_functions
    if [[ ${fn_list[(i)${fn_name}]} -gt ${#fn_list} ]]; then
        fn_list+=( $fn_name )
        zstyle :zstyle:plugins:${plugin_name} functions ${fn_list}
    fi
}
@zplugin_remember_fn zplugins @zplugin_remember_fn

############################################################################
# Plugin Global Variable Helpers
############################################################################

# Normalize the value of the `$0` variable as described in
# [zero-handling](https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling)
@zplugin_normalize_zero() {
    builtin emulate -L zsh

    local zero="${1}"

    zero="${ZERO:-${${zero:#${ZSH_ARGZERO}}:-${(%):-%N}}}"
    printf '%s' "${${(M)zero:#/*}:-${PWD}/${zero}}"
}

@zplugin_declare_global() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local plugin_dir="${2:h}"
    local plugin_file="${2:t}"

    zstyle :zplugins:plugins:${plugin_name} plugin-dir "${plugin_dir}"
    zstyle :zplugins:plugins:${plugin_name} plugin-file "${plugin_file}"

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

    local plugin_name="${1}"
    local env_var="${2}"

    zstyle :zplugins:plugins:${plugin_name} old-${env_var} "${(P)env_var}"
}
@zplugin_remember_fn zplugins @zplugin_save_global

@zplugin_restore_global() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local env_var="${2}"

    zstyle :zplugins:plugins:${plugin_name} old-${env_var} env_value

    : ${(P)env_var::=${env_value}}
}
@zplugin_remember_fn zplugins @zplugin_restore_global

############################################################################
# Plugin State Functions
############################################################################

@zplugin_plugin_dir() {
    builtin emulate -L zsh

    local plugin_name="${1}"

    zstyle :zplugins:plugins:${plugin_name} plugin-dir
}
@zplugin_remember_fn zplugins @zplugin_plugin_dir

@zplugin_plugin_file() {
    builtin emulate -L zsh

    local plugin_name="${1}"

    zstyle :zplugins:plugins:${plugin_name} plugin-file
}
@zplugin_remember_fn zplugins @zplugin_plugin_file

@zplugin_functions_dir() {
    builtin emulate -L zsh

    local plugin_name="${1}"

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
# Track Plugin Functions
############################################################################

@zplugin_unfunction_all() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local fn_list fn_name
    zstyle -a zplugins:plugins:${plugin_name} functions fn_list

    for fn_name in ${fn_list[@]}; do
        whence -w "${fn_name}" &> /dev/null && unfunction ${fn_name}
    done
}
@zplugin_remember_fn zplugins @zplugin_unfunction_all

############################################################################
# Track Plugin Aliases
############################################################################

@zplugin_define_alias() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local alias_name="${2}"
    local alias_value="${3}"
    local alias_list
    zstyle -a :zstyle:plugins:${plugin_name} aliases alias_list

    if [[ ${alias_list[(i)${fn_name}]} -gt ${#alias_list} ]]; then
        alias_list+=( $alias_name )
        zstyle :zstyle:plugins:${plugin_name} aliases ${alias_list}
    fi

    alias ${alias_name}=${alias_value}
}
@zplugin_remember_fn zplugins @zplugin_define_alias

@zplugin_unalias_all() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local alias_list alias_name
    zstyle -a :zstyle:plugins:${plugin_name} aliases alias_list

    for alias_name in ${alias_list[@]}; do
        unalias ${alias_name}
    done
}
@zplugin_remember_fn zplugins @zplugin_unalias_all

############################################################################
# Plugin Custom Paths
############################################################################

@zplugin_add_to_path() {
    local plugin_name="${1}"
    local dir="${2}"

    if [[ -n "${dir}" && ${path[(i)${dir}]} -gt ${#path} ]]; then
        path+=( "${dir}" )
        style :zstyle:plugins:${plugin_name} path ${path}
        export PATH
    fi
}
@zplugin_remember_fn zplugins @zplugin_add_to_path

@zplugin_remove_from_path() {
    local plugin_name="${1}"
    local dir="${2}"

    if [[ ${path[(i)${dir}]} -le ${#path} ]]; then
        path=( "${(@)path:#${dir}}" )
        style :zstyle:plugins:${plugin_name} path ${path}
        export PATH
    fi
}
@zplugin_remember_fn zplugins @zplugin_remove_from_path

@zplugin_add_to_fpath() {
    local plugin_name="${1}"
    local dir="${2}"

    if [[ -n "${dir}" && "${fpath[(i)${dir}]}" > "${#fpath}" ]]; then
        fpath+=( "${dir}" )
        style :zstyle:plugins:${plugin_name} fpath ${fpath}
        export FPATH
    fi
}
@zplugin_remember_fn zplugins @zplugin_add_to_fpath

@zplugin_remove_from_fpath() {
    local plugin_name="${1}"
    local dir="${2}"

    if [[ ${fpath[(i)${dir}]} -le ${#pfath} ]]; then
        fpath=( "${(@)path:#${dir}}" )
        style :zstyle:plugins:${plugin_name} fpath ${fpath}
        export FPATH
    fi
}
@zplugin_remember_fn zplugins @zplugin_remove_from_fpath

############################################################################
# Plugin Registration
############################################################################

# Register the plugin's `bin` sub-directory, if it exists, as described in
# [binaries-directory](https://wiki.zshell.dev/community/zsh_plugin_standard#binaries-directory)
@zplugin_register_bin_dir() {
    local plugin_name="${1}"
    local bin_dir="${${(P)plugin_global}[_PLUGIN_DIR]}/bin"

    if [[ -d "${bin_dir}" && ${path[(i)${bin_dir}]} -gt ${#path} ]]; then
        path+=( "${bin_dir}" )
        export PATH
    fi
}
@zplugin_remember_fn zplugins @zplugin_register_bin_dir

@zplugin_unregister_bin_dir() {
    local plugin_name="${1}"
    local bin_dir="${${(P)plugin_global}[_PLUGIN_DIR]}/bin"

    if [[ -d "${bin_dir}" && ${path[(i)${bin_dir}]} -le ${#path} ]]; then
        path=( "${(@)path:#${bin_dir}}" )
        export PATH
    fi
}
@zplugin_remember_fn zplugins @zplugin_unregister_bin_dir

# Register the plugin's `functions` sub-directory, if it exists, as described in
# [functions-directory](https://wiki.zshell.dev/community/zsh_plugin_standard#functions-directory)
@zplugin_register_function_dir() {
    local plugin_name="${1}"
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
@zplugin_remember_fn zplugins @zplugin_register_function_dir

@zplugin_unregister_function_dir() {
    local plugin_name="${1}"
    local function_dir="${${(P)plugin_global}[_PLUGIN_DIR]}/functions"

    if [[ -d "${function_dir}" && ${fpath[(i)${function_dir}]} -le ${#fpath} ]]; then
        fpath=( "${(@)fpath:#${function_dir}}" )
        export FPATH
    fi
}
@zplugin_remember_fn zplugins @zplugin_unregister_function_dir

@zplugins_all_plugin_names() {
    builtin emulate -L zsh

    printf '%s' "$(zstyle -L ':zplugins:plugins:*' | cut -d ':' -f 4 | cut -d ' ' -f 1 | sort | uniq | tr -s '\012\015' ' ')"
}
@zplugin_remember_fn zplugins @zplugins_all_plugin_names

@zplugins_plugin_styles() {
    builtin emulate -L zsh

    local plugin_name="${1}"

    printf '%s' "$(zstyle -L :zplugins:plugins:${plugin_name})"
}
@zplugin_remember_fn zplugins @zplugins_plugin_styles

@zplugin_register() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local plugin_global="${plugin_name:u}"
    local as_manager plugin_data plugin_list fn_name bin_dir function_dir add_path

    if [[ "${ZPLUGINS_USE_AS_MANAGER}" =~ (([yY][eE][sS])|([tT][rR][uU][eE])|1) ]]; then
        as_manager=0
        zstyle :zplugins as-manager yes
    else
        as_manager=1
        zstyle :zplugins as-manager no
    fi

    plugin_data=$(@zplugins_plugin_styles ${plugin_name})

    if [[ -z ${plugin_data} ]]; then
        # Add bin directory to path if exists.
        @zplugin_register_bin_dir ${plugin_name}

        # Add functions directory to fpath if exists.
        @zplugin_register_function_dir ${plugin_name}

        if [[ ${as_manager} ]]; then
            # If we are the plugin manager then update this.
            plugin_list=$(@zplugins_all_plugin_names)
            zsh_loaded_plugins=${plugin_list/ ${plugin_name}/}
            export zsh_loaded_plugins
        fi
    fi
}
@zplugin_remember_fn zplugins @zplugin_register

@zplugin_unregister() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local as_manager plugin_data plugin_list dir_list dir

    as_manager=$(zstyle -b :zstyle as-manager as_manager_str)
    plugin_data=$(@zplugins_plugin_styles ${plugin_name})

    if [[ ${plugin_name} == zplugins && ${as_manager} ]]; then
        # If we *are* the plugin manager then do not remove the plugin.
        :
    elif [[ -n "${plugin_data}" ]]; then
        if [[ ${as_manager} ]]; then
            # If we are the plugin manager then update this.
            plugin_list=$(@zplugins_all_plugin_names)
            zsh_loaded_plugins=${plugin_list}
            export zsh_loaded_plugins
        fi

        # Remove all remembered functions.
        @zplugin_unfunction_all ${plugin_name}
        
        # Remove all remembered aliases.
        @zplugin_unalias_all ${plugin_name}

        # Remove bin directory from path if it exists.
        @zplugin_unregister_bin_dir

        # Remove custom directories from path.
        zstyle -a :zplugins:plugins:${plugin_name} path dir_list
        for dir in ${dir_list[@]}; do
            @zplugin_remove_from_path "${dir}"
        done

        # Remove functions directory from fpath if it exists.
        @zplugin_unregister_function_dir

        # Remove custom directories from fpath.
        zstyle -a :zplugins:plugins:${plugin_name} fpath dir_list
        for dir in ${dir_list[@]}; do
            @zplugin_remove_from_fpath "${dir}"
        done

        # Remove the plugin's data, do this last.
        zstyle -d :zplugins:plugins:${plugin_name}
    fi
}
@zplugin_remember_fn zplugins @zplugin_unregister

@zplugin_is_registered() {
    builtin emulate -L zsh

    local plugin_name="${1}"

    return [[ " ${zsh_loaded_plugins[*]} " == *" ${plugin_name} "* ]]
}
@zplugin_remember_fn zplugins @zplugin_is_registered

############################################################################
# Plugin Lifecycle Functions
############################################################################

zplugins_plugin_init() {
    builtin emulate -L zsh

    local as_manager plugin_data plugin_list dir_list dir

    as_manager=$(zstyle -b :zstyle as-manager as_manager_str)

    # Initialization code can go here.
    if [[ (! -v zsh_loaded_plugins && ! -v PMSPEC) || ${as_manager} ]]; then
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