# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name manager
# @brief Plugin manager implementation.
#

# @internal
.zplugins_manager_init() {
    local as_manager plugin_data plugin_list dir_list dir

    if [[ "${ZPLUGINS_USE_AS_MANAGER}" =~ (([yY][eE][sS])|([tT][rR][uU][eE])|1) ]]; then
        .zplugins_log_debug ${PLUGIN[_NAME]} "setting 'as-manager' to 'yes'"
        .zplugins_ctx_set as-manager yes
        as_manager=0
    else
        .zplugins_ctx_set as-manager no
        as_manager=1
    fi

    .zplugins_log_debug ${PLUGIN[_NAME]} "init settings { zsh_loaded_plugins: (${zsh_loaded_plugins[*]}), PMSPEC: (${PMSPEC}), as_manager: ${as_manager} }"
    if [[ (! -v zsh_loaded_plugins && ! -v PMSPEC) || ${as_manager} ]]; then
        .zplugins_log_debug ${PLUGIN[_NAME]} "as we are the plugin manager then initialize 'zsh_loaded_plugins' and 'PMSPEC'"
        typeset -ga zsh_loaded_plugins=()
        typeset -g PMSPEC="fbis"
    fi
    return 0
}
@zplugins_remember_fn ${PLUGIN[_NAME]} .zplugins_manager_init

# @internal
.zplugins_as_manager() {
    builtin zstyle -t ${ZPLUGINS_CTX} as-manager
    return $?
}
@zplugins_remember_fn ${PLUGIN[_NAME]} .zplugins_as_manager

# @internal
.zplugins_manager_update() {
    local plugin_list

    if .zplugins_as_manager ; then
        .zplugins_log_debug ${PLUGIN[_NAME]} "as we are the plugin manager then update 'zsh_loaded_plugins'"
        plugin_list=$(@zplugins_all_plugin_names)
        zsh_loaded_plugins=(${(s: :)plugin_list})
        export zsh_loaded_plugins
    fi
}
@zplugins_remember_fn ${PLUGIN[_NAME]} .zplugins_manager_update
