# -*- mode: sh; eval: (sh-set-shell "zsh") -*-

############################################################################
# Plugin Context (zstyle) Helpers
############################################################################

.zplugins_ctx_get() {
    local style_name="${1}"
    local style_value

    builtin zstyle -g style_value ${ZPLUGINS_CTX} ${style_name}
    printf '%s' ${style_value}
}
@zplugins_remember_fn ${PLUGIN[_NAME]} .zplugins_ctx_get

.zplugins_ctx_set() {
    local style_name="${1}"
    local style_value="${2}"

    builtin zstyle ${ZPLUGINS_CTX} ${style_name} ${style_value}
}
@zplugins_remember_fn ${PLUGIN[_NAME]} .zplugins_ctx_set

.zplugins_plugin_ctx_get() {
    local plugin_name="${1}"
    local style_name="${2}"

    builtin zstyle -g style_value $(@zplugins_plugin_context ${plugin_name}) ${style_name}
    printf '%s' ${style_value}
}
@zplugins_remember_fn ${PLUGIN[_NAME]} .zplugins_plugin_ctx_get

.zplugins_plugin_ctx_set() {
    local plugin_name="${1}"
    local style_name="${2}"
    local style_value="${3}"

    builtin zstyle $(@zplugins_plugin_context ${plugin_name}) ${style_name} ${style_value}
}
@zplugins_remember_fn ${PLUGIN[_NAME]} .zplugins_plugin_ctx_set

@zplugins_plugin_context() {
    builtin emulate -L zsh

    local plugin_name="${1}"

    printf '%s:%s' ${ZPLUGINS_PLUGINS_CTX} ${plugin_name}
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_plugin_context

@zplugins_plugin_context_data() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local plugin_context=$(@zplugins_plugin_context ${plugin_name})

    .zplugins_log_debug ${plugin_name} "reading all from context ${plugin_context}"
    printf '%s' "$(builtin zstyle -L ${plugin_context})"
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_plugin_context_data
