# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name log
# @brief Simple logging capability to avoid dependencies.
#

###################################################################################################
# @section private
# @description
#
# Setup and truly private functions. These are not intended to be used by plugins directly###################################################################################################

ZPLUGINS_LOG=${ZPLUGINS_LOG:-1}

# @internal
.zplugins_log_level() {
    case ${ZPLUGINS_LOG} in
        0|off|OFF)
            print '0' ;;
        1|error|ERROR)
            print '1' ;;
        2|warning|WARNING)
            print '2' ;;
        3|info|INFO)
            print '3' ;;
        4|debug|DEBUG)
            print '4' ;;
        5|trace|TRACE)
            print '5' ;;
        *)
            print '1' ;;
    esac
}
# @zplugins_remember_fn zplugins .zplugins_log_level

# @internal
.zplugins_log() {
    local level=$1; shift
    if [[ $(.zplugins_log_level) -ge ${level} ]]; then
        local context="${ZPLUGINS[_CTX]}"
        if [[ -n "${1}" ]]; then
            context="${ZPLUGINS[_PLUGINS_CTX]}:${1}"
        fi
        shift

        local caller="${funcstack[2]}"
        if [[ "${caller}" == .zplugins_log_* ]]; then
            local caller="${funcstack[3]}"
        fi
        if [[ -n "${caller}" ]]; then
            caller=" $(basename ${caller}) ❱"
        fi

        echo "$(gdate -Ins) ❱ ${context} ❱${caller} $*"
    fi
}
# @zplugins_remember_fn zplugins .zplugins_log

###################################################################################################
# @section public
# @description Plugin-facing logging functions

# @internal
.zplugins_log_error() {
    local context="${1}"
    shift
    .zplugins_log 1 "${context}" "[error] $*"
}
# @zplugins_remember_fn zplugins .zplugins_log_error

# @internal
.zplugins_log_warning() {
    local context="${1}"
    shift
    .zplugins_log 2 "${context}" "[warning] $*"
}
# @zplugins_remember_fn zplugins .zplugins_log_warning

# @internal
.zplugins_log_info() {
    local context="${1}"
    shift
    .zplugins_log 3 "${context}" "[info] $*"
}
# @zplugins_remember_fn zplugins .zplugins_log_info

# @internal
.zplugins_log_debug() {
    local context="${1}"
    shift
    .zplugins_log 4 "${context}" "[debug] $*"
}
# @zplugins_remember_fn zplugins .zplugins_log_debug

# @internal
.zplugins_log_trace() {
    local context="${1}"
    shift
    .zplugins_log 5 "${context}" "[trace] $*"
}
# @zplugins_remember_fn zplugins .zplugins_log_trace

# @internal
.zplugins_logfmt_array() {
    local name=$1
    printf '%s' "( ${(P)name[*]} )"
}
# @zplugins_remember_fn zplugins .zplugins_logfmt_array

# @internal
.zplugins_logfmt_assoc_array() {
    local name=$1
    local -a out=()
    local key value

    if [[ -n "${(P)name[*]}" ]]; then
        for key in "${(@Pko)name}"; do
            value="${${(P)name}[$key]}"
            out+=("${key}: '${value}'")
        done
        printf '{ %s }' ${(j:, :)out}
    else
        printf '{}'
    fi
}
# @zplugins_remember_fn zplugins .zplugins_logfmt_assoc_array
