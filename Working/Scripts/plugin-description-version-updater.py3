#!/usr/bin/env python3

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


import argparse
from datetime import datetime
import hashlib
import re
import shutil
import struct
import sys


SIG_LENGTH = 4
UINT16_LENGTH = 2
UINT32_LENGTH = 4
VERSION_CHECK = r"^v?\d+\.\d+\.\d+" + r"($|(-(rc|beta|alpha)(\.\d+)?))" + r"($|(\+\d+))"
VERSION_REGEX = r"v?\d+\.\d+\.\d+" + r"(-(rc|beta|alpha)(\.\d+)?)?" + r"(\+\d+)?"


def replace_data(data, start, stop, new_data):
    del data[start:stop]
    for byte in new_data:
        data.insert(start, byte)
        start += 1


def validate_version(version):
    if re.search(VERSION_CHECK, version) is None:
        raise Exception("Invalid version format.")


def main(filename, version, write_data=True, make_backup=True):
    # validate version
    validate_version(version)

    # show status text
    if not write_data:
        print("[DRY RUN MODE]")
    print("Loading '" + filename + "' into memory...")

    # validate file extension
    extension = filename[-4:].lower()
    if extension not in (".esl", ".esm", ".esp"):
        raise Exception("Invalid file extension: '" + extension + "'")

    # read plugin file into memory
    with open(filename, "rb") as fh:
        plugin_data = bytearray(fh.read())

    # get info about the TES4 record
    tes4_offset = 0
    tes4_data_size_offset = tes4_offset + SIG_LENGTH
    tes4_data_offset = tes4_data_size_offset + UINT32_LENGTH
    tes4_data_size = struct.unpack(
        "I", plugin_data[tes4_data_size_offset:tes4_data_offset]
    )[0]

    # do a limited verification of the file by seeing if it begins with b"TES4"
    if plugin_data[tes4_offset:tes4_data_size_offset] != b"TES4":
        raise Exception(
            "TES4 record not found where expected. Is this a valid plugin file?"
        )

    # get info about the CNAM record
    cnam_offset = plugin_data.find(
        b"CNAM", tes4_data_offset, tes4_data_offset + tes4_data_size
    )
    if cnam_offset < 0:
        raise Exception("CNAM record not found: Possible malformed TES4 record")
    cnam_data_size_offset = cnam_offset + SIG_LENGTH
    cnam_data_offset = cnam_data_size_offset + UINT16_LENGTH
    cnam_data_size = struct.unpack(
        "H", plugin_data[cnam_data_size_offset:cnam_data_offset]
    )[0]

    # determine if SNAM record exists
    snam_offset = cnam_data_offset + cnam_data_size
    if (
        struct.unpack("4s", plugin_data[snam_offset : snam_offset + SIG_LENGTH])[0]
        != b"SNAM"
    ):
        print("No SNAM record found. Will insert at offset " + str(snam_offset) + ".")
        snam_needs_to_be_created = True
    else:
        print("SNAM record found at offset " + str(snam_offset))
        snam_needs_to_be_created = False

    # read the SNAM record if it exists, otherwise just put some dummy data in place
    if not snam_needs_to_be_created:
        snam_data_size_offset = snam_offset + SIG_LENGTH
        snam_data_offset = snam_data_size_offset + UINT16_LENGTH
        snam_data_size = struct.unpack(
            "H", plugin_data[snam_data_size_offset:snam_data_offset]
        )[0]
        description = struct.unpack(
            str(snam_data_size) + "s",
            plugin_data[snam_data_offset : snam_data_offset + snam_data_size],
        )[0].decode("latin1")[:-1]
        existing_snam_record_size = SIG_LENGTH + UINT16_LENGTH + snam_data_size
    else:
        snam_data_size = 0
        description = ""
        existing_snam_record_size = 0

    # update (or append the version to) the description
    old_description = description
    re_result = re.subn(VERSION_REGEX, version, description)
    if description == "":
        description = version
    elif re_result[1] == 0:
        description = (
            description
            + "\r\n\r\n"
            + ("" if version[0:1] == "v" else "Version: ")
            + version
        )
    else:
        description = re_result[0]
    description = description[:511] + "\0"

    # don't update the description if it's the same
    if old_description + "\0" == description and not snam_needs_to_be_created:
        print("SNAM record update not needed.")
        return

    # construct SNAM record and save the record size
    snam_record = (
        b"SNAM"
        + struct.pack("H", len(description))
        + bytes(description, encoding="latin1")
    )
    snam_record_size = len(snam_record)

    # replace an existing SNAM record or insert a new one
    replace_data(
        data=plugin_data,
        start=snam_offset,
        stop=snam_offset + existing_snam_record_size,
        new_data=snam_record,
    )
    if not snam_needs_to_be_created:
        print(
            "SNAM record size updated: "
            + str(snam_data_size)
            + " bytes -> "
            + str(len(description))
            + " bytes"
        )
        print("SNAM record data updated: " + old_description + " -> " + description)
    else:
        print("SNAM record data size: " + str(len(description)) + " bytes")
        print("SNAM record data: " + description)

    # update the TES4 record size
    updated_tes4_data_size = (
        tes4_data_size + snam_record_size - existing_snam_record_size
    )
    replace_data(
        data=plugin_data,
        start=tes4_data_size_offset,
        stop=tes4_data_offset,
        new_data=struct.pack("I", updated_tes4_data_size),
    )
    print(
        "TES4 record size updated: "
        + str(tes4_data_size)
        + " bytes -> "
        + str(updated_tes4_data_size)
        + " bytes"
    )

    # write out the file if not doing a dry run
    if write_data:
        # make a backup of the plugin if not disabled
        if make_backup:
            current_time = datetime.now()
            backup = filename + ".backup." + current_time.strftime("%Y_%m_%d_%H_%M_%S")
            print("Making backup of plugin at '" + backup + "'...")
            shutil.copy2(filename, backup)

        # write the plugin data back to the file
        print("Writing modified data to disk...")
        with open(filename, "wb") as fh:
            fh.write(plugin_data)

        # hash the modified plugin data in memory, then hash the newly-written file and compare
        plugin_data_digest = hashlib.sha512(plugin_data).hexdigest()
        with open(filename, "rb") as fh:
            file_data_digest = hashlib.sha512(fh.read()).hexdigest()
        if plugin_data_digest != file_data_digest:
            raise Exception(
                "Plugin data in memory does not match plugin data written to disk! This may mean that the plugin as written to disk was corrupted somehow. You should load it into xEdit and verify that all is as it should be."
            )

    print("Finished updating '" + filename + "'")


if __name__ == "__main__":
    # set up argument parsing
    parser = argparse.ArgumentParser(
        description="Updates or adds the supplied version string to the description of an ESL, ESM, or ESP plugin for Oblivion, Skyrim, Fallout 3, Fallout: New Vegas, and Fallout 4."
    )
    parser.add_argument(
        "version",
        help="The version to use. Must be of the format '(v)X.Y.Z(-rc|beta|alpha(.A))(+B)' where items in () are optional, and items X, Y, Z, A, and B are non-negative integers. Examples: 'v1.2.3', '0.1.2-beta', 'v1.0.0-rc.1', 'v1.2.3+3827', 'v0.3.2-alpha.1+4567'. If '(v)' is not present and the version is not present in the SNAM record, version will be preceded with 'Version: ' when added. Example: '1.0.0' -> 'Version: 1.0.0'.",
    )
    parser.add_argument(
        "plugin_file",
        nargs="+",
        help="The plugin file(s) to edit. Must be a file with extension '.esl', '.esm', or '.esp'.",
    )
    parser.add_argument(
        "-d",
        "--dry-run",
        action="store_true",
        help="perform a dry run only; doesn't actually edit any plugins",
    )
    parser.add_argument(
        "-n",
        "--no-backup",
        action="store_true",
        help="disables making a backup of the plugin before changing it",
    )
    args = parser.parse_args()

    err = False

    # validate the version
    try:
        validate_version(args.version)
    except Exception as e:
        print(e)
        err = True

    # update the files
    if not err:
        first = True
        for file in args.plugin_file:
            try:
                if first:
                    first = False
                else:
                    print("------------------------------")

                main(file, args.version, not args.dry_run, not args.no_backup)
            except Exception as e:
                print(e)
                err = True

    if err:
        exit(1)