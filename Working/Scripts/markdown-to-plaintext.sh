#!/usr/bin/env bash

[[ $# -lt 1 ]] && { printf 'need file to run on\n'; exit 1; }

set -e
for file in "${@}"; do
    input_file="${file}"
    temp_file="$(mktemp -p . "${input_file}.XXXXXXXXXX.tmp")"
    output_file="${input_file%%.*}.txt"

    tr '\n' '\f' < "${input_file}" > "${temp_file}"

    # remove anchor links
    sed -Ei 's|\[([^]]*)]\(#[^)]*\)|\1|g' "${temp_file}"
    # convert **...** to *...*
    sed -Ei 's|\*\*([^(\*\*)\f]+)\*\*|*\1*|g' "${temp_file}"
    # convert __...__ to _..._
    sed -Ei 's|__([^(__)\f]+)__|_\1_|g' "${temp_file}"
    # strip markdown URLs
    sed -Ei 's|\[([^]]*)]\(([^)]*)\)|\1 (\2)|g' "${temp_file}"
    # convert indented code to have 4 space indentations
    sed -Ei 's|\f[ ]{4,}([^-][^\f]*)\f|\f    \1\f|g' "${temp_file}"

    tr '\f' '\n' < "${temp_file}" > "${output_file}"
    rm "${temp_file}"
done