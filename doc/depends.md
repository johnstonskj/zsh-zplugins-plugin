# Module depends

Plugin dependency management.

## Index

* [@zplugins_declare_plugin_dependencies](#zpluginsdeclareplugindependencies)
* [@zplugins_plugin_dependencies](#zpluginsplugindependencies)

### @zplugins_declare_plugin_dependencies

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (string): An array of names of the plugins that the named plugin depends on.

### @zplugins_plugin_dependencies

#### Arguments

* **$1** (string): The plugin's name.

#### Output on stdout

* The array of names of the plugins that the named plugin depends on.

