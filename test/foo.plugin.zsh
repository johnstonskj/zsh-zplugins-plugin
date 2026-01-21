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

typeset -A PLUGIN
PLUGIN[_PATH]="$(@zplugins_normalize_zero "$0")"
PLUGIN[_NAME]="${${PLUGIN[_PATH]:t}%%.*}"
PLUGIN[_CONTEXT]="$(@zplugins_plugin_context ${PLUGIN[_NAME]})"

############################################################################
# Plugin Lifecycle
############################################################################

foo_plugin_init() {
    builtin emulate -L zsh

    # This should be the LAST step.
    @zplugin_register foo ${PLUGIN[_PATH]}
}
@zplugins_remember_fn foo foo_plugin_init

foo_plugin_unload() {
    builtin emulate -L zsh

    # This should be the FIRST step.
    @zplugin_unregister foo

    # These should be the LAST steps.
    unset PLUGIN
}
@zplugins_remember_fn foo foo_plugin_unload

############################################################################
# Plugin Public Things
############################################################################

############################################################################
# Plugin Initialization
############################################################################

echo
echo ">> before init"
echo ">> >> REGISTERED: $(@zplugins_all_plugin_names)"
echo ">> >> plugin styles: $(@zplugins_plugin_context_data ${PLUGIN[_NAME]})"

foo_plugin_init

echo
echo ">> after init, before unload"
echo ">> >> REGISTERED: $(@zplugins_all_plugin_names)"
echo ">> >> plugin styles: $(@zplugins_plugin_context_data ${PLUGIN[_NAME]})"

foo_plugin_unload

echo
echo ">> after unload"
echo ">> >> REGISTERED: $(@zplugins_all_plugin_names)"
echo ">> >> plugin styles: $(@zplugins_plugin_context_data ${PLUGIN[_NAME]})"
