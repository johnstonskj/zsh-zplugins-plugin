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
        .zplugins_log_error "${plugin_name}" "sheldon command not found!"
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

@zplugins_load_bootstrap_plugins() {
    .zplugins_log_info zplugins "loading plugins required to bootstrap .zshenv"

    local -a plugins=( xdg shlog paths )
    local plugin_name plugin_path
    local -a plugin_list

    for plugin_name in ${plugins[@]}; do
        if ! @zplugins_is_loaded ${plugin}; then
            plugin_path=$(.zplugins_find_load_path ${plugin_name})
            if [[ $? -eq 0 ]]; then
                plugin_list+=( "${plugin_name}=${plugin_path}" )
            else
                .zplugins_log_error ${plugin_name} "could not find path for plugin named '${plugin_name}'"
            fi
        fi
    done

    .zplugins_load_all_inner "${plugin_list[*]}"
}
@zplugins_remember_fn zplugins @zplugins_load_bootstrap_plugins

#
# @description
#
# @noargs
#
@zplugins_load_all() {
    .zplugins_log_info zplugins "loading all plugins from global array 'zplugins': ${zplugins[*]}"

    local plugin_name plugin_path
    local -a plugin_list

    for plugin_name in ${zplugins[@]}; do
        plugin_path=$(.zplugins_find_load_path ${plugin_name})
        if [[ $? -eq 0 ]]; then
            plugin_list+=( "${plugin_name}=${plugin_path}" )
        else
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
        plugin_file=${plugin_path:t}
        extension="${plugin_file#*.}"
        if [[ "${extension}" =~ ^(plugin\\.)?zsh$ ]]; then
            plugin_name="${plugin_file%%.*}"
        else
            plugin_name="${plugin_file}"
        fi
    elif [[ -d "${plugin_path}" && -n "${plugin_name}" ]]; then
        plugin_dir="${plugin_path}"
        plugin_file="${plugin_name}.plugin.zsh"
        path_parts=( ${plugin_path} ${plugin_file} )
        plugin_path="${(j:/:)path_parts}"
    else
        .zplugins_log_error "${plugin_name}" "call with either <DIR> <NAME> or <FILE>"
        return 1
    fi

    if [[ -f "${plugin_path}" ]]; then
        if ! @zplugins_is_loaded ${plugin_name}; then
            if ! source "${plugin_path}"; then
                .zplugins_log_error zplugins "could not source plugin from file ${plugin_path}; errno: $?"
            fi

            .zplugins_plugin_setup ${plugin_name} ${plugin_path}

            .zplugins_log_info zplugins "plugin '${plugin_name}' loaded"
        else
            .zplugins_log_warning zplugins "plugin '${plugin_name}' already loaded, cannot reload; loaded: $(@zplugins_loaded_plugin_names)"
        fi

        return 0
    else
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

    .zplugins_log_info zplugins "unloading plugin '${plugin_name}'"

    plugin_data=$(@zplugins_plugin_context_data ${plugin_name})

    if [[ ${plugin_name} == zplugins && ${as_manager} ]]; then
        .zplugins_log_warning zplugins 'cannot unload plugin as it is acting as plugin manager'
    elif [[ -n "${plugin_data}" ]]; then
        .zplugins_manager_update

        @zplugins_unfunction_all ${plugin_name}

        @zplugins_unalias_all ${plugin_name}

        @zplugins_unregister_bin_dir ${plugin_name}

        builtin zstyle -a ${ZPLUGINS[_PLUGINS_CTX]}:${plugin_name} path dir_list
        for dir in ${dir_list[@]}; do
            @zplugins_remove_from_path ${plugin_name} "${dir}"
        done

        @zplugins_unregister_function_dir ${plugin_name}

        builtin zstyle -a ${ZPLUGINS[_PLUGINS_CTX]}${plugin_name} fpath dir_list
        for dir in ${dir_list[@]}; do
            @zplugins_remove_from_fpath "${dir}"
        done

        builtin zstyle -d ${ZPLUGINS[_PLUGINS_CTX]}:${plugin_name}
        .zplugins_remove_loaded_plugin "${plugin_name}"

        .zplugins_log_info zplugins"plugin unloaded"
    else
        .zplugins_log_warning zplugins "no context for plugin '${plugin_name}', cannot unload"
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

    if [[ "${ZPLUGINS[_LOADED]}" == *" ${plugin_name} "* ]]; then
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

    if [[ "${ZPLUGINS[_LOADED]}" == " " ]]; then
        printf ' '
    else
        printf '%s' "${ZPLUGINS[_LOADED]:1:-1}"
    fi
}
@zplugins_remember_fn zplugins @zplugins_loaded_plugin_names

.zplugins_add_loaded_plugin() {
    local plugin_name="${1}"

    if [[ ! $(@zplugins_is_loaded ${plugin_name}) ]]; then
        ZPLUGINS[_LOADED]="${ZPLUGINS[_LOADED]}${plugin_name} "
    else
        .zplugins_log_error zplugins "plugin ${plugin_name} already in loaded list"
    fi
}
@zplugins_remember_fn zplugins .zplugins_add_loaded_plugin

.zplugins_remove_loaded_plugin() {
    local plugin_name="${1}"

    if [[ $(@zplugins_is_loaded ${plugin_name}) ]]; then
        ZPLUGINS[_LOADED]="${ZPLUGINS[_LOADED]// ${plugin_name} / }"
    else
        .zplugins_log_error zplugins "plugin ${plugin_name} not in loaded list"
    fi
}
@zplugins_remember_fn zplugins .zplugins_add_loaded_plugin

###################################################################################################
# Internal
###################################################################################################

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

    for entry in "${plugin_list[@]}"; do
        parts=( ${(@s:=:)entry} )

        if [[ ${#parts} -eq 2 ]]; then
            @zplugins_plugin_load ${parts[2]} ${parts[1]}
        elif [[ ${#parts} -eq 1 && ${entry::1} == '=' ]]; then
            @zplugins_plugin_load ${parts[1]}
        elif [[ ${#parts} -eq 1 ]]; then
            load_path="$(.zplugins_find_load_path ${parts[1]})"

            if [ $? -eq 0 ]; then
                @zplugins_plugin_load "${load_path}" ${parts[1]}
            else
                .zplugins_log_error zplugins "cannot find a plugin location for '${parts[1]}'"
            fi
        else
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

    if ! @zplugins_is_loaded ${plugin_name}; then
        .zplugins_plugin_ctx_set ${plugin_name} plugin-dir "${plugin_dir}"
        .zplugins_plugin_ctx_set ${plugin_name} plugin-file "${plugin_file}"
        .zplugins_field_parser "${plugin_name}" "${plugin_dir}/${plugin_file}"

        local dependency_string="$(@zplugins_plugin_dependencies ${plugin_name})"
        if [[ -n "${dependency_string}" ]]; then
            local -a dependencies=( "${(z)dependency_string}" )
            local -a dependency

            .zplugins_log_info "${plugin_name}" "loading dependencies (${(j:,:)dependencies}), ${#dependencies}, declared by plugin"

            for dependency in ${dependencies[@]}; do
                local optional=false
                if [[ "${dependency::1}" == '?' ]]; then
                    dependency="${dependency:1}"
                    optional=true
                fi

                @zplugins_is_loaded ${dependency}
                local is_loaded=$?

                if [[ ${is_loaded} -ne 0 && ${optional} == false ]]; then
                    .zplugins_log_error "${plugin_name}" "dependency '${dependency}' NOT satisfied"
                elif [[ ${is_loaded} -ne 0 && ${optional} == true ]]; then
                    .zplugins_log_warning "${plugin_name}" "optional dependency '${dependency}' NOT satisfied"
                fi
            done
        fi

        @zplugins_register_bin_dir ${plugin_name}

        @zplugins_register_function_dir ${plugin_name}

        if whence -f ${plugin_name}_plugin_unload &> /dev/null; then
            @zplugins_remember_fn "${plugin_name}" ${plugin_name}_plugin_unload
        fi

        .zplugins_add_loaded_plugin "${plugin_name}"
        .zplugins_manager_update

        if whence -f ${plugin_name}_plugin_init &> /dev/null; then
            @zplugins_remember_fn "${plugin_name}" ${plugin_name}_plugin_init
            ${plugin_name}_plugin_init "${plugin_path}" "${plugin_name}"
        fi
    else
        .zplugins_log_warning zplugins "plugin '${plugin_name}' already registered, cannot re-register"
    fi
}
@zplugins_remember_fn zplugins .zplugins_plugin_setup
