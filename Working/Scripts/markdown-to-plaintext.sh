#!/usr/bin/env bash

# Copyright 2021 Dan Cassidy

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# SPDX-License-Identifier: GPL-3.0-or-later

[[ $# -lt 1 ]] && { printf 'need file(s) to run on\n'; exit 1; }

set -e
for file in "${@}"; do
    # set up file variables
    input_file="${file}"
    temp_file="$(mktemp -p . "${input_file}.XXXXXXXXXX.tmp")"
    output_file="${input_file%%.*}.txt"
    cp "${input_file}" "${temp_file}"

    # remove anchor links
    sed -Ei 's|\[([^]]*)]\(#[^)]*\)|\1|g' "${temp_file}"
    # remove any remaining '(TOC)' lines and an extra newline
    perl -0777pi -e 's{\n\(TOC\)\n}{}g' "${temp_file}"
    # remove '**...**' and '__...__'
    perl -pi -e 'no warnings qw(experimental::vlb) ; s{(?<=^|\W)\*\*(.+?)\*\*(?=\W)}{${1}}g ; s{(?<=^|\W)__(.+?)__(?=\W)}{${1}}g' "${temp_file}"
    # strip markdown URLs
    sed -Ei 's|\[([^]]*)]\(([^)]*)\)|\1 (\2)|g' "${temp_file}"
    # convert indented code to have 4 space indentations
    perl -pi -e 's{^[ ]{4,}+(?!-|\* )(.*)$}{    ${1}}g' "${temp_file}"

    # if the contents of the temp and output files don't match, overwrite the output file with the temp file
    if [[ $(sha512sum "${output_file}" | cut -d ' ' -f 1) != $(sha512sum "${temp_file}" | cut -d ' ' -f 1) ]]; then
        mv "${temp_file}" "${output_file}"
    else
        rm "${temp_file}"
    fi
done
