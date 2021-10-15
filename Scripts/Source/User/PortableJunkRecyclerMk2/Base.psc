ScriptName PortableJunkRecyclerMk2:Base
{ contains base structs and utility functions used by PortableJunkRecyclerMk2-namespaced scripts }



; STRUCTS
; -------

Struct ComponentMap
    Component ComponentPart
    MiscObject ScrapPart
EndStruct
 
Struct MultiplierSet
    float MultC
    float MultU
    float MultR
    float MultS
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