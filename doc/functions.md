# functions

Track plugin-defined functions.

## Overview

Add the function to the list tracked for the named plugin to allow
it's removal later.

## Index

* [@zplugins_remember_fn](#zpluginsrememberfn)
* [@zplugins_unfunction_all](#zpluginsunfunctionall)

### @zplugins_remember_fn

Add the function to the list tracked for the named plugin to allow
it's removal later.

#### Arguments

* **$1** (string): The plugin's name.
* **$2** (string): The name of the function to remember.

### @zplugins_unfunction_all

Remove all functions remembered for the named plugin.

#### Arguments

* **$1** (string): The plugin's name.

