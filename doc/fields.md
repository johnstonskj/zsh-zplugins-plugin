# fields

Plugin state management functions.

## Overview

Plugin header fields are taken from structured comments in the plugin's main file, as shown in
the following example.

## Index

* [@zplugins_plugin_repository](#zpluginspluginrepository)
* [@zplugins_plugin_homepage](#zpluginspluginhomepage)
* [@zplugins_plugin_version](#zpluginspluginversion)
* [@zplugins_license](#zpluginslicense)

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

### @zplugins_license

#### Arguments

* **$1** (string): The plugin's name.

#### Output on stdout

* The value of the `License` header field.

