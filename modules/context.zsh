# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name context
# @brief Plugin context (zstyle) helpers.
#

typeset -gA ZPLUGINS

ZPLUGINS[_CTX]=":zplugins"
ZPLUGINS[_PLUGINS_CTX]="${ZPLUGINS[_CTX]}:plugins"
ZPLUGINS[_CONTEXT]="${ZPLUGINS[_PLUGINS_CTX]}:zplugins"

###################################################################################################
# @name global
# @description Global context functions.

# @internal
.zplugins_ctx_get() {
    local style_name="${1}"
    local style_value

    printf '%s' "$(builtin zstyle ${ZPLUGINS[_CTX]} ${style_name})"
}
@zplugins_remember_fn zplugins .zplugins_ctx_get

# @internal
.zplugins_ctx_set() {
    local style_name="${1}"
    local style_value="${2}"

    builtin zstyle ${ZPLUGINS[_CTX]} ${style_name} ${style_value}
}
@zplugins_remember_fn zplugins .zplugins_ctx_set

###################################################################################################
# @name plugin
# @description Plugin-specific context functions.

# @internal
.zplugins_plugin_ctx_get() {
    local plugin_name="${1}";
    local style_name="${2}"
    local style_value

    builtin zstyle -s $(@zplugins_plugin_context ${plugin_name}) ${style_name} style_value

    printf '%s' "${style_value}"
}
@zplugins_remember_fn zplugins .zplugins_plugin_ctx_get

# @internal
.zplugins_plugin_ctx_set() {
    local plugin_name="${1}"
    local style_name="${2}"
    shift 2
    local style_value="$*"

    builtin zstyle $(@zplugins_plugin_context ${plugin_name}) ${style_name} ${style_value}
}
@zplugins_remember_fn zplugins .zplugins_plugin_ctx_set

#
# @arg $1 string The plugin's name.
# @stdout The context path for the named plugin.
#
@zplugins_plugin_context() {
    builtin emulate -L zsh

    local plugin_name="${1}"

    printf '%s:%s' ${ZPLUGINS[_PLUGINS_CTX]} ${plugin_name}
}
@zplugins_remember_fn zplugins @zplugins_plugin_context

#
# @arg $1 string The plugin's name.
# @stdout The complete context data for the named plugin.
#
@zplugins_plugin_context_data() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local plugin_context=$(@zplugins_plugin_context ${plugin_name})

    printf '%s' "$(builtin zstyle -L ${plugin_context})"
}
@zplugins_remember_fn zplugins @zplugins_plugin_context_data
