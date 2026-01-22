# fields

Plugin header fields

## Index

* [@zplugins_plugin_dir](#zpluginsplugindir)
* [@zplugins_plugin_file](#zpluginspluginfile)
* [@zplugin_plugin_functions_dir](#zpluginpluginfunctionsdir)
* [@zplugins_plugin_bin_dir](#zpluginspluginbindir)
* [@zplugin_short_description](#zpluginshortdescription)
* [@zplugins_plugin_repository](#zpluginspluginrepository)
* [@zplugins_plugin_homepage](#zpluginspluginhomepage)
* [@zplugins_plugin_version](#zpluginspluginversion)
* [@zplugin_license](#zpluginlicense)

### @zplugins_plugin_dir

#### Arguments

* **$1** (string): The plugin's name.

### @zplugins_plugin_file

#### Arguments

* **$1** (string): The plugin's name.

### @zplugin_plugin_functions_dir

#### Arguments

* **$1** (string): The plugin's name.

### @zplugins_plugin_bin_dir

#### Arguments

* **$1** (string): The plugin's name.

## headers

```bash

# @name PINAME
# @description ONE_LINE_DESCRIPTION
# @repository URL
# @homepage URL
# @version SEMVER
# @license LICENSE_EXPR

```

### @zplugin_short_description

#### Arguments

* **$1** (string): The plugin's name.

#### Output on stdout

* The value of the `@brief` header field.

### @zplugins_plugin_repository

#### Arguments

* **$1** (string): The plugin's name.

#### Output on stdout

* The value of the `@repository` header field.

### @zplugins_plugin_homepage

#### Arguments

* **$1** (string): The plugin's name.

#### Output on stdout

* The value of the `Homepage` header field.

### @zplugins_plugin_version

#### Arguments

* **$1** (string): The plugin's name.

#### Output on stdout

* The value of the `Version` header field.

### @zplugin_license

#### Arguments

* **$1** (string): The plugin's name.

#### Output on stdout

* The value of the `License` header field.

