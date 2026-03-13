# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name Module context
# @brief Manage plugin context (Zstyle) data.
#
#
# @example
#    ❯ zstyle -L :zplugins:plugins:bat
#    zstyle :zplugins:plugins:bat aliases 'cat battail'
#    zstyle :zplugins:plugins:bat field_@_brief 'Set `bat` as a cat replacement.'
#    zstyle :zplugins:plugins:bat field_@_license 'MIT AND Apache-2.0'
#    zstyle :zplugins:plugins:bat field_@_name bat
#    zstyle :zplugins:plugins:bat field_@_repository https://github.com/johnstonskj/zsh-bat-plugin
#    zstyle :zplugins:plugins:bat field_@_version 0.1.1
#    zstyle :zplugins:plugins:bat functions bat_plugin_unload bat_plugin_init
#    zstyle :zplugins:plugins:bat old-MANPAGER 'sh -c '\''col -bx | bat -l man -p'\'
#    zstyle :zplugins:plugins:bat old-MANROFFOPT -c
#    zstyle :zplugins:plugins:bat plugin-dir /Users/s0j0g7m/Projects/Config/local/share/zsh/plugins/zsh-bat-plugin
#    zstyle :zplugins:plugins:bat plugin-file bat.plugin.zsh
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
# @description
#
# Return the context path for the named plugin. This is the specific Zstyle
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
