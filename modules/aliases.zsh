# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name Module aliases
# @brief Manage plugin-defined aliases.
#
# @description
#
# This module provides the ability to define an alias within the scope of a plugin
# so that when the plugin is unloaded the alias is also removed. A plugin may call
# `@zplugins_define_alias` either during their `_init` function or during plugin
# sourcing.
#

#
# @description
#
# Define the alias (name and value) and add the alias name to the plugin's context
# to allow it's removal later.
#
# @example 
#    @zplugins_define_alias shdoc 'shdoc-all'\
#       'for file in *.zsh; do shdoc ${file} > ${file:r}.md; done'
#
# @arg $1 string The plugin's name.
# @arg $2 string The name of the alias.
# @arg $3 string The value to expand into.
#
# @see @zplugins_unalias_all
#
@zplugins_define_alias() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local alias_flag alias_name alias_value alias_list
    if [[ "${2}" =~ -[gs] ]]; then
        alias_flag="${2} "
        alias_name="${3}"
        shift 3
        alias_value="$*"
    else
        alias_flag=''
        alias_name="${2}"
        shift 2
        alias_value="$*"
    fi

    builtin zstyle -a $(@zplugins_plugin_context ${plugin_name}) aliases alias_list

    if [[ ${alias_list[(i)${fn_name}]} -gt ${#alias_list} ]]; then
        alias_list+=( $alias_name )
        .zplugins_plugin_ctx_set ${plugin_name} aliases ${alias_list}
    fi

    alias ${alias_flag}${alias_name}=${alias_value}
}
@zplugins_remember_fn zplugins @zplugins_define_alias

#
# @description
#
# Remove all aliases remembered for the named plugin. Usually this is only called by
# the plugin unload function.
#
# @arg $1 string The plugin's name.
#
# @see @zplugins_define_alias
# @see [@zplugins_plugin_unload](load.md#zpluginspluginunload)
#
@zplugins_unalias_all() {
    builtin emulate -L zsh

    local plugin_name="${1}"
    local alias_list alias_name
    builtin zstyle -a $(@zplugins_plugin_context ${plugin_name}) aliases alias_list

    for alias_name in ${alias_list[@]}; do
        unalias ${alias_name}
    done
}
@zplugins_remember_fn zplugins @zplugins_unalias_all
