;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Terminals:TERM_PJRM2_Settings3540_Unco_01000B3C Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
PortableJunkRecyclerMk2:QuestScript PJRM2 = PortableJunkRecyclerMk2:QuestScript.GetScript()
MessageSettingShowFloat2.Show(PJRM2.MultAdjustScrapperSettlementU[0].Value)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
PortableJunkRecyclerMk2:QuestScript PJRM2 = PortableJunkRecyclerMk2:QuestScript.GetScript()
MessageSettingShowFloat2.Show(PJRM2.MultAdjustScrapperNotSettlementU[0].Value)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Message Property MessageSettingShowFloat2 Auto Const Mandatory
