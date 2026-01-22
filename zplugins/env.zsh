# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name env
# @brief Plugin global variable helpers.
#

#
# @description Normalize the value of the `$0` variable as described in
# [zero-handling](https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling).
#
# @arg $1 string The plugin's name.
# @stdout The normalized path value.
#
# @example
#    0="$(@zplugin_normalize_zero "${0}")"
#
@zplugins_normalize_zero() {
    builtin emulate -L zsh

    local zero="${1}"

    zero="${ZERO:-${${zero:#${ZSH_ARGZERO}}:-${(%):-%N}}}"
    printf '%s' "${${(M)zero:#/*}:-${PWD}/${zero}}"
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_normalize_zero

#
# @brief Save the state of the variable `VARNAME` in the global state variable `_OLD_VARNAME`.
# 
# @arg $1 string The plugin's name.
# @arg $2 string Name of the environment variable to save.
#
@zplugins_envvar_save() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local env_var="${2}"

    .zplugins_plugin_ctx_set ${plugin_name} old-${env_var} "${(P)env_var}"
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_envvar_save

#
# @brief Restore the state of the variable `VARNAME` from the global state variable `_OLD_VARNAME`.
#
# @arg $1 string The plugin's name.
# @arg $2 string Name of the environment variable to restore.
# @set NAME
#
@zplugins_envvar_restore() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local env_var="${2}"

    .zplugins_plugin_ctx_set old-${env_var} env_value

    : ${(P)env_var::=${env_value}}
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_envvar_restore
