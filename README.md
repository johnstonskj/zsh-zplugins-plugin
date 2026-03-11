# Zsh Plugin `zplugins`

Zsh plugin to provide standard plugin functionality for plugin development.

[![Shell Workflow](https://github.com/johnstonskj/johnstonskj/zsh-zplugins/actions/workflows/shell.yml/badge.svg)](<https://github.com/johnstonskj/johnstonskj/zsh-zplugins/actions/workflows/shell.yml>)
[![GitHub stars](https://img.shields.io/github/stars/johnstonskj/zsh-zplugins-plugin.svg)](<https://github.com/johnstonskj/zsh-zplugins-plugin/stargazers>)

Complete Description...

## Installation

TBD

## Usage

TBD

### Miniml Plugin Skeleton

```bash
# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name foo
# @brief An example plugin
# @version 0.0.1
#

###################################################################################################
# @section lifecycle
# @description Plugin lifecycle functions.
#

## Plugin Lifecycle

foo_plugin_init() {
    builtin emulate -L zsh

    return 0
}
@zplugins_remember_fn foo foo_plugin_init

foo_plugin_unload() {
    builtin emulate -L zsh

    return 0
}
@zplugins_remember_fn foo foo_plugin_unload
```

## CLI Functions

These functions are intended for command-line use by humans, they produce Markdown formatted output
and will, by default, attempt to pipe it through a formatter to get the best visual output possible.
Formatters are tried in the following order:

* **[glow](https://github.com/charmbracelet/glow)** Glow is a terminal based markdown reader
  designed from the ground up to bring out the beauty—and power—of the CLI.
* **[bat](https://github.com/sharkdp/bat)** A cat(1) clone with syntax highlighting and Git
  integration.
* `${PAGER}` not really a formatter, but a nice to have, and if not set the `more` command will be
  used.

To avoid the use of an additional formatter and see only the raw Markdown set the environment
variable `ZPS_NO_FORMAT` to the value `1`.

### zps-context

This function will format the *context* for a loaded plugin. The context is a set of information
maintained by the plugin manager about each plugin, tracking metadata and state. Each section
includes a short introduction to describe how the particular data is set/managed.

```bash
❯ zps-context rust
# Zsh Plugin rust

Plugin source in file `rust.plugin.zsh`, in directory
`[zsh-rust-plugin](file:///Users/s0j0g7m/Projects/Config/local/share/zsh/plugins/zsh-rust-plugin)`.

## Declared Dependencies

*Dependencies are defined via a call to `@zplugins_declare_plugin_dependencies` during 
initialization.*

* `cargo`: Setup for the `cargo` package manager.
* `shlog`: Logging utility functions for shell scripts.

## Defined Functions

*Functions are may be tracked manually using `@zplugins_remember_fn`, or
`@zplugins_register_function_dir`. However, the plugin manager will automatically define/track
functions in the `functions` directory and a plugins `_init` and `_unload` functions.*

* `rust_plugin_unload`
* `rust_plugin_init`

## Saved Environment Variables

*Environment variables can be saved during initialization with a call to `@zplugins_envvar_save`
which will then restore their original value when the plugin is unloaded.*

* **`RUST_SRC_PATH`**: ``

## Header Fields

*Header fields are file-level [shdoc](https://github.com/reconquest/shdoc) annotations stored
during initialization for faster run-time lookup.*

* **brief**: Set environment variables for the Rust programming language.
* **license**: MIT AND Apache-2.0
* **name**: rust
* **repository**: https://gi
```

### zps-doc

This function wraps calls to the [shdoc](https://github.com/reconquest/shdoc) tool to produce
structured documentation for a plugin.

```bash
❯ zps-doc rust            
# Zsh Plugin : rust

# @brief: Set environment variables for the Rust programming language.

## Overview

* **repository**: : https://github.com/johnstonskj/zsh-rust-plugin
* **version**: : 0.1.1
* **license**: : MIT AND Apache-2.0

### Public variables

* `RUST_SRC_PATH`; path to rust source installed by rustup.

## Index

* [rust_plugin_init](#rustplugininit)
* [rust_plugin_unload](#rustpluginunload)

## Lifecycle

Plugin lifecycle functions.
See https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling

### rust_plugin_init

This function initializes the `RUST_SRC_PATH` variable.

_Function has no arguments._

### rust_plugin_unload

Called when the plugin is unloaded to clean up after itself.

_Function has no arguments._
```

### zps-loaded

This function shows a list of all loaded plugins along with their brief description and version number.

```bash
❯ zps-loaded            
# Loaded Plugins

| Name          | Description                                                              | Version |
| ------------- | ------------------------------------------------------------------------ | ------- |
| xdg           | Bootstrap/setup the XDG Base Directory environment variables.            | 0.1.1   |
| shlog         | Logging utility functions for shell scripts.                             |         |
| paths         | Simple functions for managing `PATH`, `MANPATH` and `FPATH`.             | 0.1.1   |
| bat           | Set `bat` as a cat replacement.                                          | 0.1.1   |
| brew          | Setup for the `brew` package manager.                                    | 0.1.1   |
| cargo         | Setup for the `cargo` package manager.                                   | 0.1.1   |
| completion    | Setup Zsh core completion.                                               | 0.1.1   |
| emacs         | Set initial Emacs environment.                                           | 0.1.1   |
| eza           | Set aliases for the `eza` command, a modern replacement for `ls`.        | 0.1.1   |
| fzf           | Integrate the fzf tool into Zsh.                                         | 0.1.1   |
| getopt        | Set the correct path for `get-opt` installed via Homebrew.               | 0.1.1   |
| git           | Set the path to the Git installed via Homebrew.                          | 0.1.1   |
| gnupg         | Set up environment variables for GnuPG.                                  | 0.1.1   |
| gsed          | Replace `sed`` with GNU sed (`gsed`).                                    | 0.1.1   |
| guile         | Set environment variables for the GNU Guile Scheme programming language. | 0.1.1   |
| hd            | Provide `hd` (hexdump) related alias(es).                                | 0.1.1   |
| history       | Configure Zsh core history functionality.                                | 0.1.1   |
| intelli_shell | Set the environment for IntelliShell completion.                         | 0.1.1   |
| kiro          | Set up environment when running inside AWS's Kiro IDE.                   | 0.1.1   |
| less          | Set the environment for the command `less`.                              | 0.1.1   |
| llvm          | Set build flag environment variables for LLVM.                           | 0.1.1   |
| mcfly         | Integrate the `mcfly` command history tool.                              | 0.1.1   |
| myip          | Provide `myip` alias to show external IP address.                        | 0.1.1   |
| nix           | Initialize THE Nix package manager                                       | 0.1.1   |
| openssh       | Set the OpenSSH environment.                                             | 0.1.1   |
| orbstack      | Set the environment for the OrbStack CLI.                                | 0.1.1   |
| racket        | Set environment variables for the Racket programming language.           | 0.1.1   |
| ruby          | Set environment variables for the Ruby programming language.             | 0.1.1   |
| rust          | Set environment variables for the Rust programming language.             | 0.1.1   |
| rvm           | Setup for the `rvm` package manager.                                     | 0.1.1   |
| starship      | Setup Starship prompt for Zsh shells.                                    | 0.1.1   |
| todo          | Provide `todo` alias to show `TODO` comments in files.                   | 0.1.1   |
| vim           | Provide alias `vi` for Vim.                                              | 0.1.1   |
| xcode         | Add Xcode command-line tools to path.                                    | 0.1.1   |
| zoxide        | Initialize `zoxide` shell integration.                                   | 0.1.1   |
```

## Module/Function Documentation

The [module and function documentation](./doc/index.md) was generated by
[shdoc](https://github.com/reconquest/shdoc).

## License(s)

The contents of this repository are made available under the following licenses:

### Apache-2.0

> ```text
> Copyright 2026 Simon Johnston <johnstonskj@gmail.com>
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
> Copyright 2026 Simon Johnston <johnstonskj@gmail.com>
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
