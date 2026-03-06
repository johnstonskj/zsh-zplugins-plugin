# aliases

Track plugin-defined aliases.

## Overview

Define the alias (name and value) and add the alias name to
the list tracked for the named plugin to allow it's removal later.

## Index

* [@zplugins_define_alias](#zplugindefinealias)
* [@zplugins_unalias_all](#zpluginunaliasall)

### @zplugins_define_alias

Define the alias (name and value) and add the alias name to
the list tracked for the named plugin to allow it's removal later.

#### Example

```bash
@zplugins_define_alias shdoc shdoc-all 'for file in *.zsh; do shdoc ${file} > ${file:r}.md; done'
```

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (string): The name of the alias.
* **$3** (string): The value to expand into.

### @zplugins_unalias_all

Remove all aliases remembered for the named plugin.

#### Arguments

* **$1** (string): The plugin's name.

