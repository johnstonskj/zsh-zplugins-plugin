# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name load
# @brief Plugin loading functions.
#
# @description
#
# * From a bare-bones plugin manager.
# * From the `zplugins` variable.
#

#
# @description
#
# @noargs
#
@zplugins_load_all_from_sheldon() {
    .zplugins_log_info zplugins "loading all plugins managed by sheldon"

    if ! command -v sheldon >/dev/null 2>&1 ; then
        echo "Error: sheldon command not found!" >&2
    else
        local sourced 
        local -a sourced_paths
        local line
        local -a plugin_paths

        sourced="$(sheldon source)"
        sourced_paths=( "${(@f)sourced}" )
        
        for line in ${sourced_paths[@]}; do
            line=$(echo ${line} | cut -d' ' -f2)
            plugin_paths+=( "=${line:1:-1}" )
        done
        
        .zplugins_load_all_inner "${plugin_paths[*]}"
    fi
}
@zplugins_remember_fn zplugins @zplugins_load_all_from_sheldon

#
# @description
#
# @noargs
#
@zplugins_load_all() {
    .zplugins_log_info zplugins "loading all plugins from global array 'zplugins': ${zplugins[*]}"
    local -a plugin_list
    local plugin_name plugin_path

    for plugin_name in ${zplugins[@]}; do
        plugin_path=$(.zplugins_find_load_path ${plugin_name})
        if [[ $? -eq 0 ]]; then
            .zplugins_log_trace zplugins "plugin '${plugin_name}' found in '${plugin_path}'"
            plugin_list+=( "${plugin_name}=${plugin_path}" )
        else
            echo "Error: could not find path for plugin named '${plugin_name}'" >&2
            .zplugins_log_error ${plugin_name} "could not find path for plugin named '${plugin_name}'"
        fi
    done

    .zplugins_load_all_inner "${plugin_list[*]}"
}
@zplugins_remember_fn zplugins @zplugins_load_all

#
# @arg $1 path Path to plugin file or directory.
# @arg $2 string The plugin's (optional).
#
@zplugins_plugin_load() {
    local plugin_path="${1:P}"
    local plugin_name="${2}"
    local plugin_dir plugin_file extension path_parts

    .zplugins_log_info zplugins "loading plugin: { path: '${plugin_path}', name: '${plugin_name}' }"

    if [[ -f "${plugin_path}" && -n "${plugin_name}" ]]; then
        : # We have everything we think we need
    elif [[ -f "${plugin_path}" && -z "${plugin_name}" ]]; then
        .zplugins_log_trace "${plugin_name}" "deconstruct dir and name from path"
        plugin_file=${plugin_path:t}
        extension="${plugin_file#*.}"
        if [[ "${extension}" =~ ^(plugin\\.)?zsh$ ]]; then
            plugin_name="${plugin_file%%.*}"
        else
            plugin_name="${plugin_file}"
        fi
    elif [[ -d "${plugin_path}" && -n "${plugin_name}" ]]; then
        .zplugins_log_trace "${plugin_name}" "construct path from dir and name"
        plugin_dir="${plugin_path}"
        plugin_file="${plugin_name}.plugin.zsh"
        path_parts=( ${plugin_path} ${plugin_file} )
        plugin_path="${(j:/:)path_parts}"
    else
        echo "Error: call with either <DIR> <NAME> or <FILE>" >&2
        .zplugins_log_error "${plugin_name}" "call with either <DIR> <NAME> or <FILE>"
        return 1
    fi

    if [[ -f "${plugin_path}" ]]; then
        .zplugins_log_trace "${plugin_name}" "sourcing file at ${plugin_path}"
        source "${plugin_path}"

        if ! @zplugins_is_loaded ${plugin_name}; then
            .zplugins_plugin_setup ${plugin_name} ${plugin_path}

            .zplugins_log_info zplugins "plugin '${plugin_name}' loaded"
        else
            .zplugins_log_warning zplugins "plugin '${plugin_name}' already loaded, cannot reload"
        fi

        return 0
    else
        echo "Error: plugin path '${plugin_path}' is not a loadable file." >&2
        .zplugins_log_error zplugins "plugin path '${plugin_path}' is not a loadable file."
        return 1
    fi
}
@zplugins_remember_fn zplugins @zplugins_plugin_load

#
# @arg $1 string The name of a loaded plugin.
#
@zplugins_plugin_unload() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local plugin_data plugin_list dir_list dir

    .zplugins_log_trace zplugins "unload plugin '${plugin_name}'"

    plugin_data=$(@zplugins_plugin_context_data ${plugin_name})

    if [[ ${plugin_name} == zplugins && ${as_manager} ]]; then
        .zplugins_log_warning zplugins 'cannot unload plugin as it is acting as plugin manager'
    elif [[ -n "${plugin_data}" ]]; then
        .zplugins_manager_update

        .zplugins_log_trace "${plugin_name}" 'remove all remembered functions'
        @zplugins_unfunction_all ${plugin_name}
        
        .zplugins_log_trace "${plugin_name}" 'remove all remembered aliases'
        @zplugins_unalias_all ${plugin_name}

        .zplugins_log_trace "${plugin_name}" 'remove bin directory from path if it exists'
        @zplugins_unregister_bin_dir ${plugin_name}

        .zplugins_log_trace "${plugin_name}" 'remove custom directories from path'
        builtin zstyle -a ${ZPLUGINS[_PLUGINS_CTX]}:${plugin_name} path dir_list
        for dir in ${dir_list[@]}; do
            @zplugins_remove_from_path ${plugin_name} "${dir}"
        done

        .zplugins_log_trace "${plugin_name}" 'remove functions directory from fpath if it exists'
        @zplugins_unregister_function_dir ${plugin_name}

        .zplugins_log_trace "${plugin_name}" 'remove custom directories from fpath'
        builtin zstyle -a ${ZPLUGINS[_PLUGINS_CTX]}${plugin_name} fpath dir_list
        for dir in ${dir_list[@]}; do
            @zplugins_remove_from_fpath "${dir}"
        done

        .zplugins_log_trace "${plugin_name}" 'remove the plugin zstyle context, do this last'
        builtin zstyle -d ${ZPLUGINS[_PLUGINS_CTX]}:${plugin_name}

        .zplugins_log_trace zplugins"plugin unloaded"
    else
        .zplugins_log_debug zplugins "no context for plugin '${plugin_name}', cannot unload"
    fi
}
@zplugins_remember_fn zplugins @zplugins_unload

#
# @arg $1 string The plugin's name.
# @exitcode 0 Named plugin is registered.
# @exitcode 1 Named plugin is **not** registered.
#
@zplugins_is_loaded() {
    builtin emulate -L zsh

    local plugin_name="${1}"

    .zplugins_log_trace zplugins "is plugin '${plugin_name}' in ( ${zsh_loaded_plugins[*]} )?"
    if [[ " ${zsh_loaded_plugins[*]} " == *" ${plugin_name} "* ]]; then
        return 0
    else
        return 1
    fi
}
@zplugins_remember_fn zplugins @zplugins_is_loaded

#
# @noargs
# @stdout Space-separated list of plugin names *directly* managed by `zplugins`.
#
@zplugins_loaded_plugin_names() {
    builtin emulate -L zsh

    printf '%s' "$(builtin zstyle -L ${ZPLUGINS[_PLUGINS_CTX]}:'*' | cut -d ':' -f 4 | cut -d ' ' -f 1 | sort | uniq | tr -s '\012\015' ' ')"
}
@zplugins_remember_fn zplugins @zplugins_loaded_plugin_names

############################################################################
# Internal
############################################################################

# @internal
.zplugins_find_load_path() {
    local plugin_name="${1}"
    local -a try_dirs
    local -a try_files
    local try_dir try_file try_path

    try_dirs=( "zsh-${plugin_name}-plugin" "zsh-${plugin_name}" "${plugin_name}.zsh" )
    try_files=( "${plugin_name}.plugin.zsh" )
            
    for try_dir in ${try_dirs[@]}; do
        for try_file in ${try_files[@]}; do
            try_path="${ZPLUGINS_PLUGIN_HOME}/${try_dir}/${try_file}"
            if [[ -f "${try_path}" ]]; then
                printf '%s' "${try_path}"
                return 0
            fi
        done
    done
    return 1
}
@zplugins_remember_fn zplugins .zplugins_find_load_path

# @internal
.zplugins_load_all_inner() {
    local -a plugin_list=( ${(@s: :)1} )
    local entry parts load_path

    .zplugins_log_info zplugins "load plugins from ( ${plugin_list[@]} )"

    for entry in "${plugin_list[@]}"; do
        parts=( ${(@s:=:)entry} )

        .zplugins_log_trace zplugins "split path: '${parts[1]}' = '${parts[2]}'"
        
        if [[ ${#parts} -eq 2 ]]; then
            @zplugins_plugin_load ${parts[2]} ${parts[1]}
        elif [[ ${#parts} -eq 1 && ${entry::1} == '=' ]]; then
            @zplugins_plugin_load ${parts[1]}
        elif [[ ${#parts} -eq 1 ]]; then
            load_path="$(.zplugins_find_load_path ${parts[1]})"

            if [ $? -eq 0 ]; then
                @zplugins_plugin_load "${load_path}" ${parts[1]}
            else
                echo "Error: cannot find a plugin location for '${parts[1]}'" >&2
                .zplugins_log_error zplugins "cannot find a plugin location for '${parts[1]}'"
            fi
        else
            echo "Error: badly formed load string '${entry}'" >&2
            .zplugins_log_error zplugins "badly formed load string '${entry}'"
        fi 
    done
}
@zplugins_remember_fn zplugins .zplugins_load_all_inner

# @internal
.zplugins_plugin_setup() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local plugin_path="${2}"

    local plugin_dir="${plugin_path:h}"
    local plugin_file="${plugin_path:t}"

    .zplugins_log_trace zplugins "setting up plugin '${plugin_name}', in '${plugin_path}', with dependencies: '$(.zplugins_logfmt_array dependencies)'"

    if ! @zplugins_is_loaded ${plugin_name}; then
        .zplugins_plugin_ctx_set ${plugin_name} plugin-dir "${plugin_dir}"
        .zplugins_plugin_ctx_set ${plugin_name} plugin-file "${plugin_file}"

        if [[ -n "#{3}" ]]; then
            local -a dependencies=( "${3}" )
            local dependency
            zstyle -a $(@zplugins_plugin_context ${plugin_name}) dependencies dependencies

            for dependency in ${dependencies[@]}; do
                if [[ "${dependency::1}" == '?' ]]; then
                    optional=0
                    dependency="${dependency:1}"
                else
                    optional=1
                fi

                if @zplugins_is_loaded ${dependency} && ! optional; then
                    .zplugins_log_trace "${plugin_name}" "dependency '${dependency}' satisfied"
                elif optional; then
                    .plugins_log_warning "${plugin_name}" "optional dependency '${dependency}' NOT satisfied"
                else
                    .plugins_log_error "${plugin_name}" "dependency '${dependency}' NOT satisfied"
                fi
            done
        fi

        .zplugins_log_trace "${plugin_name}" "add 'bin' sub-directory to path, if it exists"
        @zplugins_register_bin_dir ${plugin_name}

        .zplugins_log_trace "${plugin_name}" "add 'functions' sub-directory to fpath, if it exists"
        @zplugins_register_function_dir ${plugin_name}

        .zplugins_log_trace "${plugin_name}" "remember _plugin_unload"
        if whence -f ${plugin_name}_plugin_unload &> /dev/null; then
            @zplugins_remember_fn "${plugin_name}" ${plugin_name}_plugin_unload
        fi

        .zplugins_manager_update

        .zplugins_log_trace "${plugin_name}" "call/remember _plugin_init"
        if whence -f ${plugin_name}_plugin_init &> /dev/null; then
            @zplugins_remember_fn "${plugin_name}" ${plugin_name}_plugin_init
            ${plugin_name}_plugin_init "${plugin_path}" "${plugin_name}"
        fi

        .zplugins_log_trace zplugins "plugin '${plugin_name}' setup complete"
    else
        .zplugins_log_warning zplugins "plugin '${plugin_name}' already registered, cannot re-register"
    fi
}
@zplugins_remember_fn zplugins .zplugins_plugin_setup
