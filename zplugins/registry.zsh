# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name registry
# @brief Plugin registry functions.
#

#
# @description
#
# [Standard Plugins Hash](https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash)
#
# ### Optional keyword arguments
# 
# * `fpath <PATH>`; add PATH to the fpath; no functions are autoloaded from this path.
# * `path <PATH>`; add PATH to the path.
# * `save <VARNAME>`; save the content of VARNAME in the `_OLD_VARNAME` variable.
# 
# @arg $1 string The plugin's name.
# @arg $2 path The plugin's main file path.
#
@zplugin_register() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local plugin_path="${2}"
    shift 2

    local -a dependencies
    if [[ $# > 0 ]]; then
        dependencies=( ${1} )
        shift
    fi

    local plugin_dir="${plugin_path:h}"
    local plugin_file="${plugin_path:t}"
    local plugin_list

    .zplugins_log ${plugin_name} "register plugin 'plugin_name}', in '${plugin_path}', with dependencies: '${dependencies}'"

    if ! @zplugin_is_registered ${plugin_name}; then
        .zplugins_plugin_ctx_set ${plugin_name} plugin-dir "${plugin_dir}"
        .zplugins_plugin_ctx_set ${plugin_name} plugin-file "${plugin_file}"
        .zplugins_plugin_ctx_set ${plugin_name} dependencies ${dependencies}

        .zplugins_log ${plugin_name} "zplugin_register :: add 'bin' sub-directory to path if exists"
        @zplugin_register_bin_dir ${plugin_name}

        .zplugins_log ${plugin_name} "zplugin_register :: add 'functions' sub-directory to fpath if exists"
        @zplugin_register_function_dir ${plugin_name}

        .zplugins_log ${plugin_name} "zplugin_register :: handle additional settings: $*"
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
                    @zplugins_envvar_save "${plugin_name}" "${1}"
                    ;;
            esac
            shift
        done

        .zplugins_manager_update

        .zplugins_log ${plugin_name} "plugin registered"
    else
        .zplugins_log ${plugin_name} "plugin '${plugin_name}' already registered, cannot re-register"
    fi
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugin_register

#
# @arg $1 string The name of a registered plugin.
#
@zplugin_unregister() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local plugin_data plugin_list dir_list dir

    .zplugins_log_trace ${plugin_name} "unregister plugin 'plugin_nameme}'"

    plugin_data=$(@zplugins_plugin_context_data ${plugin_name})

    if [[ ${plugin_name} == ${PLUGIN[_NAME]} && ${as_manager} ]]; then
        .zplugins_log_warning ${plugin_name} 'cannot unload plugin as it is acting as plugin manager'
    elif [[ -n "${plugin_data}" ]]; then
        .zplugins_manager_update

        .zplugins_log_debug ${plugin_name} 'remove all remembered functions'
        @zplugins_unfunction_all ${plugin_name}
        
        .zplugins_log_debug ${plugin_name} 'remove all remembered aliases'
        @zplugin_unalias_all ${plugin_name}

        .zplugins_log_debug ${plugin_name} 'remove bin directory from path if it exists'
        @zplugin_unregister_bin_dir ${plugin_name}

        .zplugins_log_debug ${plugin_name} 'remove custom directories from path'
        builtin zstyle -a ${ZPLUGINS_PLUGINS_CTX}:${plugin_name} path dir_list
        for dir in ${dir_list[@]}; do
            @zplugin_remove_from_path ${plugin_name} "${dir}"
        done

        .zplugins_log_debug ${plugin_name} 'remove functions directory from fpath if it exists'
        @zplugin_unregister_function_dir ${plugin_name}

        .zplugins_log_debug ${plugin_name} 'remove custom directories from fpath'
        builtin zstyle -a ${ZPLUGINS_PLUGINS_CTX}${plugin_name} fpath dir_list
        for dir in ${dir_list[@]}; do
            @zplugin_remove_from_fpath "${dir}"
        done

        .zplugins_log_debug ${plugin_name} 'remove the plugin zstyle context, do this last'
        builtin zstyle -d ${ZPLUGINS_PLUGINS_CTX}:${plugin_name}

        .zplugins_log_debug ${plugin_name} "plugin unregistered"
    else
        .zplugins_log_debug ${plugin_name} "no context for plugin 'plugin_nameme}', cannot unregister"
    fi
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugin_unregister

#
# @noargs
# @stdout Space-separated list of plugin names *directly* managed by `zplugins`.
#
@zplugins_all_plugin_names() {
    builtin emulate -L zsh

    printf '%s' "$(builtin zstyle -L ${ZPLUGINS_PLUGINS_CTX}:'*' | cut -d ':' -f 4 | cut -d ' ' -f 1 | sort | uniq | tr -s '\012\015' ' ')"
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_all_plugin_names

#
# @arg $1 string The plugin's name.
# @exitcode 0 Named plugin is registered.
# @exitcode 1 Named plugin is **not** registered.
#
@zplugin_is_registered() {
    builtin emulate -L zsh

    local plugin_name="${1}"

    .zplugins_log_debug ${plugin_name} "is plugin 'plugin_nameme}' in (${zsh_loaded_plugins[*]}) #${#zsh_loaded_plugins}"
    if [[ " ${zsh_loaded_plugins[*]} " == *" ${plugin_name} "* ]]; then
        return 0
    else
        return 1
    fi
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugin_is_registered
