;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Terminals:TERM_PJRM2_Settings3410_Mini_01000B28 Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
PortableJunkRecyclerMk2:QuestScript PJRM2 = PortableJunkRecyclerMk2:QuestScript.GetScript()
PJRM2.ChangeSettingHolotape(PJRM2.MultAdjustRandomMin, PJRM2.MultAdjustRandomMin.Value + 0.5, MessageSettingUpdateFloat2)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
PortableJunkRecyclerMk2:QuestScript PJRM2 = PortableJunkRecyclerMk2:QuestScript.GetScript()
PJRM2.ChangeSettingHolotape(PJRM2.MultAdjustRandomMin, PJRM2.MultAdjustRandomMin.Value + 0.1, MessageSettingUpdateFloat2)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_03
Function Fragment_Terminal_03(ObjectReference akTerminalRef)
;BEGIN CODE
PortableJunkRecyclerMk2:QuestScript PJRM2 = PortableJunkRecyclerMk2:QuestScript.GetScript()
PJRM2.ChangeSettingHolotape(PJRM2.MultAdjustRandomMin, PJRM2.MultAdjustRandomMin.Value + 0.05, MessageSettingUpdateFloat2)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_04
Function Fragment_Terminal_04(ObjectReference akTerminalRef)
;BEGIN CODE
PortableJunkRecyclerMk2:QuestScript PJRM2 = PortableJunkRecyclerMk2:QuestScript.GetScript()
PJRM2.ChangeSettingHolotape(PJRM2.MultAdjustRandomMin, PJRM2.MultAdjustRandomMin.Value + 0.01, MessageSettingUpdateFloat2)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_05
Function Fragment_Terminal_05(ObjectReference akTerminalRef)
;BEGIN CODE
PortableJunkRecyclerMk2:QuestScript PJRM2 = PortableJunkRecyclerMk2:QuestScript.GetScript()
PJRM2.ChangeSettingHolotape(PJRM2.MultAdjustRandomMin, PJRM2.MultAdjustRandomMin.Value - 0.01, MessageSettingUpdateFloat2)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_06
Function Fragment_Terminal_06(ObjectReference akTerminalRef)
;BEGIN CODE
PortableJunkRecyclerMk2:QuestScript PJRM2 = PortableJunkRecyclerMk2:QuestScript.GetScript()
PJRM2.ChangeSettingHolotape(PJRM2.MultAdjustRandomMin, PJRM2.MultAdjustRandomMin.Value - 0.05, MessageSettingUpdateFloat2)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_07
Function Fragment_Terminal_07(ObjectReference akTerminalRef)
;BEGIN CODE
PortableJunkRecyclerMk2:QuestScript PJRM2 = PortableJunkRecyclerMk2:QuestScript.GetScript()
PJRM2.ChangeSettingHolotape(PJRM2.MultAdjustRandomMin, PJRM2.MultAdjustRandomMin.Value - 0.1, MessageSettingUpdateFloat2)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_08
Function Fragment_Terminal_08(ObjectReference akTerminalRef)
;BEGIN CODE
PortableJunkRecyclerMk2:QuestScript PJRM2 = PortableJunkRecyclerMk2:QuestScript.GetScript()
PJRM2.ChangeSettingHolotape(PJRM2.MultAdjustRandomMin, PJRM2.MultAdjustRandomMin.Value - 0.5, MessageSettingUpdateFloat2)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Message Property MessageSettingUpdateFloat2 Auto Const Mandatory
