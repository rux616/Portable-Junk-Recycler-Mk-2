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

[[ $# -lt 1 ]] && { printf 'need file to run on\n'; exit 1; }

set -e
for file in "${@}"; do
    # set up file variables
    input_file="${file}"
    temp_file="$(mktemp -p . "${input_file}.XXXXXXXXXX.tmp")"
    temp_file2="$(mktemp -p . "${input_file}.XXXXXXXXXX.tmp2")"
    output_file="${input_file%%.*}.txt"

    # convert \n to \f for ease of use with sed
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

    # convert \f back to \n
    tr '\f' '\n' < "${temp_file}" > "${temp_file2}"

    # if the contents of the files don't match, overwrite the current output file
    if [[ $(sha512sum "${output_file}" | cut -d ' ' -f 1) != $(sha512sum "${temp_file2}" | cut -d ' ' -f 1) ]]; then
        mv "${temp_file2}" "${output_file}"
    else
        rm "${temp_file2}"
    fi
    rm "${temp_file}"
done