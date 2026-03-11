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
.zplugins_field_style_name() {
    local field_name="${1}"

    printf '%s' "field_@_${field_name}"
}

# @internal
.zplugins_field_parser() {
    local plugin_name="${1}"
    local plugin_file_path="${2}"

    local header_state=top
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ ${header_state} == top && "${line}" =~ (-\*- mode: sh|^#!/) ]]; then
            header_state=top
        elif [[ ${header_state} == top && "${line}" =~ ^[[:space:]]*$ ]]; then
            header_state=space
        elif [[ ${header_state} =~ (top|space|within) && "${line}" =~ ^#[[:space:]]*@([[:alpha:]]+)[[:space:]]*:?[[:space:]]+([^[:space:]].*)$ ]]; then
            header_state=within
            .zplugins_plugin_ctx_set ${plugin_name} "$(.zplugins_field_style_name ${match[1]})" "${match[2]}"
        elif [[ ${header_state} == within && "${line}" =~ ^[[:space:]]*$ ]]; then
            break
        fi
    done < "${plugin_file_path}"
    return 0
}

#
# @arg $1 string The plugin's name.
# @stdout The value of the `@brief` header field.
#
@zplugins_short_description() {
    builtin emulate -L zsh

    .zplugins_plugin_ctx_get "${1}" "$(.zplugins_field_style_name brief)"
}
@zplugins_remember_fn zplugins @zplugins_plugin_short_description

#
# @arg $1 string The plugin's name.
# @stdout The value of the `@repository` header field.
#
@zplugins_plugin_repository() {
    builtin emulate -L zsh

    .zplugins_plugin_ctx_get "${1}" "$(.zplugins_field_style_name repository)"
}
@zplugins_remember_fn zplugins @zplugins_plugin_repository

#
# @arg $1 string The plugin's name.
# @stdout The value of the `Homepage` header field.
#
@zplugins_plugin_homepage() {
    builtin emulate -L zsh

    .zplugins_plugin_ctx_get "${1}" "$(.zplugins_field_style_name homepage)"
}
@zplugins_remember_fn zplugins @zplugins_plugin_homepage

#
# @arg $1 string The plugin's name.
# @stdout The value of the `Version` header field.
#
@zplugins_plugin_version() {
    builtin emulate -L zsh

    .zplugins_plugin_ctx_get "${1}" "$(.zplugins_field_style_name version)"
}
@zplugins_remember_fn zplugins @zplugins_plugin_version

#
# @arg $1 string The plugin's name.
# @stdout The value of the `License` header field.
#
@zplugins_license() {
    builtin emulate -L zsh

    .zplugins_plugin_ctx_get "${1}" "$(.zplugins_field_style_name license)"
}
@zplugins_remember_fn zplugins @zplugins_plugin_license
