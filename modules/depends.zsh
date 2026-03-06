# -*- mode: sh; eval: (sh-set-shell "zsh") -*-

@zplugins_declare_plugin_dependencies() {
    local plugin_name="${1}"
    shift
    local -a dependencies=( "$*" )

    .zplugins_plugin_ctx_set ${plugin_name} dependencies ${dependencies}
}
@zplugins_remember_fn zplugins @zplugins_declare_plugin_dependencies

@zplugins_plugin_dependencies() {
    local plugin_name="${1}"

    .zplugins_plugin_ctx_get ${plugin_name} dependencies
}
@zplugins_remember_fn zplugins @zplugins_plugin_dependencies
