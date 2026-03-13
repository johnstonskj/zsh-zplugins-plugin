# Module aliases

Manage plugin-defined aliases.

## Overview

This module provides the ability to define an alias within the scope of a plugin
so that when the plugin is unloaded the alias is also removed. A plugin may call
`@zplugins_define_alias` either during their `_init` function or during plugin
sourcing.

## Index

* [@zplugins_define_alias](#zpluginsdefinealias)
* [@zplugins_unalias_all](#zpluginsunaliasall)

### @zplugins_define_alias

Define the alias (name and value) and add the alias name to the plugin's context
to allow it's removal later.

#### Example

```bash
@zplugins_define_alias shdoc 'shdoc-all'\
   'for file in *.zsh; do shdoc ${file} > ${file:r}.md; done'
```

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (string): The name of the alias.
* **$3** (string): The value to expand into.

#### See also

* [@zplugins_unalias_all](#zpluginsunaliasall)

### @zplugins_unalias_all

Remove all aliases remembered for the named plugin. Usually this is only called by
the plugin unload function.

#### Arguments

* **$1** (string): The plugin's name.

#### See also

* [@zplugins_define_alias](#zpluginsdefinealias)
* [@zplugins_plugin_unload](load.md#zpluginspluginunload)

