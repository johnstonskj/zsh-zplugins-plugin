# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name Module load
# @brief Plugin loading and unloading functions.
#
# @description
#
# * From a bare-bones plugin manager.
# * From the `zplugins` variable.
#

declare -a ZPLUGINS_BOOTSTRAP_PLUGINS=( xdg shlog paths )

#
# @description
#
# TBD
#
# @noargs
#
# @see @zplugins_plugin_load
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

#
# @description
#
# Load all plugins in the global array `zplugins`. This allows a similar experience to other
# plugin managers such as Oh-my-Zsh that use a global `plugins` array.
#
# @noargs
#
# @see @zplugins_plugin_load
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
    return $?
}
@zplugins_remember_fn zplugins @zplugins_load_all

#
# @description
#
# Load a plugin given a path and name. The path may be the the plugin's root file, or the directory
# containing the root file, and the name may be optional. The table below shows the **valid**
# combinations.
#
# | arg-1     | arg-2 | path                       | name          |
# |-----------|-------|----------------------------|---------------|
# | file-path | name  | file-path                  | name          |
# | file-path | ''    | file-path                  | {file-path:t} |
# | dir-path  | name  | dir-path/{name}.plugin.zsh | name          |
#
# Loading a plugin has a number of automatic registration activities, specifically:
#
# 1. Initialize the plugin's context in Zstyle.
# 2. Parse header fields from the plugin's source file into the context.
# 3. Check for any dependencies declared previously and determine if they are already loaded.
# 4. Add the plugin's `bin` directory to `$PATH` if it exists.
# 5. Add the plugin's `functions` directory to `$FPATH` if it exists.
# 6. Remember all functions in the `functions` directory, if it exists.
# 7. Add to the loaded plugin list.
#
# @arg $1 path Path to plugin file or directory.
# @arg $2 string The plugin's name (optional).
#
# @exitcode 0 Named plugin was loaded successfully.
# @exitcode 1 Invalid parameters.
# @exitcode 2 Invalid plugin file.
#
# @see [@zplugins_register_bin_dir](paths.md#zpluginsregisterbindir)
# @see [@zplugins_register_function_dir](paths.md#zpluginsregisterfunctiondir)
# @see [@zplugins_remember_fn](functions.md#zpluginsrememberfn)
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
        return 2
    fi
}
@zplugins_remember_fn zplugins @zplugins_plugin_load

#
# @description
#
# Unload the named plugin. This unwinds all the automatic registration actions.
#
# 1. Call the plugin's `_unload` function.
# 2. Call `unfunction` for all remembered plugin functions.
# 3. Call `unalias` for all defined plugin aliases.
# 4. Remove the plugin's `bin` directory from `$PATH`.
# 5. Remove any plugin custom path entries from `$PATH`.
# 6. Remove the plugin's `functions` directory from `$FPATH`.
# 7. Remove any plugin custom function path entries from `$FPATH`.
# 8. Remove plugin from loaded plugin list.
#
# @arg $1 string The name of a loaded plugin to unload.
#
# @exitcode 0 Named plugin was unloaded successfully.
# @exitcode 1 Cannot unload the plugin `zplugins` _if_ it is acting as plugin manager.
# @exitcode 2 Plugin has no context data.
#
# @see [@zplugins_unfunction_all](functions.md#zpluginsunfunctionall)
# @see [@zplugins_unalias_all](aliases.md#zpluginsunaliasall)
# @see [@zplugins_unregister_bin_dir](paths.md#zpluginsunregisterbindir)
# @see [@zplugins_remove_from_path](paths.md#zpluginsremovefrompath)
# @see [@zplugins_unregister_function_dir](paths.md#zpluginsunregisterfunctiondir)
# @see [@zplugins_remove_from_fpath](paths.md#zpluginsremovefrom_path)
#
@zplugins_plugin_unload() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local plugin_data plugin_list dir_list dir

    .zplugins_log_info zplugins "unloading plugin '${plugin_name}'"

    plugin_data=$(@zplugins_plugin_context_data ${plugin_name})

    if [[ ${plugin_name} == zplugins && ${as_manager} ]]; then
        .zplugins_log_warning zplugins 'cannot unload plugin as it is acting as plugin manager'
        return 1
    elif [[ -n "${plugin_data}" ]]; then

        # Call this first, this way the plugin removes any custom stuff while the 
        # automatic stuff remains.
        if whence -f ${plugin_name}_plugin_unload &> /dev/null; then
            if ! ${plugin_name}_plugin_unload; then
                .zplugins_log_error "${plugin_name}" "plugin's _unload function returned non-zero"
            fi
        fi

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
        .zplugins_log_error zplugins "no context for plugin '${plugin_name}', cannot unload"
        return 2
    fi
    return 0
}
@zplugins_remember_fn zplugins @zplugins_unload

#
# @description
#
# Determine whether a named plugin is loaded.
#
# @example
#    if @zplugins_is_loaded myplugin; then
#        echo "myplugin is loaded"
#    else
#        echo "myplugin is not loaded"
#    fi
#
# @arg $1 string The plugin's name.
#
# @exitcode 0 Named plugin is registered.
# @exitcode 1 Named plugin is **not** registered.
#
# @see @zplugins_is_loaded
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
# @description
#
# Return an array of plugin names as a string.
#
# @example
#    typeset -s name_str="$(@zplugins_loaded_plugin_names)"
#    typeset -a names=( ${(z)name_str} )
#    echo "Loaded plugins: ${(j:, :)names}."
#
# @noargs
#
# @stdout Space-separated list of plugin names _directly_ managed by `zplugins`.
#
# @see @zplugins_is_loaded
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

###################################################################################################
# Internal
###################################################################################################

# @internal
# @description
#
# Load all the plugins required for initial execution of the plugin manager. These plugins are
# defined in the global array `ZPLUGINS_BOOTSTRAP_PLUGINS`.
#
# @noargs
#
.zplugins_load_bootstrap_plugins() {
    .zplugins_log_info zplugins "loading plugins required to bootstrap .zshenv"

    local plugin_name plugin_path
    local -a plugin_list

    for plugin_name in ${ZPLUGINS_BOOTSTRAP_PLUGINS[@]}; do
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
    return $?
}
@zplugins_remember_fn zplugins .zplugins_load_bootstrap_plugins

#
# @internal
# @description
#
# Add the named plugin to the loaded plugin list, and update the plugin manager.
#
# @arg $1 string The plugin's name.
#
# @exitcode 0 Success
# @exitcode 1 Named plugin **already** in the loaded plugin list.
#
# @see .zplugins_remove_loaded_plugin
#
.zplugins_add_loaded_plugin() {
    local plugin_name="${1}"

    if [[ ! $(@zplugins_is_loaded ${plugin_name}) ]]; then
        ZPLUGINS[_LOADED]="${ZPLUGINS[_LOADED]}${plugin_name} "
        .zplugins_manager_update
    else
        .zplugins_log_error zplugins "plugin ${plugin_name} already in loaded list"
        return 1
    fi
    return 0
}
@zplugins_remember_fn zplugins .zplugins_add_loaded_plugin

#
# @internal
# @description
#
# Remove the named plugin from the loaded plugin list, and update the plugin manager.
#
# @arg $1 string The plugin's name.
#
# @exitcode 0 Success
# @exitcode 1 Named plugin **not** in the loaded plugin list.
#
# @see .zplugins_add_loaded_plugin
#
.zplugins_remove_loaded_plugin() {
    local plugin_name="${1}"

    if [[ $(@zplugins_is_loaded ${plugin_name}) ]]; then
        ZPLUGINS[_LOADED]="${ZPLUGINS[_LOADED]// ${plugin_name} / }"
        .zplugins_manager_update
    else
        .zplugins_log_error zplugins "plugin ${plugin_name} not in loaded list"
        return 1
    fi
    return 0
}
@zplugins_remember_fn zplugins .zplugins_add_loaded_plugin

#
# @internal
# @description
#
# @arg $1 string The plugin's name.
#
# @exitcode 0 Success
# @exitcode 1 No path found for the plugin.
#
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

#
# @internal
# @description
#
# Takes an array of plugin name/path pairs and loads each in turn. The string may contain
# just the name, just the path, or both.
#
# * `name=path`; both name and path are known.
# * `=path`; only the path is known.
# * `name`; only the name is known.
#
# @arg $1 array An array of strings where each is a plugin name/path pair.
#
# @exitcode 0 Success
#
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

    return 0
}
@zplugins_remember_fn zplugins .zplugins_load_all_inner

#
# @internal
# @description
#
# @arg $1 string The plugin's name.
# @arg $2 path The plugin file's absolute path.
#
# @exitcode 0 Success
# @exitcode 1 Plugin already setup
# @exitcode 2 Plugin _init function error
#
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

        # Do this last so that all the automatic registration stuff is complete
        # and any data/functions are accessible.
        if whence -f ${plugin_name}_plugin_init &> /dev/null; then
            @zplugins_remember_fn "${plugin_name}" ${plugin_name}_plugin_init
            if ! ${plugin_name}_plugin_init "${plugin_path}" "${plugin_name}"; then
                .zplugins_log_error "${plugin_name}" "plugin's _init function returned non-zero; errno: $?"
                return 2
            fi
        fi
    else
        .zplugins_log_warning zplugins "plugin '${plugin_name}' already setup, cannot re-setup"
        return 1
    fi
    return 0
}
@zplugins_remember_fn zplugins .zplugins_plugin_setup
