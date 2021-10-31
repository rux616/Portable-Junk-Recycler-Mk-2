ScriptName PortableJunkRecyclerMk2:Base
{ contains base structs and utility functions used by PortableJunkRecyclerMk2-namespaced scripts }



; STRUCTS
; -------

Struct ComponentMap
    Component ComponentPart
    string ComponentPartName
    MiscObject ScrapPart
    string ScrapPartName
    int Rarity
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

Struct SettingBool
    bool Value
    bool ValueDefault
    string McmId
EndStruct

Struct SettingFloat
    float Value
    float ValueDefault
    string McmId
    float ValueMin
    float ValueMax
EndStruct

Struct SettingInt
    int Value
    int ValueDefault
    string McmId
    int ValueMin
    int ValueMax
EndStruct

Struct FormListWrapper
    FormList List
    int Size
EndStruct



; FUNCTIONS
; ---------

; generic interface to change settings
Function ChangeSetting(var akSettingToChange, int aiChangeType, var avNewValue, string asMcmModName) global
    If akSettingToChange is SettingBool
        ChangeSettingBool(akSettingToChange as SettingBool, aiChangeType, avNewValue as bool, asMcmModName)
    ElseIf akSettingToChange is SettingFloat
        ChangeSettingFloat(akSettingToChange as SettingFloat, aiChangeType, avNewValue as float, asMcmModName)
    ElseIf akSettingToChange is SettingInt
        ChangeSettingInt(akSettingToChange as SettingInt, aiChangeType, avNewValue as int, asMcmModName)
    EndIf
EndFunction

; interface to change bool settings
Function ChangeSettingBool(SettingBool akSettingToChange, int aiChangeType, bool abNewValue, string asMcmModName) global
    SettingChangeType availableChangeTypes = new SettingChangeType

    If aiChangeType == availableChangeTypes.ValueOnly || aiChangeType == availableChangeTypes.Both
        akSettingToChange.Value = abNewValue
    EndIf

    If aiChangeType == availableChangeTypes.McmOnly || aiChangeType == availableChangeTypes.Both
        MCM.SetModSettingBool(asMcmModName, akSettingToChange.McmId, abNewValue)
    EndIf
EndFunction

; interface to change float settings
Function ChangeSettingFloat(SettingFloat akSettingToChange, int aiChangeType, float afNewValue, string asMcmModName) global
    SettingChangeType availableChangeTypes = new SettingChangeType

    ; clamp the requested change if too large or too small
    If afNewValue > akSettingToChange.ValueMax
        afNewValue = akSettingToChange.ValueMax
    ElseIf afNewValue < akSettingToChange.ValueMin
        afNewValue = akSettingToChange.ValueMin
    EndIf

    If aiChangeType == availableChangeTypes.ValueOnly || aiChangeType == availableChangeTypes.Both
        akSettingToChange.Value = afNewValue
    EndIf

    If aiChangeType == availableChangeTypes.McmOnly || aiChangeType == availableChangeTypes.Both
        MCM.SetModSettingFloat(asMcmModName, akSettingToChange.McmId, afNewValue)
    EndIf
EndFunction

; interface to change int settings
Function ChangeSettingInt(SettingInt akSettingToChange, int aiChangeType, int aiNewValue, string asMcmModName) global
    SettingChangeType availableChangeTypes = new SettingChangeType

    ; clamp the requested change if too large or too small
    If aiNewValue > akSettingToChange.ValueMax
        aiNewValue = akSettingToChange.ValueMax
    ElseIf aiNewValue < akSettingToChange.ValueMin
        aiNewValue = akSettingToChange.ValueMin
    EndIf

    If aiChangeType == availableChangeTypes.ValueOnly || aiChangeType == availableChangeTypes.Both
        akSettingToChange.Value = aiNewValue
    EndIf

    If aiChangeType == availableChangeTypes.McmOnly || aiChangeType == availableChangeTypes.Both
        MCM.SetModSettingInt(asMcmModName, akSettingToChange.McmId, aiNewValue)
    EndIf
EndFunction

; generic interface to load settings from the MCM
Function LoadSettingFromMCM(var akSetting, string asMcmModName) global
    If akSetting is SettingBool
        LoadSettingBoolFromMCM(akSetting as SettingBool, asMcmModName)
    ElseIf akSetting is SettingFloat
        LoadSettingFloatFromMCM(akSetting as SettingFloat, asMcmModName)
    ElseIf akSetting is SettingInt
        LoadSettingIntFromMCM(akSetting as SettingInt, asMcmModName)
    EndIf
EndFunction

; interface to load bool settings from the MCM
Function LoadSettingBoolFromMCM(SettingBool akSetting, string asMcmModName) global
    SettingChangeType availableChangeTypes = new SettingChangeType
    ChangeSetting(akSetting, availableChangeTypes.ValueOnly, MCM.GetModSettingBool(asMcmModName, akSetting.McmId), asMcmModName)
EndFunction

; interface to load float settings from the MCM
Function LoadSettingFloatFromMCM(SettingFloat akSetting, string asMcmModName) global
    SettingChangeType availableChangeTypes = new SettingChangeType
    ChangeSetting(akSetting, availableChangeTypes.ValueOnly, MCM.GetModSettingFloat(asMcmModName, akSetting.McmId), asMcmModName)
EndFunction

; interface to load int settings from the MCM
Function LoadSettingIntFromMCM(SettingInt akSetting, string asMcmModName) global
    SettingChangeType availableChangeTypes = new SettingChangeType
    ChangeSetting(akSetting, availableChangeTypes.ValueOnly, MCM.GetModSettingInt(asMcmModName, akSetting.McmId), asMcmModName)
EndFunction

; waits for a specified number of threads to finish before returning
Function WaitForThreads(var[] akThreads, int aiNumThreads) global
    ; wait for 0.1s for threads to start up
    Utility.WaitMenuMode(0.1)

    bool waitingOnThreads = true
    int index
    ; loop until threads are finished running
    While waitingOnThreads
        index = 0
        waitingOnThreads = false
        ; check every thread to see if it's still running; short-circuits if one is found running
        While ! waitingOnThreads && index < aiNumThreads
            waitingOnThreads = waitingOnThreads || (akThreads[index] as WorkerThreadBase).IsRunning()
            index += 1
        EndWhile
        ; if any threads are still running, wait for 0.1s
        If waitingOnThreads
            Utility.WaitMenuMode(0.1)
        EndIf
    EndWhile
EndFunction