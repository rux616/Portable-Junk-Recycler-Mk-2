; Copyright 2021 Dan Cassidy

; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <https://www.gnu.org/licenses/>.

; SPDX-License-Identifier: GPL-3.0-or-later



ScriptName PortableJunkRecyclerMk2:WorkerThread25 Extends PortableJunkRecyclerMk2:WorkerThreadBase

Function _DebugTrace(string asMessage, int aiSeverity = 0) DebugOnly
    string baseMessage = "WorkerThread 25: " const
    If aiSeverity == 0
        Debug.TraceUser(ModName, baseMessage + asMessage)
    ElseIf aiSeverity == 1
        Debug.TraceUser(ModName, "WARNING: " + baseMessage + asMessage)
    ElseIf aiSeverity == 2
        Debug.TraceUser(ModName, "ERROR: " + baseMessage + asMessage)
    EndIf
EndFunction