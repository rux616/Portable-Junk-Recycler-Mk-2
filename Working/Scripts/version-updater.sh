#!/usr/bin/env bash

# file list:
# fomod/info.xml
# MCM/Config/Portable Junk Recycler Mk 2/Portable Junk Recycler Mk 2.jsonnet
# Scripts/Source/User/PortableJunkRecyclerMk2/ControlScript.psc
# Scripts/Source/User/Portable Junk Recycler Mk 2.ppj

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

# fomod/info.xml
# <Version>...</Version>
iconv -f utf-16 -t utf-8 "fomod/info.xml" > "fomod/info.xml.tmp"
sed -Ei "s|(<Version>)[^<]*(</Version>)|\1${version}\2|" "fomod/info.xml.tmp"
iconv -f utf-8 -t utf-16 "fomod/info.xml.tmp" > "fomod/info.xml"
rm "fomod/info.xml.tmp"

# MCM/Config/Portable Junk Recycler Mk 2/Portable Junk Recycler Mk 2.jsonnet
# version: '...',
sed -Ei "s|(version: ')[^']*(',)|\1${version}\2|" "MCM/Config/Portable Junk Recycler Mk 2/Portable Junk Recycler Mk 2.jsonnet"

# Scripts/Source/User/PortableJunkRecyclerMk2/ControlScript.psc
# string ModVersion = "..." const
sed -Ei "s|(string ModVersion = \")[^\"]*(\" const)|\1${version}\2|" "Scripts/Source/User/PortableJunkRecyclerMk2/ControlScript.psc"

# Scripts/Source/User/Portable Junk Recycler Mk 2.ppj
# <Variable Name="ModVersion" Value="..."/>
sed -Ei "s|(<Variable Name=\"ModVersion\" Value=\")[^\"]*(\"/>)|\1${version}\2|" "Scripts/Source/User/Portable Junk Recycler Mk 2.ppj"