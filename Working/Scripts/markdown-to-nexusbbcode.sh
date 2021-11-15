#!/usr/bin/env bash

[[ $# -lt 1 ]] && { printf 'need file to run on\n'; exit 1; }

set -e
for file in "${@}"; do
    input_file="${file}"
    temp_file="$(mktemp -p . "${input_file}.XXXXXXXXXX.tmp")"
    output_file="${input_file%%.*}.nexusbbcode"

    tr '\n' '\f' < "${input_file}" > "${temp_file}"

    # convert '===' headers to [size=6]...[/size]
    sed -Ei 's|([^\f]*)\f={3,}\f|[size=6]\1[/size]\f|g' "${temp_file}"
    # convert '---' headers to [size=5]...[/size]
    sed -Ei 's|([^\f]*)\f-{3,}\f|[size=5]\1[/size]\f|g' "${temp_file}"
    # remove anchor links
    sed -Ei 's|\[([^]]*)]\(#[^)]*\)|\1|g' "${temp_file}"
    # convert **...** and __...__ to [b]...[/b]
    sed -Ei -e 's|\*\*([^(\*\*)\f]+)\*\*|[b]\1[/b]|g' -e 's|__([^(__)\f]+)__|[b]\1[/b]|g' "${temp_file}"
    # convert *...* and _..._ to [i]...[/i]
    sed -Ei -e 's|\*([^\*\f]+)\*|[i]\1[/i]|g' -e 's|_([^_\f]+)_|[i]\1[/i]|g' "${temp_file}"
    # convert markdown URLs to BBCode URLs
    sed -Ei 's|\[([^]]*)]\(([^)]*)\)|[url=\2]\1[/url]|g' "${temp_file}"
    # convert `...` to [font=Courier New][color=#rrggbb]...[/color][/font]
    sed -Ei 's|`([^`]*)`|[font=Courier New][color=#6d9eeb]\1[/color][/font]|g' "${temp_file}"
    # convert indented code to [font=Courier New][color=#rrggbb]...[/color][/font]
    sed -Ei 's|\f[ ]{4,}([^-][^\f]*)\f|\f    [font=Courier New][color=#6d9eeb]\1[/color][/font]\f|g' "${temp_file}"

    tr '\f' '\n' < "${temp_file}" > "${output_file}"
    rm "${temp_file}"
done