# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name depends
# @brief Plugin dependency management.
#
# This module provides for plgins to declare dependencies which should be loaded prior
# to the primary plugin. This list of dependencies is stored in the plugin's context
# with the key `dependencies`.
#

#
# Called by a plugin during loading, prior to initialization, to declare dependencies.
#
# @arg $1 string The plugin's name.
# @arg $2 string An array of names of the plugins that the named plugin depends on.
#
@zplugins_declare_plugin_dependencies() {
    local plugin_name="${1}"
    shift
    local -a dependencies=( "$*" )

    .zplugins_plugin_ctx_set ${plugin_name} dependencies ${dependencies}
}
@zplugins_remember_fn zplugins @zplugins_declare_plugin_dependencies

#
# Retrieve the array of dependencies declared for the provided plugin.
#
# @arg $1 string The plugin's name.
# @stdout The array of names of the plugins that the named plugin depends on.
#
@zplugins_plugin_dependencies() {
    local plugin_name="${1}"

    .zplugins_plugin_ctx_get ${plugin_name} dependencies
}
@zplugins_remember_fn zplugins @zplugins_plugin_dependencies
