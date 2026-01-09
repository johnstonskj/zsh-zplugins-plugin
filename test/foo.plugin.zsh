# -*- mode: sh; eval: (sh-set-shell "zsh") -*-


############################################################################
# Standard Setup Behavior
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

############################################################################
# This should be loaded prior to evaluating this file.
############################################################################

source "zplugins.plugin.zsh"

############################################################################
# Actual Plugin Code
############################################################################

@zplugin_declare_global foo "$0" aliases functions bin_dir function_dir

echo "FOO(plugin global): ${(kv)FOO}"

foo_plugin_init() {
    builtin emulate -L zsh

    @zplugin_register foo
}
@zplugin_remember_fn foo foo_plugin_init

echo "FOO(plugin global): ${(kv)FOO}"

foo_plugin_unload() {
    builtin emulate -L zsh

    @zplugin_unfunction_all foo
    @zplugin_unalias_all foo
    @zplugin_unregister foo

    unset FOO

    unfunction foo_plugin_unload
}
@zplugin_remember_fn foo foo_plugin_unload

echo "REGISTERED: ${ZPLUGINS[_PLUGINS]}"
echo "FOO(plugin global): ${(kv)FOO}"

foo_plugin_init
 
echo "FOO(plugin global): ${(kv)FOO}"
echo "REGISTERED: ${ZPLUGINS[_PLUGINS]}"
 
foo_plugin_unload
 
echo "FOO(plugin global): ${(kv)FOO}"
echo "REGISTERED: ${ZPLUGINS[_PLUGINS]}"
