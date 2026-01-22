# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name load
# @brief load function for plugins.
#

#
# @arg $1 path Path to plugin file or directory.
# @arg $2 string The plugin's (optional).
#
@zplugins_plugin_load() {
    local plugin_path="${1:P}"
    local plugin_name="${2}"
    local plugin_dir plugin_file path_parts

    .zplugins_log_trace "${PLUGIN[_NAME]}" "{ path: '${plugin_path}', name: '${plugin_name}' }"

    if [[ -d "${plugin_path}" && -n "${plugin_name}" ]]; then
        .zplugins_log_trace "${PLUGIN[_NAME]}" "construct path from dir and name"
        plugin_dir="${plugin_path}"
        plugin_file="${plugin_name}.plugin.zsh"
        path_parts=( ${plugin_path} ${plugin_file} )
        plugin_path="${(j:/:)path_parts}"
    elif [[ -f "${plugin_path}" && -z "${plugin_name}" ]]; then
        .zplugins_log_trace "${PLUGIN[_NAME]}" "deconstruct dir and name from path"
        plugin_dir="${plugin_path:h}"
        plugin_file="${plugin_path:t}"

        plugin_ext="${plugin_file#*.}"
        if [[ "${plugin_ext}" =~ ^(plugin\\.)?zsh$ ]]; then
            plugin_name="${plugin_file%%.*}"
        else
            plugin_name="${plugin_file}"
        fi
    else
        .zplugins_log_error "${PLUGIN[_NAME]}" "call with either <DIR> <NAME> or <FILE>"
        return 1
    fi

    .zplugins_log_trace "${PLUGIN[_NAME]}" "normalized { path: '${plugin_path}', dir: '${plugin_dir}', file: '${plugin_file}', name: '${plugin_name}' }"

    if [[ -s "${plugin_path}" ]]; then
        .zplugins_log_trace "${PLUGIN[_NAME]}" "sourcing file"

        .zplugins_log_trace "${PLUGIN[_NAME]}" "remember plugin unload"
        if whence -f ${plugin_name}_plugin_unload &> /dev/null; then
            @zplugins_remember_fn "${plugin_name}" ${plugin_name}_plugin_unload
        fi
        
        .zplugins_log_trace "${PLUGIN[_NAME]}" "call/remember plugin init"
        if whence -f ${plugin_name}_plugin_init &> /dev/null; then
            @zplugins_remember_fn "${plugin_name}" ${plugin_name}_plugin_init
            # ${plugin_name}_plugin_init "${plugin_path}" "${plugin_name}"
        fi

        return 0
    else
        .zplugins_log_error "${PLUGIN[_NAME]}" "plugin path '${plugin_path}' is not a loadable file."
        return 1
    fi
}

@zplugins_plugin_unload() {
    local plugin_name="${1}"
}