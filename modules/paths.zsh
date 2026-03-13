# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name Module paths
# @brief Path handing functions.

###################################################################################################
# @section plugin
# @description Plugin directory and file paths.

#
# @arg $1 string The plugin's directory.
# @stdout The plugin's fully qualified directory path.
#
@zplugins_plugin_dir() {
    builtin emulate -L zsh

    local plugin_name="${1}"

    printf '%s' "$(.zplugins_plugin_ctx_get "${plugin_name}" plugin-dir)"
}
@zplugins_remember_fn zplugins @zplugins_plugin_dir

#
# @arg $1 string The plugin's file name.
# @stdout The plugin's main file name.
#
@zplugins_plugin_file() {
    builtin emulate -L zsh

    local plugin_name="${1}"

    printf '%s' "$(.zplugins_plugin_ctx_get "${plugin_name}" plugin-file)"
}
@zplugins_remember_fn zplugins @zplugins_plugin_file

###################################################################################################
# @section bin-dir
# @description Plugin standard `bin` sub-directory path.

#
# @description
#
# Register the plugin's `bin` sub-directory, if it exists, as described in
# [binaries-directory](https://wiki.zshell.dev/community/zsh_plugin_standard#binaries-directory)
#
# @arg $1 string The plugin's name.
#
@zplugins_register_bin_dir() {
    local plugin_name="${1}"
    local bin_dir=$(@zplugins_plugin_bin_dir ${plugin_name})

    if [[ -d "${bin_dir}" ]]; then
        path+=( "${bin_dir}" )
        export PATH
    fi
}
@zplugins_remember_fn zplugins @zplugins_register_bin_dir

#
# @arg $1 string The plugin's name.
#
@zplugins_unregister_bin_dir() {
    local plugin_name="${1}"
    local bin_dir=$(@zplugins_plugin_bin_dir ${plugin_name})

    if [[ -d "${bin_dir}" && ${path[(i)${bin_dir}]} -le ${#path} ]]; then
        path=( "${(@)path:#${bin_dir}}" )
        export PATH
    fi
}
@zplugins_remember_fn zplugins @zplugins_unregister_bin_dir

#
# @arg $1 string The plugin's name.
# @arg $2 boolean Whether to create the directory if it doesn't exist.
# @stdout The plugin's `bin` sub-directory path.
#
@zplugins_plugin_bin_dir() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local create_if_not_exists="${2:-no}"

    local bin_dir="$(@zplugins_plugin_dir "${plugin_name}")/bin"
    if [[ "${create_if_not_exists:l}" =~ (create|true|yes) && ! -d "${bin_dir}" ]]; then
        if ! mkdir -p "${bin_dir}" >/dev/null 2>&1; then
            log_error 'Failed to create bin directory for plugin "%s".' "${plugin_name}" >&2
        fi
    fi
    printf '%s' "${bin_dir}"
}
@zplugins_remember_fn zplugins @zplugins_plugin_bin_dir

###################################################################################################
# @section function-dir
# @description Plugin standard `functions` sub-directory path.

#
# @description
#
# Register the plugin's `function` sub-directory, if it exists, as described in
# [binaries-directory](https://wiki.zshell.dev/community/zsh_plugin_standard#functions-directory).
#
# @arg $1 string The plugin's name.
#
@zplugins_register_function_dir() {
    local plugin_name="${1}"
    local function_dir="$(@zplugins_plugin_functions_dir "${plugin_name}")"

    if [[ -d "${function_dir}" ]]; then
        if [[ ${fpath[(i)${function_dir}]} -le ${#fpath} ]]; then
            .zplugins_log_warning ${plugin_name} "'functions' sub-directory already added? adding again"
        fi
        fpath+=( "${function_dir}" )
        export FPATH

        # Autoload functions from the functions directory.
        for fn_name in ${function_dir}/*(DN.:t); do
            autoload -Uz ${fn_name}
            @zplugins_remember_fn ${plugin_name} ${fn_name}
        done
    fi
}
@zplugins_remember_fn zplugins @zplugins_register_function_dir

#
# @arg $1 string The plugin's name.
#
@zplugins_unregister_function_dir() {
    local plugin_name="${1}"
    local function_dir=$(@zplugins_plugin_functions_dir ${plugin_name})

    if [[ -d "${function_dir}" ]]; then
        for fn_name in ${function_dir}/*(DN.:t); do
            whence -f "${fn_name}" &> /dev/null && unfunction ${fn_name}
        done
        builtin zstyle -d $(@zplugins_plugin_context ${plugin_name}) functions

        if [[ ${fpath[(i)${function_dir}]} -le ${#fpath} ]]; then
            fpath=( "${(@)fpath:#${function_dir}}" )
            export FPATH
        fi
    fi
}
@zplugins_remember_fn zplugins @zplugins_unregister_function_dir

#
# @arg $1 string The plugin's name.
# @arg $2 boolean Whether to create the directory if it doesn't exist.
# @stdout The plugin's `functions` sub-directory path.
#
@zplugins_plugin_functions_dir() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local create_if_not_exists="${2:-no}"

    local functions_dir="$(@zplugins_plugin_dir "${plugin_name}")/functions"
    if [[ "${create_if_not_exists:l}" =~ (create|true|yes) && ! -d "${functions_dir}" ]]; then
        if ! mkdir -p "${functions_dir}" >/dev/null 2>&1; then
            log_error 'Failed to create functions directory for plugin "%s".' "${plugin_name}" >&2
        fi
    fi
    printf '%s' "${functions_dir}"
}
@zplugins_remember_fn zplugins @zplugins_plugin_functions_dir

###################################################################################################
# @section custom
# @description Plugin custom paths.

#
# @description
#
# Add a directory to a plugin-managed path variable. This **only** adds the
# directory once, any subsequent calls to add the same directory will be no-ops. If the directory
# is added, the plugin's context for the path variable will be updated to reflect the change.
#
# If the directory doesn't exist, the third parameter can be used to specify that it should be
# created.
#
# @arg $1 string The plugin's name.
# @arg $2 path Directory path to add to `path`
# @arg $3 boolean Whether to create the directory if it doesn't exist.
#
@zplugins_add_to_path() {
    local plugin_name="${1}"
    local dir="${2}"
    local create_if_not_exists="${3:-no}"

    if [[ -n "${dir}" && ${path[(i)${dir}]} -gt ${#path} ]]; then
        if [[ ${create_if_not_exists:l} =~ (create|true|yes) && ! -d "${dir}" ]]; then
            if ! mkdir -p "${dir}" ; then
                .zplugins_log_warning ${plugin_name} "could not create directory, error $?"
            fi
        fi
        path+=( "${dir}" )
        .zplugins_plugin_ctx_set ${plugin_name} path ${path}
        export PATH
    fi
}
@zplugins_remember_fn zplugins @zplugins_add_to_path

#
# @arg $1 string The plugin's name.
# @arg $2 path Directory path to add to `path`
# @arg $3 boolean Whether to create the directory if it doesn't exist.
#
@zplugins_add_to_path_if_exists() {
    local plugin_name="${1}"
    local dir="${2}"
    local create_if_not_exists="${3:-no}"

    if [[ -d "${dir}" ]]; then
        @zplugins_add_to_path "${plugin_name}" "${dir}" "${create_if_not_exists}"
    fi
}
@zplugins_remember_fn zplugins @zplugins_add_to_path_if_exists

#
# @arg $1 string The plugin's name.
# @arg $2 path Directory path to remove from `path`
#
@zplugins_remove_from_path() {
    local plugin_name="${1}"
    local dir="${2}"

    if [[ ${path[(i)${dir}]} -le ${#path} ]]; then
        path=( "${(@)path:#${dir}}" )
        .zplugins_plugin_ctx_set ${plugin_name} path ${path}
        export PATH
    fi
}
@zplugins_remember_fn zplugins @zplugins_remove_from_path

#
# @description
#
# Add a directory to a plugin-managed function path variable. This **only** adds the
# directory once, any subsequent calls to add the same directory will be no-ops. If the directory
# is added, the plugin's context for the path variable will be updated to reflect the change.
#
# If the directory doesn't exist, the third parameter can be used to specify that it should be
# created.
#
# @arg $1 string The plugin's name.
# @arg $2 path Directory path to add to `fpath`
# @arg $3 boolean Whether to create the directory if it doesn't exist.
#
@zplugins_add_to_fpath() {
    local plugin_name="${1}"
    local dir="${2}"
    local create_if_not_exists="${3}"

    if [[ -n "${dir}" && "${fpath[(i)${dir}]}" > "${#fpath}" ]]; then
        if [[ ${create_if_not_exists:l} =~ (create|true|yes) && ! -d "${dir}" ]]; then
            if ! mkdir -p "${dir}" ; then
                .zplugins_log_warning ${plugin_name} "could not create directory, error $?"
            fi
        fi
        fpath+=( "${dir}" )
        .zplugins_plugin_ctx_set ${plugin_name} fpath ${fpath}
        export FPATH
    fi
}
@zplugins_remember_fn zplugins @zplugins_add_to_fpath

#
# @arg $1 string The plugin's name.
# @arg $2 path Directory path to add to `fpath`
# @arg $3 boolean Whether to create the directory if it doesn't exist.
#
@zplugins_add_to_fpath_if_exists() {
    local plugin_name="${1}"
    local dir="${2}"
    local create_if_not_exists="${3:-no}"

    if [[ -d "${dir}" ]]; then
        @zplugins_add_to_fpath "${plugin_name}" "${dir}" "${create_if_not_exists}"
    fi
}
@zplugins_remember_fn zplugins @zplugins_add_to_fpath_if_exists

#
# @arg $1 string The plugin's name.
# @arg $2 path Directory path to remove from `fpath`
#
@zplugins_remove_from_fpath() {
    local plugin_name="${1}"
    local dir="${2}"

    if [[ ${fpath[(i)${dir}]} -le ${#pfath} ]]; then
        fpath=( "${(@)path:#${dir}}" )
        .zplugins_plugin_ctx_set ${plugin_name} fpath ${fpath}
        export FPATH
    fi
}
@zplugins_remember_fn zplugins @zplugins_remove_from_fpath
