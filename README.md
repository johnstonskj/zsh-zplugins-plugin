# Zsh Plugin `zplugins`

Zsh plugin to provide standard plugin functionality for plugin development.

[![Shell Workflow](https://github.com/johnstonskj/johnstonskj/zsh-zplugins/actions/workflows/shell.yml/badge.svg)](<https://github.com/johnstonskj/johnstonskj/zsh-zplugins/actions/workflows/shell.yml>)
[![GitHub stars](https://img.shields.io/github/stars/johnstonskj/zsh-zplugins-plugin.svg)](<https://github.com/johnstonskj/zsh-zplugins-plugin/stargazers>)

Complete Description...

## Installation

TBD

### Sheldon

```bash
❱ sheldon add johnstonskj/zsh-zplugin-plugin
```

## Usage

TBD

```bash
#
# Name: foo
# Description: An example plugin
# Version: 0.0.1
# License: MIT
#

## Plugin Setup

0="$(@zplugin_normalize_zero "$0")"

@zplugin_declare_global foo "$0" aliases functions bin_dir function_dir

## Plugin Lifecycle

foo_plugin_init() {
    builtin emulate -L zsh

    @zplugin_register foo
}
@zplugin_remember_fn foo foo_plugin_init

foo_plugin_unload() {
    builtin emulate -L zsh

    @zplugin_unfunction_all foo
    @zplugin_unalias_all foo
    @zplugin_unregister foo

    unset FOO

    unfunction foo_plugin_unload
}
@zplugin_remember_fn foo foo_plugin_unload

## Plugin Public Things

## Plugin Initialization

foo_plugin_init

true
```

### File Header & Header Fields

```bash
#
# Name: PINAME
# Description: ONE_LINE_DESCRIPTION
# Repository: URL
# Homepage: URL
# Version: SEMVER
# License: LICENSE_EXPR
#
```

## Functions

### Plugin Global State

**`function @zplugin_normalize_zero ${0}`**

Normalize the plugin path from the top-level `${0}` as per the standard
[Zero Handling](https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling).

**`function @zplugin_declare_global <PINAME> <DIR> [FLAGS]`**

[Standard Plugins Hash](https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash)

Flags:

* `aliases`
* `bin_dir`
* `function_dir`
* `functions`
* `save <VARNAME>`

Given a plugin in the file `/home/user/zsh/zsh-myplugin-plugin/myplugin.plugin.zsh`,
the call pattern below,

```bash
0=@zplugin_normalize_zero "${0}"
@zplugin_declare_global \
        myplugin \      # plugin name
        "${0}" \        # _DIR
        aliases \       # _ALIASES
        functions \     # _FUNCTIONS
        function_dir \  # add to fpath
        save MYHOME     # _OLD_MYHOME
```

results in the logical equivalent below.

```bash
declare -gA MYPLUGIN
MYPLUGIN[_PLUGIN_DIR]="/home/user/zsh/zsh-myplugin-plugin"
MYPLUGIN[_PLUGIN_FILE]="myplugin.plugin.zsh"
MYPLUGIN[_ALIASES]=''
MYPLUGIN[_FUNCTIONS]=''
MYPLUGIN[_FNS_DIR]="/home/user/zsh/zsh-myplugin-plugin/functions"
MYPLUGIN[_OLD_MYHOME]="${MYHOME}"
```

**`@zplugin_save_global <PINAME> <VARNAME>`**

Save the state of the variable `VARNAME` in the global state variable
`_OLD_VARNAME`.

**`@zplugin_restore_global <PINAME> <VARNAME>`**

Restore the state of the variable `VARNAME` from the global state variable
`_OLD_VARNAME`.

### Plugin Runtime State

**`@zplugin_plugin_dir <PINAME>`**

Returns the value of the global state variable `_PLUGIN_DIR`.

**`@zplugin_plugin_file <PINAME>`**

Returns the value of the global state variable `_PLUGIN_FILE`.

**`@zplugin_functions_dir <PINAME>`**

Returns the value of the global state variable `_FNS_DIR`.

**`@zplugin_bin_dir <PINAME>`**

Returns the value of the global state variable `_BIN_DIR`.

**`@zplugin_short_description <PINAME>`**

Returns the content of the header with the prefix `Description:`. By convention
this is a single-line description with more details as free-form text after all
the header fields. 

The following are similarly defined for header fields.

1. **`@zplugin_repository <PINAME>`**; returns the content of the header field
   `Repository`.
1. **`@zplugin_homepage <PINAME>`**; returns the content of the header field
   `Homepage`.
1. **`@zplugin_version <PINAME>`**; returns the content of the header field
   `Version`.
1. **`@zplugin_license <PINAME>`**; returns the content of the header field
   `License`.

### Plugin Function & Alias Tracking

**`@zplugin_remember_fn <PINAME> <FNNAME>`**

Add `FNNAME` to the global state variable `_FUNCTIONS`.

**`@zplugin_unfunction_all <PINAME>`**

Remove all functions listed in the global state variable `_FUNCTIONS`.

**`@zplugin_define_alias <PINAME> <ALIAS> <DEFN>`**

Add `ALIAS` to the global state variable `_ALIASES`.

**`@zplugin_unalias_all <PINAME>`**

Remove all aliases listed in the global state variable `_ALIASES`.

### Plugin Registration

**`@zplugin_register <PINAME>`**

**`@zplugin_unregister <PINAME>`**

**`@zplugin_is_registered <PINAME>`**

## Environment Variables

* `ZPLUGINS`; the global state variable for the `zplugin` plugin itself.
* `ZPLUGINS_USE_AS_MANAGER`; if set *before* the plugin is loaded will force it
  to behave like a plugin manager.


## License(s)

The contents of this repository are made available under the following
licenses:

### Apache-2.0

> ```text
> Copyright 2025 Simon Johnston <johnstonskj@gmail.com>
> 
> Licensed under the Apache License, Version 2.0 (the "License");
> you may not use this file except in compliance with the License.
> You may obtain a copy of the License at
> 
>     http://www.apache.org/licenses/LICENSE-2.0
> 
> Unless required by applicable law or agreed to in writing, software
> distributed under the License is distributed on an "AS IS" BASIS,
> WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
> See the License for the specific language governing permissions and
> limitations under the License.
> ```

See the enclosed file [LICENSE-Apache](https://github.com/johnstonskj/zsh-zplugin-plugin/blob/main/LICENSE-Apache).

### MIT

> ```text
> Copyright 2025 Simon Johnston <johnstonskj@gmail.com>
> 
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the “Software”), to deal
> in the Software without restriction, including without limitation the rights to
> use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
> the Software, and to permit persons to whom the Software is furnished to do so,
> subject to the following conditions:
> 
> The above copyright notice and this permission notice shall be included in all
> copies or substantial portions of the Software.
> 
> THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
> INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
> PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
> HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
> OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
> SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
> ```

See the enclosed file [LICENSE-MIT](https://github.com/johnstonskj/zsh-zplugin-plugin/blob/main/LICENSE-MIT).

## Changes

TBD
