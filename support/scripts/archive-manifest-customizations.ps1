# Copyright 2024 Dan Cassidy

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


# customizations for the archive manifests

$additional_exclude_all = @("dummy_placeholder.STRINGS")

$additional_exclude_ba2 = @("Interface\Translations\*.txt")

$additional_exclude_7z = @("PJRM2 Test Items.esp")
$additional_include_7z = @("Interface\Translations\*.txt", "Scripts\Source\*.psc")
