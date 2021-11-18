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

# file list:
# fomod/info.xml
# MCM/Config/Portable Junk Recycler Mk 2/Portable Junk Recycler Mk 2.jsonnet
# Scripts/Source/User/PortableJunkRecyclerMk2/ControlScript.psc
# Scripts/Source/User/Portable Junk Recycler Mk 2.ppj
# PJRM2 Crafting Category Override - AWKCR Devices.esp
# PJRM2 Crafting Category Override - AWKCR Other.esp
# PJRM2 Crafting Category Override - AWKCR Tools.esp
# PJRM2 Crafting Category Override - LKR Devices.esp
# PJRM2 Crafting Category Override - LKR Utility.esp
# Portable Junk Recycler Mk 2.esp

source ".version"

# update build number
build_number+=1
sed -Ei "s|(declare -i build_number=')[^']*(')|\1${build_number}\2|" ".version"

# check whether to include the build number
if ${include_build_number}; then
    build_number_text=${build_number}
else
    build_number_text=''
fi

# check to see if this is a pre-release
if ${is_rc}; then
    prerelease_classification='rc'
elif ${is_beta}; then
    prerelease_classification='beta'
elif ${is_alpha}; then
    prerelease_classification='alpha'
else
    prerelease_classification=''
fi

# build the version string
version="${version_major}.${version_minor}.${version_patch}${prerelease_classification:+-${prerelease_classification}${prerelease_version:+.${prerelease_version}}}${build_number_text:++${build_number_text}}"

# make the file changes

make_backups="false"
backup_suffix=".backup.$(date +%Y_%m_%d_%H_%M_%S)"

# fomod/info.xml
# <Version>...</Version>
working_file="fomod/info.xml"
temp_file="${working_file}.tmp"
temp_file2="${working_file}.tmp2"
${make_backups} && cp "${working_file}" "${working_file}${backup_suffix}"
iconv -f utf-16 -t utf-8 "${working_file}" > "${temp_file}"
sed -Ei "s|(<Version>)[^<]*(</Version>)|\1${version}\2|" "${temp_file}"
iconv -f utf-8 -t utf-16 "${temp_file}" > "${temp_file2}"
if [[ $(sha512sum "${working_file}" | cut -d ' ' -f 1) != $(sha512sum "${temp_file2}" | cut -d ' ' -f 1) ]]; then
    mv "${temp_file2}" "${working_file}"
else
    rm "${temp_file2}"
fi
rm "${temp_file}"

# MCM/Config/Portable Junk Recycler Mk 2/Portable Junk Recycler Mk 2.jsonnet
# version: '...',
working_file="MCM/Config/Portable Junk Recycler Mk 2/Portable Junk Recycler Mk 2.jsonnet"
temp_file="${working_file}.tmp"
${make_backups} && cp "${working_file}" "${working_file}${backup_suffix}"
sed -E "s|(version: ')[^']*(',)|\1${version}\2|" "${working_file}" > "${temp_file}"
if [[ $(sha512sum "${working_file}" | cut -d ' ' -f 1) != $(sha512sum "${temp_file}" | cut -d ' ' -f 1) ]]; then
    mv "${temp_file}" "${working_file}"
else
    rm "${temp_file}"
fi

# Scripts/Source/User/PortableJunkRecyclerMk2/ControlScript.psc
# string ModVersion = "..." const
working_file="Scripts/Source/User/PortableJunkRecyclerMk2/ControlScript.psc"
temp_file="${working_file}.tmp"
${make_backups} && cp "${working_file}" "${working_file}${backup_suffix}"
sed -E "s|(string ModVersion = \")[^\"]*(\" const)|\1${version}\2|" "${working_file}" > "${temp_file}"
if [[ $(sha512sum "${working_file}" | cut -d ' ' -f 1) != $(sha512sum "${temp_file}" | cut -d ' ' -f 1) ]]; then
    mv "${temp_file}" "${working_file}"
else
    rm "${temp_file}"
fi

# Scripts/Source/User/Portable Junk Recycler Mk 2.ppj
# <Variable Name="ModVersion" Value="..."/>
working_file="Scripts/Source/User/Portable Junk Recycler Mk 2.ppj"
temp_file="${working_file}.tmp"
${make_backups} && cp "${working_file}" "${working_file}${backup_suffix}"
sed -E "s|(<Variable Name=\"ModVersion\" Value=\")[^\"]*(\"/>)|\1${version}\2|" "${working_file}" > "${temp_file}"
if [[ $(sha512sum "${working_file}" | cut -d ' ' -f 1) != $(sha512sum "${temp_file}" | cut -d ' ' -f 1) ]]; then
    mv "${temp_file}" "${working_file}"
else
    rm "${temp_file}"
fi

# *.esp
"./Working/Scripts/plugin-description-version-updater.py3" "$(${make_backups} || printf -- '-n')" "${version}" {"PJRM2 Crafting Category Override - AWKCR Devices","PJRM2 Crafting Category Override - AWKCR Other","PJRM2 Crafting Category Override - AWKCR Tools","PJRM2 Crafting Category Override - LKR Devices","PJRM2 Crafting Category Override - LKR Utility","Portable Junk Recycler Mk 2"}.esp