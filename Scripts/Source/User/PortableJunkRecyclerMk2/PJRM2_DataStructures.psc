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



ScriptName PortableJunkRecyclerMk2:PJRM2_DataStructures
{ contains data structures used by PortableJunkRecyclerMk2-namespaced scripts }



; STRUCTS
; -------

Struct ComponentMap
    Component ComponentPart
    string ComponentPartName
    MiscObject ScrapPart
    string ScrapPartName
    float Weight
    int Rarity
EndStruct

Struct FormListWrapper
    FormList List
    int Size
EndStruct

Struct MultiplierSet
    float MultC
    float MultU
    float MultR
    float MultS
    float RandomMin
    float RandomMax
    float RandomMinC
    float RandomMaxC
    float RandomMinU
    float RandomMaxU
    float RandomMinR
    float RandomMaxR
    float RandomMinS
    float RandomMaxS
EndStruct

Struct SettingChangeType
    int ValueOnly = 0
    int McmOnly = 1
    int Both = 2
EndStruct

Struct SettingCallbackType
    int NoCallback = 0
    int FunctionCallback = 1
    int GlobalFunctionCallback = 2
EndStruct

Struct SettingCallbackArgumentType
    int NoArguments = 0
    int NewValueOnly = 1
    int OldValueOnly = 2
    int Both = 3
EndStruct

Struct SettingBool
    string McmId

    bool Value
    bool ValueDefault

    int CallbackType
    Form CallbackForm
    string CallbackScript
    string CallbackFunction
    int CallbackArgumentType
    bool WaitOnCallback = false
EndStruct

Struct SettingFloat
    string McmId

    float Value
    float ValueDefault

    float ValueMin
    float ValueMax

    int CallbackType
    Form CallbackForm
    string CallbackScript
    string CallbackFunction
    int CallbackArgumentType
    bool WaitOnCallback = false
EndStruct

Struct SettingInt
    string McmId

    int Value
    int ValueDefault

    int ValueMin
    int ValueMax

    int CallbackType
    Form CallbackForm
    string CallbackScript
    string CallbackFunction
    int CallbackArgumentType
    bool WaitOnCallback = false
EndStruct

Struct SettingString
    string McmId

    string Value
    string ValueDefault

    int CallbackType
    Form CallbackForm
    string CallbackScript
    string CallbackFunction
    int CallbackArgumentType
    bool WaitOnCallback = false
EndStruct