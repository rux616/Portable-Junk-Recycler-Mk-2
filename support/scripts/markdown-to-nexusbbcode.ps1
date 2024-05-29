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
    $code_font_color = "b2b2b2"
}

process {
    $Files | ForEach-Object {
        $file_in = Get-Item $_ -ErrorAction Stop
        $file_out = "$($file_in.Directory)\$($file_in.BaseName).nexusbbcode"
        if (-not (Test-Path -LiteralPath $file_out)) { New-Item $file_out | Out-Null }
        $file_out = Get-Item -LiteralPath $file_out

        $content = Get-Content -LiteralPath $file_in -Raw

        # convert '...\n===' headers to '[size=5][b]...[/b][/size]'
        $content = $content -replace "(.*)$line_ending={3,}", "[size=5][b]`$1[/b][/size]"
        # convert '...\n---' headers to '[size=4][b][u]...:[/u][/b][/size]'
        $content = $content -replace "(.*)$line_ending-{3,}", "[size=4][b][u]`$1:[/u][/b][/size]"
        # remove anchor links
        $content = $content -replace "\[(.*?)\]\(#.*?\)", "`$1"
        # remove any remaining '(TOC)' lines and an extra newline
        $content = $content -replace "$line_ending\(TOC\)$line_ending", ""
        # remove '<details><summary>...</summary>' and '</details>' and extra newline on each
        $content = $content -replace "$line_ending<details>.*?</summary>$line_ending", ""
        $content = $content -replace "$line_ending</details>$line_ending", ""
        # convert '**...**' and '__...__' to '[b]...[/b]'
        $content = $content -replace "(?<=^|\W)\*\*(.+?)\*\*(?=\W)", "[b]`$1[/b]"
        $content = $content -replace "(?<=^|\W)__(.+?)__(?=\W)", "[b]`$1[/b]"
        # convert '*...*' and '_..._' to '[i]...[/i]'
        $content = $content -replace "(?<=^|\W)\*(.+?)\*(?=\W)", "[u]`$1[/u]"
        $content = $content -replace "(?<=^|\W)_(.+?)_(?=\W)", "[u]`$1[/u]"
        # convert markdown URLs to BBCode URLs
        $content = $content -replace "\[([^]]*)]\(([^)]*)\)", "[url=`$2]`$1[/url]"
        # convert '`...`' to '[font=Courier New][color=#$code_font_color]...[/color][/font]'
        $content = $content -replace "``(.*?)``", "[font=Courier New][color=#$code_font_color]`$1[/color][/font]"
        # convert indented code to '    [font=Courier New][color=#$code_font_color]...[/color][/font]'
        $content = $content -replace "($line_ending*)[ ]{4,}(?! *-|\* )(.*?)($line_ending*)", "`$1    [font=Courier New][color=#$code_font_color]`$2[/color][/font]`$3"

        $content | Set-Content -LiteralPath $file_out -NoNewline
    }
}
