;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Terminals:TERM_PJRM2_Settings2800_Luck_01000B0A Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
PortableJunkRecyclerMk2:QuestScript PJRM2 = PortableJunkRecyclerMk2:QuestScript.GetScript()
PJRM2.ChangeSettingHolotape(PJRM2.LckAffectsMult, 0, MessageSettingUpdateOff)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
PortableJunkRecyclerMk2:QuestScript PJRM2 = PortableJunkRecyclerMk2:QuestScript.GetScript()
PJRM2.ChangeSettingHolotape(PJRM2.LckAffectsMult, 1, MessageSettingUpdateOnSimple)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_03
Function Fragment_Terminal_03(ObjectReference akTerminalRef)
;BEGIN CODE
PortableJunkRecyclerMk2:QuestScript PJRM2 = PortableJunkRecyclerMk2:QuestScript.GetScript()
PJRM2.ChangeSettingHolotape(PJRM2.LckAffectsMult, 2, MessageSettingUpdateOnDetailed)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Message Property MessageSettingUpdateOff Auto Const Mandatory

Message Property MessageSettingUpdateOnSimple Auto Const Mandatory

Message Property MessageSettingUpdateOnDetailed Auto Const Mandatory
