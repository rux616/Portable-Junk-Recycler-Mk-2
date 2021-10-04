ScriptName PortableJunkRecyclerMk2:Base
{ contains base structs and utility functions used by the PortableJunkRecyclerMk2 namespaced scripts }



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
    GlobalVariable GlobalVar
EndStruct

Struct SettingFloat
    float Value
    float ValueDefault
    string McmId
    GlobalVariable GlobalVar
    float ValueMin
    float ValueMax
EndStruct

Struct SettingInt
    int Value
    int ValueDefault
    string McmId
    GlobalVariable GlobalVar
    int ValueMin
    int ValueMax
EndStruct



; FUNCTIONS
; ---------

; generic interface to change settings
Function ChangeSetting(var akSettingToChange, int aiChangeType, var avNewValue, string asMcmModName, \
        Message akMessage = None) global
    If akSettingToChange is SettingBool
        ChangeSettingBool(akSettingToChange as SettingBool, aiChangeType, avNewValue as bool, asMcmModName, akMessage)
    ElseIf akSettingToChange is SettingFloat
        ChangeSettingFloat(akSettingToChange as SettingFloat, aiChangeType, avNewValue as float, asMcmModName, akMessage)
    ElseIf akSettingToChange is SettingInt
        ChangeSettingInt(akSettingToChange as SettingInt, aiChangeType, avNewValue as int, asMcmModName, akMessage)
    EndIf
EndFunction

; interface to change bool settings
Function ChangeSettingBool(SettingBool akSettingToChange, int aiChangeType, bool abNewValue, string asMcmModName, \
        Message akMessage = None) global
    SettingChangeType availableChangeTypes = new SettingChangeType

    If aiChangeType == availableChangeTypes.ValueOnly || aiChangeType == availableChangeTypes.Both
        akSettingToChange.Value = abNewValue
    EndIf
    
    If aiChangeType == availableChangeTypes.McmOnly || aiChangeType == availableChangeTypes.Both
        var[] params = new var[3]
        params[0] = asMcmModName
        params[1] = akSettingToChange.McmId
        params[2] = abNewValue
        Utility.CallGlobalFunction("MCM", "SetModSettingBool", params)
    EndIf

    If akSettingToChange.GlobalVar
        akSettingToChange.GlobalVar.SetValueInt(abNewValue as int)
    EndIf

    If akMessage
        akMessage.Show(akSettingToChange.Value as int)
    EndIf
EndFunction

; interface to change float settings
Function ChangeSettingFloat(SettingFloat akSettingToChange, int aiChangeType, float afNewValue, string asMcmModName, \
        Message akMessage = None) global
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
        var[] params = new var[3]
        params[0] = asMcmModName
        params[1] = akSettingToChange.McmId
        params[2] = afNewValue
        Utility.CallGlobalFunction("MCM", "SetModSettingFloat", params)
    EndIf

    If akSettingToChange.GlobalVar
        akSettingToChange.GlobalVar.SetValue(afNewValue)
    EndIf

    If akMessage
        akMessage.Show(akSettingToChange.Value)
    EndIf
EndFunction

; interface to change int settings
Function ChangeSettingInt(SettingInt akSettingToChange, int aiChangeType, int aiNewValue, string asMcmModName, \
        Message akMessage = None) global
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
        var[] params = new var[3]
        params[0] = asMcmModName
        params[1] = akSettingToChange.McmId
        params[2] = aiNewValue
        Utility.CallGlobalFunction("MCM", "SetModSettingInt", params)
    EndIf

    If akSettingToChange.GlobalVar
        akSettingToChange.GlobalVar.SetValueInt(aiNewValue)
    EndIf

    If akMessage
        akMessage.Show(akSettingToChange.Value)
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
    var[] params = new var[2]
    params[0] = asMcmModName
    params[1] = akSetting.McmId
    ChangeSetting(akSetting, availableChangeTypes.ValueOnly, \
        Utility.CallGlobalFunction("MCM", "GetModSettingBool", params) as bool, asMcmModName)
    If akSetting.GlobalVar
        akSetting.GlobalVar.SetValueInt(akSetting.Value as int)
    EndIf
EndFunction

; interface to load float settings from the MCM
Function LoadSettingFloatFromMCM(SettingFloat akSetting, string asMcmModName) global
    SettingChangeType availableChangeTypes = new SettingChangeType
    var[] params = new var[2]
    params[0] = asMcmModName
    params[1] = akSetting.McmId
    ChangeSetting(akSetting, availableChangeTypes.ValueOnly, \
        Utility.CallGlobalFunction("MCM", "GetModSettingFloat", params) as float, asMcmModName)
    If akSetting.GlobalVar
        akSetting.GlobalVar.SetValue(akSetting.Value)
    EndIf
EndFunction

; interface to load int settings from the MCM
Function LoadSettingIntFromMCM(SettingInt akSetting, string asMcmModName) global
    SettingChangeType availableChangeTypes = new SettingChangeType
    var[] params = new var[2]
    params[0] = asMcmModName
    params[1] = akSetting.McmId
    ChangeSetting(akSetting, availableChangeTypes.ValueOnly, \
        Utility.CallGlobalFunction("MCM", "GetModSettingInt", params) as int, asMcmModName)
    If akSetting.GlobalVar
        akSetting.GlobalVar.SetValueInt(akSetting.Value)
    EndIf
EndFunction

; convert integer into hexstring with count of 8 numbers
; sample: 842 -> "0000034A"
string Function ConvertIDToHex(int aiID) global
    ; pulled and adapted from code at the following url:
    ; https://forums.nexusmods.com/index.php?/topic/8441118-convert-decimal-formid-to-hexadecimal/page-2#entry78086848
    
    ; 842  = 8*10^2 + 4*10^1 + 2*10^0               ; base 10
    ; 34Ah = 3*16^2 + 4*16^1 + A*16^0               ; base 16
 
    string[] hexDigits = New string[16]
    hexDigits[0] = "0"
    hexDigits[1] = "1"
    hexDigits[2] = "2"
    hexDigits[3] = "3"
    hexDigits[4] = "4"
    hexDigits[5] = "5"
    hexDigits[6] = "6"
    hexDigits[7] = "7"
    hexDigits[8] = "8"
    hexDigits[9] = "9"
    hexDigits[10] = "a"
    hexDigits[11] = "b"
    hexDigits[12] = "c"
    hexDigits[13] = "d"
    hexDigits[14] = "e"
    hexDigits[15] = "f"

    int offset = 0                                  ; digit offset

    If (aiID < 0)                                   ; if negative, adjust offsets
        aiID += 1
        offset = 15
    EndIf

    string toReturn
    int divisor = 0x10000000                        ; init divisor

    While (divisor > 0)
        int interim = aiID / divisor
        toReturn += hexDigits[interim + offset]
        aiID = aiID % divisor                       ; new remainder as result of modulo
        divisor = divisor / 16                      ; new divisor
    EndWhile

    Return toReturn
EndFunction