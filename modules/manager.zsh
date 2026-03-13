# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name Module manager
# @brief Plugin manager implementation.
#

# @internal
.zplugins_manager_init() {
    local as_manager plugin_data plugin_list dir_list dir

    if [[ "${ZPLUGINS_USE_AS_MANAGER}" =~ (#i)(true|yes|1) ]]; then
        .zplugins_ctx_set as-manager yes
        as_manager=0
    else
        .zplugins_ctx_set as-manager no
        as_manager=1
    fi

    if [[ (! -v zsh_loaded_plugins && ! -v PMSPEC) || ${as_manager} ]]; then
        typeset -ga zsh_loaded_plugins=()
        typeset -g PMSPEC="fbis"
    fi
    # shellcheck disable=SC2086
    return ${EC_SUCCESS}
}
@zplugins_remember_fn zplugins .zplugins_manager_init

# @internal
.zplugins_as_manager() {
    builtin zstyle -t ${ZPLUGINS[_CTX]} as-manager
    return $?
}
@zplugins_remember_fn zplugins .zplugins_as_manager

# @internal
.zplugins_manager_update() {
    local plugin_list

    if .zplugins_as_manager ; then
        plugin_list=$(@zplugins_loaded_plugin_names)
        zsh_loaded_plugins=(${(s: :)plugin_list})
        export zsh_loaded_plugins
    fi
}
@zplugins_remember_fn zplugins .zplugins_manager_update
