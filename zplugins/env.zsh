# -*- mode: sh; eval: (sh-set-shell "zsh") -*-

############################################################################
# Plugin Global Variable Helpers
############################################################################

# Normalize the value of the `$0` variable as described in
# [zero-handling](https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling)
@zplugins_normalize_zero() {
    builtin emulate -L zsh

    local zero="${1}"

    zero="${ZERO:-${${zero:#${ZSH_ARGZERO}}:-${(%):-%N}}}"
    printf '%s' "${${(M)zero:#/*}:-${PWD}/${zero}}"
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_normalize_zero

@zplugins_envvar_save() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local env_var="${2}"

    .zplugins_plugin_ctx_set ${plugin_name} old-${env_var} "${(P)env_var}"
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_envvar_save

@zplugins_envvar_restore() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local env_var="${2}"

    .zplugins_plugin_ctx_set old-${env_var} env_value

    : ${(P)env_var::=${env_value}}
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_envvar_restore
