# -*- mode: sh; eval: (sh-set-shell "zsh") -*-

############################################################################
# Track Plugin Aliases
############################################################################

@zplugin_define_alias() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local alias_name="${2}"
    local alias_value="${3}"
    local alias_list

    builtin zstyle -a ${ZPLUGINS_PLUGINS_CTX}:${plugin_name} aliases alias_list
    .zplugins_log_trace ${} "adding '${alias_name}' to plugin aliases list (${alias_list})"

    if [[ ${alias_list[(i)${fn_name}]} -gt ${#alias_list} ]]; then
        alias_list+=( $alias_name )
        .zplugins_plugin_ctx_set ${plugin_name} aliases ${alias_list}
    fi

    alias ${alias_name}=${alias_value}
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugin_define_alias

@zplugin_unalias_all() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local alias_list alias_name
    builtin zstyle -a ${ZPLUGINS_PLUGINS_CTX}:${plugin_name} aliases alias_list

    for alias_name in ${alias_list[@]}; do
        .zplugins_log_trace ${plugin_name} "unalias '${alias_name}'"
        unalias ${alias_name}
    done
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugin_unalias_all
