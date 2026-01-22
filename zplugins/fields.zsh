# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name fields
# @brief Plugin state management functions.
#

#
# @arg $1 string The plugin's name.
#
@zplugins_plugin_dir() {
    builtin emulate -L zsh

    local plugin_name="${1}"

    $(.zplugins_plugin_ctx_get plugin-dir)
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_plugin_dir

#
# @arg $1 string The plugin's name.
#
@zplugins_plugin_file() {
    builtin emulate -L zsh

    local plugin_name="${1}"

    $(.zplugins_plugin_ctx_get plugin-file)
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_plugin_file

#
# @arg $1 string The plugin's name.
#
@zplugin_plugin_functions_dir() {
    builtin emulate -L zsh

    local plugin_name="${1}"

    printf '%s/functions' $(.zplugins_plugin_ctx_get plugin-dir)
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugin_plugin_functions_dir

#
# @arg $1 string The plugin's name.
#
@zplugins_plugin_bin_dir() {
    builtin emulate -L zsh

    local plugin_name="${1}"

    printf '%s/bin' $(.zplugins_plugin_ctx_get plugin-dir)
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_plugin_bin_dir

############################################################################
# @section headers
# @brief Plugin header fields
#
# @description
#
# ```bash
# #
# # @name PINAME
# # @description ONE_LINE_DESCRIPTION
# # @repository URL
# # @homepage URL
# # @version SEMVER
# # @license LICENSE_EXPR
# #
# ```


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
@zplugins_remember_fn ${PLUGIN[_NAME]} .zplugins_plugin_field

#
# @arg $1 string The plugin's name.
# @stdout The value of the `@brief` header field.
#
@zplugin_short_description() {
    builtin emulate -L zsh

    .zplugins_plugin_field "${1}" brief
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugin_plugin_short_description

#
# @arg $1 string The plugin's name.
# @stdout The value of the `@repository` header field.
#
@zplugins_plugin_repository() {
    builtin emulate -L zsh

    .zplugins_plugin_field "${1}" repository
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_plugin_repository

#
# @arg $1 string The plugin's name.
# @stdout The value of the `Homepage` header field.
#
@zplugins_plugin_homepage() {
    builtin emulate -L zsh

    .zplugins_plugin_field "${1}" homepage
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_plugin_homepage

#
# @arg $1 string The plugin's name.
# @stdout The value of the `Version` header field.
#
@zplugins_plugin_version() {
    builtin emulate -L zsh

    .zplugins_plugin_field "${1}" version
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_plugin_version

#
# @arg $1 string The plugin's name.
# @stdout The value of the `License` header field.
#
@zplugin_license() {
    builtin emulate -L zsh

    .zplugins_plugin_field "${1}" license
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_plugin_license
