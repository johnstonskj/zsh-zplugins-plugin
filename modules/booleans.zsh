# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name booleans
# @brief Boolean predicates.
#

#
# @description
#
# Test whether it's argument is a boolean _true_ value; values are `true`, `yes`, and `1`.
#
# @arg $1 string The value to test
#
# @exitcode 0 The value of `$1` **is** a truth value.
# @exitcode 1 The value of `$1` is **not** a truth value.
#
@boolean_is_true() {
    [[ "${1:l}" =~ ^(true|yes|1)$ ]]
}

#
# @description
#
# Test whether it's argument is a _truthy_ value, basically _not false_.
#
# @arg $1 string The value to test
#
# @exitcode 0 The value of `$1` **is** a _truthy_ value.
# @exitcode 1 The value of `$1` is **not** a _truthy_ value.
#
@boolean_is_truthy() {
    ! @boolean_is_false "${1}"
}

#
# @description
#
# Test whether it's argument is a boolean _falsity_ value; values are `false`, `no`, and `0`.
#
# @arg $1 string The value to test
#
# @exitcode 0 The value of `$1` **is** a falsity value.
# @exitcode 1 The value of `$1` is **not** a falsity value.
#
@boolean_is_false() {
    [[ "${1:l}" =~ ^(false|no|0)$ ]]
}

#
# @description
#
# Test whether it's argument is valid boolean value.
#
# @arg $1 string The value to test
#
# @exitcode 0 The value of `$1` **is** a boolean value.
# @exitcode 1 The value of `$1` is **not** a boolean value.
#
@boolean_is_valid() {
    @boolean_is_true "${1}" || @boolean_is_false "${1}"
}