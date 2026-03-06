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
# Plugin Lifecycle
############################################################################

foo_plugin_init() {
    builtin emulate -L zsh

    echo
    echo ">> after init, before unload"
    echo ">> >> REGISTERED: $(@zplugins_all_plugin_names)"
    echo ">> >> plugin styles: $(@zplugins_plugin_context_data foo)"
}

foo_plugin_unload() {
    builtin emulate -L zsh

    echo foo_plugin_unload
}

############################################################################
# Plugin Public Things
############################################################################

############################################################################
# Plugin Initialization
############################################################################

echo
echo ">> before init"
echo ">> >> REGISTERED: $(@zplugins_all_plugin_names)"
echo ">> >> plugin styles: $(@zplugins_plugin_context_data foo)"
