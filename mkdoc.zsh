#!/usr/bin/env zsh # -*- mode: sh; eval: (sh-set-shell "zsh") -*-

if ! command -v shdoc 2>&1 >/dev/null; then
    echo "shdoc not installed, go to https://github.com/reconquest/shdoc"
    exit 1
fi

INPUT_PATH=${${PWD:-.}:P}
OUTPUT_PATH=${INPUT_PATH}/doc

shdoc ${INPUT_PATH}/zplugins.plugin.zsh > ${OUTPUT_PATH}/index.md

for file in ${INPUT_PATH}/zplugins/*.zsh; do
    shdoc ${file} > ${OUTPUT_PATH}/${${file:t}:r}.md
done