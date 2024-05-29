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

# file list:
#   text files:
#     .version.ps1
#     fomod/info.xml
#     MCM/Config/Portable Junk Recycler Mk 2/Portable Junk Recycler Mk 2.jsonnet
#     Scripts/Source/User/PortableJunkRecyclerMk2/ControlScript.psc
#     Scripts/Source/User/Portable Junk Recycler Mk 2.ppj
#   esp files:
#     PJRM2 Crafting Category Override - AWKCR Devices.esp
#     PJRM2 Crafting Category Override - AWKCR Other.esp
#     PJRM2 Crafting Category Override - AWKCR Tools.esp
#     PJRM2 Crafting Category Override - LKR Devices.esp
#     PJRM2 Crafting Category Override - LKR Utility.esp
#     Portable Junk Recycler Mk 2.esp


# get a hash from a string
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-filehash?view=powershell-7.3#examples

function Get-StringHash([string] $content) {
    $string_as_stream = [System.IO.MemoryStream]::new()
    $writer = [System.IO.StreamWriter]::new($string_as_stream)
    $writer.write($content)
    $writer.Flush()
    $string_as_stream.Position = 0
    (Get-FileHash -InputStream $string_as_stream).Hash
}

# stop the script if an uncaught error happens
$ErrorActionPreference = "Stop"

# source version file
. "./.version.ps1"

# update build number
$build_number += 1

# check to see if this is a pre-release
if ($is_pre) {
    [string] $prerelease_classification = "pre"
}
elseif ($is_rc) {
    [string] $prerelease_classification = "rc"
}
elseif ($is_beta) {
    [string] $prerelease_classification = "beta"
}
elseif ($is_alpha) {
    [string] $prerelease_classification = "alpha"
}
else {
    [string] $prerelease_classification = ""
}

# build the version strings
[string] $version = "$version_major.$version_minor.$version_patch"
if ($prerelease_classification) {
    $version += "-$prerelease_classification"
    if ($version_prerelease) {
        $version += ".$version_prerelease"
    }
}
if ($include_build_in_version) {
    $version += "+$build_number"
    [string] $version_with_build = $version
}
else {
    [string] $version_with_build = "$version+$build_number"
}
"version: $version"
"version with build: $version_with_build"

# make the file changes

[bool] $make_backups = $false
[string] $backup_suffix = ".$((Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmss\Z")).backup"

# text files
[System.Collections.Generic.List[hashtable]] $text_files = New-Object System.Collections.Generic.List[hashtable]
$text_files.Add(@{
        # .version.ps1
        # build_number = ...
        file               = "./.version.ps1"
        search_and_replace = @(
            @{
                search  = "(build_number = )\d*"
                replace = "`${1}$build_number"
            }
        )
    })
$text_files.Add(@{
        # fomod/info.xml
        # <Version>...</Version>
        file               = "./fomod/info.xml"
        search_and_replace = @(
            @{
                search  = "(<Version>).*(</Version>)"
                replace = "`${1}$version`${2}"
            }
        )
        encoding           = "Unicode"
    })
$text_files.Add(@{
        # MCM/Config/Portable Junk Recycler Mk 2/Portable Junk Recycler Mk 2.jsonnet
        # version: '...',
        file               = "./MCM/Config/Portable Junk Recycler Mk 2/Portable Junk Recycler Mk 2.jsonnet"
        search_and_replace = @(
            @{
                search  = "(version: ').*(',)"
                replace = "`${1}$version`${2}"
            }
        )
    })
$text_files.Add(@{
        # Scripts/Source/User/PortableJunkRecyclerMk2/PJRM2_ControlManager.psc
        # string ModVersion = "..." const
        file               = "./Scripts/Source/User/PortableJunkRecyclerMk2/PJRM2_ControlManager.psc"
        search_and_replace = @(
            @{
                search  = "(string ModVersion = `").*(`" const)"
                replace = "`${1}$version`${2}"
            }
        )
    })
$text_files.Add(@{
        # Scripts/Source/User/Portable Junk Recycler Mk 2 - Release.ppj
        # <Variable Name="ModVersion" Value="..."/>
        # <Variable Name="ModVersionWithBuild" Value="..."/>
        file               = "./Scripts/Source/User/Portable Junk Recycler Mk 2 - Release.ppj"
        search_and_replace = @(
            @{
                search  = "(<Variable Name=`"ModVersion`" Value=`").*(`"/>)"
                replace = "`${1}$version`${2}"
            },
            @{
                search  = "(<Variable Name=`"ModVersionWithBuild`" Value=`").*(`"/>)"
                replace = "`${1}$version_with_build`${2}"
            }
        )
    })

"------------------------------"
$text_files | ForEach-Object {
    $file = Get-Item $_.file
    "Version Updater: Examining '$($_.file)'"
    $updated = 0
    $encoding = if ($_.encoding) { $_.encoding } else { "UTF8NoBOM" }
    if ($make_backups) { Copy-Item -LiteralPath $file "$file$backup_suffix" }
    $_.search_and_replace | ForEach-Object {
        $content = Get-Content -LiteralPath $file -Encoding $encoding -Raw
        $original_hash = Get-StringHash $content
        $content = $content -replace $_.search, $_.replace
        $new_hash = Get-StringHash $content
        if ($new_hash -ne $original_hash) {
            $content | Set-Content -LiteralPath $file -Encoding $encoding -NoNewline
            $updated += 1
        }
        # (Get-Content -LiteralPath $file -Encoding $encoding) -replace $_.search, $_.replace | Set-Content -LiteralPath $file -Encoding $encoding
    }
    if ($updated) { "File updated with new version string$(if ($updated -gt 1) { "s" })." } else { "No file updated needed." }
    "------------------------------"
}

# esp files
[string[]] $esp_files = @(
    "PJRM2 Crafting Category Override - AWKCR Devices.esp"
    "PJRM2 Crafting Category Override - AWKCR Other.esp"
    "PJRM2 Crafting Category Override - AWKCR Tools.esp"
    "PJRM2 Crafting Category Override - LKR Devices.esp"
    "PJRM2 Crafting Category Override - LKR Utility.esp"
    "Portable Junk Recycler Mk 2.esp"
)
# python3 needs to be accessible from PATH!
python3.exe "./Working/Scripts/plugin-description-version-updater.py" $(if (-not $make_backups) { "-n" }) "$version" $esp_files
