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

    # Zsh global
    typeset -A _comps

    # Calls to zstyle directly so that no module dependencies exist
    builtin zstyle -a ${ZPLUGINS[_PLUGINS_CTX]}:${plugin_name} functions fn_list

    if [[ ${fn_list[(i)${fn_name}]} -gt ${#fn_list} ]]; then
        fn_list+=( $fn_name )
        builtin zstyle ${ZPLUGINS[_PLUGINS_CTX]}:${plugin_name} functions ${fn_list}

        if [[ "${fn_name}" == _* && -z "${_comps[${fn_name:2}]}" ]]; then
            .zplugins_log_info ${plugin_name} "function appears to be a completion for command '${fn_name:1}', adding to '_comps'"
            _comps[${fn_name:2}]=${fn_name}
        fi
    fi
}
@zplugins_remember_fn zplugins @zplugins_remember_fn

#
# @description
#
# Remove all functions remembered for the named plugin.
#
# @arg $1 string The plugin's name.
#
@zplugins_unfunction_all() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local fn_list fn_name
    builtin zstyle -a ${ZPLUGINS[_PLUGINS_CTX]}:${plugin_name} functions fn_list

    for fn_name in ${fn_list[@]}; do
        if whence -f "${fn_name}" /dev/null 2>&1; then
            unfunction ${fn_name}
        fi
    done
}
@zplugins_remember_fn zplugins @zplugins_unfunction_all
