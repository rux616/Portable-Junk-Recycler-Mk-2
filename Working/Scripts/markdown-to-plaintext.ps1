# Copyright 2023 Dan Cassidy

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

[CmdletBinding()]
param (
    [Parameter(Mandatory, ValueFromRemainingArguments, ValueFromPipeline)]
    [string[]] $Files
)

begin {
    $line_ending = "`r`n"
}

process {
    $Files | ForEach-Object {
        $file_in = Get-Item $_ -ErrorAction Stop
        $file_out = "$($file_in.Directory)\$($file_in.BaseName).txt"
        if (-not (Test-Path -LiteralPath $file_out)) { New-Item $file_out | Out-Null }
        $file_out = Get-Item -LiteralPath $file_out

        $content = Get-Content -LiteralPath $file_in -Raw

        # remove anchor links
        # "[foo bar](#foo-bar)" -> "foo bar"
        $content = $content -replace "\[(.*?)\]\(#.*?\)", "`$1"
        # remove any remaining '(TOC)' lines and an extra line
        # "$line_ending(TOC)$line_ending" -> ""
        $content = $content -replace "$line_ending\(TOC\)$line_ending", ""
        # remove '<details><summary>...</summary>' and an extra line
        # "$line_ending<details><summary>Click here to show more</summary>$line_ending" -> ""
        $content = $content -replace "$line_ending<details>.*?</summary>$line_ending", ""
        # remove '</details>' and line
        # "$line_ending</details>$line_ending" -> ""
        $content = $content -replace "$line_ending</details>$line_ending", ""
        # remove '**...**'
        # "**foo bar baz**" -> ""
        $content = $content -replace "(?<=^|\W)\*\*(.+?)\*\*(?=\W)", "`$1"
        # remove '__...__'
        # "__foo bar baz__" -> ""
        $content = $content -replace "(?<=^|\W)__(.+?)__(?=\W)", "`$1"
        # strip markdown URLs
        # "[foo bar](https://foo.com/bar)" -> "foo bar (https://foo.com/bar)"
        $content = $content -replace "\[(.*?)\](\(.*?\))", "`$1 `$2"
        # convert indented code to have 4 space indentations
        # "      foo = bar + baz" -> "    foo = bar + baz"
        $content = $content -replace "($line_ending*)[ ]{5,}(?! *-|\* )(.*?)($line_ending*)", "`$1    `$2`$3"

        $content | Set-Content -LiteralPath $file_out -NoNewline
    }
}
