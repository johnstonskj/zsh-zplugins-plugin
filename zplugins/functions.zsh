# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name functions
# @brief Track plugin-defined functions.
#

#
# @description Add the function to the list tracked for the named plugin to allow
#   it's removal later.
#
# @arg $1 string The plugin's name.
# @arg $2 string The name of the function to remember.
#
@zplugins_remember_fn() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local fn_name="${2}"
    local fn_list

    # Calls to zstyle directly so that no module dependencies exist

    builtin zstyle -a ${ZPLUGINS_PLUGINS_CTX}:${plugin_name} functions fn_list
    .zplugins_log_debug ${plugin_name} "adding '${fn_name}' to plugin functions list: (${fn_list})"

    if [[ ${fn_list[(i)${fn_name}]} -gt ${#fn_list} ]]; then
        fn_list+=( $fn_name )
        builtin zstyle ${ZPLUGINS_PLUGINS_CTX}:${plugin_name} functions ${fn_list}
    fi
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_remember_fn

#
# @description Remove all functions remembered for the named plugin.
#
# @arg $1 string The plugin's name.
#
@zplugins_unfunction_all() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local fn_list fn_name
    builtin zstyle -a ${ZPLUGINS_PLUGINS_CTX}:${plugin_name} functions fn_list

    for fn_name in ${fn_list[@]}; do
        .zplugins_log_trace ${plugin_name} "unfunction '${fn_name}'"
        whence -f "${fn_name}" &> /dev/null && unfunction ${fn_name}
    done
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_unfunction_all
