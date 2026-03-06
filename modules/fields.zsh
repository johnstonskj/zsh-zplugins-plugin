# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name fields
# @brief Plugin state management functions.
#
# @description
#
# Plugin header fields are taken from structured comments in the plugin's main file, as shown in
# the following example.
#
# @example
#    #
#    # @name PINAME
#    # @description ONE_LINE_DESCRIPTION
#    # @repository URL
#    # @homepage URL
#    # @version SEMVER
#    # @license LICENSE_EXPR
#    #
#

# @internal
.zplugins_plugin_field() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local plugin_path="$(@zplugins_plugin_dir ${plugin_name})/$(@zplugins_plugin_file ${plugin_name})/"
    local field_name="${2}"

    local field_value=$(grep -m 1 -E "^#[ \\t]+@${field_name}" "${plugin_path}" | cut -d':' -f2-)
    if $?; then
        printf '%s' "${field_value//^[[:space:]]+|[[:space:]]+$//}"
    else
        printf ''
    fi
}
@zplugins_remember_fn zplugins .zplugins_plugin_field

#
# @arg $1 string The plugin's name.
# @stdout The value of the `@brief` header field.
#
@zplugins_short_description() {
    builtin emulate -L zsh

    .zplugins_plugin_field "${1}" brief
}
@zplugins_remember_fn zplugins @zplugins_plugin_short_description

#
# @arg $1 string The plugin's name.
# @stdout The value of the `@repository` header field.
#
@zplugins_plugin_repository() {
    builtin emulate -L zsh

    .zplugins_plugin_field "${1}" repository
}
@zplugins_remember_fn zplugins @zplugins_plugin_repository

#
# @arg $1 string The plugin's name.
# @stdout The value of the `Homepage` header field.
#
@zplugins_plugin_homepage() {
    builtin emulate -L zsh

    .zplugins_plugin_field "${1}" homepage
}
@zplugins_remember_fn zplugins @zplugins_plugin_homepage

#
# @arg $1 string The plugin's name.
# @stdout The value of the `Version` header field.
#
@zplugins_plugin_version() {
    builtin emulate -L zsh

    .zplugins_plugin_field "${1}" version
}
@zplugins_remember_fn zplugins @zplugins_plugin_version

#
# @arg $1 string The plugin's name.
# @stdout The value of the `License` header field.
#
@zplugins_license() {
    builtin emulate -L zsh

    .zplugins_plugin_field "${1}" license
}
@zplugins_remember_fn zplugins @zplugins_plugin_license
