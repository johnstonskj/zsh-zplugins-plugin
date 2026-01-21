# -*- mode: sh; eval: (sh-set-shell "zsh") -*-

############################################################################
# Plugin State (zstyle) Functions
############################################################################

@zplugins_plugin_dir() {
    builtin emulate -L zsh

    local plugin_name="${1}"

    $(.zplugins_plugin_ctx_get plugin-dir)
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_plugin_dir

@zplugins_plugin_file() {
    builtin emulate -L zsh

    local plugin_name="${1}"

    $(.zplugins_plugin_ctx_get plugin-file)
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_plugin_file

@zplugin_plugin_functions_dir() {
    builtin emulate -L zsh

    local plugin_name="${1}"

    printf '%s/functions' $(.zplugins_plugin_ctx_get plugin-dir)
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugin_plugin_functions_dir

@zplugins_plugin_bin_dir() {
    builtin emulate -L zsh

    local plugin_name="${1}"

    printf '%s/bin' $(.zplugins_plugin_ctx_get plugin-dir)
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_plugin_bin_dir

############################################################################
# Plugin Header Fields
############################################################################

.zplugins_plugin_field() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local plugin_path="$(@zplugins_plugin_dir ${plugin_name})/$(@zplugins_plugin_file ${plugin_name})/"
    local field_name="${2}"

    local field_value=$(grep -m 1 -E "^#[ \\t]+${field_name}:" "${plugin_path}" | cut -d':' -f2-)
    if $?; then
        printf '%s' "${field_value//^[[:space:]]+|[[:space:]]+$//}"
    else
        printf ''
    fi
}
@zplugins_remember_fn ${PLUGIN[_NAME]} .zplugins_plugin_field

@zplugin_short_description() {
    builtin emulate -L zsh

    .zplugins_plugin_field "${1}" Description
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugin_plugin_short_description

@zplugins_plugin_repository() {
    builtin emulate -L zsh

    .zplugins_plugin_field "${1}" Repository
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_plugin_repository

@zplugins_plugin_homepage() {
    builtin emulate -L zsh

    .zplugins_plugin_field "${1}" Homepage
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_plugin_homepage

@zplugins_plugin_version() {
    builtin emulate -L zsh

    .zplugins_plugin_field "${1}" Version
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_plugin_version

@zplugin_license() {
    builtin emulate -L zsh

    .zplugins_plugin_field "${1}" License
}
@zplugins_remember_fn ${PLUGIN[_NAME]} @zplugins_plugin_license
