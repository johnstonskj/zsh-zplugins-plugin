# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# Name: foo
# Description: An example plugin
# Version: 0.0.1
#

############################################################################
# This should be loaded prior to evaluating this file.
############################################################################

source "zplugins.plugin.zsh"

############################################################################
# Plugin Setup
############################################################################

0="$(@zplugin_normalize_zero "$0")"

@zplugin_declare_global foo "$0"

############################################################################
# Plugin Lifecycle
############################################################################

foo_plugin_init() {
    builtin emulate -L zsh

    # This should be the LAST step.
    @zplugin_register foo
}
@zplugin_remember_fn foo foo_plugin_init

echo "FOO(plugin global): ${(kv)FOO}"

foo_plugin_unload() {
    builtin emulate -L zsh

    # This should be the FIRST step.
    @zplugin_unregister foo

    unfunction foo_plugin_unload
}
@zplugin_remember_fn foo foo_plugin_unload

############################################################################
# Plugin Public Things
############################################################################

############################################################################
# Plugin Initialization
############################################################################

echo "REGISTERED: ${ZPLUGINS[_PLUGINS]}"
echo "FOO(plugin global): ${(kv)FOO}"

foo_plugin_init
 
echo "FOO(plugin global): ${(kv)FOO}"
echo "REGISTERED: ${ZPLUGINS[_PLUGINS]}"
 
foo_plugin_unload
 
echo "FOO(plugin global): ${(kv)FOO}"
echo "REGISTERED: ${ZPLUGINS[_PLUGINS]}"
