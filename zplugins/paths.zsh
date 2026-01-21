# -*- mode: sh; eval: (sh-set-shell "zsh") -*-

############################################################################
# Plugin Standard Paths
############################################################################

# Register the plugin's `bin` sub-directory, if it exists, as described in
# [binaries-directory](https://wiki.zshell.dev/community/zsh_plugin_standard#binaries-directory)
@zplugin_register_bin_dir() {
    local plugin_name="${1}"
    local bin_dir=$(@zplugins_plugin_bin_dir ${plugin_name})

    if [[ -d "${bin_dir}" && ${path[(i)${bin_dir}]} -gt ${#path} ]]; then
        .zplugins_log_debug ${plugin_name} "adding standard 'bin' sub-directory to path"
        path+=( "${bin_dir}" )
        export PATH
    fi
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugin_register_bin_dir

@zplugin_unregister_bin_dir() {
    local plugin_name="${1}"
    local bin_dir=$(@zplugins_plugin_bin_dir ${plugin_name})

    if [[ -d "${bin_dir}" && ${path[(i)${bin_dir}]} -le ${#path} ]]; then
        .zplugins_log_debug ${plugin_name} "removing standard 'bin' sub-directory from path"
        path=( "${(@)path:#${bin_dir}}" )
        export PATH
    fi
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugin_unregister_bin_dir

# Register the plugin's `functions` sub-directory, if it exists, as described in
# [functions-directory](https://wiki.zshell.dev/community/zsh_plugin_standard#functions-directory)
@zplugin_register_function_dir() {
    local plugin_name="${1}"
    local function_dir=$(@zplugin_plugin_functions_dir ${plugin_name})

    if [[ -d "${function_dir}" && ${fpath[(i)${function_dir}]} -gt ${#fpath} ]]; then
        .zplugins_log_debug ${plugin_name} "adding standard 'functions' sub-directory to function path"
        fpath+=( "${function_dir}" )
        export FPATH

        # Autoload functions from the functions directory.
        for fn_name in ${function_dir}/*(N.:t); do
            .zplugins_log_debug ${plugin_name} "load function '${fn_name}' from the standard 'functions' sub-directory"
            autoload -Uz ${fn_name}
            @zplugins_remember_fn ${plugin_name} ${fn_name}
        done
    fi
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugin_register_function_dir

@zplugin_unregister_function_dir() {
    local plugin_name="${1}"
    local function_dir=$(@zplugin_plugin_functions_dir ${plugin_name})

    if [[ -d "${function_dir}" && ${fpath[(i)${function_dir}]} -le ${#fpath} ]]; then
        .zplugins_log_debug ${plugin_name} "removing standard 'functions' sub-directory from function path"
        fpath=( "${(@)fpath:#${function_dir}}" )
        export FPATH
    fi
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugin_unregister_function_dir

############################################################################
# Plugin Custom Paths
############################################################################

@zplugin_add_to_path() {
    local plugin_name="${1}"
    local dir="${2}"
    local create_if_not_exists="${2}"

    if [[ -n "${dir}" && ${path[(i)${dir}]} -gt ${#path} ]]; then
        if [[ ${create_if_not_exists} == yes && ! -d "${dir}" ]]; then
            .zplugins_log_debug ${plugin_name} "creating non-existing '${dir}'"
            if ! mkdir -p "${dir}" ; then
                .zplugins_log_warning ${plugin_name} "could not create directory, error $?"
            fi
        fi
        .zplugins_log_debug ${plugin_name} "adding '${dir}' to plugin path ($(@zplugins_plugin_ctx_get ${plugin_name} path))"
        path+=( "${dir}" )
        .zplugins_plugin_ctx_set ${plugin_name} path ${path}
        export PATH
    fi
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugin_add_to_path

@zplugin_remove_from_path() {
    local plugin_name="${1}"
    local dir="${2}"

    if [[ ${path[(i)${dir}]} -le ${#path} ]]; then
        .zplugins_log_debug ${plugin_name} "removing '${dir}' from plugin path ($(@zplugins_plugin_ctx_get ${plugin_name} path))"
        path=( "${(@)path:#${dir}}" )
        .zplugins_plugin_ctx_set ${plugin_name} path ${path}
        export PATH
    fi
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugin_remove_from_path

@zplugin_add_to_fpath() {
    local plugin_name="${1}"
    local dir="${2}"
    local create_if_not_exists="${2}"

    if [[ -n "${dir}" && "${fpath[(i)${dir}]}" > "${#fpath}" ]]; then
        if [[ ${create_if_not_exists} == yes && ! -d "${dir}" ]]; then
            .zplugins_log_debug ${plugin_name} "creating non-existing '${dir}'"
            if ! mkdir -p "${dir}" ; then
                .zplugins_log_warning ${plugin_name} "could not create directory, error $?"
            fi
        fi
        .zplugins_log_debug ${plugin_name} "adding '${dir}' to plugin function path ($(@zplugins_plugin_ctx_get ${plugin_name} fpath))"
        fpath+=( "${dir}" )
        .zplugins_plugin_ctx_set ${plugin_name} fpath ${fpath}
        export FPATH
    fi
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugin_add_to_fpath

@zplugin_remove_from_fpath() {
    local plugin_name="${1}"
    local dir="${2}"

    if [[ ${fpath[(i)${dir}]} -le ${#pfath} ]]; then
        .zplugins_log_debug ${plugin_name} "removing '${dir}' from plugin function path ($(@zplugins_plugin_ctx_get ${plugin_name} fpath))"
        fpath=( "${(@)path:#${dir}}" )
        .zplugins_plugin_ctx_set ${plugin_name} fpath ${fpath}
        export FPATH
    fi
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugin_remove_from_fpath
