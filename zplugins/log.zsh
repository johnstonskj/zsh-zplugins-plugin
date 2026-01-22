# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name log
# @brief Simple logging capability to avoid dependencies.
#

# @internal
.zplugins_log() {
    if [[ -n "${ZPLUGINS_LOG}" ]]; then
        local context="${ZPLUGINS_CTX}"
        if [[ -n "${1}" ]]; then
            context="${ZPLUGINS_PLUGINS_CTX}:${1}"
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

# @internal
.zplugins_log_error() {
    local context="${1}"
    shift
    .zplugins_log "${context}" "[error] $*"
}

# @internal
.zplugins_log_warning() {
    local context="${1}"
    shift
    .zplugins_log "${context}" "[warning] $*"
}

# @internal
.zplugins_log_debug() {
    local context="${1}"
    shift
    .zplugins_log "${context}" "[debug] $*"
}

# @internal
.zplugins_log_trace() {
    local context="${1}"
    shift
    .zplugins_log "${context}" "[trace] $*"
}

# @internal
.zplugins_logfmt_array() {
    local name=$1
    echo "( ${(P)name[*]} )"
}

# @internal
.zplugins_logfmt_assoc_array() {
    local name=$1
    local -a out=()
    local key value

    for key in "${(@Pko)name}"; do
        value="${${(P)name}[$key]}"
        out+=("${key}: '${value}'")
    done
    printf '{ %s }' ${(j:, :)out}
}
