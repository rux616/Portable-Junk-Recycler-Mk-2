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



ScriptName PortableJunkRecyclerMk2:PJRM2_SettingManager Extends Quest

; import data structures
import PortableJunkRecyclerMk2:PJRM2_DataStructures
; import utility functions
import PortableJunkRecyclerMk2:PJRM2_Utility



; PROPERTIES
; ----------

Group Settings
    ; settings - general
    float Property MultBase Hidden
        float Function Get()
            Return MultBase_Var.Value
        EndFunction
    EndProperty
    bool Property ReturnAtLeastOneComponent Hidden
        bool Function Get()
            Return ReturnAtLeastOneComponent_Var.Value
        EndFunction
    EndProperty
    int Property FractionalComponentHandling Hidden
        int Function Get()
            Return FractionalComponentHandling_Var.Value
        EndFunction
    EndProperty
    bool Property HasLimitedUses Hidden
        bool Function Get()
            Return HasLimitedUses_Var.Value
        EndFunction
    EndProperty
    int Property NumberOfUses Hidden
        int Function Get()
            Return NumberOfUses_Var.Value
        EndFunction
    EndProperty

    ; settings - adjustment options
    int Property GeneralMultAdjust Hidden
        int Function Get()
            Return GeneralMultAdjust_Var.Value
        EndFunction
    EndProperty
    int Property IntAffectsMult Hidden
        int Function Get()
            Return IntAffectsMult_Var.Value
        EndFunction
    EndProperty
    int Property LckAffectsMult Hidden
        int Function Get()
            Return LckAffectsMult_Var.Value
        EndFunction
    EndProperty
    int Property RngAffectsMult Hidden
        int Function Get()
            Return RngAffectsMult_Var.Value
        EndFunction
    EndProperty
    int Property ScrapperAffectsMult Hidden
        int Function Get()
            Return ScrapperAffectsMult_Var.Value
        EndFunction
    EndProperty

    ; recycler interface - behavior
    bool Property AutoRecyclingMode Hidden
        bool Function Get()
            Return AutoRecyclingMode_Var.Value
        EndFunction
    EndProperty
    bool Property EnableJunkFilter Hidden
        bool Function Get()
            Return EnableJunkFilter_Var.Value
        EndFunction
    EndProperty
    bool Property AutoTransferJunk Hidden
        bool Function Get()
            Return AutoTransferJunk_Var.Value
        EndFunction
    EndProperty
    int Property TransferLowWeightRatioItems Hidden
        int Function Get()
            Return TransferLowWeightRatioItems_Var.Value
        EndFunction
    EndProperty
    bool Property UseAlwaysAutoTransferList Hidden
        bool Function Get()
            Return UseAlwaysAutoTransferList_Var.Value
        EndFunction
    EndProperty
    bool Property UseNeverAutoTransferList Hidden
        bool Function Get()
            Return UseNeverAutoTransferList_Var.Value
        EndFunction
    EndProperty
    bool Property EnableAutoTransferListEditing Hidden
        bool Function Get()
            Return EnableAutoTransferListEditing_Var.Value
        EndFunction
    EndProperty
    bool Property EnableBehaviorOverrides Hidden
        bool Function Get()
            Return EnableBehaviorOverrides_Var.Value
        EndFunction
    EndProperty
    float Property ModifierReadDelay Hidden
        float Function Get()
            Return ModifierReadDelay_Var.Value
        EndFunction
    EndProperty
    bool Property ReturnItemsSilently Hidden
        bool Function Get()
            Return ReturnItemsSilently_Var.Value
        EndFunction
    EndProperty
    int Property InventoryRemovalProtection Hidden
        int Function Get()
            Return InventoryRemovalProtection_Var.Value
        EndFunction
    EndProperty

    ; recycler interface - crafting
    bool Property UseSimpleCraftingRecipe Hidden
        bool Function Get()
            Return UseSimpleCraftingRecipe_Var.Value
        EndFunction
    EndProperty
    int Property CraftingStation Hidden
        int Function Get()
            Return CraftingStation_Var.Value
        EndFunction
    EndProperty

    ; multiplier adjustments - general
    float Property MultAdjustGeneralSettlement Hidden
        float Function Get()
            Return MultAdjustGeneralSettlement_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustGeneralSettlementC Hidden
        float Function Get()
            Return MultAdjustGeneralSettlementC_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustGeneralSettlementU Hidden
        float Function Get()
            Return MultAdjustGeneralSettlementU_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustGeneralSettlementR Hidden
        float Function Get()
            Return MultAdjustGeneralSettlementR_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustGeneralSettlementS Hidden
        float Function Get()
            Return MultAdjustGeneralSettlementS_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustGeneralNotSettlement Hidden
        float Function Get()
            Return MultAdjustGeneralNotSettlement_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustGeneralNotSettlementC Hidden
        float Function Get()
            Return MultAdjustGeneralNotSettlementC_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustGeneralNotSettlementU Hidden
        float Function Get()
            Return MultAdjustGeneralNotSettlementU_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustGeneralNotSettlementR Hidden
        float Function Get()
            Return MultAdjustGeneralNotSettlementR_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustGeneralNotSettlementS Hidden
        float Function Get()
            Return MultAdjustGeneralNotSettlementS_Var.Value
        EndFunction
    EndProperty

    ; multiplier adjustments - intelligence
    float Property MultAdjustInt Hidden
        float Function Get()
            Return MultAdjustInt_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustIntC Hidden
        float Function Get()
            Return MultAdjustIntC_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustIntU Hidden
        float Function Get()
            Return MultAdjustIntU_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustIntR Hidden
        float Function Get()
            Return MultAdjustIntR_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustIntS Hidden
        float Function Get()
            Return MultAdjustIntS_Var.Value
        EndFunction
    EndProperty

    ; multiplier adjustments - luck
    float Property MultAdjustLck Hidden
        float Function Get()
            Return MultAdjustLck_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustLckC Hidden
        float Function Get()
            Return MultAdjustLckC_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustLckU Hidden
        float Function Get()
            Return MultAdjustLckU_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustLckR Hidden
        float Function Get()
            Return MultAdjustLckR_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustLckS Hidden
        float Function Get()
            Return MultAdjustLckS_Var.Value
        EndFunction
    EndProperty

    ; multiplier adjustments - randomness
    float Property MultAdjustRandomMin Hidden
        float Function Get()
            Return MultAdjustRandomMin_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustRandomMinC Hidden
        float Function Get()
            Return MultAdjustRandomMinC_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustRandomMinU Hidden
        float Function Get()
            Return MultAdjustRandomMinU_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustRandomMinR Hidden
        float Function Get()
            Return MultAdjustRandomMinR_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustRandomMinS Hidden
        float Function Get()
            Return MultAdjustRandomMinS_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustRandomMax Hidden
        float Function Get()
            Return MultAdjustRandomMax_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustRandomMaxC Hidden
        float Function Get()
            Return MultAdjustRandomMaxC_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustRandomMaxU Hidden
        float Function Get()
            Return MultAdjustRandomMaxU_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustRandomMaxR Hidden
        float Function Get()
            Return MultAdjustRandomMaxR_Var.Value
        EndFunction
    EndProperty
    float Property MultAdjustRandomMaxS Hidden
        float Function Get()
            Return MultAdjustRandomMaxS_Var.Value
        EndFunction
    EndProperty

    ; multiplier adjustments - scrapper
    float[] Property MultAdjustScrapperSettlement Hidden
        float[] Function Get()
            float[] toReturn = new float[MultAdjustScrapperSettlement_Var.Length]
            int index = 0
            While index < MultAdjustScrapperSettlement_Var.Length
                toReturn[index] = MultAdjustScrapperSettlement_Var[index].Value
                index += 1
            EndWhile
            Return toReturn
        EndFunction
    EndProperty
    float[] Property MultAdjustScrapperSettlementC Hidden
        float[] Function Get()
            float[] toReturn = new float[MultAdjustScrapperSettlementC_Var.Length]
            int index = 0
            While index < MultAdjustScrapperSettlementC_Var.Length
                toReturn[index] = MultAdjustScrapperSettlementC_Var[index].Value
                index += 1
            EndWhile
            Return toReturn
        EndFunction
    EndProperty
    float[] Property MultAdjustScrapperSettlementU Hidden
        float[] Function Get()
            float[] toReturn = new float[MultAdjustScrapperSettlementU_Var.Length]
            int index = 0
            While index < MultAdjustScrapperSettlementU_Var.Length
                toReturn[index] = MultAdjustScrapperSettlementU_Var[index].Value
                index += 1
            EndWhile
            Return toReturn
        EndFunction
    EndProperty
    float[] Property MultAdjustScrapperSettlementR Hidden
        float[] Function Get()
            float[] toReturn = new float[MultAdjustScrapperSettlementR_Var.Length]
            int index = 0
            While index < MultAdjustScrapperSettlementR_Var.Length
                toReturn[index] = MultAdjustScrapperSettlementR_Var[index].Value
                index += 1
            EndWhile
            Return toReturn
        EndFunction
    EndProperty
    float[] Property MultAdjustScrapperSettlementS Hidden
        float[] Function Get()
            float[] toReturn = new float[MultAdjustScrapperSettlementS_Var.Length]
            int index = 0
            While index < MultAdjustScrapperSettlementS_Var.Length
                toReturn[index] = MultAdjustScrapperSettlementS_Var[index].Value
                index += 1
            EndWhile
            Return toReturn
        EndFunction
    EndProperty
    float[] Property MultAdjustScrapperNotSettlement Hidden
        float[] Function Get()
            float[] toReturn = new float[MultAdjustScrapperNotSettlement_Var.Length]
            int index = 0
            While index < MultAdjustScrapperNotSettlement_Var.Length
                toReturn[index] = MultAdjustScrapperNotSettlement_Var[index].Value
                index += 1
            EndWhile
            Return toReturn
        EndFunction
    EndProperty
    float[] Property MultAdjustScrapperNotSettlementC Hidden
        float[] Function Get()
            float[] toReturn = new float[MultAdjustScrapperNotSettlementC_Var.Length]
            int index = 0
            While index < MultAdjustScrapperNotSettlementC_Var.Length
                toReturn[index] = MultAdjustScrapperNotSettlementC_Var[index].Value
                index += 1
            EndWhile
            Return toReturn
        EndFunction
    EndProperty
    float[] Property MultAdjustScrapperNotSettlementU Hidden
        float[] Function Get()
            float[] toReturn = new float[MultAdjustScrapperNotSettlementU_Var.Length]
            int index = 0
            While index < MultAdjustScrapperNotSettlementU_Var.Length
                toReturn[index] = MultAdjustScrapperNotSettlementU_Var[index].Value
                index += 1
            EndWhile
            Return toReturn
        EndFunction
    EndProperty
    float[] Property MultAdjustScrapperNotSettlementR Hidden
        float[] Function Get()
            float[] toReturn = new float[MultAdjustScrapperNotSettlementR_Var.Length]
            int index = 0
            While index < MultAdjustScrapperNotSettlementR_Var.Length
                toReturn[index] = MultAdjustScrapperNotSettlementR_Var[index].Value
                index += 1
            EndWhile
            Return toReturn
        EndFunction
    EndProperty
    float[] Property MultAdjustScrapperNotSettlementS Hidden
        float[] Function Get()
            float[] toReturn = new float[MultAdjustScrapperNotSettlementS_Var.Length]
            int index = 0
            While index < MultAdjustScrapperNotSettlementS_Var.Length
                toReturn[index] = MultAdjustScrapperNotSettlementS_Var[index].Value
                index += 1
            EndWhile
            Return toReturn
        EndFunction
    EndProperty

    ; advanced - general options
    int Property ThreadLimit Hidden
        int Function Get()
            Return ThreadLimit_Var.Value
        EndFunction
    EndProperty
    bool Property EnableLogging Hidden
        bool Function Get()
            If ! EnableLogging_Var
                Return EnableLoggingDefault
            Else
                Return EnableLogging_Var.Value
            EndIf
        EndFunction
    EndProperty
    bool Property EnableProfiling Hidden
        bool Function Get()
            If ! EnableProfiling_Var
                Return EnableProfilingDefault
            Else
                Return EnableProfiling_Var.Value
            EndIf
        EndFunction
    EndProperty

    ; advanced - methodology
    bool Property UseDirectMoveRecyclableItemListUpdate Hidden
        bool Function Get()
            Return UseDirectMoveRecyclableItemListUpdate_Var.Value
        EndFunction
    EndProperty
EndGroup

Group RuntimeState
    bool Property MCM_GeneralMultAdjustSimple Auto Hidden
    bool Property MCM_GeneralMultAdjustDetailed Auto Hidden
    bool Property MCM_IntAffectsMultSimple Auto Hidden
    bool Property MCM_IntAffectsMultDetailed Auto Hidden
    bool Property MCM_LckAffectsMultSimple Auto Hidden
    bool Property MCM_LckAffectsMultDetailed Auto Hidden
    bool Property MCM_RngAffectsMultSimple Auto Hidden
    bool Property MCM_RngAffectsMultDetailed Auto Hidden
    bool Property MCM_ScrapperAffectsMultSimple Auto Hidden
    bool Property MCM_ScrapperAffectsMultDetailed Auto Hidden
    bool Property MCM_Scrapper3Available Auto Hidden
    bool Property MCM_Scrapper4Available Auto Hidden
    bool Property MCM_Scrapper5Available Auto Hidden
EndGroup

Group Other
    int Property ScrapperPerkMaxRanksSupported = 5 AutoReadOnly
    string Property ModName = "Portable Junk Recycler Mk 2" AutoReadOnly
    string Property FullScriptName = "PortableJunkRecyclerMk2:PJRM2_SettingManager" AutoReadOnly
    ConstructibleObject Property PortableJunkRecyclerConstructibleObject Auto Mandatory
    ConstructibleObject Property PortableJunkRecyclerConstructibleObjectSimple Auto Mandatory
    Keyword Property NullWorkbenchKeyword Auto Mandatory
    bool Property PreInitialized = false Auto
    bool Property Initialized = false Auto
EndGroup



; VARIABLES: PROPERTIES
; ---------------------

; settings - general
SettingFloat MultBase_Var
SettingBool ReturnAtLeastOneComponent_Var
SettingInt FractionalComponentHandling_Var
SettingBool HasLimitedUses_Var
SettingInt NumberOfUses_Var

; settings - adjustment options
SettingInt GeneralMultAdjust_Var
SettingInt IntAffectsMult_Var
SettingInt LckAffectsMult_Var
SettingInt RngAffectsMult_Var
SettingInt ScrapperAffectsMult_Var

; recycler interface - behavior
SettingBool AutoRecyclingMode_Var
SettingBool EnableJunkFilter_Var
SettingBool AutoTransferJunk_Var
SettingInt TransferLowWeightRatioItems_Var
SettingBool UseAlwaysAutoTransferList_Var
SettingBool UseNeverAutoTransferList_Var
SettingBool EnableAutoTransferListEditing_Var
SettingBool EnableBehaviorOverrides_Var
SettingFloat ModifierReadDelay_Var
SettingBool ReturnItemsSilently_Var
SettingInt InventoryRemovalProtection_Var

; recycler interface - crafting
SettingBool UseSimpleCraftingRecipe_Var
SettingInt CraftingStation_Var

; multiplier adjustments - general
SettingFloat MultAdjustGeneralSettlement_Var
SettingFloat MultAdjustGeneralSettlementC_Var
SettingFloat MultAdjustGeneralSettlementU_Var
SettingFloat MultAdjustGeneralSettlementR_Var
SettingFloat MultAdjustGeneralSettlementS_Var
SettingFloat MultAdjustGeneralNotSettlement_Var
SettingFloat MultAdjustGeneralNotSettlementC_Var
SettingFloat MultAdjustGeneralNotSettlementU_Var
SettingFloat MultAdjustGeneralNotSettlementR_Var
SettingFloat MultAdjustGeneralNotSettlementS_Var

; multiplier adjustments - intelligence
SettingFloat MultAdjustInt_Var
SettingFloat MultAdjustIntC_Var
SettingFloat MultAdjustIntU_Var
SettingFloat MultAdjustIntR_Var
SettingFloat MultAdjustIntS_Var

; multiplier adjustments - luck
SettingFloat MultAdjustLck_Var
SettingFloat MultAdjustLckC_Var
SettingFloat MultAdjustLckU_Var
SettingFloat MultAdjustLckR_Var
SettingFloat MultAdjustLckS_Var

; multiplier adjustments - randomness
SettingFloat MultAdjustRandomMin_Var
SettingFloat MultAdjustRandomMinC_Var
SettingFloat MultAdjustRandomMinU_Var
SettingFloat MultAdjustRandomMinR_Var
SettingFloat MultAdjustRandomMinS_Var
SettingFloat MultAdjustRandomMax_Var
SettingFloat MultAdjustRandomMaxC_Var
SettingFloat MultAdjustRandomMaxU_Var
SettingFloat MultAdjustRandomMaxR_Var
SettingFloat MultAdjustRandomMaxS_Var

; multiplier adjustments - scrapper
SettingFloat[] MultAdjustScrapperSettlement_Var
SettingFloat[] MultAdjustScrapperSettlementC_Var
SettingFloat[] MultAdjustScrapperSettlementU_Var
SettingFloat[] MultAdjustScrapperSettlementR_Var
SettingFloat[] MultAdjustScrapperSettlementS_Var
SettingFloat[] MultAdjustScrapperNotSettlement_Var
SettingFloat[] MultAdjustScrapperNotSettlementC_Var
SettingFloat[] MultAdjustScrapperNotSettlementU_Var
SettingFloat[] MultAdjustScrapperNotSettlementR_Var
SettingFloat[] MultAdjustScrapperNotSettlementS_Var

; advanced - general options
SettingInt ThreadLimit_Var
SettingBool EnableLogging_Var
SettingBool EnableProfiling_Var

; advanced - methodology
SettingBool UseDirectMoveRecyclableItemListUpdate_Var



; VARIABLES
; ---------

PJRM2_ControlManager ControlManager
PJRM2_ThreadManager ThreadManager
PJRM2_ContainerManager ContainerManager
bool EnableLoggingDefault = false const
bool EnableProfilingDefault = false const

SettingChangeType AvailableChangeTypes

bool ProfilingActive = false



; EVENTS
; ------

Event OnInit()
    ControlManager = (Self as Quest) as PJRM2_ControlManager
    ThreadManager = (Self as Quest) as PJRM2_ThreadManager
    ContainerManager = (Self as Quest) as PJRM2_ContainerManager

    ; set up default logging
    EnableLogging_Var = new SettingBool
    EnableLogging_Var.Value = EnableLoggingDefault
    ; set up default profiling
    EnableProfiling_Var = new SettingBool
    EnableProfiling_Var.Value = EnableProfilingDefault
    ; mark script pre-initialization as complete
    PreInitialized = true
EndEvent

Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
    If asMenuName == "PauseMenu" && ! abOpening
        Self._Log("Pause menu closing")
        Self.MultAdjustRandomSanityCheck()
    EndIf
EndEvent



; FUNCTIONS
; ---------

; add a bit of text to traces going into the papyrus user log
Function _Log(string asMessage, int aiSeverity = 0, bool abForce = false) DebugOnly
    If EnableLogging_Var.Value || abForce
        Log(ModName, "SettingManager", asMessage, aiSeverity)
    EndIf
EndFunction

; start stack profiling
Function _StartStackProfiling() DebugOnly
    If EnableProfiling
        Debug.StartStackProfiling()
        ProfilingActive = true
        Self._Log("Stack profiling started")
    EndIf
EndFunction

; stop stack profiling
Function _StopStackProfiling() DebugOnly
    If ProfilingActive
        Debug.StopStackProfiling()
        ProfilingActive = false
        Self._Log("Stack profiling stopped")
    EndIf
EndFunction

; main initialization
Function Initialize(bool abQuestInit = false)
    Self.InitVariables(abForce = abQuestInit)
    Self.InitSettings(abForce = abQuestInit)
    Self.InitSettingsSupplemental()
    Self.LoadAllSettingsFromMCM()
    ; manually run the Crafting Station callback to resolve any weirdness that may have occurred
    ; due to multithreaded loading of the MCM settings
    Self.CallbackCraftingStation()
    Self.RegisterForMCMEvents()
    If abQuestInit
        RegisterForMenuOpenCloseEvent("PauseMenu")
    EndIf
    Initialized = true
EndFunction

; initialize script-internal variables
Function InitVariables(bool abForce = false)
    Self._Log("Initializing variables")
    If abForce || ! AvailableChangeTypes
        Self._Log("Initializing AvailableChangeTypes")
        AvailableChangeTypes = new SettingChangeType
    EndIf
EndFunction

; initialize properties that hold settings
Function InitSettings(bool abForce = false)
    Self._Log("Initializing settings")

    ; settings - general
    If abForce || ! MultBase_Var
        Self._Log("Initializing MultBase_Var")
        MultBase_Var = new SettingFloat
    EndIf
    If abForce || ! ReturnAtLeastOneComponent_Var
        Self._Log("Initializing ReturnAtLeastOneComponent_Var")
        ReturnAtLeastOneComponent_Var = new SettingBool
    EndIf
    If abForce || ! FractionalComponentHandling_Var
        Self._Log("Initializing FractionalComponentHandling_Var")
        FractionalComponentHandling_Var = new SettingInt
    EndIf
    If abForce || ! HasLimitedUses_Var
        Self._Log("Initializing HasLimitedUses_Var")
        HasLimitedUses_Var = new SettingBool
    EndIf
    If abForce || ! NumberOfUses_Var
        Self._Log("Initializing NumberOfUses_Var")
        NumberOfUses_Var = new SettingInt
    EndIf

    ; settings - adjustment options
    If abForce || ! GeneralMultAdjust_Var
        Self._Log("Initializing GeneralMultAdjust_Var")
        GeneralMultAdjust_Var = new SettingInt
    EndIf
    If abForce || ! IntAffectsMult_Var
        Self._Log("Initializing IntAffectsMult_Var")
        IntAffectsMult_Var = new SettingInt
    EndIf
    If abForce || ! LckAffectsMult_Var
        Self._Log("Initializing LckAffectsMult_Var")
        LckAffectsMult_Var = new SettingInt
    EndIf
    If abForce || ! RngAffectsMult_Var
        Self._Log("Initializing RngAffectsMult_Var")
        RngAffectsMult_Var = new SettingInt
    EndIf
    If abForce || ! ScrapperAffectsMult_Var
        Self._Log("Initializing ScrapperAffectsMult_Var")
        ScrapperAffectsMult_Var = new SettingInt
    EndIf

    ; recycler interface - behavior
    If abForce || ! AutoRecyclingMode_Var
        Self._Log("Initializing AutoRecyclingMode_Var")
        AutoRecyclingMode_Var = new SettingBool
    EndIf
    If abForce || ! EnableJunkFilter_Var
        Self._Log("Initializing EnableJunkFilter_Var")
        EnableJunkFilter_Var = new SettingBool
    EndIf
    If abForce || ! AutoTransferJunk_Var
        Self._Log("Initializing AutoTransferJunk_Var")
        AutoTransferJunk_Var = new SettingBool
    EndIf
    If abForce || ! TransferLowWeightRatioItems_Var
        Self._Log("Initializing TransferLowWeightRatioItems_Var")
        TransferLowWeightRatioItems_Var = new SettingInt
    EndIf
    If abForce || ! UseAlwaysAutoTransferList_Var
        Self._Log("Initializing UseAlwaysAutoTransferList_Var")
        UseAlwaysAutoTransferList_Var = new SettingBool
    EndIf
    If abForce || ! UseNeverAutoTransferList_Var
        Self._Log("Initializing UseNeverAutoTransferList_Var")
        UseNeverAutoTransferList_Var = new SettingBool
    EndIf
    If abForce || ! EnableAutoTransferListEditing_Var
        Self._Log("Initializing EnableAutoTransferListEditing_Var")
        EnableAutoTransferListEditing_Var = new SettingBool
    EndIf
    If abForce || ! EnableBehaviorOverrides_Var
        Self._Log("Initializing EnableBehaviorOverrides_Var")
        EnableBehaviorOverrides_Var = new SettingBool
    EndIf
    if abForce || ! ModifierReadDelay_Var
        Self._Log("Initializing ModifierReadDelay_Var")
        ModifierReadDelay_Var = new SettingFloat
    EndIf
    If abForce || ! ReturnItemsSilently_Var
        Self._Log("Initializing ReturnItemsSilently_Var")
        ReturnItemsSilently_Var = new SettingBool
    EndIf
    If abForce || ! InventoryRemovalProtection_Var
        Self._Log("Initializing InventoryRemovalProtection_Var")
        InventoryRemovalProtection_Var = new SettingInt
    EndIf

    ; recycler interface - crafting
    if abForce || ! UseSimpleCraftingRecipe_Var
        Self._Log("Initializing UseSimpleCraftingRecipe_Var")
        UseSimpleCraftingRecipe_Var = new SettingBool
    EndIf
    if abForce || ! CraftingStation_Var
        Self._Log("Initializing CraftingStation_Var")
        CraftingStation_Var = new SettingInt
    EndIf

    ; multiplier adjustments - general
    If abForce || ! MultAdjustGeneralSettlement_Var
        Self._Log("Initializing MultAdjustGeneralSettlement_Var")
        MultAdjustGeneralSettlement_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustGeneralSettlementC_Var
        Self._Log("Initializing MultAdjustGeneralSettlementC_Var")
        MultAdjustGeneralSettlementC_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustGeneralSettlementU_Var
        Self._Log("Initializing MultAdjustGeneralSettlementU_Var")
        MultAdjustGeneralSettlementU_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustGeneralSettlementR_Var
        Self._Log("Initializing MultAdjustGeneralSettlementR_Var")
        MultAdjustGeneralSettlementR_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustGeneralSettlementS_Var
        Self._Log("Initializing MultAdjustGeneralSettlementS_Var")
        MultAdjustGeneralSettlementS_Var = new SettingFloat
    EndIf

    If abForce || ! MultAdjustGeneralNotSettlement_Var
        Self._Log("Initializing MultAdjustGeneralNotSettlement_Var")
        MultAdjustGeneralNotSettlement_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustGeneralNotSettlementC_Var
        Self._Log("Initializing MultAdjustGeneralNotSettlementC_Var")
        MultAdjustGeneralNotSettlementC_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustGeneralNotSettlementU_Var
        Self._Log("Initializing MultAdjustGeneralNotSettlementU_Var")
        MultAdjustGeneralNotSettlementU_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustGeneralNotSettlementR_Var
        Self._Log("Initializing MultAdjustGeneralNotSettlementR_Var")
        MultAdjustGeneralNotSettlementR_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustGeneralNotSettlementS_Var
        Self._Log("Initializing MultAdjustGeneralNotSettlementS_Var")
        MultAdjustGeneralNotSettlementS_Var = new SettingFloat
    EndIf

    ; multiplier adjustments - intelligence
    If abForce || ! MultAdjustInt_Var
        Self._Log("Initializing MultAdjustInt_Var")
        MultAdjustInt_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustIntC_Var
        Self._Log("Initializing MultAdjustIntC_Var")
        MultAdjustIntC_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustIntU_Var
        Self._Log("Initializing MultAdjustIntU_Var")
        MultAdjustIntU_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustIntR_Var
        Self._Log("Initializing MultAdjustIntR_Var")
        MultAdjustIntR_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustIntS_Var
        Self._Log("Initializing MultAdjustIntS_Var")
        MultAdjustIntS_Var = new SettingFloat
    EndIf

    ; multiplier adjustments - luck
    If abForce || ! MultAdjustLck_Var
        Self._Log("Initializing MultAdjustLck_Var")
        MultAdjustLck_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustLckC_Var
        Self._Log("Initializing MultAdjustLckC_Var")
        MultAdjustLckC_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustLckU_Var
        Self._Log("Initializing MultAdjustLckU_Var")
        MultAdjustLckU_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustLckR_Var
        Self._Log("Initializing MultAdjustLckR_Var")
        MultAdjustLckR_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustLckS_Var
        Self._Log("Initializing MultAdjustLckS_Var")
        MultAdjustLckS_Var = new SettingFloat
    EndIf

    ; multiplier adjustments - randomness
    If abForce || ! MultAdjustRandomMin_Var
        Self._Log("Initializing MultAdjustRandomMin_Var")
        MultAdjustRandomMin_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustRandomMinC_Var
        Self._Log("Initializing MultAdjustRandomMinC_Var")
        MultAdjustRandomMinC_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustRandomMinU_Var
        Self._Log("Initializing MultAdjustRandomMinU_Var")
        MultAdjustRandomMinU_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustRandomMinR_Var
        Self._Log("Initializing MultAdjustRandomMinR_Var")
        MultAdjustRandomMinR_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustRandomMinS_Var
        Self._Log("Initializing MultAdjustRandomMinS_Var")
        MultAdjustRandomMinS_Var = new SettingFloat
    EndIf

    If abForce || ! MultAdjustRandomMax_Var
        Self._Log("Initializing MultAdjustRandomMax_Var")
        MultAdjustRandomMax_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustRandomMaxC_Var
        Self._Log("Initializing MultAdjustRandomMaxC_Var")
        MultAdjustRandomMaxC_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustRandomMaxU_Var
        Self._Log("Initializing MultAdjustRandomMaxU_Var")
        MultAdjustRandomMaxU_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustRandomMaxR_Var
        Self._Log("Initializing MultAdjustRandomMaxR_Var")
        MultAdjustRandomMaxR_Var = new SettingFloat
    EndIf
    If abForce || ! MultAdjustRandomMaxS_Var
        Self._Log("Initializing MultAdjustRandomMaxS_Var")
        MultAdjustRandomMaxS_Var = new SettingFloat
    EndIf

    ; multiplier adjustments - scrapper 1-5
    If abForce || ! MultAdjustScrapperSettlement_Var
        Self._Log("Initializing MultAdjustScrapperSettlement_Var")
        MultAdjustScrapperSettlement_Var = new SettingFloat[ScrapperPerkMaxRanksSupported]
    EndIf
    If abForce || ! MultAdjustScrapperSettlementC_Var
        Self._Log("Initializing MultAdjustScrapperSettlementC_Var")
        MultAdjustScrapperSettlementC_Var = new SettingFloat[ScrapperPerkMaxRanksSupported]
    EndIf
    If abForce || ! MultAdjustScrapperSettlementU_Var
        Self._Log("Initializing MultAdjustScrapperSettlementU_Var")
        MultAdjustScrapperSettlementU_Var = new SettingFloat[ScrapperPerkMaxRanksSupported]
    EndIf
    If abForce || ! MultAdjustScrapperSettlementR_Var
        Self._Log("Initializing MultAdjustScrapperSettlementR_Var")
        MultAdjustScrapperSettlementR_Var = new SettingFloat[ScrapperPerkMaxRanksSupported]
    EndIf
    If abForce || ! MultAdjustScrapperSettlementS_Var
        Self._Log("Initializing MultAdjustScrapperSettlementS_Var")
        MultAdjustScrapperSettlementS_Var = new SettingFloat[ScrapperPerkMaxRanksSupported]
    EndIf

    If abForce || ! MultAdjustScrapperNotSettlement_Var
        Self._Log("Initializing MultAdjustScrapperNotSettlement_Var")
        MultAdjustScrapperNotSettlement_Var = new SettingFloat[ScrapperPerkMaxRanksSupported]
    EndIf
    If abForce || ! MultAdjustScrapperNotSettlementC_Var
        Self._Log("Initializing MultAdjustScrapperNotSettlementC_Var")
        MultAdjustScrapperNotSettlementC_Var = new SettingFloat[ScrapperPerkMaxRanksSupported]
    EndIf
    If abForce || ! MultAdjustScrapperNotSettlementU_Var
        Self._Log("Initializing MultAdjustScrapperNotSettlementU_Var")
        MultAdjustScrapperNotSettlementU_Var = new SettingFloat[ScrapperPerkMaxRanksSupported]
    EndIf
    If abForce || ! MultAdjustScrapperNotSettlementR_Var
        Self._Log("Initializing MultAdjustScrapperNotSettlementR_Var")
        MultAdjustScrapperNotSettlementR_Var = new SettingFloat[ScrapperPerkMaxRanksSupported]
    EndIf
    If abForce || ! MultAdjustScrapperNotSettlementS_Var
        Self._Log("Initializing MultAdjustScrapperNotSettlementS_Var")
        MultAdjustScrapperNotSettlementS_Var = new SettingFloat[ScrapperPerkMaxRanksSupported]
    EndIf

    int index = 0
    While index < ScrapperPerkMaxRanksSupported
        If abForce || ! MultAdjustScrapperSettlement_Var[index]
            Self._Log("Initializing MultAdjustScrapperSettlement_Var[" + index + "]")
            MultAdjustScrapperSettlement_Var[index] = new SettingFloat
        EndIf
        If abForce || ! MultAdjustScrapperSettlementC_Var[index]
            Self._Log("Initializing MultAdjustScrapperSettlementC_Var[" + index + "]")
            MultAdjustScrapperSettlementC_Var[index] = new SettingFloat
        EndIf
        If abForce || ! MultAdjustScrapperSettlementU_Var[index]
            Self._Log("Initializing MultAdjustScrapperSettlementU_Var[" + index + "]")
            MultAdjustScrapperSettlementU_Var[index] = new SettingFloat
        EndIf
        If abForce || ! MultAdjustScrapperSettlementR_Var[index]
            Self._Log("Initializing MultAdjustScrapperSettlementR_Var[" + index + "]")
            MultAdjustScrapperSettlementR_Var[index] = new SettingFloat
        EndIf
        If abForce || ! MultAdjustScrapperSettlementS_Var[index]
            Self._Log("Initializing MultAdjustScrapperSettlementS_Var[" + index + "]")
            MultAdjustScrapperSettlementS_Var[index] = new SettingFloat
        EndIf

        If abForce || ! MultAdjustScrapperNotSettlement_Var[index]
            Self._Log("Initializing MultAdjustScrapperNotSettlement_Var[" + index + "]")
            MultAdjustScrapperNotSettlement_Var[index] = new SettingFloat
        EndIf
        If abForce || ! MultAdjustScrapperNotSettlementC_Var[index]
            Self._Log("Initializing MultAdjustScrapperNotSettlementC_Var[" + index + "]")
            MultAdjustScrapperNotSettlementC_Var[index] = new SettingFloat
        EndIf
        If abForce || ! MultAdjustScrapperNotSettlementU_Var[index]
            Self._Log("Initializing MultAdjustScrapperNotSettlementU_Var[" + index + "]")
            MultAdjustScrapperNotSettlementU_Var[index] = new SettingFloat
        EndIf
        If abForce || ! MultAdjustScrapperNotSettlementR_Var[index]
            Self._Log("Initializing MultAdjustScrapperNotSettlementR_Var[" + index + "]")
            MultAdjustScrapperNotSettlementR_Var[index] = new SettingFloat
        EndIf
        If abForce || ! MultAdjustScrapperNotSettlementS_Var[index]
            Self._Log("Initializing MultAdjustScrapperNotSettlementS_Var[" + index + "]")
            MultAdjustScrapperNotSettlementS_Var[index] = new SettingFloat
        EndIf

        index += 1
    EndWhile

    ; advanced - general options
    If abForce || ! ThreadLimit_Var
        Self._Log("Initializing ThreadLimit_Var")
        ThreadLimit_Var = new SettingInt
    EndIf
    If abForce || ! EnableLogging_Var
        Self._Log("Initializing EnableLogging_Var")
        EnableLogging_Var = new SettingBool
        EnableLogging_Var.Value = EnableLoggingDefault
    EndIf
    If abForce || ! EnableProfiling_Var
        Self._Log("Initializing EnableProfiling_Var")
        EnableProfiling_Var = new SettingBool
    EndIf

    ; advanced - methodology
    If abForce || ! UseDirectMoveRecyclableItemListUpdate_Var
        Self._Log("Initializing UseDirectMoveRecyclableItemListUpdate_Var")
        UseDirectMoveRecyclableItemListUpdate_Var = new SettingBool
    EndIf
EndFunction

; perform supplemental initialization on properties that hold settings
Function InitSettingsSupplemental()
    Self._Log("Initializing settings (supplemental)")

    SettingCallbackType availableCallbackTypes = new SettingCallbackType
    SettingCallbackArgumentType availableCallbackArgumentTypes = new SettingCallbackArgumentType
    float adjustMin = -2.0 const
    float adjustMax = 2.0 const
    float statAdjustMin = 0.0 const
    float statAdjustMax = 1.0 const
    float randomAdjustMin = -6.0 const
    float randomAdjustMax = 6.0 const

    ; settings - general
    MultBase_Var.ValueDefault = 1.0
    MultBase_Var.McmId = "fMultBase:GeneralOptions"
    MultBase_Var.ValueMin = 0.0
    MultBase_Var.ValueMax = adjustMax

    ReturnAtLeastOneComponent_Var.ValueDefault = true
    ReturnAtLeastOneComponent_Var.McmId = "bReturnAtLeastOneComponent:GeneralOptions"

    FractionalComponentHandling_Var.ValueDefault = 2
    FractionalComponentHandling_Var.McmId = "iFractionalComponentHandling:GeneralOptions"
    FractionalComponentHandling_Var.ValueMin = 0
    FractionalComponentHandling_Var.ValueMax = 2

    HasLimitedUses_Var.ValueDefault = false
    HasLimitedUses_Var.McmId = "bHasLimitedUses:GeneralOptions"

    NumberOfUses_Var.ValueDefault = 50
    NumberOfUses_Var.McmId = "iNumberOfUses:GeneralOptions"
    NumberOfUses_Var.ValueMin = 1
    NumberOfUses_Var.ValueMax = 200

    ; settings - adjustment options
    GeneralMultAdjust_Var.ValueDefault = 0
    GeneralMultAdjust_Var.McmId = "iGeneralMultAdjust:AdjustmentOptions"
    GeneralMultAdjust_Var.ValueMin = 0
    GeneralMultAdjust_Var.ValueMax = 1
    GeneralMultAdjust_Var.CallbackType = availableCallbackTypes.FunctionCallback
    GeneralMultAdjust_Var.CallbackForm = Self
    GeneralMultAdjust_Var.CallbackScript = FullScriptName
    GeneralMultAdjust_Var.CallbackFunction = "CallbackGeneralMultAdjust"

    IntAffectsMult_Var.ValueDefault = 1
    IntAffectsMult_Var.McmId = "iIntAffectsMult:AdjustmentOptions"
    IntAffectsMult_Var.ValueMin = 0
    IntAffectsMult_Var.ValueMax = 2
    IntAffectsMult_Var.CallbackType = availableCallbackTypes.FunctionCallback
    IntAffectsMult_Var.CallbackForm = Self
    IntAffectsMult_Var.CallbackScript = FullScriptName
    IntAffectsMult_Var.CallbackFunction = "CallbackIntAffectsMult"

    LckAffectsMult_Var.ValueDefault = 1
    LckAffectsMult_Var.McmId = "iLckAffectsMult:AdjustmentOptions"
    LckAffectsMult_Var.ValueMin = 0
    LckAffectsMult_Var.ValueMax = 2
    LckAffectsMult_Var.CallbackType = availableCallbackTypes.FunctionCallback
    LckAffectsMult_Var.CallbackForm = Self
    LckAffectsMult_Var.CallbackScript = FullScriptName
    LckAffectsMult_Var.CallbackFunction = "CallbackLckAffectsMult"

    RngAffectsMult_Var.ValueDefault = 0
    RngAffectsMult_Var.McmId = "iRngAffectsMult:AdjustmentOptions"
    RngAffectsMult_Var.ValueMin = 0
    RngAffectsMult_Var.ValueMax = 2
    RngAffectsMult_Var.CallbackType = availableCallbackTypes.FunctionCallback
    RngAffectsMult_Var.CallbackForm = Self
    RngAffectsMult_Var.CallbackScript = FullScriptName
    RngAffectsMult_Var.CallbackFunction = "CallbackRngAffectsMult"

    ScrapperAffectsMult_Var.ValueDefault = 1
    ScrapperAffectsMult_Var.McmId = "iScrapperAffectsMult:AdjustmentOptions"
    ScrapperAffectsMult_Var.ValueMin = 0
    ScrapperAffectsMult_Var.ValueMax = 2
    ScrapperAffectsMult_Var.CallbackType = availableCallbackTypes.FunctionCallback
    ScrapperAffectsMult_Var.CallbackForm = Self
    ScrapperAffectsMult_Var.CallbackScript = FullScriptName
    ScrapperAffectsMult_Var.CallbackFunction = "CallbackScrapperAffectsMult"

    ; recycler interface - behavior
    AutoRecyclingMode_Var.ValueDefault = false
    AutoRecyclingMode_Var.McmId = "bAutoRecyclingMode:Behavior"

    EnableJunkFilter_Var.ValueDefault = true
    EnableJunkFilter_Var.McmId = "bEnableJunkFilter:Behavior"

    AutoTransferJunk_Var.ValueDefault = true
    AutoTransferJunk_Var.McmId = "bAutoTransferJunk:Behavior"

    TransferLowWeightRatioItems_Var.ValueDefault = 0
    TransferLowWeightRatioItems_Var.McmId = "iTransferLowWeightRatioItems:Behavior"
    TransferLowWeightRatioItems_Var.ValueMin = 0
    TransferLowWeightRatioItems_Var.ValueMax = 3

    UseAlwaysAutoTransferList_Var.ValueDefault = true
    UseAlwaysAutoTransferList_Var.McmId = "bUseAlwaysAutoTransferList:Behavior"

    UseNeverAutoTransferList_Var.ValueDefault = true
    UseNeverAutoTransferList_Var.McmId = "bUseNeverAutoTransferList:Behavior"

    EnableAutoTransferListEditing_Var.Value = false
    EnableAutoTransferListEditing_Var.McmId = "bEnableAutoTransferListEditing:Behavior"

    EnableBehaviorOverrides_Var.ValueDefault = false
    EnableBehaviorOverrides_Var.McmId = "bEnableBehaviorOverrides:Behavior"

    ModifierReadDelay_Var.ValueDefault = 0.3
    ModifierReadDelay_Var.McmId = "fModifierReadDelay:Behavior"
    ModifierReadDelay_Var.ValueMin = 0.0
    ModifierReadDelay_Var.ValueMax = 1.0

    ReturnItemsSilently_Var.ValueDefault = true
    ReturnItemsSilently_Var.McmId = "bReturnItemsSilently:Behavior"

    InventoryRemovalProtection_Var.ValueDefault = 0
    InventoryRemovalProtection_Var.McmId = "iInventoryRemovalProtection:Behavior"
    InventoryRemovalProtection_Var.ValueMin = 0
    InventoryRemovalProtection_Var.ValueMax = 2

    ; recycler interface - crafting
    UseSimpleCraftingRecipe_Var.ValueDefault = false
    UseSimpleCraftingRecipe_Var.McmId = "bUseSimpleCraftingRecipe:Crafting"
    UseSimpleCraftingRecipe_Var.CallbackType = availableCallbackTypes.FunctionCallback
    UseSimpleCraftingRecipe_Var.CallbackForm = Self
    UseSimpleCraftingRecipe_Var.CallbackScript = FullScriptName
    UseSimpleCraftingRecipe_Var.CallbackFunction = "CallbackUseSimpleCraftingRecipe"

    CraftingStation_Var.ValueDefault = 0
    CraftingStation_Var.McmId = "iCraftingStation:Crafting"
    CraftingStation_Var.ValueMin = 0
    CraftingStation_Var.ValueMax = 9
    CraftingStation_Var.CallbackType = availableCallbackTypes.FunctionCallback
    CraftingStation_Var.CallbackForm = Self
    CraftingStation_Var.CallbackScript = FullScriptName
    CraftingStation_Var.CallbackFunction = "CallbackCraftingStation"

    ; multiplier adjustments - general
    MultAdjustGeneralSettlement_Var.ValueDefault = 0.0
    MultAdjustGeneralSettlement_Var.McmId = "fMultAdjustGeneralSettlement:MultiplierAdjustments"
    MultAdjustGeneralSettlement_Var.ValueMin = adjustMin
    MultAdjustGeneralSettlement_Var.ValueMax = adjustMax

    MultAdjustGeneralSettlementC_Var.ValueDefault = 0.0
    MultAdjustGeneralSettlementC_Var.McmId = "fMultAdjustGeneralSettlementC:MultiplierAdjustments"
    MultAdjustGeneralSettlementC_Var.ValueMin = adjustMin
    MultAdjustGeneralSettlementC_Var.ValueMax = adjustMax

    MultAdjustGeneralSettlementU_Var.ValueDefault = 0.0
    MultAdjustGeneralSettlementU_Var.McmId = "fMultAdjustGeneralSettlementU:MultiplierAdjustments"
    MultAdjustGeneralSettlementU_Var.ValueMin = adjustMin
    MultAdjustGeneralSettlementU_Var.ValueMax = adjustMax

    MultAdjustGeneralSettlementR_Var.ValueDefault = 0.0
    MultAdjustGeneralSettlementR_Var.McmId = "fMultAdjustGeneralSettlementR:MultiplierAdjustments"
    MultAdjustGeneralSettlementR_Var.ValueMin = adjustMin
    MultAdjustGeneralSettlementR_Var.ValueMax = adjustMax

    MultAdjustGeneralSettlementS_Var.ValueDefault = 0.0
    MultAdjustGeneralSettlementS_Var.McmId = "fMultAdjustGeneralSettlementS:MultiplierAdjustments"
    MultAdjustGeneralSettlementS_Var.ValueMin = adjustMin
    MultAdjustGeneralSettlementS_Var.ValueMax = adjustMax

    MultAdjustGeneralNotSettlement_Var.ValueDefault = 0.0
    MultAdjustGeneralNotSettlement_Var.McmId = "fMultAdjustGeneralNotSettlement:MultiplierAdjustments"
    MultAdjustGeneralNotSettlement_Var.ValueMin = adjustMin
    MultAdjustGeneralNotSettlement_Var.ValueMax = adjustMax

    MultAdjustGeneralNotSettlementC_Var.ValueDefault = 0.0
    MultAdjustGeneralNotSettlementC_Var.McmId = "fMultAdjustGeneralNotSettlementC:MultiplierAdjustments"
    MultAdjustGeneralNotSettlementC_Var.ValueMin = adjustMin
    MultAdjustGeneralNotSettlementC_Var.ValueMax = adjustMax

    MultAdjustGeneralNotSettlementU_Var.ValueDefault = 0.0
    MultAdjustGeneralNotSettlementU_Var.McmId = "fMultAdjustGeneralNotSettlementU:MultiplierAdjustments"
    MultAdjustGeneralNotSettlementU_Var.ValueMin = adjustMin
    MultAdjustGeneralNotSettlementU_Var.ValueMax = adjustMax

    MultAdjustGeneralNotSettlementR_Var.ValueDefault = 0.0
    MultAdjustGeneralNotSettlementR_Var.McmId = "fMultAdjustGeneralNotSettlementR:MultiplierAdjustments"
    MultAdjustGeneralNotSettlementR_Var.ValueMin = adjustMin
    MultAdjustGeneralNotSettlementR_Var.ValueMax = adjustMax

    MultAdjustGeneralNotSettlementS_Var.ValueDefault = 0.0
    MultAdjustGeneralNotSettlementS_Var.McmId = "fMultAdjustGeneralNotSettlementS:MultiplierAdjustments"
    MultAdjustGeneralNotSettlementS_Var.ValueMin = adjustMin
    MultAdjustGeneralNotSettlementS_Var.ValueMax = adjustMax

    ; multiplier adjustments - intelligence
    MultAdjustInt_Var.ValueDefault = 0.01
    MultAdjustInt_Var.McmId = "fMultAdjustInt:MultiplierAdjustments"
    MultAdjustInt_Var.ValueMin = statAdjustMin
    MultAdjustInt_Var.ValueMax = statAdjustMax

    MultAdjustIntC_Var.ValueDefault = 0.01
    MultAdjustIntC_Var.McmId = "fMultAdjustIntC:MultiplierAdjustments"
    MultAdjustIntC_Var.ValueMin = statAdjustMin
    MultAdjustIntC_Var.ValueMax = statAdjustMax

    MultAdjustIntU_Var.ValueDefault = 0.01
    MultAdjustIntU_Var.McmId = "fMultAdjustIntU:MultiplierAdjustments"
    MultAdjustIntU_Var.ValueMin = statAdjustMin
    MultAdjustIntU_Var.ValueMax = statAdjustMax

    MultAdjustIntR_Var.ValueDefault = 0.01
    MultAdjustIntR_Var.McmId = "fMultAdjustIntR:MultiplierAdjustments"
    MultAdjustIntR_Var.ValueMin = statAdjustMin
    MultAdjustIntR_Var.ValueMax = statAdjustMax

    MultAdjustIntS_Var.ValueDefault = 0.0
    MultAdjustIntS_Var.McmId = "fMultAdjustIntS:MultiplierAdjustments"
    MultAdjustIntS_Var.ValueMin = statAdjustMin
    MultAdjustIntS_Var.ValueMax = statAdjustMax

    ; multiplier adjustments - luck
    MultAdjustLck_Var.ValueDefault = 0.01
    MultAdjustLck_Var.McmId = "fMultAdjustLck:MultiplierAdjustments"
    MultAdjustLck_Var.ValueMin = statAdjustMin
    MultAdjustLck_Var.ValueMax = statAdjustMax

    MultAdjustLckC_Var.ValueDefault = 0.01
    MultAdjustLckC_Var.McmId = "fMultAdjustLckC:MultiplierAdjustments"
    MultAdjustLckC_Var.ValueMin = statAdjustMin
    MultAdjustLckC_Var.ValueMax = statAdjustMax

    MultAdjustLckU_Var.ValueDefault = 0.01
    MultAdjustLckU_Var.McmId = "fMultAdjustLckU:MultiplierAdjustments"
    MultAdjustLckU_Var.ValueMin = statAdjustMin
    MultAdjustLckU_Var.ValueMax = statAdjustMax

    MultAdjustLckR_Var.ValueDefault = 0.01
    MultAdjustLckR_Var.McmId = "fMultAdjustLckR:MultiplierAdjustments"
    MultAdjustLckR_Var.ValueMin = statAdjustMin
    MultAdjustLckR_Var.ValueMax = statAdjustMax

    MultAdjustLckS_Var.ValueDefault = 0.0
    MultAdjustLckS_Var.McmId = "fMultAdjustLckS:MultiplierAdjustments"
    MultAdjustLckS_Var.ValueMin = statAdjustMin
    MultAdjustLckS_Var.ValueMax = statAdjustMax

    ; multiplier adjustments - randomness
    MultAdjustRandomMin_Var.ValueDefault = -0.1
    MultAdjustRandomMin_Var.McmId = "fMultAdjustRandomMin:MultiplierAdjustments"
    MultAdjustRandomMin_Var.ValueMin = randomAdjustMin
    MultAdjustRandomMin_Var.ValueMax = randomAdjustMax

    MultAdjustRandomMinC_Var.ValueDefault = -0.1
    MultAdjustRandomMinC_Var.McmId = "fMultAdjustRandomMinC:MultiplierAdjustments"
    MultAdjustRandomMinC_Var.ValueMin = randomAdjustMin
    MultAdjustRandomMinC_Var.ValueMax = randomAdjustMax

    MultAdjustRandomMinU_Var.ValueDefault = -0.1
    MultAdjustRandomMinU_Var.McmId = "fMultAdjustRandomMinU:MultiplierAdjustments"
    MultAdjustRandomMinU_Var.ValueMin = randomAdjustMin
    MultAdjustRandomMinU_Var.ValueMax = randomAdjustMax

    MultAdjustRandomMinR_Var.ValueDefault = -0.1
    MultAdjustRandomMinR_Var.McmId = "fMultAdjustRandomMinR:MultiplierAdjustments"
    MultAdjustRandomMinR_Var.ValueMin = randomAdjustMin
    MultAdjustRandomMinR_Var.ValueMax = randomAdjustMax

    MultAdjustRandomMinS_Var.ValueDefault = 0.0
    MultAdjustRandomMinS_Var.McmId = "fMultAdjustRandomMinS:MultiplierAdjustments"
    MultAdjustRandomMinS_Var.ValueMin = randomAdjustMin
    MultAdjustRandomMinS_Var.ValueMax = randomAdjustMax

    MultAdjustRandomMax_Var.ValueDefault = 0.1
    MultAdjustRandomMax_Var.McmId = "fMultAdjustRandomMax:MultiplierAdjustments"
    MultAdjustRandomMax_Var.ValueMin = randomAdjustMin
    MultAdjustRandomMax_Var.ValueMax = randomAdjustMax

    MultAdjustRandomMaxC_Var.ValueDefault = 0.1
    MultAdjustRandomMaxC_Var.McmId = "fMultAdjustRandomMaxC:MultiplierAdjustments"
    MultAdjustRandomMaxC_Var.ValueMin = randomAdjustMin
    MultAdjustRandomMaxC_Var.ValueMax = randomAdjustMax

    MultAdjustRandomMaxU_Var.ValueDefault = 0.1
    MultAdjustRandomMaxU_Var.McmId = "fMultAdjustRandomMaxU:MultiplierAdjustments"
    MultAdjustRandomMaxU_Var.ValueMin = randomAdjustMin
    MultAdjustRandomMaxU_Var.ValueMax = randomAdjustMax

    MultAdjustRandomMaxR_Var.ValueDefault = 0.1
    MultAdjustRandomMaxR_Var.McmId = "fMultAdjustRandomMaxR:MultiplierAdjustments"
    MultAdjustRandomMaxR_Var.ValueMin = randomAdjustMin
    MultAdjustRandomMaxR_Var.ValueMax = randomAdjustMax

    MultAdjustRandomMaxS_Var.ValueDefault = 0.0
    MultAdjustRandomMaxS_Var.McmId = "fMultAdjustRandomMaxS:MultiplierAdjustments"
    MultAdjustRandomMaxS_Var.ValueMin = randomAdjustMin
    MultAdjustRandomMaxS_Var.ValueMax = randomAdjustMax

    ; multiplier adjustments - scrapper 1-5
    float[] scrapperSettlementDefaults = new float[ScrapperPerkMaxRanksSupported]
    scrapperSettlementDefaults[0] = 0.1
    scrapperSettlementDefaults[1] = 0.2
    scrapperSettlementDefaults[2] = 0.3
    scrapperSettlementDefaults[3] = 0.4
    scrapperSettlementDefaults[4] = 0.5

    int index = 0
    While index < ScrapperPerkMaxRanksSupported
        MultAdjustScrapperSettlement_Var[index].ValueDefault = scrapperSettlementDefaults[index]
        MultAdjustScrapperSettlement_Var[index].McmId = "fMultAdjustScrapperSettlement" + (index+1) + ":MultiplierAdjustments"
        MultAdjustScrapperSettlement_Var[index].ValueMin = adjustMin
        MultAdjustScrapperSettlement_Var[index].ValueMax = adjustMax

        MultAdjustScrapperSettlementC_Var[index].ValueDefault = scrapperSettlementDefaults[index]
        MultAdjustScrapperSettlementC_Var[index].McmId = "fMultAdjustScrapperSettlementC" + (index+1) + ":MultiplierAdjustments"
        MultAdjustScrapperSettlementC_Var[index].ValueMin = adjustMin
        MultAdjustScrapperSettlementC_Var[index].ValueMax = adjustMax

        MultAdjustScrapperSettlementU_Var[index].ValueDefault = scrapperSettlementDefaults[index]
        MultAdjustScrapperSettlementU_Var[index].McmId = "fMultAdjustScrapperSettlementU" + (index+1) + ":MultiplierAdjustments"
        MultAdjustScrapperSettlementU_Var[index].ValueMin = adjustMin
        MultAdjustScrapperSettlementU_Var[index].ValueMax = adjustMax

        MultAdjustScrapperSettlementR_Var[index].ValueDefault = scrapperSettlementDefaults[index]
        MultAdjustScrapperSettlementR_Var[index].McmId = "fMultAdjustScrapperSettlementR" + (index+1) + ":MultiplierAdjustments"
        MultAdjustScrapperSettlementR_Var[index].ValueMin = adjustMin
        MultAdjustScrapperSettlementR_Var[index].ValueMax = adjustMax

        MultAdjustScrapperSettlementS_Var[index].ValueDefault = 0.0
        MultAdjustScrapperSettlementS_Var[index].McmId = "fMultAdjustScrapperSettlementS" + (index+1) + ":MultiplierAdjustments"
        MultAdjustScrapperSettlementS_Var[index].ValueMin = adjustMin
        MultAdjustScrapperSettlementS_Var[index].ValueMax = adjustMax

        MultAdjustScrapperNotSettlement_Var[index].ValueDefault = 0.0
        MultAdjustScrapperNotSettlement_Var[index].McmId = "fMultAdjustScrapperNotSettlement" + (index+1) + ":MultiplierAdjustments"
        MultAdjustScrapperNotSettlement_Var[index].ValueMin = adjustMin
        MultAdjustScrapperNotSettlement_Var[index].ValueMax = adjustMax

        MultAdjustScrapperNotSettlementC_Var[index].ValueDefault = 0.0
        MultAdjustScrapperNotSettlementC_Var[index].McmId = "fMultAdjustScrapperNotSettlementC" + (index+1) + ":MultiplierAdjustments"
        MultAdjustScrapperNotSettlementC_Var[index].ValueMin = adjustMin
        MultAdjustScrapperNotSettlementC_Var[index].ValueMax = adjustMax

        MultAdjustScrapperNotSettlementU_Var[index].ValueDefault = 0.0
        MultAdjustScrapperNotSettlementU_Var[index].McmId = "fMultAdjustScrapperNotSettlementU" + (index+1) + ":MultiplierAdjustments"
        MultAdjustScrapperNotSettlementU_Var[index].ValueMin = adjustMin
        MultAdjustScrapperNotSettlementU_Var[index].ValueMax = adjustMax

        MultAdjustScrapperNotSettlementR_Var[index].ValueDefault = 0.0
        MultAdjustScrapperNotSettlementR_Var[index].McmId = "fMultAdjustScrapperNotSettlementR" + (index+1) + ":MultiplierAdjustments"
        MultAdjustScrapperNotSettlementR_Var[index].ValueMin = adjustMin
        MultAdjustScrapperNotSettlementR_Var[index].ValueMax = adjustMax

        MultAdjustScrapperNotSettlementS_Var[index].ValueDefault = 0.0
        MultAdjustScrapperNotSettlementS_Var[index].McmId = "fMultAdjustScrapperNotSettlementS" + (index+1) + ":MultiplierAdjustments"
        MultAdjustScrapperNotSettlementS_Var[index].ValueMin = adjustMin
        MultAdjustScrapperNotSettlementS_Var[index].ValueMax = adjustMax

        index += 1
    EndWhile

    ; advanced - general options
    ThreadLimit_Var.ValueDefault = ThreadManager.NumberOfWorkerThreads
    ThreadLimit_Var.McmId = "iThreadLimit:Advanced"
    ThreadLimit_Var.ValueMin = 1
    ThreadLimit_Var.ValueMax = ThreadManager.NumberOfWorkerThreads
    ThreadLimit_Var.CallbackType = availableCallbackTypes.FunctionCallback
    ThreadLimit_Var.CallbackForm = ThreadManager
    ThreadLimit_Var.CallbackScript = ThreadManager.FullScriptName
    ThreadLimit_Var.CallbackFunction = "SetThreadLimit"
    ThreadLimit_Var.CallbackArgumentType = availableCallbackArgumentTypes.NewValueOnly

    EnableLogging_Var.ValueDefault = EnableLoggingDefault
    EnableLogging_Var.McmId = "bEnableLogging:Advanced"
    EnableLogging_Var.CallbackType = availableCallbackTypes.FunctionCallback
    EnableLogging_Var.CallbackForm = Self
    EnableLogging_Var.CallbackScript = FullScriptName
    EnableLogging_Var.CallbackFunction = "CallbackEnableLogging"
    EnableLogging_Var.CallbackArgumentType = availableCallbackArgumentTypes.Both

    EnableProfiling_Var.ValueDefault = EnableProfilingDefault
    EnableProfiling_Var.McmId = "bEnableProfiling:Advanced"
    EnableProfiling_Var.CallbackType = availableCallbackTypes.FunctionCallback
    EnableProfiling_Var.CallbackForm = Self
    EnableProfiling_Var.CallbackScript = FullScriptName
    EnableProfiling_Var.CallbackFunction = "CallbackEnableProfiling"
    EnableProfiling_Var.CallbackArgumentType = availableCallbackArgumentTypes.NewValueOnly

    ; advanced - methodology
    UseDirectMoveRecyclableItemListUpdate_Var.ValueDefault = false
    UseDirectMoveRecyclableItemListUpdate_Var.McmId = "bUseDirectMoveRecyclableItemListUpdate:Advanced"
EndFunction

; reset values of properties that hold settings to their defaults
Function InitSettingsDefaultValues()
    Self._Log("Initializing settings (default values)")

    ; set things to defaults
    ThreadManager.ChangeSettingsToDefaults(Self.CollectMCMSettings(), ControlManager.CurrentChangeType, ModName)
EndFunction

; load MCM settings
Function LoadAllSettingsFromMCM()
    If ControlManager.ModConfigMenuInstalled
        Self._Log("Loading settings from MCM")

        ; load all the settings, multithread to cut down on time
        ThreadManager.LoadMCMSettings(Self.CollectMCMSettings(), ModName)

        ; sanity check
        Self.MultAdjustRandomSanityCheck()
    Else
        Self._Log("Loading settings from MCM; skipping (MCM not enabled)")
    EndIf
EndFunction

; returns an array containing all the MCM settings
var[] Function CollectMCMSettings()
    Self._Log("Collecting MCM settings")

    var[] toReturn = new var[0]

    ; settings - general
    toReturn.Add(MultBase_Var)
    toReturn.Add(ReturnAtLeastOneComponent_Var)
    toReturn.Add(FractionalComponentHandling_Var)
    toReturn.Add(HasLimitedUses_Var)
    toReturn.Add(NumberOfUses_Var)

    ; settings - adjustment options
    toReturn.Add(GeneralMultAdjust_Var)
    toReturn.Add(IntAffectsMult_Var)
    toReturn.Add(LckAffectsMult_Var)
    toReturn.Add(RngAffectsMult_Var)
    toReturn.Add(ScrapperAffectsMult_Var)

    ; recycler interface - behavior
    toReturn.Add(AutoRecyclingMode_Var)
    toReturn.Add(EnableJunkFilter_Var)
    toReturn.Add(AutoTransferJunk_Var)
    toReturn.Add(TransferLowWeightRatioItems_Var)
    toReturn.Add(UseAlwaysAutoTransferList_Var)
    toReturn.Add(UseNeverAutoTransferList_Var)
    toReturn.Add(EnableAutoTransferListEditing_Var)
    toReturn.Add(EnableBehaviorOverrides_Var)
    toReturn.Add(ModifierReadDelay)
    toReturn.Add(ReturnItemsSilently_Var)
    toReturn.Add(InventoryRemovalProtection_Var)

    ; recycler interface - crafting
    toReturn.Add(UseSimpleCraftingRecipe_Var)
    toReturn.Add(CraftingStation_Var)

    ; multiplier adjustments - general
    toReturn.Add(MultAdjustGeneralSettlement_Var)
    toReturn.Add(MultAdjustGeneralSettlementC_Var)
    toReturn.Add(MultAdjustGeneralSettlementU_Var)
    toReturn.Add(MultAdjustGeneralSettlementR_Var)
    toReturn.Add(MultAdjustGeneralSettlementS_Var)

    toReturn.Add(MultAdjustGeneralNotSettlement_Var)
    toReturn.Add(MultAdjustGeneralNotSettlementC_Var)
    toReturn.Add(MultAdjustGeneralNotSettlementU_Var)
    toReturn.Add(MultAdjustGeneralNotSettlementR_Var)
    toReturn.Add(MultAdjustGeneralNotSettlementS_Var)

    ; multiplier adjustments - intelligence
    toReturn.Add(MultAdjustInt_Var)
    toReturn.Add(MultAdjustIntC_Var)
    toReturn.Add(MultAdjustIntU_Var)
    toReturn.Add(MultAdjustIntR_Var)
    toReturn.Add(MultAdjustIntS_Var)

    ; multiplier adjustments - luck
    toReturn.Add(MultAdjustLck_Var)
    toReturn.Add(MultAdjustLckC_Var)
    toReturn.Add(MultAdjustLckU_Var)
    toReturn.Add(MultAdjustLckR_Var)
    toReturn.Add(MultAdjustLckS_Var)

    ; multiplier adjustments - randomness
    toReturn.Add(MultAdjustRandomMin_Var)
    toReturn.Add(MultAdjustRandomMinC_Var)
    toReturn.Add(MultAdjustRandomMinU_Var)
    toReturn.Add(MultAdjustRandomMinR_Var)
    toReturn.Add(MultAdjustRandomMinS_Var)

    toReturn.Add(MultAdjustRandomMax_Var)
    toReturn.Add(MultAdjustRandomMaxC_Var)
    toReturn.Add(MultAdjustRandomMaxU_Var)
    toReturn.Add(MultAdjustRandomMaxR_Var)
    toReturn.Add(MultAdjustRandomMaxS_Var)

    ; multiplier adjustments - scrapper 1-5
    int index = 0
    While index < ScrapperPerkMaxRanksSupported
        toReturn.Add(MultAdjustScrapperSettlement_Var[index])
        toReturn.Add(MultAdjustScrapperSettlementC_Var[index])
        toReturn.Add(MultAdjustScrapperSettlementU_Var[index])
        toReturn.Add(MultAdjustScrapperSettlementR_Var[index])
        toReturn.Add(MultAdjustScrapperSettlementS_Var[index])

        toReturn.Add(MultAdjustScrapperNotSettlement_Var[index])
        toReturn.Add(MultAdjustScrapperNotSettlementC_Var[index])
        toReturn.Add(MultAdjustScrapperNotSettlementU_Var[index])
        toReturn.Add(MultAdjustScrapperNotSettlementR_Var[index])
        toReturn.Add(MultAdjustScrapperNotSettlementS_Var[index])

        index += 1
    EndWhile

    ; advanced - general options
    toReturn.Add(ThreadLimit_Var)
    toReturn.Add(EnableLogging_Var)
    toReturn.Add(EnableProfiling_Var)

    ; advanced - methodology
    toReturn.Add(UseDirectMoveRecyclableItemListUpdate_Var)

    Return toReturn
EndFunction

; register this script for MCM events
Function RegisterForMCMEvents()
    Self._Log("Attempting to register for MCM events")
    If ControlManager.ModConfigMenuInstalled
        Self._Log("MCM installed; registering for MCM events")
        string eventName = "OnMCMSettingChange|" + ModName
        string callback = "OnMCMSettingChange"
        RegisterForExternalEvent(eventName, callback)
        Self._Log("Registered for MCM event '" + eventName + "' with a callback of '" + callback + "'")
        eventName = "OnMCMMenuClose|" + ModName
        callback = "OnMCMMenuClose"
        RegisterForExternalEvent(eventName, callback)
        Self._Log("Registered for MCM event '" + eventName + "' with a callback of '" + callback + "'")
    Else
        Self._Log("MCM not installed; skipping", 1)
    EndIf
EndFunction

Function CallbackGeneralMultAdjust()
    Self._Log("Callback for GeneralMultAdjust triggered")
    MCM_GeneralMultAdjustSimple = GeneralMultAdjust_Var.Value == 0
    MCM_GeneralMultAdjustDetailed = GeneralMultAdjust_Var.Value > 0
    MCM.RefreshMenu()
EndFunction

Function CallbackIntAffectsMult()
    Self._Log("Callback for IntAffectsMult triggered")
    MCM_IntAffectsMultSimple = IntAffectsMult_Var.Value == 1
    MCM_IntAffectsMultDetailed = IntAffectsMult_Var.Value > 1
    MCM.RefreshMenu()
EndFunction

Function CallbackLckAffectsMult()
    Self._Log("Callback for LckAffectsMult triggered")
    MCM_LckAffectsMultSimple = LckAffectsMult_Var.Value == 1
    MCM_LckAffectsMultDetailed = LckAffectsMult_Var.Value > 1
    MCM.RefreshMenu()
EndFunction

Function CallbackRngAffectsMult()
    Self._Log("Callback for RngAffectsMult triggered")
    MCM_RngAffectsMultSimple = RngAffectsMult_Var.Value == 1
    MCM_RngAffectsMultDetailed = RngAffectsMult_Var.Value > 1
    MCM.RefreshMenu()
EndFunction

Function CallbackScrapperAffectsMult()
    Self._Log("Callback for ScrapperAffectsMult triggered")
    MCM_ScrapperAffectsMultSimple = ScrapperAffectsMult_Var.Value == 1
    MCM_ScrapperAffectsMultDetailed = ScrapperAffectsMult_Var.Value > 1
    MCM.RefreshMenu()
EndFunction

Function CallbackUseSimpleCraftingRecipe()
    Self._Log("Callback for UseSimpleCraftingRecipe triggered")
    ; grab and log the current recipe workbench keywords
    Keyword complexRecipeCurrentWorkbench = PortableJunkRecyclerConstructibleObject.GetWorkbenchKeyword()
    Self._Log("CallbackUseSimpleCraftingRecipe: complexRecipeCurrentKeyword: " + complexRecipeCurrentWorkbench)
    Keyword simpleRecipeCurrentWorkbench = PortableJunkRecyclerConstructibleObjectSimple.GetWorkbenchKeyword()
    Self._Log("CallbackUseSimpleCraftingRecipe: simpleRecipeCurrentKeyword: " + simpleRecipeCurrentWorkbench)

    ; if the respective {complex,simple}RecipeCurrentWorkbench == NullWorkbenchKeyword,
    ; then this happened during script initialization and should be ignored
    If UseSimpleCraftingRecipe_Var.Value && complexRecipeCurrentWorkbench != NullWorkbenchKeyword
        PortableJunkRecyclerConstructibleObject.SetWorkbenchKeyword(NullWorkbenchKeyword)
        Self._Log("CallbackUseSimpleCraftingRecipe: complex recipe set to workbench keyword: " + NullWorkbenchKeyword)
        PortableJunkRecyclerConstructibleObjectSimple.SetWorkbenchKeyword(complexRecipeCurrentWorkbench)
        Self._Log("CallbackUseSimpleCraftingRecipe: simple recipe set to workbench keyword: " + complexRecipeCurrentWorkbench)
    ElseIf !UseSimpleCraftingRecipe_Var.Value && simpleRecipeCurrentWorkbench != NullWorkbenchKeyword
        PortableJunkRecyclerConstructibleObject.SetWorkbenchKeyword(simpleRecipeCurrentWorkbench)
        Self._Log("CallbackUseSimpleCraftingRecipe: complex recipe set to workbench keyword: " + simpleRecipeCurrentWorkbench)
        PortableJunkRecyclerConstructibleObjectSimple.SetWorkbenchKeyword(NullWorkbenchKeyword)
        Self._Log("CallbackUseSimpleCraftingRecipe: simple recipe set to workbench keyword: " + NullWorkbenchKeyword)
    EndIf
EndFunction

; determine where the crafting recipe lives
Function CallbackCraftingStation()
    Self._Log("Callback for CraftingStation triggered")
    string pluginNameSWesl = "StandaloneWorkbenches.esl" const
    string pluginNameSWesp = "StandaloneWorkbenches.esp" const
    string pluginNameECO = "ECO.esp" const
    string pluginNameAWKCR = "ArmorKeywords.esm" const
    string pluginNameSW
    bool isSWInstalled
    If Game.IsPluginInstalled(pluginNameSWesl)
        isSWInstalled = true
        pluginNameSW = pluginNameSWesl
    ElseIf Game.IsPluginInstalled(pluginNameSWesp)
        isSWInstalled = true
        pluginNameSW = pluginNameSWesp
    EndIf
    bool isECOInstalled = Game.IsPluginInstalled(pluginNameECO)
    bool isAWKCRInstalled = Game.IsPluginInstalled(pluginNameAWKCR)
    Keyword craftingStationKeyword = none

    ; handle 'dynamic' workbenches first
    If (CraftingStation_Var.Value == 5 || CraftingStation_Var.Value == 0) && isSWInstalled
        ; Standalone Workbenches - Utility Workbench (Keyword FExxx81C - wSW_UtilityWorkbench_CraftingKey)
        craftingStationKeyword = Game.GetFormFromFile(0x81C, pluginNameSW) as Keyword
        Self._Log("CallbackCraftingStation: Standalone Workbenches - Utility Workbench " + craftingStationKeyword)
    ElseIf (CraftingStation_Var.Value == 9 || CraftingStation_Var.Value == 0) && isECOInstalled
        ; Equipment and Crafting Overhaul - Utility Station (Keyword xx02788D - Dank_Workbench_TypeUtility)
        craftingStationKeyword = Game.GetFormFromFile(0x02788D, pluginNameECO) as Keyword
        Self._Log("CallbackCraftingStation: Equipment and Crafting Overhaul - Utility Station " + craftingStationKeyword)
    ElseIf (CraftingStation_Var.Value == 8 || CraftingStation_Var.Value == 0) && isAWKCRInstalled
        ; AWKCR - Utility Workbench (Keyword xx001765 - AEC_ck_UtilityCraftingKey)
        craftingStationKeyword = Game.GetFormFromFile(0x001765, pluginNameAWKCR) as Keyword
        Self._Log("CallbackCraftingStation: AWKCR - Utility Workbench " + craftingStationKeyword)

    ; handle other manual workbench choices
    ElseIf CraftingStation_Var.Value == 2 && isSWInstalled
        ; Standalone Workbenches - Electronics Workbench (Keyword FExxx80D - wSW_ElectronicsWorkbench_CraftingKey)
        craftingStationKeyword = Game.GetFormFromFile(0x80D, pluginNameSW) as Keyword
        Self._Log("CallbackCraftingStation: Standalone Workbenches - Electronics Workbench " + craftingStationKeyword)
    ElseIf CraftingStation_Var.Value == 3 && isSWInstalled
        ; Standalone Workbenches - Engineering Workbench (Keyword FExxx810 - wSW_EngineeringWorkbench_CraftingKey)
        craftingStationKeyword = Game.GetFormFromFile(0x810, pluginNameSW) as Keyword
        Self._Log("CallbackCraftingStation: Standalone Workbenches - Engineering Workbench " + craftingStationKeyword)
    ElseIf CraftingStation_Var.Value == 4 && isSWInstalled
        ; Standalone Workbenches - Manufacturing Workbench (Keyword FExxx822 - wSW_ManufacturingWorkbench_CraftingKey)
        craftingStationKeyword = Game.GetFormFromFile(0x822, pluginNameSW) as Keyword
        Self._Log("CallbackCraftingStation: Standalone Workbenches - Manufacturing Workbench " + craftingStationKeyword)
    ElseIf CraftingStation_Var.Value == 6 && isAWKCRInstalled
        ; AWKCR - Advanced Engineering Workbench (Keyword xx00195A - AEC_ck_AdvancedEngineeringCraftingKey)
        craftingStationKeyword = Game.GetFormFromFile(0x00195A, pluginNameAWKCR) as Keyword
        Self._Log("CallbackCraftingStation: AWKCR - Advanced Engineering Workbench " + craftingStationKeyword)
    ElseIf CraftingStation_Var.Value == 7 && isAWKCRInstalled
        ; AWKCR - Electronics Workstation (Keyword xx001764 - AEC_ck_ElectronicsCraftingKey)
        craftingStationKeyword = Game.GetFormFromFile(0x001764, pluginNameAWKCR) as Keyword
        Self._Log("CallbackCraftingStation: AWKCR - Electronics Workstation " + craftingStationKeyword)
    EndIf

    ; handle everything else, like missing mods, missing keywords, etc
    If !craftingStationKeyword
        ; Vanilla - Chemistry Station (Keyword xx102158 - WorkbenchChemlab)
        craftingStationKeyword = Game.GetFormFromFile(0x102158, "Fallout4.esm") as Keyword
        If CraftingStation_Var.Value == 0 && (isSWInstalled || isECOInstalled || isAWKCRInstalled)
            Self._Log("CallbackCraftingStation: Dynamic workbench specified and supported mod found, but keyword not detected; falling back to vanilla " + craftingStationKeyword)
        ElseIf CraftingStation_Var.Value >= 2 && CraftingStation_Var.Value <= 5
            Self._Log("CallbackCraftingStation: Standalone Workbenches workbench specified but mod or keyword not detected; falling back to vanilla " + craftingStationKeyword)
        ElseIF CraftingStation_Var.Value >= 6 && CraftingStation_Var.Value <= 8
            Self._Log("CallbackCraftingStation: AWKCR workbench specified but mod or keyword not detected; falling back to vanilla " + craftingStationKeyword)
        ElseIf CraftingStation_Var.Value == 9
            Self._Log("CallbackCraftingStation: ECO workbench specified but mod or keyword not detected; falling back to vanilla " + craftingStationKeyword)
        Else
            Self._Log("CallbackCraftingStation: Vanilla - Chemistry Station " + craftingStationKeyword)
        EndIf
    EndIf

    ; actually set the keyword
    if UseSimpleCraftingRecipe_Var.Value
        Self._Log("CallbackCraftingStation: Using simple recipe")
        PortableJunkRecyclerConstructibleObject.SetWorkbenchKeyword(NullWorkbenchKeyword)
        PortableJunkRecyclerConstructibleObjectSimple.SetWorkbenchKeyword(craftingStationKeyword)
    Else
        Self._Log("CallbackCraftingStation: Using complex recipe")
        PortableJunkRecyclerConstructibleObject.SetWorkbenchKeyword(craftingStationKeyword)
        PortableJunkRecyclerConstructibleObjectSimple.SetWorkbenchKeyword(NullWorkbenchKeyword)
    EndIf
EndFunction

Function CallbackEnableLogging(bool abOldValue, bool abNewValue)
    Self._Log("Callback for EnableLogging triggered")
    If abOldValue != abNewValue
        If abNewValue
            Self._Log("Logging enabled", abForce = true)
        Else
            Self._Log("Logging disabled", abForce = true)
        EndIf
        ControlManager.SetLogging(abNewValue)
        ContainerManager.SetLogging(abNewValue)
        ; the thread manager can be a bit chatty owing to the worker threads, so change its setting last
        ThreadManager.SetLogging(abNewValue)
    EndIf
EndFunction

Function CallbackEnableProfiling(bool abNewValue)
    Self._Log("Callback for EnableProfiling triggered")
    ControlManager.SetProfiling(abNewValue)
    ContainerManager.SetProfiling(abNewValue)
    ; the thread manager can be a bit chatty owing to the worker threads, so change its setting last
    ThreadManager.SetProfiling(abNewValue)
EndFunction

; callback function for when MCM changes settings
Function OnMCMSettingChange(string asModName, string asControlId)
    If asModName == ModName
        int defaultValue = 2147483647 ; use 32-bit signed integer maximum to serve as a default value
        var oldValue = defaultValue
        var newValue

        ; settings - general
        If asControlId == MultBase_Var.McmId
            oldValue = MultBase_Var.Value
            LoadSettingFromMCM(MultBase_Var, ModName)
            newValue = MultBase_Var.Value
        ElseIf asControlId == ReturnAtLeastOneComponent_Var.McmId
            oldValue = ReturnAtLeastOneComponent_Var.Value
            LoadSettingFromMCM(ReturnAtLeastOneComponent_Var, ModName)
            newValue = ReturnAtLeastOneComponent_Var.Value
        ElseIf asControlId == FractionalComponentHandling_Var.McmId
            oldValue = FractionalComponentHandling_Var.Value
            LoadSettingFromMCM(FractionalComponentHandling_Var, ModName)
            newValue = FractionalComponentHandling_Var.Value
        ElseIf asControlId == HasLimitedUses_Var.McmId
            oldValue = HasLimitedUses_Var.Value
            LoadSettingFromMCM(HasLimitedUses_Var, ModName)
            newValue = HasLimitedUses_Var.Value
        ElseIf asControlId == NumberOfUses_Var.McmId
            oldValue = NumberOfUses_Var.Value
            LoadSettingFromMCM(NumberOfUses_Var, ModName)
            newValue = NumberOfUses_Var.Value

        ; settings - adjustment options
        ElseIf asControlId == GeneralMultAdjust_Var.McmId
            oldValue = GeneralMultAdjust_Var.Value
            LoadSettingFromMCM(GeneralMultAdjust_Var, ModName)
            newValue = GeneralMultAdjust_Var.Value
        ElseIf asControlId == IntAffectsMult_Var.McmId
            oldValue = IntAffectsMult_Var.Value
            LoadSettingFromMCM(IntAffectsMult_Var, ModName)
            newValue = IntAffectsMult_Var.Value
        ElseIf asControlId == LckAffectsMult_Var.McmId
            oldValue = LckAffectsMult_Var.Value
            LoadSettingFromMCM(LckAffectsMult_Var, ModName)
            newValue = LckAffectsMult_Var.Value
        ElseIf asControlId == RngAffectsMult_Var.McmId
            oldValue = RngAffectsMult_Var.Value
            LoadSettingFromMCM(RngAffectsMult_Var, ModName)
            newValue = RngAffectsMult_Var.Value
        ElseIf asControlId == ScrapperAffectsMult_Var.McmId
            oldValue = ScrapperAffectsMult_Var.Value
            LoadSettingFromMCM(ScrapperAffectsMult_Var, ModName)
            newValue = ScrapperAffectsMult_Var.Value

        ; recycler interface - behavior
        ElseIf asControlId == AutoRecyclingMode_Var.McmId
            oldValue = AutoRecyclingMode_Var.Value
            LoadSettingFromMCM(AutoRecyclingMode_Var, ModName)
            newValue = AutoRecyclingMode_Var.Value
        ElseIf asControlId == EnableJunkFilter_Var.McmId
            oldValue = EnableJunkFilter_Var.Value
            LoadSettingFromMCM(EnableJunkFilter_Var, ModName)
            newValue = EnableJunkFilter_Var.Value
        ElseIf asControlId == AutoTransferJunk_Var.McmId
            oldValue = AutoTransferJunk_Var.Value
            LoadSettingFromMCM(AutoTransferJunk_Var, ModName)
            newValue = AutoTransferJunk_Var.Value
        ElseIf asControlId == TransferLowWeightRatioItems_Var.McmId
            oldValue = TransferLowWeightRatioItems_Var.Value
            LoadSettingFromMCM(TransferLowWeightRatioItems_Var, ModName)
            newValue = TransferLowWeightRatioItems_Var.Value
        ElseIf asControlId == UseAlwaysAutoTransferList_Var.McmId
            oldValue = UseAlwaysAutoTransferList_Var.Value
            LoadSettingFromMCM(UseAlwaysAutoTransferList_Var, ModName)
            newValue = UseAlwaysAutoTransferList_Var.Value
        ElseIf asControlId == UseNeverAutoTransferList_Var.McmId
            oldValue = UseNeverAutoTransferList_Var.Value
            LoadSettingFromMCM(UseNeverAutoTransferList_Var, ModName)
            newValue = UseNeverAutoTransferList_Var.Value
        ElseIf asControlId == EnableAutoTransferListEditing_Var.McmId
            oldValue = EnableAutoTransferListEditing_Var.Value
            LoadSettingFromMCM(EnableAutoTransferListEditing_Var, ModName)
            newValue = EnableAutoTransferListEditing_Var.Value
        ElseIf asControlId == EnableBehaviorOverrides_Var.McmId
            oldValue = EnableBehaviorOverrides_Var.Value
            LoadSettingFromMCM(EnableBehaviorOverrides_Var, ModName)
            newValue = EnableBehaviorOverrides_Var.Value
        ElseIf asControlId == ModifierReadDelay_Var.McmId
            oldValue = ModifierReadDelay_Var.Value
            LoadSettingFromMCM(ModifierReadDelay_Var, ModName)
            newValue = ModifierReadDelay_Var.Value
        ElseIf asControlId == ReturnItemsSilently_Var.McmId
            oldValue = ReturnItemsSilently_Var.Value
            LoadSettingFromMCM(ReturnItemsSilently_Var, ModName)
            newValue = ReturnItemsSilently_Var.Value
        ElseIf asControlId == InventoryRemovalProtection_Var.McmId
            oldValue = InventoryRemovalProtection_Var.Value
            LoadSettingFromMCM(InventoryRemovalProtection_Var, ModName)
            newValue = InventoryRemovalProtection_Var.Value

        ; recycler interface - crafting
        ElseIf asControlId == UseSimpleCraftingRecipe_Var.McmId
            oldValue = UseSimpleCraftingRecipe_Var.Value
            LoadSettingFromMCM(UseSimpleCraftingRecipe_Var, ModName)
            newValue = UseSimpleCraftingRecipe_Var.Value
        ElseIf asControlId == CraftingStation_Var.McmId
            oldValue = CraftingStation_Var.Value
            LoadSettingFromMCM(CraftingStation_Var, ModName)
            newValue = CraftingStation_Var.Value

        ; multiplier adjustments - general
        ElseIf asControlId == MultAdjustGeneralSettlement_Var.McmId
            oldValue = MultAdjustGeneralSettlement_Var.Value
            LoadSettingFromMCM(MultAdjustGeneralSettlement_Var, ModName)
            newValue = MultAdjustGeneralSettlement_Var.Value
        ElseIf asControlId == MultAdjustGeneralSettlementC_Var.McmId
            oldValue = MultAdjustGeneralSettlementC_Var.Value
            LoadSettingFromMCM(MultAdjustGeneralSettlementC_Var, ModName)
            newValue = MultAdjustGeneralSettlementC_Var.Value
        ElseIf asControlId == MultAdjustGeneralSettlementU_Var.McmId
            oldValue = MultAdjustGeneralSettlementU_Var.Value
            LoadSettingFromMCM(MultAdjustGeneralSettlementU_Var, ModName)
            newValue = MultAdjustGeneralSettlementU_Var.Value
        ElseIf asControlId == MultAdjustGeneralSettlementR_Var.McmId
            oldValue = MultAdjustGeneralSettlementR_Var.Value
            LoadSettingFromMCM(MultAdjustGeneralSettlementR_Var, ModName)
            newValue = MultAdjustGeneralSettlementR_Var.Value
        ElseIf asControlId == MultAdjustGeneralSettlementS_Var.McmId
            oldValue = MultAdjustGeneralSettlementS_Var.Value
            LoadSettingFromMCM(MultAdjustGeneralSettlementS_Var, ModName)
            newValue = MultAdjustGeneralSettlementS_Var.Value

        ElseIf asControlId == MultAdjustGeneralNotSettlement_Var.McmId
            oldValue = MultAdjustGeneralNotSettlement_Var.Value
            LoadSettingFromMCM(MultAdjustGeneralNotSettlement_Var, ModName)
            newValue = MultAdjustGeneralNotSettlement_Var.Value
        ElseIf asControlId == MultAdjustGeneralNotSettlementC_Var.McmId
            oldValue = MultAdjustGeneralNotSettlementC_Var.Value
            LoadSettingFromMCM(MultAdjustGeneralNotSettlementC_Var, ModName)
            newValue = MultAdjustGeneralNotSettlementC_Var.Value
        ElseIf asControlId == MultAdjustGeneralNotSettlementU_Var.McmId
            oldValue = MultAdjustGeneralNotSettlementU_Var.Value
            LoadSettingFromMCM(MultAdjustGeneralNotSettlementU_Var, ModName)
            newValue = MultAdjustGeneralNotSettlementU_Var.Value
        ElseIf asControlId == MultAdjustGeneralNotSettlementR_Var.McmId
            oldValue = MultAdjustGeneralNotSettlementR_Var.Value
            LoadSettingFromMCM(MultAdjustGeneralNotSettlementR_Var, ModName)
            newValue = MultAdjustGeneralNotSettlementR_Var.Value
        ElseIf asControlId == MultAdjustGeneralNotSettlementS_Var.McmId
            oldValue = MultAdjustGeneralNotSettlementS_Var.Value
            LoadSettingFromMCM(MultAdjustGeneralNotSettlementS_Var, ModName)
            newValue = MultAdjustGeneralNotSettlementS_Var.Value

        ; multiplier adjustments - intelligence
        ElseIf asControlId == MultAdjustInt_Var.McmId
            oldValue = MultAdjustInt_Var.Value
            LoadSettingFromMCM(MultAdjustInt_Var, ModName)
            newValue = MultAdjustInt_Var.Value
        ElseIf asControlId == MultAdjustIntC_Var.McmId
            oldValue = MultAdjustIntC_Var.Value
            LoadSettingFromMCM(MultAdjustIntC_Var, ModName)
            newValue = MultAdjustIntC_Var.Value
        ElseIf asControlId == MultAdjustIntU_Var.McmId
            oldValue = MultAdjustIntU_Var.Value
            LoadSettingFromMCM(MultAdjustIntU_Var, ModName)
            newValue = MultAdjustIntU_Var.Value
        ElseIf asControlId == MultAdjustIntR_Var.McmId
            oldValue = MultAdjustIntR_Var.Value
            LoadSettingFromMCM(MultAdjustIntR_Var, ModName)
            newValue = MultAdjustIntR_Var.Value
        ElseIf asControlId == MultAdjustIntS_Var.McmId
            oldValue = MultAdjustIntS_Var.Value
            LoadSettingFromMCM(MultAdjustIntS_Var, ModName)
            newValue = MultAdjustIntS_Var.Value

        ; multiplier adjustments - luck
        ElseIf asControlId == MultAdjustLck_Var.McmId
            oldValue = MultAdjustLck_Var.Value
            LoadSettingFromMCM(MultAdjustLck_Var, ModName)
            newValue = MultAdjustLck_Var.Value
        ElseIf asControlId == MultAdjustLckC_Var.McmId
            oldValue = MultAdjustLckC_Var.Value
            LoadSettingFromMCM(MultAdjustLckC_Var, ModName)
            newValue = MultAdjustLckC_Var.Value
        ElseIf asControlId == MultAdjustLckU_Var.McmId
            oldValue = MultAdjustLckU_Var.Value
            LoadSettingFromMCM(MultAdjustLckU_Var, ModName)
            newValue = MultAdjustLckU_Var.Value
        ElseIf asControlId == MultAdjustLckR_Var.McmId
            oldValue = MultAdjustLckR_Var.Value
            LoadSettingFromMCM(MultAdjustLckR_Var, ModName)
            newValue = MultAdjustLckR_Var.Value
        ElseIf asControlId == MultAdjustLckS_Var.McmId
            oldValue = MultAdjustLckS_Var.Value
            LoadSettingFromMCM(MultAdjustLckS_Var, ModName)
            newValue = MultAdjustLckS_Var.Value

        ; multiplier adjustments - randomness
        ElseIf asControlId == MultAdjustRandomMin_Var.McmId
            oldValue = MultAdjustRandomMin_Var.Value
            LoadSettingFromMCM(MultAdjustRandomMin_Var, ModName)
            newValue = MultAdjustRandomMin_Var.Value
        ElseIf asControlId == MultAdjustRandomMinC_Var.McmId
            oldValue = MultAdjustRandomMinC_Var.Value
            LoadSettingFromMCM(MultAdjustRandomMinC_Var, ModName)
            newValue = MultAdjustRandomMinC_Var.Value
        ElseIf asControlId == MultAdjustRandomMinU_Var.McmId
            oldValue = MultAdjustRandomMinU_Var.Value
            LoadSettingFromMCM(MultAdjustRandomMinU_Var, ModName)
            newValue = MultAdjustRandomMinU_Var.Value
        ElseIf asControlId == MultAdjustRandomMinR_Var.McmId
            oldValue = MultAdjustRandomMinR_Var.Value
            LoadSettingFromMCM(MultAdjustRandomMinR_Var, ModName)
            newValue = MultAdjustRandomMinR_Var.Value
        ElseIf asControlId == MultAdjustRandomMinS_Var.McmId
            oldValue = MultAdjustRandomMinS_Var.Value
            LoadSettingFromMCM(MultAdjustRandomMinS_Var, ModName)
            newValue = MultAdjustRandomMinS_Var.Value

        ElseIf asControlId == MultAdjustRandomMax_Var.McmId
            oldValue = MultAdjustRandomMax_Var.Value
            LoadSettingFromMCM(MultAdjustRandomMax_Var, ModName)
            newValue = MultAdjustRandomMax_Var.Value
        ElseIf asControlId == MultAdjustRandomMaxC_Var.McmId
            oldValue = MultAdjustRandomMaxC_Var.Value
            LoadSettingFromMCM(MultAdjustRandomMaxC_Var, ModName)
            newValue = MultAdjustRandomMaxC_Var.Value
        ElseIf asControlId == MultAdjustRandomMaxU_Var.McmId
            oldValue = MultAdjustRandomMaxU_Var.Value
            LoadSettingFromMCM(MultAdjustRandomMaxU_Var, ModName)
            newValue = MultAdjustRandomMaxU_Var.Value
        ElseIf asControlId == MultAdjustRandomMaxR_Var.McmId
            oldValue = MultAdjustRandomMaxR_Var.Value
            LoadSettingFromMCM(MultAdjustRandomMaxR_Var, ModName)
            newValue = MultAdjustRandomMaxR_Var.Value
        ElseIf asControlId == MultAdjustRandomMaxS_Var.McmId
            oldValue = MultAdjustRandomMaxS_Var.Value
            LoadSettingFromMCM(MultAdjustRandomMaxS_Var, ModName)
            newValue = MultAdjustRandomMaxS_Var.Value

        ; advanced - general options
        ElseIf asControlId == ThreadLimit_Var.McmId
            oldValue = ThreadLimit_Var.Value
            LoadSettingFromMCM(ThreadLimit_Var, ModName)
            newValue = ThreadLimit_Var.Value
            ThreadManager.SetThreadLimit(ThreadLimit_Var.Value)
        ElseIf asControlId == EnableLogging_Var.McmId
            oldValue = EnableLogging_Var.Value
            LoadSettingFromMCM(EnableLogging_Var, ModName)
            newValue = EnableLogging_Var.Value
        ElseIf asControlId == EnableProfiling_Var.McmId
            oldValue = EnableProfiling_Var.Value
            LoadSettingFromMCM(EnableProfiling_Var, ModName)
            newValue = EnableProfiling_Var.Value

        ; advanced - methodology
        ElseIf asControlId == UseDirectMoveRecyclableItemListUpdate_Var.McmId
            oldValue = UseDirectMoveRecyclableItemListUpdate_Var.Value
            LoadSettingFromMCM(UseDirectMoveRecyclableItemListUpdate_Var, ModName)
            newValue = UseDirectMoveRecyclableItemListUpdate_Var.Value

        ; multiplier adjustments - scrapper 1-5
        Else
            int index = 0
            While index < ScrapperPerkMaxRanksSupported && oldValue as int == defaultValue
                If asControlId == MultAdjustScrapperSettlement_Var[index].McmId
                    oldValue = MultAdjustScrapperSettlement_Var[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperSettlement_Var[index], ModName)
                    newValue = MultAdjustScrapperSettlement_Var[index].Value
                ElseIf asControlId == MultAdjustScrapperSettlementC_Var[index].McmId
                    oldValue = MultAdjustScrapperSettlementC_Var[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperSettlementC_Var[index], ModName)
                    newValue = MultAdjustScrapperSettlementC_Var[index].Value
                ElseIf asControlId == MultAdjustScrapperSettlementU_Var[index].McmId
                    oldValue = MultAdjustScrapperSettlementU_Var[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperSettlementU_Var[index], ModName)
                    newValue = MultAdjustScrapperSettlementU_Var[index].Value
                ElseIf asControlId == MultAdjustScrapperSettlementR_Var[index].McmId
                    oldValue = MultAdjustScrapperSettlementR_Var[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperSettlementR_Var[index], ModName)
                    newValue = MultAdjustScrapperSettlementR_Var[index].Value
                ElseIf asControlId == MultAdjustScrapperSettlementS_Var[index].McmId
                    oldValue = MultAdjustScrapperSettlementS_Var[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperSettlementS_Var[index], ModName)
                    newValue = MultAdjustScrapperSettlementS_Var[index].Value

                ElseIf asControlId == MultAdjustScrapperNotSettlement_Var[index].McmId
                    oldValue = MultAdjustScrapperNotSettlement_Var[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperNotSettlement_Var[index], ModName)
                    newValue = MultAdjustScrapperNotSettlement_Var[index].Value
                ElseIf asControlId == MultAdjustScrapperNotSettlementC_Var[index].McmId
                    oldValue = MultAdjustScrapperNotSettlementC_Var[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperNotSettlementC_Var[index], ModName)
                    newValue = MultAdjustScrapperNotSettlementC_Var[index].Value
                ElseIf asControlId == MultAdjustScrapperNotSettlementU_Var[index].McmId
                    oldValue = MultAdjustScrapperNotSettlementU_Var[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperNotSettlementU_Var[index], ModName)
                    newValue = MultAdjustScrapperNotSettlementU_Var[index].Value
                ElseIf asControlId == MultAdjustScrapperNotSettlementR_Var[index].McmId
                    oldValue = MultAdjustScrapperNotSettlementR_Var[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperNotSettlementR_Var[index], ModName)
                    newValue = MultAdjustScrapperNotSettlementR_Var[index].Value
                ElseIf asControlId == MultAdjustScrapperNotSettlementS_Var[index].McmId
                    oldValue = MultAdjustScrapperNotSettlementS_Var[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperNotSettlementS_Var[index], ModName)
                    newValue = MultAdjustScrapperNotSettlementS_Var[index].Value
                EndIf

                index += 1
            EndWhile
        EndIf

        If oldValue as int != defaultValue
            Self._Log("MCM control ID '" + asControlId + "' was changed. Old value = " + oldValue \
                + ", new value = " + newValue)
        Else
            Self._Log("Unknown control ID: " + asControlId, 2)
        EndIf
    EndIf
EndFunction

; callback function for when the user moves to a different MCM menu
Function OnMCMMenuClose()
    Self.MultAdjustRandomSanityCheck()
    MCM.RefreshMenu()
EndFunction

; make sure that MultAdjustRandomMin_Var* properties are less than their MultAdjustRandomMax_Var* counterparts
; not strictly necessary since Utility.RandomFloat() doesn't care, but it looks better in the menus
Function MultAdjustRandomSanityCheck()
    Self._Log("Running sanity checks on MultAdjustRandom{Min,Max}* properties")
    float tempValue
    If MultAdjustRandomMin_Var.Value > MultAdjustRandomMax_Var.Value
        Self._Log("Fixing invalid combination: MultAdjustRandomMin_Var=" + MultAdjustRandomMin_Var.Value \
            + "; MultAdjustRandomMax_Var=" + MultAdjustRandomMax_Var.Value)
        tempValue = MultAdjustRandomMin_Var.Value
        ChangeSetting(MultAdjustRandomMin_Var, AvailableChangeTypes.Both, MultAdjustRandomMax_Var.Value, ModName)
        ChangeSetting(MultAdjustRandomMax_Var, AvailableChangeTypes.Both, tempValue, ModName)
    EndIf
    If MultAdjustRandomMinC_Var.Value > MultAdjustRandomMaxC_Var.Value
        Self._Log("Fixing invalid combination: MultAdjustRandomMinC_Var=" + MultAdjustRandomMinC_Var.Value \
            + "; MultAdjustRandomMaxC_Var=" + MultAdjustRandomMaxC_Var.Value)
        tempValue = MultAdjustRandomMinC_Var.Value
        ChangeSetting(MultAdjustRandomMinC_Var, AvailableChangeTypes.Both, MultAdjustRandomMaxC_Var.Value, ModName)
        ChangeSetting(MultAdjustRandomMaxC_Var, AvailableChangeTypes.Both, tempValue, ModName)
    EndIf
    If MultAdjustRandomMinU_Var.Value > MultAdjustRandomMaxU_Var.Value
        Self._Log("Fixing invalid combination: MultAdjustRandomMinU_Var=" + MultAdjustRandomMinU_Var.Value \
            + "; MultAdjustRandomMaxU_Var=" + MultAdjustRandomMaxU_Var.Value)
        tempValue = MultAdjustRandomMinU_Var.Value
        ChangeSetting(MultAdjustRandomMinU_Var, AvailableChangeTypes.Both, MultAdjustRandomMaxU_Var.Value, ModName)
        ChangeSetting(MultAdjustRandomMaxU_Var, AvailableChangeTypes.Both, tempValue, ModName)
    EndIf
    If MultAdjustRandomMinR_Var.Value > MultAdjustRandomMaxR_Var.Value
        Self._Log("Fixing invalid combination: MultAdjustRandomMinR_Var=" + MultAdjustRandomMinR_Var.Value \
            + "; MultAdjustRandomMaxR_Var=" + MultAdjustRandomMaxR_Var.Value)
        tempValue = MultAdjustRandomMinR_Var.Value
        ChangeSetting(MultAdjustRandomMinR_Var, AvailableChangeTypes.Both, MultAdjustRandomMaxR_Var.Value, ModName)
        ChangeSetting(MultAdjustRandomMaxR_Var, AvailableChangeTypes.Both, tempValue, ModName)
    EndIf
    If MultAdjustRandomMinS_Var.Value > MultAdjustRandomMaxS_Var.Value
        Self._Log("Fixing invalid combination: MultAdjustRandomMinS_Var=" + MultAdjustRandomMinS_Var.Value \
            + "; MultAdjustRandomMaxS_Var=" + MultAdjustRandomMaxS_Var.Value)
        tempValue = MultAdjustRandomMinS_Var.Value
        ChangeSetting(MultAdjustRandomMinS_Var, AvailableChangeTypes.Both, MultAdjustRandomMaxS_Var.Value, ModName)
        ChangeSetting(MultAdjustRandomMaxS_Var, AvailableChangeTypes.Both, tempValue, ModName)
    EndIf
EndFunction

; prep for uninstall of mod
Function Uninstall()
    Self._Log("Uninstallation sequence initialized!", 1, true)

    ; unregister from all events
    UnregisterForMenuOpenCloseEvent("PauseMenu")
    UnregisterForExternalEvent("OnMCMSettingChange|" + ModName)
    UnregisterForExternalEvent("OnMCMMenuClose|" + ModName)

    ; properties
    ; group Other
    PortableJunkRecyclerConstructibleObject = None

    ; group Settings
    ; settings - general
    MultBase_Var = None
    ReturnAtLeastOneComponent_Var = None
    FractionalComponentHandling_Var = None
    HasLimitedUses_Var = None
    NumberOfUses_Var = None
    ; settings - adjustment options
    GeneralMultAdjust_Var = None
    IntAffectsMult_Var = None
    LckAffectsMult_Var = None
    RngAffectsMult_Var = None
    ScrapperAffectsMult_Var = None
    ; recycler interface - behavior
    AutoRecyclingMode_Var = None
    EnableJunkFilter_Var = None
    AutoTransferJunk_Var = None
    TransferLowWeightRatioItems_Var = None
    UseAlwaysAutoTransferList_Var = None
    UseNeverAutoTransferList_Var = None
    EnableAutoTransferListEditing_Var = None
    EnableBehaviorOverrides_Var = None
    ModifierReadDelay_Var = None
    ReturnItemsSilently_Var = None
    InventoryRemovalProtection_Var = None
    ; recycler interface - crafting
    UseSimpleCraftingRecipe_Var = None
    CraftingStation_Var = None
    ; multiplier adjustments - general
    MultAdjustGeneralSettlement_Var = None
    MultAdjustGeneralSettlementC_Var = None
    MultAdjustGeneralSettlementU_Var = None
    MultAdjustGeneralSettlementR_Var = None
    MultAdjustGeneralSettlementS_Var = None
    MultAdjustGeneralNotSettlement_Var = None
    MultAdjustGeneralNotSettlementC_Var = None
    MultAdjustGeneralNotSettlementU_Var = None
    MultAdjustGeneralNotSettlementR_Var = None
    MultAdjustGeneralNotSettlementS_Var = None
    ; multiplier adjustments - intelligence
    MultAdjustInt_Var = None
    MultAdjustIntC_Var = None
    MultAdjustIntU_Var = None
    MultAdjustIntR_Var = None
    MultAdjustIntS_Var = None
    ; multiplier adjustments - luck
    MultAdjustLck_Var = None
    MultAdjustLckC_Var = None
    MultAdjustLckU_Var = None
    MultAdjustLckR_Var = None
    MultAdjustLckS_Var = None
    ; multiplier adjustments - randomness
    MultAdjustRandomMin_Var = None
    MultAdjustRandomMinC_Var = None
    MultAdjustRandomMinU_Var = None
    MultAdjustRandomMinR_Var = None
    MultAdjustRandomMinS_Var = None
    MultAdjustRandomMax_Var = None
    MultAdjustRandomMaxC_Var = None
    MultAdjustRandomMaxU_Var = None
    MultAdjustRandomMaxR_Var = None
    MultAdjustRandomMaxS_Var = None
    ; multiplier adjustments - scrapper
    DestroyArrayContents(MultAdjustScrapperSettlement_Var as var[])
    MultAdjustScrapperSettlement_Var = None
    DestroyArrayContents(MultAdjustScrapperSettlementC_Var as var[])
    MultAdjustScrapperSettlementC_Var = None
    DestroyArrayContents(MultAdjustScrapperSettlementU_Var as var[])
    MultAdjustScrapperSettlementU_Var = None
    DestroyArrayContents(MultAdjustScrapperSettlementR_Var as var[])
    MultAdjustScrapperSettlementR_Var = None
    DestroyArrayContents(MultAdjustScrapperSettlementS_Var as var[])
    MultAdjustScrapperSettlementS_Var = None
    DestroyArrayContents(MultAdjustScrapperNotSettlement_Var as var[])
    MultAdjustScrapperNotSettlement_Var = None
    DestroyArrayContents(MultAdjustScrapperNotSettlementC_Var as var[])
    MultAdjustScrapperNotSettlementC_Var = None
    DestroyArrayContents(MultAdjustScrapperNotSettlementU_Var as var[])
    MultAdjustScrapperNotSettlementU_Var = None
    DestroyArrayContents(MultAdjustScrapperNotSettlementR_Var as var[])
    MultAdjustScrapperNotSettlementR_Var = None
    DestroyArrayContents(MultAdjustScrapperNotSettlementS_Var as var[])
    MultAdjustScrapperNotSettlementS_Var = None
    ; advanced - general options
    ThreadLimit_Var = None
    EnableLogging_Var = None
    EnableProfiling_Var = None
    ; advanced - methodology
    UseDirectMoveRecyclableItemListUpdate_Var = None

    ; local variables
    ControlManager = None
    ThreadManager = None
    AvailableChangeTypes = None

    Self._Log("Uninstallation sequence complete!", 1, abForce = true)
EndFunction
