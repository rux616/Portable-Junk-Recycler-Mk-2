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



ScriptName PortableJunkRecyclerMk2:PJRM2_Utility Hidden
{ contains utility functions used by PortableJunkRecyclerMk2-namespaced scripts }

; import data structures
import PortableJunkRecyclerMk2:PJRM2_DataStructures

; generic interface to change settings
Function ChangeSetting(var akSettingToChange, int aiChangeType, var avNewValue, string asMcmModName) Global
    SettingCallbackType availableCallbackTypes = new SettingCallbackType
    SettingCallbackArgumentType availableCallbackArgumentTypes = new SettingCallbackArgumentType

    ; go through and change settings, with consideration for each setting type
    var[] callbackInfo
    If akSettingToChange is SettingFloat
        callbackInfo = ChangeSettingFloat(akSettingToChange as SettingFloat, aiChangeType, avNewValue as float, asMcmModName)
    ElseIf akSettingToChange is SettingBool
        callbackInfo = ChangeSettingBool(akSettingToChange as SettingBool, aiChangeType, avNewValue as bool, asMcmModName)
    ElseIf akSettingToChange is SettingInt
        callbackInfo = ChangeSettingInt(akSettingToChange as SettingInt, aiChangeType, avNewValue as int, asMcmModName)
    ElseIf akSettingToChange is SettingString
        callbackInfo = ChangeSettingString(akSettingToChange as SettingString, aiChangeType, avNewValue as string, asMcmModName)
    EndIf

    ; if setting has no callback associated with it, skip the rest
    If callbackInfo[0] as int != availableCallbackTypes.NoCallback
        ; parse the returned callback info
        int callbackType = callbackInfo[0] as int
        Form callbackForm = callbackInfo[1] as Form
        string callbackScript = callbackInfo[2] as string
        string callbackFunction = callbackInfo[3] as string
        int callbackArgumentType = callbackInfo[4] as int
        var oldValue = callbackInfo[5]
        var newValue = callbackInfo[6]
        bool waitOnCallback = callbackInfo[7] as bool

        ; prepare parameters for callback function
        var[] params = new var[0]
        If callbackArgumentType == availableCallbackArgumentTypes.NoArguments
            ; do nothing
        ElseIf callbackArgumentType == availableCallbackArgumentTypes.NewValueOnly
            params.Add(newValue)
        ElseIf callbackArgumentType == availableCallbackArgumentTypes.OldValueOnly
            params.Add(oldValue)
        ElseIf callbackArgumentType == availableCallbackArgumentTypes.Both
            params.Add(oldValue)
            params.Add(newValue)
        EndIf

        ; execute callback
        If callbackType == availableCallbackTypes.FunctionCallback
            ScriptObject callbackScriptObject = callbackForm.CastAs(callbackScript)
            If callbackScriptObject
                If waitOnCallback
                    callbackScriptObject.CallFunction(callbackFunction, params)
                Else
                    callbackScriptObject.CallFunctionNoWait(callbackFunction, params)
                EndIf
            EndIf
        ElseIf callbackType == availableCallbackTypes.GlobalFunctionCallback
            If waitOnCallback
                Utility.CallGlobalFunction(callbackScript, callbackFunction, params)
            Else
                Utility.CallGlobalFunctionNoWait(callbackScript, callbackFunction, params)
            EndIf
        EndIf
    EndIf
EndFunction

; interface to change bool settings
; you should probably use the generic interface
var[] Function ChangeSettingBool(SettingBool akSettingToChange, int aiChangeType, bool abNewValue, string asMcmModName) Global
    SettingChangeType availableChangeTypes = new SettingChangeType

    ; record the old value
    bool oldValue = akSettingToChange.Value

    If aiChangeType == availableChangeTypes.Both || aiChangeType == availableChangeTypes.ValueOnly
        akSettingToChange.Value = abNewValue
    EndIf

    If aiChangeType == availableChangeTypes.Both || aiChangeType == availableChangeTypes.McmOnly
        MCM.SetModSettingBool(asMcmModName, akSettingToChange.McmId, abNewValue)
    EndIf

    ; collect callback info to return
    var[] toReturn = new var[0]
    toReturn.Add(akSettingToChange.CallbackType)
    If akSettingToChange.CallbackType
        toReturn.Add(akSettingToChange.CallbackForm)
        toReturn.Add(akSettingToChange.CallbackScript)
        toReturn.Add(akSettingToChange.CallbackFunction)
        toReturn.Add(akSettingToChange.CallbackArgumentType)
        toReturn.Add(oldValue) ; old value
        toReturn.Add(akSettingToChange.Value) ; new value
        toReturn.Add(akSettingToChange.WaitOnCallback)
    EndIf
    Return toReturn
EndFunction

; interface to change float settings
; you should probably use the generic interface
var[] Function ChangeSettingFloat(SettingFloat akSettingToChange, int aiChangeType, float afNewValue, string asMcmModName) Global
    SettingChangeType availableChangeTypes = new SettingChangeType

    ; clamp the requested change if too large or too small
    If afNewValue > akSettingToChange.ValueMax
        afNewValue = akSettingToChange.ValueMax
    ElseIf afNewValue < akSettingToChange.ValueMin
        afNewValue = akSettingToChange.ValueMin
    EndIf

    ; record the old value
    float oldValue = akSettingToChange.Value

    If aiChangeType == availableChangeTypes.Both || aiChangeType == availableChangeTypes.ValueOnly
        akSettingToChange.Value = afNewValue
    EndIf

    If aiChangeType == availableChangeTypes.Both || aiChangeType == availableChangeTypes.McmOnly
        MCM.SetModSettingFloat(asMcmModName, akSettingToChange.McmId, afNewValue)
    EndIf

    ; collect callback info to return
    var[] toReturn = new var[0]
    toReturn.Add(akSettingToChange.CallbackType)
    If akSettingToChange.CallbackType
        toReturn.Add(akSettingToChange.CallbackForm)
        toReturn.Add(akSettingToChange.CallbackScript)
        toReturn.Add(akSettingToChange.CallbackFunction)
        toReturn.Add(akSettingToChange.CallbackArgumentType)
        toReturn.Add(oldValue) ; old value
        toReturn.Add(akSettingToChange.Value) ; new value
        toReturn.Add(akSettingToChange.WaitOnCallback)
    EndIf
    Return toReturn
EndFunction

; interface to change int settings
; you should probably use the generic interface
var[] Function ChangeSettingInt(SettingInt akSettingToChange, int aiChangeType, int aiNewValue, string asMcmModName) Global
    SettingChangeType availableChangeTypes = new SettingChangeType

    ; clamp the requested change if too large or too small
    If aiNewValue > akSettingToChange.ValueMax
        aiNewValue = akSettingToChange.ValueMax
    ElseIf aiNewValue < akSettingToChange.ValueMin
        aiNewValue = akSettingToChange.ValueMin
    EndIf

    ; record the old value
    int oldValue = akSettingToChange.Value

    If aiChangeType == availableChangeTypes.Both || aiChangeType == availableChangeTypes.ValueOnly
        akSettingToChange.Value = aiNewValue
    EndIf

    If aiChangeType == availableChangeTypes.Both || aiChangeType == availableChangeTypes.McmOnly
        MCM.SetModSettingInt(asMcmModName, akSettingToChange.McmId, aiNewValue)
    EndIf

    ; collect callback info to return
    var[] toReturn = new var[0]
    toReturn.Add(akSettingToChange.CallbackType)
    If akSettingToChange.CallbackType
        toReturn.Add(akSettingToChange.CallbackForm)
        toReturn.Add(akSettingToChange.CallbackScript)
        toReturn.Add(akSettingToChange.CallbackFunction)
        toReturn.Add(akSettingToChange.CallbackArgumentType)
        toReturn.Add(oldValue) ; old value
        toReturn.Add(akSettingToChange.Value) ; new value
        toReturn.Add(akSettingToChange.WaitOnCallback)
    EndIf
    Return toReturn
EndFunction

; interface to change string settings
; you should probably use the generic interface
var[] Function ChangeSettingString(SettingString akSettingToChange, int aiChangeType, string asNewValue, string asMcmModName) Global
    SettingChangeType availableChangeTypes = new SettingChangeType

    ; record the old value
    string oldValue = akSettingToChange.Value

    If aiChangeType == availableChangeTypes.Both || aiChangeType == availableChangeTypes.ValueOnly
        akSettingToChange.Value = asNewValue
    EndIf

    If aiChangeType == availableChangeTypes.Both || aiChangeType == availableChangeTypes.McmOnly
        MCM.SetModSettingBool(asMcmModName, akSettingToChange.McmId, asNewValue)
    EndIf

    ; collect callback info to return
    var[] toReturn = new var[0]
    toReturn.Add(akSettingToChange.CallbackType)
    If akSettingToChange.CallbackType
        toReturn.Add(akSettingToChange.CallbackForm)
        toReturn.Add(akSettingToChange.CallbackScript)
        toReturn.Add(akSettingToChange.CallbackFunction)
        toReturn.Add(akSettingToChange.CallbackArgumentType)
        toReturn.Add(oldValue) ; old value
        toReturn.Add(akSettingToChange.Value) ; new value
        toReturn.Add(akSettingToChange.WaitOnCallback)
    EndIf
    Return toReturn
EndFunction

; generic interface to load settings from the MCM
Function LoadSettingFromMCM(var akSetting, string asMcmModName) Global
    If akSetting is SettingBool
        LoadSettingBoolFromMCM(akSetting as SettingBool, asMcmModName)
    ElseIf akSetting is SettingFloat
        LoadSettingFloatFromMCM(akSetting as SettingFloat, asMcmModName)
    ElseIf akSetting is SettingInt
        LoadSettingIntFromMCM(akSetting as SettingInt, asMcmModName)
    ElseIf akSetting is SettingString
        LoadSettingStringFromMCM(akSetting as SettingString, asMcmModName)
    EndIf
EndFunction

; interface to load bool settings from the MCM
; you should probably use the generic interface
Function LoadSettingBoolFromMCM(SettingBool akSetting, string asMcmModName) Global
    SettingChangeType availableChangeTypes = new SettingChangeType
    ChangeSetting(akSetting, availableChangeTypes.ValueOnly, MCM.GetModSettingBool(asMcmModName, akSetting.McmId), asMcmModName)
EndFunction

; interface to load float settings from the MCM
; you should probably use the generic interface
Function LoadSettingFloatFromMCM(SettingFloat akSetting, string asMcmModName) Global
    SettingChangeType availableChangeTypes = new SettingChangeType
    ChangeSetting(akSetting, availableChangeTypes.ValueOnly, MCM.GetModSettingFloat(asMcmModName, akSetting.McmId), asMcmModName)
EndFunction

; interface to load int settings from the MCM
; you should probably use the generic interface
Function LoadSettingIntFromMCM(SettingInt akSetting, string asMcmModName) Global
    SettingChangeType availableChangeTypes = new SettingChangeType
    ChangeSetting(akSetting, availableChangeTypes.ValueOnly, MCM.GetModSettingInt(asMcmModName, akSetting.McmId), asMcmModName)
EndFunction

; interface to load string settings from the MCM
; you should probably use the generic interface
Function LoadSettingStringFromMCM(SettingString akSetting, string asMcmModName) Global
    SettingChangeType availableChangeTypes = new SettingChangeType
    ChangeSetting(akSetting, availableChangeTypes.ValueOnly, MCM.GetModSettingBool(asMcmModName, akSetting.McmId), asMcmModName)
EndFunction

; fully destroy the contents of an array
Function DestroyArrayContents(var[] akArray) Global
    int index = akArray.Length - 1
    While index >= 0
        akArray[index] = None
        akArray.Remove(index)
        index -= 1
    EndWhile
EndFunction

; get components of a COBJ
; ConstructibleObject:ConstructableComponent[] Function GetComponents(Form akItem) Global
;     ; string function_name = "GetComponents"
;     ConstructibleObject[] constructable_objects = SUP_F4SE.GetAllConstructibleObjectsFromForm(akItem)
;     ; Self._Log(function_name + ": item: " + akItem + ", COBJs: " + constructable_objects)
;     If constructable_objects.Length > 0
;         int index = 0
;         ; don't need to set index if length == 1, because it's already 0
;         If constructable_objects.Length >= 1
;             index = Utility.RandomInt(0, constructable_objects.Length)
;         EndIf
;         ; Self._Log(function_name + ": item " + akItem + ", index: " + index + ", COBJ: " + constructable_objects[index])
;         Return constructable_objects[index].GetConstructibleComponents()
;     EndIf
;     Return None
; EndFunction


; write text to the user log, opening it if necessary
Function Log(string asLogName, string asScript, string asLogMessage, int aiSeverity = 0) DebugOnly Global
    string asSeverity = ""
    If aiSeverity == 0
        ; do nothing
    ElseIf aiSeverity == 1
        asSeverity = "WARNING: "
    ElseIf aiSeverity == 2
        asSeverity = "ERROR: "
    EndIf
    asLogMessage = asSeverity + asScript + ": " + asLogMessage
    If ! Debug.TraceUser(asLogName, asLogMessage)
        ; if log wasn't open, open it, then send trace again
        Debug.OpenUserLog(asLogName)
        Debug.TraceUser(asLogName, asLogMessage)
    EndIf
EndFunction
