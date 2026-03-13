# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name Module errors
# @brief Generic definitions for exit codes and predicates.
# 
# @description
# 
# |   | Constant             | Description                        | Predicate                  |
# |---|----------------------|------------------------------------|----------------------------|
# | 0 | `EC_SUCCESS`         | All good.                          | `@is_success`              |
# | 1 | `EC_ERROR`           | An unspecified error occurred.     | `@is_error`                |
# | 2 | `EC_ARG_ERROR`       | Incorrect arguments provided.      | `@is_argument_error`       |
# | 3 | `EC_EXEC_ERROR`      | Execution of sub-process failed.   | `@is_execution_error`      |
# | 4 | `EC_EXISTS_ERROR`    | File system entity already exists. | `@is_already_exists_error` |
# | 5 | `EC_NOT_FOUND_ERROR` | File system entity not found.      | `@is_not_found_error`      |
#
# @example
#    typeset -gi EC_SUCCESS
#    typeset -gi EC_ERROR
#
#    example_fn() {
#        if some_other_thing; then
#            return ${EC_SUCCESS}
#        else
#            return ${EC_ERROR}
#        fi
#    }
# 

typeset -gir EC_SUCCESS=0
typeset -gir EC_ERROR=1
typeset -gir EC_ARG_ERROR=2
typeset -gir EC_EXEC_ERROR=3
typeset -gir EC_EXISTS_ERROR=4
typeset -gir EC_NOT_FOUND_ERROR=5

#
# @description Test whether it's argument equals `EC_SUCCESS`.
#
# @arg $1 int The value to test
#
# @exitcode 0 The value of `$1` **is** equal to `EC_SUCCESS`.
# @exitcode 1 The value of `$1` is **not** equal to `EC_SUCCESS`.
#
@is_success() {
    local -i exit_code=${1}
    [[ ${exit_code} -eq ${EC_SUCCESS} ]]
}

#
# @description Test whether it's argument **does not** equal `EC_SUCCESS`.
#
# @arg $1 int The value to test
#
# @exitcode 0 The value of `$1` is **not** equal to `EC_SUCCESS`.
# @exitcode 1 The value of `$1` **is** equal to `EC_SUCCESS`.
#
@is_not_success() {
    local -i exit_code=${1}
    [[ ${exit_code} -ne ${EC_SUCCESS} ]]
}

#
# @description Test whether it's argument equals `EC_ERROR`.
#
# @arg $1 int The value to test
#
# @exitcode 0 The value of `$1` **is** equal to `EC_ERROR`.
# @exitcode 1 The value of `$1` is **not** equal to `EC_ERROR`.
#
@is_error() {
    local -i exit_code=${1}
    [[ ${exit_code} -eq ${EC_ERROR} ]]
}

#
# @description Test whether it's argument equals `EC_ARG_ERROR`.
#
# @arg $1 int The value to test
#
# @exitcode 0 The value of `$1` **is** equal to `EC_ARG_ERROR`.
# @exitcode 1 The value of `$1` is **not** equal to `EC_ARG_ERROR`.
#
@is_argument_error() {
    local -i exit_code=${1}
    [[ ${exit_code} -eq ${EC_ARG_ERROR} ]]
}

#
# @description Test whether it's argument equals `EC_EXEC_ERROR`.
#
# @arg $1 int The value to test
#
# @exitcode 0 The value of `$1` **is** equal to `EC_EXEC_ERROR`.
# @exitcode 1 The value of `$1` is **not** equal to `EC_EXEC_ERROR`.
#
@is_execution_error() {
    local -i exit_code=${1}
    [[ ${exit_code} -eq ${EC_EXEC_ERROR} ]]
}

#
# @description Test whether it's argument equals `EC_EXISTS_ERROR`.
#
# @arg $1 int The value to test
#
# @exitcode 0 The value of `$1` **is** equal to `EC_EXISTS_ERROR`.
# @exitcode 1 The value of `$1` is **not** equal to `EC_EXISTS_ERROR`.
#
@is_already_exists_error() {
    local -i exit_code=${1}
    [[ ${exit_code} -eq ${EC_EXISTS_ERROR} ]]
}

#
# @description Test whether it's argument equals `EC_NOT_FOUND_ERROR`.
#
# @arg $1 int The value to test
#
# @exitcode 0 The value of `$1` **is** equal to `EC_NOT_FOUND_ERROR`.
# @exitcode 1 The value of `$1` is **not** equal to `EC_NOT_FOUND_ERROR`.
#
@is_not_found_error() {
    local -i exit_code=${1}
    [[ ${exit_code} -eq ${EC_NOT_FOUND_ERROR} ]]
}
