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



ScriptName PortableJunkRecyclerMk2:ControlScript extends Quest

; import the base global functions and structs
import PortableJunkRecyclerMk2:Base



; PROPERTIES
; ----------

Group Components
    FormListWrapper Property ComponentListC Auto Mandatory
    FormListWrapper Property ComponentListU Auto Mandatory
    FormListWrapper Property ComponentListR Auto Mandatory
    FormListWrapper Property ComponentListS Auto Mandatory

    FormListWrapper Property ScrapListC Auto Mandatory
    FormListWrapper Property ScrapListU Auto Mandatory
    FormListWrapper Property ScrapListR Auto Mandatory
    FormListWrapper Property ScrapListS Auto Mandatory

    FormListWrapper Property ScrapListAll Auto Mandatory

    ComponentMap[] Property ComponentMappings Auto Hidden
EndGroup

Group Messages
    Message Property MessageF4SENotInstalled Auto Mandatory
    Message Property MessageMCMNotInstalled Auto Mandatory
    Message Property MessageInitialized Auto Mandatory
    Message Property MessageCurrentMultipliers Auto Mandatory
    Message Property MessageCurrentMultipliersRng Auto Mandatory
    Message Property MessageUsesLeftLimited Auto Mandatory
    Message Property MessageUsesLeftUnlimited Auto Mandatory
    Message Property MessageSettingsReset Auto Mandatory
    Message Property MessageSettingsResetFailBusy Auto Mandatory
    Message Property MessageSettingsResetFailRunning Auto Mandatory
    Message Property MessageLocksReset Auto Mandatory
    Message Property MessageRecyclableItemsListsReset Auto Mandatory
    Message Property MessageRecyclableItemsListsResetFailBusy Auto Mandatory
    Message Property MessageRecyclableItemsListsResetFailRunning Auto Mandatory
    Message Property MessageAlwaysAutoTransferListReset Auto Mandatory
    Message Property MessageAlwaysAutoTransferListResetFailBusy Auto Mandatory
    Message Property MessageAlwaysAutoTransferListResetFailRunning Auto Mandatory
    Message Property MessageNeverAutoTransferListReset Auto Mandatory
    Message Property MessageNeverAutoTransferListResetFailBusy Auto Mandatory
    Message Property MessageNeverAutoTransferListResetFailRunning Auto Mandatory
    Message Property MessageUninstalled Auto Mandatory
    Message Property MessageUninstallFailBusy Auto Mandatory
    Message Property MessageUninstallFailRunning Auto Mandatory
EndGroup

Group Other
    Actor Property PlayerRef Auto Mandatory
    WorkshopParentScript Property WorkshopParent Auto Mandatory
    { the workshop parent script
      enables this script to determine whether its in a player-owned settlement or not }

    FormListWrapper Property RecyclableItemList Auto Mandatory
    FormListWrapper Property LowWeightRatioItemList Auto Mandatory

    FormListWrapper Property NeverAutoTransferList Auto Mandatory
    FormListWrapper Property AlwaysAutoTransferList Auto Mandatory

    ; WorkerThread scripts are attached to a different quest to prevent issues using MCM
    ThreadManager Property ThreadManager Auto Mandatory

    ; this is the COBJ record for the recycler item, so it can be dynamically manipulated
    ConstructibleObject Property PortableJunkRecyclerConstructibleObject Auto Mandatory
EndGroup

Group RuntimeState
    ; not 'real' mutexes, but I don't feel like trying to use states for this purpose
    bool Property MutexBusy Auto Hidden
    bool Property MutexRunning Auto Hidden
    bool Property MutexWaiting Auto Hidden

    int Property NumberOfTimesUsed Auto Hidden

    Perk[] Property ScrapperPerks Auto Hidden

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

    bool Property ScriptExtenderInstalled Auto Hidden
    bool Property ModConfigMenuInstalled Auto Hidden

    bool Property HotkeyForceTransferJunk Auto Hidden
    bool Property HotkeyForceRetainJunk Auto Hidden
    bool Property HotkeyEditAutoTransferLists Auto Hidden
EndGroup

Group Settings
    ; settings - general
    SettingFloat Property MultBase Auto Hidden
    SettingBool Property ReturnAtLeastOneComponent Auto Hidden
    SettingInt Property FractionalComponentHandling Auto Hidden
    SettingBool Property HasLimitedUses Auto Hidden
    SettingInt Property NumberOfUses Auto Hidden

    ; settings - adjustment options
    SettingInt Property GeneralMultAdjust Auto Hidden
    SettingInt Property IntAffectsMult Auto Hidden
    SettingInt Property LckAffectsMult Auto Hidden
    SettingInt Property RngAffectsMult Auto Hidden
    SettingInt Property ScrapperAffectsMult Auto Hidden

    ; recycler interface - behavior
    SettingBool Property AutoRecyclingMode Auto Hidden
    SettingBool Property EnableJunkFilter Auto Hidden
    SettingBool Property AutoTransferJunk Auto Hidden
    SettingInt Property TransferLowWeightRatioItems Auto Hidden
    SettingBool Property UseAlwaysAutoTransferList Auto Hidden
    SettingBool Property UseNeverAutoTransferList Auto Hidden
    SettingBool Property EnableAutoTransferListEditing Auto Hidden
    SettingBool Property EnableBehaviorOverrides Auto Hidden
    SettingBool Property ReturnItemsSilently Auto Hidden

    ; recycler interface - crafting
    SettingInt Property CraftingStation Auto Hidden

    ; multiplier adjustments - general
    SettingFloat Property MultAdjustGeneralSettlement Auto Hidden
    SettingFloat Property MultAdjustGeneralSettlementC Auto Hidden
    SettingFloat Property MultAdjustGeneralSettlementU Auto Hidden
    SettingFloat Property MultAdjustGeneralSettlementR Auto Hidden
    SettingFloat Property MultAdjustGeneralSettlementS Auto Hidden
    SettingFloat Property MultAdjustGeneralNotSettlement Auto Hidden
    SettingFloat Property MultAdjustGeneralNotSettlementC Auto Hidden
    SettingFloat Property MultAdjustGeneralNotSettlementU Auto Hidden
    SettingFloat Property MultAdjustGeneralNotSettlementR Auto Hidden
    SettingFloat Property MultAdjustGeneralNotSettlementS Auto Hidden

    ; multiplier adjustments - intelligence
    SettingFloat Property MultAdjustInt Auto Hidden
    SettingFloat Property MultAdjustIntC Auto Hidden
    SettingFloat Property MultAdjustIntU Auto Hidden
    SettingFloat Property MultAdjustIntR Auto Hidden
    SettingFloat Property MultAdjustIntS Auto Hidden

    ; multiplier adjustments - luck
    SettingFloat Property MultAdjustLck Auto Hidden
    SettingFloat Property MultAdjustLckC Auto Hidden
    SettingFloat Property MultAdjustLckU Auto Hidden
    SettingFloat Property MultAdjustLckR Auto Hidden
    SettingFloat Property MultAdjustLckS Auto Hidden

    ; multiplier adjustments - randomness
    SettingFloat Property MultAdjustRandomMin Auto Hidden
    SettingFloat Property MultAdjustRandomMinC Auto Hidden
    SettingFloat Property MultAdjustRandomMinU Auto Hidden
    SettingFloat Property MultAdjustRandomMinR Auto Hidden
    SettingFloat Property MultAdjustRandomMinS Auto Hidden
    SettingFloat Property MultAdjustRandomMax Auto Hidden
    SettingFloat Property MultAdjustRandomMaxC Auto Hidden
    SettingFloat Property MultAdjustRandomMaxU Auto Hidden
    SettingFloat Property MultAdjustRandomMaxR Auto Hidden
    SettingFloat Property MultAdjustRandomMaxS Auto Hidden

    ; multiplier adjustments - scrapper
    SettingFloat[] Property MultAdjustScrapperSettlement Auto Hidden
    SettingFloat[] Property MultAdjustScrapperSettlementC Auto Hidden
    SettingFloat[] Property MultAdjustScrapperSettlementU Auto Hidden
    SettingFloat[] Property MultAdjustScrapperSettlementR Auto Hidden
    SettingFloat[] Property MultAdjustScrapperSettlementS Auto Hidden
    SettingFloat[] Property MultAdjustScrapperNotSettlement Auto Hidden
    SettingFloat[] Property MultAdjustScrapperNotSettlementC Auto Hidden
    SettingFloat[] Property MultAdjustScrapperNotSettlementU Auto Hidden
    SettingFloat[] Property MultAdjustScrapperNotSettlementR Auto Hidden
    SettingFloat[] Property MultAdjustScrapperNotSettlementS Auto Hidden

    ; advanced - multithreading
    SettingInt Property ThreadLimit Auto Hidden

    ; advanced - methodology
    SettingBool Property UseDirectMoveRecyclableItemListUpdate Auto Hidden
EndGroup

int Property iSaveFileMonitor Auto Hidden ; Do not mess with ever - this is used by Canary to track data loss
{ Canary support
  https://www.nexusmods.com/fallout4/mods/44949 }



; VARIABLES
; ---------

string ModName = "Portable Junk Recycler Mk 2" const
string ModVersion = "0.6.0-beta" const
string FullScriptName = "PortableJunkRecyclerMk2:ControlScript" const
int ScrapperPerkMaxRanksSupported = 5 const
SettingChangeType AvailableChangeTypes
int CurrentChangeType

; DirectX scan codes: https://www.creationkit.com/fallout4/index.php?title=DirectX_Scan_Codes
int LShift = 160 const
int RShift = 161 const
int LCtrl = 162 const
int RCtrl = 163 const
int LAlt = 164 const
int RAlt = 165 const



; EVENTS
; ------

Event OnQuestInit()
    MutexBusy = true
    Debug.StartStackProfiling()
    Debug.OpenUserLog(ModName)

    Self.Initialize(abQuestInit = true)

    Debug.StopStackProfiling()
    MutexBusy = false
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    Debug.StartStackProfiling()
    Debug.OpenUserLog(ModName)

    ; immediately abort if there's already a thread waiting on mutex release
    If MutexWaiting
        Self._DebugTrace("OnPlayerLoadGame: Already a thread waiting on mutex release; aborting")
        Return
    EndIf

    ; wait for mutexes to release
    int waitTimeLeft = 30
    float waitTime = 3.0 const
    While (MutexRunning || MutexBusy) && waitTimeLeft > 0
        MutexWaiting = true
        Self._DebugTrace("OnPlayerLoadGame: Waiting on mutex release. Time left = " + waitTimeLeft)
        Utility.Wait(waitTime)
        waitTimeLeft -= waitTime as int
    EndWhile

    ; lock function in case user exits game while recycling process is running or this same function is running
    If ! (MutexRunning || MutexBusy)
        MutexBusy = true

        Self.Initialize()

        MutexBusy = false
    Else
        Self._DebugTrace("OnPlayerLoadGame: Mutexes didn't release within time limit", 1)
    EndIf

    Debug.StopStackProfiling()
    MutexWaiting = false
EndEvent

Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
    If asMenuName == "PauseMenu" && ! abOpening
        Self._DebugTrace("Pause menu closing")
        Self.MultAdjustRandomSanityCheck()
    EndIf
EndEvent

Event OnKeyDown(int aiKeyCode)
    If aiKeyCode == LAlt || aiKeyCode == RAlt
        Self._DebugTrace("OnKeyDown: Alt (" + aiKeyCode + ")")
        HotkeyEditAutoTransferLists = true
    ElseIf aiKeyCode == LCtrl || aiKeyCode == RCtrl
        Self._DebugTrace("OnKeyDown: Ctrl (" + aiKeyCode + ")")
        HotkeyForceRetainJunk = true
    ElseIf aiKeyCode == LShift || aiKeyCode == RShift
        Self._DebugTrace("OnKeyDown: Shift (" + aiKeyCode + ")")
        HotkeyForceTransferJunk = true
    EndIf
EndEvent

Event OnKeyUp(int aiKeyCode, float afTime)
    If aiKeyCode == LAlt || aiKeyCode == RAlt
        Self._DebugTrace("OnKeyDown: Alt (" + aiKeyCode + ")")
        HotkeyEditAutoTransferLists = false
    ElseIf aiKeyCode == LCtrl || aiKeyCode == RCtrl
        Self._DebugTrace("OnKeyUp: Ctrl (" + aiKeyCode + ")")
        HotkeyForceRetainJunk = false
    ElseIf aiKeyCode == LShift || aiKeyCode == RShift
        Self._DebugTrace("OnKeyUp: Shift (" + aiKeyCode + ")")
        HotkeyForceTransferJunk = false
    EndIf
EndEvent



; FUNCTIONS
; ---------

; add a bit of text to traces going into the papyrus user log
Function _DebugTrace(string asMessage, int aiSeverity = 0) DebugOnly
    string baseMessage = "ControlScript: " const
    If aiSeverity == 0
        Debug.TraceUser(ModName, baseMessage + asMessage)
    ElseIf aiSeverity == 1
        Debug.TraceUser(ModName, "WARNING: " + baseMessage + asMessage)
    ElseIf aiSeverity == 2
        Debug.TraceUser(ModName, "ERROR: " + baseMessage + asMessage)
    EndIf
EndFunction

; consolidated init
Function Initialize(bool abQuestInit = false)
    Self._DebugTrace(ModName + " v" + ModVersion)
    Self._DebugTrace("ThreadManager initialized: " + ThreadManager.Initialized)
    If abQuestInit
        Self._DebugTrace("Beginning onetime init process")
    Else
        Self._DebugTrace("Beginning runtime init process")
    EndIf
    Self.CheckForCanary()
    Self.InitVariables(abForce = abQuestInit)
    Self.CheckForF4SE()
    Self.CheckForMCM()
    Self.InitSettings(abForce = abQuestInit)
    Self.InitSettingsSupplemental()
    Self.LoadAllSettingsFromMCM()
    Self.InitFormListWrappers()
    Self.InitComponentMappings()
    Self.InitScrapListAll()
    Self.InitScrapperPerks()
    Self.RegisterForMCMEvents()
    If ScriptExtenderInstalled
        RegisterForKey(LAlt)
        RegisterForKey(RAlt)
        RegisterForKey(LCtrl)
        RegisterForKey(RCtrl)
        RegisterForKey(LShift)
        RegisterForKey(RShift)
    EndIf
    If abQuestInit
        RegisterForRemoteEvent(PlayerRef, "OnPlayerLoadGame")
        RegisterForMenuOpenCloseEvent("PauseMenu")
        MessageInitialized.Show()
        Self._DebugTrace("Finished onetime init process")
    Else
        Self._DebugTrace("Finished runtime init process")
    EndIf
EndFunction

; initialize script-internal variables
Function InitVariables(bool abForce = false)
    Self._DebugTrace("Initializing variables")
    If abForce || ! AvailableChangeTypes
        Self._DebugTrace("Initializing AvailableChangeTypes")
        AvailableChangeTypes = new SettingChangeType
    EndIf
EndFunction

; check to see if F4SE is installed
Function CheckForF4SE()
    Debug.Trace(FullScriptName + ": Checking if F4SE is installed...")
    Self._DebugTrace("Checking if F4SE is installed...")
    ScriptExtenderInstalled = F4SE.GetVersionRelease() as bool
    If ScriptExtenderInstalled
        Debug.Trace(FullScriptName + ": F4SE installed")
        Self._DebugTrace("F4SE v" + F4SE.GetVersion() + "." + F4SE.GetVersionMinor() + "." + F4SE.GetVersionBeta() + "." + \
            F4SE.GetVersionRelease() + " installed (script version " + F4SE.GetScriptVersionRelease() + ")")
    Else
        Debug.Trace(FullScriptName + ": F4SE not installed", 1)
        Self._DebugTrace("F4SE not installed", 1)
        MessageF4SENotInstalled.Show()
    EndIf
EndFunction

; check to see if MCM is installed; depends on F4SE
Function CheckForMCM()
    Debug.Trace(FullScriptName + ": Checking if MCM is installed...")
    Self._DebugTrace("Checking if MCM is installed...")
    ModConfigMenuInstalled = MCM.IsInstalled() as bool
    If ModConfigMenuInstalled && ScriptExtenderInstalled
        Debug.Trace(FullScriptName + ": MCM installed")
        Self._DebugTrace("MCM installed (version code " + MCM.GetVersionCode() + ")")
        CurrentChangeType = AvailableChangeTypes.Both
    ElseIf ModConfigMenuInstalled && ! ScriptExtenderInstalled
        Debug.Trace(FullScriptName + ": MCM installed, but F4SE is not; disabling support")
        Self._DebugTrace("MCM installed, but F4SE is not; disabling support")
        ModConfigMenuInstalled = false
        CurrentChangeType = AvailableChangeTypes.ValueOnly
    Else
        Debug.Trace(FullScriptName + ": MCM not installed")
        Self._DebugTrace("MCM not installed")
        CurrentChangeType = AvailableChangeTypes.ValueOnly
        MessageMCMNotInstalled.Show()
    EndIf
EndFunction

; initialize properties that hold settings
Function InitSettings(bool abForce = false)
    Self._DebugTrace("Initializing settings")

    ; settings - general
    If abForce || ! MultBase
        Self._DebugTrace("Initializing MultBase")
        MultBase = new SettingFloat
    EndIf
    If abForce || ! ReturnAtLeastOneComponent
        Self._DebugTrace("Initializing ReturnAtLeastOneComponent")
        ReturnAtLeastOneComponent = new SettingBool
    EndIf
    If abForce || ! FractionalComponentHandling
        Self._DebugTrace("Initializing FractionalComponentHandling")
        FractionalComponentHandling = new SettingInt
    EndIf
    If abForce || ! HasLimitedUses
        Self._DebugTrace("Initializing HasLimitedUses")
        HasLimitedUses = new SettingBool
    EndIf
    If abForce || ! NumberOfUses
        Self._DebugTrace("Initializing NumberOfUses")
        NumberOfUses = new SettingInt
    EndIf

    ; settings - adjustment options
    If abForce || ! GeneralMultAdjust
        Self._DebugTrace("Initializing GeneralMultAdjust")
        GeneralMultAdjust = new SettingInt
    EndIf
    If abForce || ! IntAffectsMult
        Self._DebugTrace("Initializing IntAffectsMult")
        IntAffectsMult = new SettingInt
    EndIf
    If abForce || ! LckAffectsMult
        Self._DebugTrace("Initializing LckAffectsMult")
        LckAffectsMult = new SettingInt
    EndIf
    If abForce || ! RngAffectsMult
        Self._DebugTrace("Initializing RngAffectsMult")
        RngAffectsMult = new SettingInt
    EndIf
    If abForce || ! ScrapperAffectsMult
        Self._DebugTrace("Initializing ScrapperAffectsMult")
        ScrapperAffectsMult = new SettingInt
    EndIf

    ; recycler interface - behavior
    If abForce || ! AutoRecyclingMode
        Self._DebugTrace("Initializing AutoRecyclingMode")
        AutoRecyclingMode = new SettingBool
    EndIf
    If abForce || ! EnableJunkFilter
        Self._DebugTrace("Initializing EnableJunkFilter")
        EnableJunkFilter = new SettingBool
    EndIf
    If abForce || ! AutoTransferJunk
        Self._DebugTrace("Initializing AutoTransferJunk")
        AutoTransferJunk = new SettingBool
    EndIf
    If abForce || ! TransferLowWeightRatioItems
        Self._DebugTrace("Initializing TransferLowWeightRatioItems")
        TransferLowWeightRatioItems = new SettingInt
    EndIf
    If abForce || ! UseAlwaysAutoTransferList
        Self._DebugTrace("Initializing UseAlwaysAutoTransferList")
        UseAlwaysAutoTransferList = new SettingBool
    EndIf
    If abForce || ! UseNeverAutoTransferList
        Self._DebugTrace("Initializing UseNeverAutoTransferList")
        UseNeverAutoTransferList = new SettingBool
    EndIf
    If abForce || ! EnableAutoTransferListEditing
        Self._DebugTrace("Initializing EnableAutoTransferListEditing")
        EnableAutoTransferListEditing = new SettingBool
    EndIf
    If abForce || ! EnableBehaviorOverrides
        Self._DebugTrace("Initializing EnableBehaviorOverrides")
        EnableBehaviorOverrides = new SettingBool
    EndIf
    If abForce || ! ReturnItemsSilently
        Self._DebugTrace("Initializing ReturnItemsSilently")
        ReturnItemsSilently = new SettingBool
    EndIf

    ; recycler interface - crafting
    if abForce || ! CraftingStation
        Self._DebugTrace("Initializing CraftingStation")
        CraftingStation = new SettingInt
    EndIf

    ; multiplier adjustments - general
    If abForce || ! MultAdjustGeneralSettlement
        Self._DebugTrace("Initializing MultAdjustGeneralSettlement")
        MultAdjustGeneralSettlement = new SettingFloat
    EndIf
    If abForce || ! MultAdjustGeneralSettlementC
        Self._DebugTrace("Initializing MultAdjustGeneralSettlementC")
        MultAdjustGeneralSettlementC = new SettingFloat
    EndIf
    If abForce || ! MultAdjustGeneralSettlementU
        Self._DebugTrace("Initializing MultAdjustGeneralSettlementU")
        MultAdjustGeneralSettlementU = new SettingFloat
    EndIf
    If abForce || ! MultAdjustGeneralSettlementR
        Self._DebugTrace("Initializing MultAdjustGeneralSettlementR")
        MultAdjustGeneralSettlementR = new SettingFloat
    EndIf
    If abForce || ! MultAdjustGeneralSettlementS
        Self._DebugTrace("Initializing MultAdjustGeneralSettlementS")
        MultAdjustGeneralSettlementS = new SettingFloat
    EndIf

    If abForce || ! MultAdjustGeneralNotSettlement
        Self._DebugTrace("Initializing MultAdjustGeneralNotSettlement")
        MultAdjustGeneralNotSettlement = new SettingFloat
    EndIf
    If abForce || ! MultAdjustGeneralNotSettlementC
        Self._DebugTrace("Initializing MultAdjustGeneralNotSettlementC")
        MultAdjustGeneralNotSettlementC = new SettingFloat
    EndIf
    If abForce || ! MultAdjustGeneralNotSettlementU
        Self._DebugTrace("Initializing MultAdjustGeneralNotSettlementU")
        MultAdjustGeneralNotSettlementU = new SettingFloat
    EndIf
    If abForce || ! MultAdjustGeneralNotSettlementR
        Self._DebugTrace("Initializing MultAdjustGeneralNotSettlementR")
        MultAdjustGeneralNotSettlementR = new SettingFloat
    EndIf
    If abForce || ! MultAdjustGeneralNotSettlementS
        Self._DebugTrace("Initializing MultAdjustGeneralNotSettlementS")
        MultAdjustGeneralNotSettlementS = new SettingFloat
    EndIf

    ; multiplier adjustments - intelligence
    If abForce || ! MultAdjustInt
        Self._DebugTrace("Initializing MultAdjustInt")
        MultAdjustInt = new SettingFloat
    EndIf
    If abForce || ! MultAdjustIntC
        Self._DebugTrace("Initializing MultAdjustIntC")
        MultAdjustIntC = new SettingFloat
    EndIf
    If abForce || ! MultAdjustIntU
        Self._DebugTrace("Initializing MultAdjustIntU")
        MultAdjustIntU = new SettingFloat
    EndIf
    If abForce || ! MultAdjustIntR
        Self._DebugTrace("Initializing MultAdjustIntR")
        MultAdjustIntR = new SettingFloat
    EndIf
    If abForce || ! MultAdjustIntS
        Self._DebugTrace("Initializing MultAdjustIntS")
        MultAdjustIntS = new SettingFloat
    EndIf

    ; multiplier adjustments - luck
    If abForce || ! MultAdjustLck
        Self._DebugTrace("Initializing MultAdjustLck")
        MultAdjustLck = new SettingFloat
    EndIf
    If abForce || ! MultAdjustLckC
        Self._DebugTrace("Initializing MultAdjustLckC")
        MultAdjustLckC = new SettingFloat
    EndIf
    If abForce || ! MultAdjustLckU
        Self._DebugTrace("Initializing MultAdjustLckU")
        MultAdjustLckU = new SettingFloat
    EndIf
    If abForce || ! MultAdjustLckR
        Self._DebugTrace("Initializing MultAdjustLckR")
        MultAdjustLckR = new SettingFloat
    EndIf
    If abForce || ! MultAdjustLckS
        Self._DebugTrace("Initializing MultAdjustLckS")
        MultAdjustLckS = new SettingFloat
    EndIf

    ; multiplier adjustments - randomness
    If abForce || ! MultAdjustRandomMin
        Self._DebugTrace("Initializing MultAdjustRandomMin")
        MultAdjustRandomMin = new SettingFloat
    EndIf
    If abForce || ! MultAdjustRandomMinC
        Self._DebugTrace("Initializing MultAdjustRandomMinC")
        MultAdjustRandomMinC = new SettingFloat
    EndIf
    If abForce || ! MultAdjustRandomMinU
        Self._DebugTrace("Initializing MultAdjustRandomMinU")
        MultAdjustRandomMinU = new SettingFloat
    EndIf
    If abForce || ! MultAdjustRandomMinR
        Self._DebugTrace("Initializing MultAdjustRandomMinR")
        MultAdjustRandomMinR = new SettingFloat
    EndIf
    If abForce || ! MultAdjustRandomMinS
        Self._DebugTrace("Initializing MultAdjustRandomMinS")
        MultAdjustRandomMinS = new SettingFloat
    EndIf

    If abForce || ! MultAdjustRandomMax
        Self._DebugTrace("Initializing MultAdjustRandomMax")
        MultAdjustRandomMax = new SettingFloat
    EndIf
    If abForce || ! MultAdjustRandomMaxC
        Self._DebugTrace("Initializing MultAdjustRandomMaxC")
        MultAdjustRandomMaxC = new SettingFloat
    EndIf
    If abForce || ! MultAdjustRandomMaxU
        Self._DebugTrace("Initializing MultAdjustRandomMaxU")
        MultAdjustRandomMaxU = new SettingFloat
    EndIf
    If abForce || ! MultAdjustRandomMaxR
        Self._DebugTrace("Initializing MultAdjustRandomMaxR")
        MultAdjustRandomMaxR = new SettingFloat
    EndIf
    If abForce || ! MultAdjustRandomMaxS
        Self._DebugTrace("Initializing MultAdjustRandomMaxS")
        MultAdjustRandomMaxS = new SettingFloat
    EndIf

    ; multiplier adjustments - scrapper 1-5
    If abForce || ! MultAdjustScrapperSettlement
        Self._DebugTrace("Initializing MultAdjustScrapperSettlement")
        MultAdjustScrapperSettlement = new SettingFloat[ScrapperPerkMaxRanksSupported]
    EndIf
    If abForce || ! MultAdjustScrapperSettlementC
        Self._DebugTrace("Initializing MultAdjustScrapperSettlementC")
        MultAdjustScrapperSettlementC = new SettingFloat[ScrapperPerkMaxRanksSupported]
    EndIf
    If abForce || ! MultAdjustScrapperSettlementU
        Self._DebugTrace("Initializing MultAdjustScrapperSettlementU")
        MultAdjustScrapperSettlementU = new SettingFloat[ScrapperPerkMaxRanksSupported]
    EndIf
    If abForce || ! MultAdjustScrapperSettlementR
        Self._DebugTrace("Initializing MultAdjustScrapperSettlementR")
        MultAdjustScrapperSettlementR = new SettingFloat[ScrapperPerkMaxRanksSupported]
    EndIf
    If abForce || ! MultAdjustScrapperSettlementS
        Self._DebugTrace("Initializing MultAdjustScrapperSettlementS")
        MultAdjustScrapperSettlementS = new SettingFloat[ScrapperPerkMaxRanksSupported]
    EndIf

    If abForce || ! MultAdjustScrapperNotSettlement
        Self._DebugTrace("Initializing MultAdjustScrapperNotSettlement")
        MultAdjustScrapperNotSettlement = new SettingFloat[ScrapperPerkMaxRanksSupported]
    EndIf
    If abForce || ! MultAdjustScrapperNotSettlementC
        Self._DebugTrace("Initializing MultAdjustScrapperNotSettlementC")
        MultAdjustScrapperNotSettlementC = new SettingFloat[ScrapperPerkMaxRanksSupported]
    EndIf
    If abForce || ! MultAdjustScrapperNotSettlementU
        Self._DebugTrace("Initializing MultAdjustScrapperNotSettlementU")
        MultAdjustScrapperNotSettlementU = new SettingFloat[ScrapperPerkMaxRanksSupported]
    EndIf
    If abForce || ! MultAdjustScrapperNotSettlementR
        Self._DebugTrace("Initializing MultAdjustScrapperNotSettlementR")
        MultAdjustScrapperNotSettlementR = new SettingFloat[ScrapperPerkMaxRanksSupported]
    EndIf
    If abForce || ! MultAdjustScrapperNotSettlementS
        Self._DebugTrace("Initializing MultAdjustScrapperNotSettlementS")
        MultAdjustScrapperNotSettlementS = new SettingFloat[ScrapperPerkMaxRanksSupported]
    EndIf

    int index = 0
    While index < ScrapperPerkMaxRanksSupported
        If abForce || ! MultAdjustScrapperSettlement[index]
            Self._DebugTrace("Initializing MultAdjustScrapperSettlement[" + index + "]")
            MultAdjustScrapperSettlement[index] = new SettingFloat
        EndIf
        If abForce || ! MultAdjustScrapperSettlementC[index]
            Self._DebugTrace("Initializing MultAdjustScrapperSettlementC[" + index + "]")
            MultAdjustScrapperSettlementC[index] = new SettingFloat
        EndIf
        If abForce || ! MultAdjustScrapperSettlementU[index]
            Self._DebugTrace("Initializing MultAdjustScrapperSettlementU[" + index + "]")
            MultAdjustScrapperSettlementU[index] = new SettingFloat
        EndIf
        If abForce || ! MultAdjustScrapperSettlementR[index]
            Self._DebugTrace("Initializing MultAdjustScrapperSettlementR[" + index + "]")
            MultAdjustScrapperSettlementR[index] = new SettingFloat
        EndIf
        If abForce || ! MultAdjustScrapperSettlementS[index]
            Self._DebugTrace("Initializing MultAdjustScrapperSettlementS[" + index + "]")
            MultAdjustScrapperSettlementS[index] = new SettingFloat
        EndIf

        If abForce || ! MultAdjustScrapperNotSettlement[index]
            Self._DebugTrace("Initializing MultAdjustScrapperNotSettlement[" + index + "]")
            MultAdjustScrapperNotSettlement[index] = new SettingFloat
        EndIf
        If abForce || ! MultAdjustScrapperNotSettlementC[index]
            Self._DebugTrace("Initializing MultAdjustScrapperNotSettlementC[" + index + "]")
            MultAdjustScrapperNotSettlementC[index] = new SettingFloat
        EndIf
        If abForce || ! MultAdjustScrapperNotSettlementU[index]
            Self._DebugTrace("Initializing MultAdjustScrapperNotSettlementU[" + index + "]")
            MultAdjustScrapperNotSettlementU[index] = new SettingFloat
        EndIf
        If abForce || ! MultAdjustScrapperNotSettlementR[index]
            Self._DebugTrace("Initializing MultAdjustScrapperNotSettlementR[" + index + "]")
            MultAdjustScrapperNotSettlementR[index] = new SettingFloat
        EndIf
        If abForce || ! MultAdjustScrapperNotSettlementS[index]
            Self._DebugTrace("Initializing MultAdjustScrapperNotSettlementS[" + index + "]")
            MultAdjustScrapperNotSettlementS[index] = new SettingFloat
        EndIf

        index += 1
    EndWhile

    ; advanced - multithreading
    If abForce || ! ThreadLimit
        Self._DebugTrace("Initializing ThreadLimit")
        ThreadLimit = new SettingInt
    EndIf

    ; advanced - methodology
    If abForce || ! UseDirectMoveRecyclableItemListUpdate
        Self._DebugTrace("Initializing UseNoTouchRecyclableItemListUpdate")
        UseDirectMoveRecyclableItemListUpdate = new SettingBool
    EndIf
EndFunction

; perform supplemental initialization on properties that hold settings
Function InitSettingsSupplemental()
    Self._DebugTrace("Initializing settings (supplemental)")

    float adjustMin = -2.0 const
    float adjustMax = 2.0 const
    float statAdjustMin = 0.0 const
    float statAdjustMax = 1.0 const
    float randomAdjustMin = -6.0 const
    float randomAdjustMax = 6.0 const

    ; settings - general
    MultBase.ValueDefault = 1.0
    MultBase.McmId = "fMultBase:GeneralOptions"
    MultBase.ValueMin = 0.0
    MultBase.ValueMax = adjustMax

    ReturnAtLeastOneComponent.ValueDefault = true
    ReturnAtLeastOneComponent.McmId = "bReturnAtLeastOneComponent:GeneralOptions"

    FractionalComponentHandling.ValueDefault = 2
    FractionalComponentHandling.McmId = "iFractionalComponentHandling:GeneralOptions"
    FractionalComponentHandling.ValueMin = 0
    FractionalComponentHandling.ValueMax = 2

    HasLimitedUses.ValueDefault = false
    HasLimitedUses.McmId = "bHasLimitedUses:GeneralOptions"

    NumberOfUses.ValueDefault = 50
    NumberOfUses.McmId = "iNumberOfUses:GeneralOptions"
    NumberOfUses.ValueMin = 1
    NumberOfUses.ValueMax = 200

    ; settings - adjustment options
    GeneralMultAdjust.ValueDefault = 0
    GeneralMultAdjust.McmId = "iGeneralMultAdjust:AdjustmentOptions"
    GeneralMultAdjust.ValueMin = 0
    GeneralMultAdjust.ValueMax = 1

    IntAffectsMult.ValueDefault = 1
    IntAffectsMult.McmId = "iIntAffectsMult:AdjustmentOptions"
    IntAffectsMult.ValueMin = 0
    IntAffectsMult.ValueMax = 2

    LckAffectsMult.ValueDefault = 1
    LckAffectsMult.McmId = "iLckAffectsMult:AdjustmentOptions"
    LckAffectsMult.ValueMin = 0
    LckAffectsMult.ValueMax = 2

    RngAffectsMult.ValueDefault = 0
    RngAffectsMult.McmId = "iRngAffectsMult:AdjustmentOptions"
    RngAffectsMult.ValueMin = 0
    RngAffectsMult.ValueMax = 2

    ScrapperAffectsMult.ValueDefault = 1
    ScrapperAffectsMult.McmId = "iScrapperAffectsMult:AdjustmentOptions"
    ScrapperAffectsMult.ValueMin = 0
    ScrapperAffectsMult.ValueMax = 2

    ; recycler interface - behavior
    AutoRecyclingMode.ValueDefault = false
    AutoRecyclingMode.McmId = "bAutoRecyclingMode:Behavior"

    EnableJunkFilter.ValueDefault = true
    EnableJunkFilter.McmId = "bEnableJunkFilter:Behavior"

    AutoTransferJunk.ValueDefault = true
    AutoTransferJunk.McmId = "bAutoTransferJunk:Behavior"

    TransferLowWeightRatioItems.ValueDefault = 0
    TransferLowWeightRatioItems.McmId = "iTransferLowWeightRatioItems:Behavior"
    TransferLowWeightRatioItems.ValueMin = 0
    TransferLowWeightRatioItems.ValueMax = 3

    UseAlwaysAutoTransferList.ValueDefault = true
    UseAlwaysAutoTransferList.McmId = "bUseAlwaysAutoTransferList:Behavior"

    UseNeverAutoTransferList.ValueDefault = true
    UseNeverAutoTransferList.McmId = "bUseNeverAutoTransferList:Behavior"

    EnableAutoTransferListEditing.Value = false
    EnableAutoTransferListEditing.McmId = "bEnableAutoTransferListEditing:Behavior"

    EnableBehaviorOverrides.ValueDefault = false
    EnableBehaviorOverrides.McmId = "bEnableBehaviorOverrides:Behavior"

    ReturnItemsSilently.ValueDefault = true
    ReturnItemsSilently.McmId = "bReturnItemsSilently:Behavior"

    ; recycler interface - crafting
    CraftingStation.ValueDefault = 0
    CraftingStation.McmId = "iCraftingStation:Crafting"
    CraftingStation.ValueMin = 0
    CraftingStation.ValueMax = 9

    ; multiplier adjustments - general
    MultAdjustGeneralSettlement.ValueDefault = 0.0
    MultAdjustGeneralSettlement.McmId = "fMultAdjustGeneralSettlement:MultiplierAdjustments"
    MultAdjustGeneralSettlement.ValueMin = adjustMin
    MultAdjustGeneralSettlement.ValueMax = adjustMax

    MultAdjustGeneralSettlementC.ValueDefault = 0.0
    MultAdjustGeneralSettlementC.McmId = "fMultAdjustGeneralSettlementC:MultiplierAdjustments"
    MultAdjustGeneralSettlementC.ValueMin = adjustMin
    MultAdjustGeneralSettlementC.ValueMax = adjustMax

    MultAdjustGeneralSettlementU.ValueDefault = 0.0
    MultAdjustGeneralSettlementU.McmId = "fMultAdjustGeneralSettlementU:MultiplierAdjustments"
    MultAdjustGeneralSettlementU.ValueMin = adjustMin
    MultAdjustGeneralSettlementU.ValueMax = adjustMax

    MultAdjustGeneralSettlementR.ValueDefault = 0.0
    MultAdjustGeneralSettlementR.McmId = "fMultAdjustGeneralSettlementR:MultiplierAdjustments"
    MultAdjustGeneralSettlementR.ValueMin = adjustMin
    MultAdjustGeneralSettlementR.ValueMax = adjustMax

    MultAdjustGeneralSettlementS.ValueDefault = 0.0
    MultAdjustGeneralSettlementS.McmId = "fMultAdjustGeneralSettlementS:MultiplierAdjustments"
    MultAdjustGeneralSettlementS.ValueMin = adjustMin
    MultAdjustGeneralSettlementS.ValueMax = adjustMax

    MultAdjustGeneralNotSettlement.ValueDefault = 0.0
    MultAdjustGeneralNotSettlement.McmId = "fMultAdjustGeneralNotSettlement:MultiplierAdjustments"
    MultAdjustGeneralNotSettlement.ValueMin = adjustMin
    MultAdjustGeneralNotSettlement.ValueMax = adjustMax

    MultAdjustGeneralNotSettlementC.ValueDefault = 0.0
    MultAdjustGeneralNotSettlementC.McmId = "fMultAdjustGeneralNotSettlementC:MultiplierAdjustments"
    MultAdjustGeneralNotSettlementC.ValueMin = adjustMin
    MultAdjustGeneralNotSettlementC.ValueMax = adjustMax

    MultAdjustGeneralNotSettlementU.ValueDefault = 0.0
    MultAdjustGeneralNotSettlementU.McmId = "fMultAdjustGeneralNotSettlementU:MultiplierAdjustments"
    MultAdjustGeneralNotSettlementU.ValueMin = adjustMin
    MultAdjustGeneralNotSettlementU.ValueMax = adjustMax

    MultAdjustGeneralNotSettlementR.ValueDefault = 0.0
    MultAdjustGeneralNotSettlementR.McmId = "fMultAdjustGeneralNotSettlementR:MultiplierAdjustments"
    MultAdjustGeneralNotSettlementR.ValueMin = adjustMin
    MultAdjustGeneralNotSettlementR.ValueMax = adjustMax

    MultAdjustGeneralNotSettlementS.ValueDefault = 0.0
    MultAdjustGeneralNotSettlementS.McmId = "fMultAdjustGeneralNotSettlementS:MultiplierAdjustments"
    MultAdjustGeneralNotSettlementS.ValueMin = adjustMin
    MultAdjustGeneralNotSettlementS.ValueMax = adjustMax

    ; multiplier adjustments - intelligence
    MultAdjustInt.ValueDefault = 0.01
    MultAdjustInt.McmId = "fMultAdjustInt:MultiplierAdjustments"
    MultAdjustInt.ValueMin = statAdjustMin
    MultAdjustInt.ValueMax = statAdjustMax

    MultAdjustIntC.ValueDefault = 0.01
    MultAdjustIntC.McmId = "fMultAdjustIntC:MultiplierAdjustments"
    MultAdjustIntC.ValueMin = statAdjustMin
    MultAdjustIntC.ValueMax = statAdjustMax

    MultAdjustIntU.ValueDefault = 0.01
    MultAdjustIntU.McmId = "fMultAdjustIntU:MultiplierAdjustments"
    MultAdjustIntU.ValueMin = statAdjustMin
    MultAdjustIntU.ValueMax = statAdjustMax

    MultAdjustIntR.ValueDefault = 0.01
    MultAdjustIntR.McmId = "fMultAdjustIntR:MultiplierAdjustments"
    MultAdjustIntR.ValueMin = statAdjustMin
    MultAdjustIntR.ValueMax = statAdjustMax

    MultAdjustIntS.ValueDefault = 0.0
    MultAdjustIntS.McmId = "fMultAdjustIntS:MultiplierAdjustments"
    MultAdjustIntS.ValueMin = statAdjustMin
    MultAdjustIntS.ValueMax = statAdjustMax

    ; multiplier adjustments - luck
    MultAdjustLck.ValueDefault = 0.01
    MultAdjustLck.McmId = "fMultAdjustLck:MultiplierAdjustments"
    MultAdjustLck.ValueMin = statAdjustMin
    MultAdjustLck.ValueMax = statAdjustMax

    MultAdjustLckC.ValueDefault = 0.01
    MultAdjustLckC.McmId = "fMultAdjustLckC:MultiplierAdjustments"
    MultAdjustLckC.ValueMin = statAdjustMin
    MultAdjustLckC.ValueMax = statAdjustMax

    MultAdjustLckU.ValueDefault = 0.01
    MultAdjustLckU.McmId = "fMultAdjustLckU:MultiplierAdjustments"
    MultAdjustLckU.ValueMin = statAdjustMin
    MultAdjustLckU.ValueMax = statAdjustMax

    MultAdjustLckR.ValueDefault = 0.01
    MultAdjustLckR.McmId = "fMultAdjustLckR:MultiplierAdjustments"
    MultAdjustLckR.ValueMin = statAdjustMin
    MultAdjustLckR.ValueMax = statAdjustMax

    MultAdjustLckS.ValueDefault = 0.0
    MultAdjustLckS.McmId = "fMultAdjustLckS:MultiplierAdjustments"
    MultAdjustLckS.ValueMin = statAdjustMin
    MultAdjustLckS.ValueMax = statAdjustMax

    ; multiplier adjustments - randomness
    MultAdjustRandomMin.ValueDefault = -0.1
    MultAdjustRandomMin.McmId = "fMultAdjustRandomMin:MultiplierAdjustments"
    MultAdjustRandomMin.ValueMin = randomAdjustMin
    MultAdjustRandomMin.ValueMax = randomAdjustMax

    MultAdjustRandomMinC.ValueDefault = -0.1
    MultAdjustRandomMinC.McmId = "fMultAdjustRandomMinC:MultiplierAdjustments"
    MultAdjustRandomMinC.ValueMin = randomAdjustMin
    MultAdjustRandomMinC.ValueMax = randomAdjustMax

    MultAdjustRandomMinU.ValueDefault = -0.1
    MultAdjustRandomMinU.McmId = "fMultAdjustRandomMinU:MultiplierAdjustments"
    MultAdjustRandomMinU.ValueMin = randomAdjustMin
    MultAdjustRandomMinU.ValueMax = randomAdjustMax

    MultAdjustRandomMinR.ValueDefault = -0.1
    MultAdjustRandomMinR.McmId = "fMultAdjustRandomMinR:MultiplierAdjustments"
    MultAdjustRandomMinR.ValueMin = randomAdjustMin
    MultAdjustRandomMinR.ValueMax = randomAdjustMax

    MultAdjustRandomMinS.ValueDefault = 0.0
    MultAdjustRandomMinS.McmId = "fMultAdjustRandomMinS:MultiplierAdjustments"
    MultAdjustRandomMinS.ValueMin = randomAdjustMin
    MultAdjustRandomMinS.ValueMax = randomAdjustMax

    MultAdjustRandomMax.ValueDefault = 0.1
    MultAdjustRandomMax.McmId = "fMultAdjustRandomMax:MultiplierAdjustments"
    MultAdjustRandomMax.ValueMin = randomAdjustMin
    MultAdjustRandomMax.ValueMax = randomAdjustMax

    MultAdjustRandomMaxC.ValueDefault = 0.1
    MultAdjustRandomMaxC.McmId = "fMultAdjustRandomMaxC:MultiplierAdjustments"
    MultAdjustRandomMaxC.ValueMin = randomAdjustMin
    MultAdjustRandomMaxC.ValueMax = randomAdjustMax

    MultAdjustRandomMaxU.ValueDefault = 0.1
    MultAdjustRandomMaxU.McmId = "fMultAdjustRandomMaxU:MultiplierAdjustments"
    MultAdjustRandomMaxU.ValueMin = randomAdjustMin
    MultAdjustRandomMaxU.ValueMax = randomAdjustMax

    MultAdjustRandomMaxR.ValueDefault = 0.1
    MultAdjustRandomMaxR.McmId = "fMultAdjustRandomMaxR:MultiplierAdjustments"
    MultAdjustRandomMaxR.ValueMin = randomAdjustMin
    MultAdjustRandomMaxR.ValueMax = randomAdjustMax

    MultAdjustRandomMaxS.ValueDefault = 0.0
    MultAdjustRandomMaxS.McmId = "fMultAdjustRandomMaxS:MultiplierAdjustments"
    MultAdjustRandomMaxS.ValueMin = randomAdjustMin
    MultAdjustRandomMaxS.ValueMax = randomAdjustMax

    ; multiplier adjustments - scrapper 1-5
    float[] scrapperSettlementDefaults = new float[ScrapperPerkMaxRanksSupported]
    scrapperSettlementDefaults[0] = 0.1
    scrapperSettlementDefaults[1] = 0.2
    scrapperSettlementDefaults[2] = 0.3
    scrapperSettlementDefaults[3] = 0.4
    scrapperSettlementDefaults[4] = 0.5

    int index = 0
    While index < ScrapperPerkMaxRanksSupported
        MultAdjustScrapperSettlement[index].ValueDefault = scrapperSettlementDefaults[index]
        MultAdjustScrapperSettlement[index].McmId = "fMultAdjustScrapperSettlement" + (index+1) + ":MultiplierAdjustments"
        MultAdjustScrapperSettlement[index].ValueMin = adjustMin
        MultAdjustScrapperSettlement[index].ValueMax = adjustMax

        MultAdjustScrapperSettlementC[index].ValueDefault = scrapperSettlementDefaults[index]
        MultAdjustScrapperSettlementC[index].McmId = "fMultAdjustScrapperSettlementC" + (index+1) + ":MultiplierAdjustments"
        MultAdjustScrapperSettlementC[index].ValueMin = adjustMin
        MultAdjustScrapperSettlementC[index].ValueMax = adjustMax

        MultAdjustScrapperSettlementU[index].ValueDefault = scrapperSettlementDefaults[index]
        MultAdjustScrapperSettlementU[index].McmId = "fMultAdjustScrapperSettlementU" + (index+1) + ":MultiplierAdjustments"
        MultAdjustScrapperSettlementU[index].ValueMin = adjustMin
        MultAdjustScrapperSettlementU[index].ValueMax = adjustMax

        MultAdjustScrapperSettlementR[index].ValueDefault = scrapperSettlementDefaults[index]
        MultAdjustScrapperSettlementR[index].McmId = "fMultAdjustScrapperSettlementR" + (index+1) + ":MultiplierAdjustments"
        MultAdjustScrapperSettlementR[index].ValueMin = adjustMin
        MultAdjustScrapperSettlementR[index].ValueMax = adjustMax

        MultAdjustScrapperSettlementS[index].ValueDefault = 0.0
        MultAdjustScrapperSettlementS[index].McmId = "fMultAdjustScrapperSettlementS" + (index+1) + ":MultiplierAdjustments"
        MultAdjustScrapperSettlementS[index].ValueMin = adjustMin
        MultAdjustScrapperSettlementS[index].ValueMax = adjustMax

        MultAdjustScrapperNotSettlement[index].ValueDefault = 0.0
        MultAdjustScrapperNotSettlement[index].McmId = "fMultAdjustScrapperNotSettlement" + (index+1) + ":MultiplierAdjustments"
        MultAdjustScrapperNotSettlement[index].ValueMin = adjustMin
        MultAdjustScrapperNotSettlement[index].ValueMax = adjustMax

        MultAdjustScrapperNotSettlementC[index].ValueDefault = 0.0
        MultAdjustScrapperNotSettlementC[index].McmId = "fMultAdjustScrapperNotSettlementC" + (index+1) + ":MultiplierAdjustments"
        MultAdjustScrapperNotSettlementC[index].ValueMin = adjustMin
        MultAdjustScrapperNotSettlementC[index].ValueMax = adjustMax

        MultAdjustScrapperNotSettlementU[index].ValueDefault = 0.0
        MultAdjustScrapperNotSettlementU[index].McmId = "fMultAdjustScrapperNotSettlementU" + (index+1) + ":MultiplierAdjustments"
        MultAdjustScrapperNotSettlementU[index].ValueMin = adjustMin
        MultAdjustScrapperNotSettlementU[index].ValueMax = adjustMax

        MultAdjustScrapperNotSettlementR[index].ValueDefault = 0.0
        MultAdjustScrapperNotSettlementR[index].McmId = "fMultAdjustScrapperNotSettlementR" + (index+1) + ":MultiplierAdjustments"
        MultAdjustScrapperNotSettlementR[index].ValueMin = adjustMin
        MultAdjustScrapperNotSettlementR[index].ValueMax = adjustMax

        MultAdjustScrapperNotSettlementS[index].ValueDefault = 0.0
        MultAdjustScrapperNotSettlementS[index].McmId = "fMultAdjustScrapperNotSettlementS" + (index+1) + ":MultiplierAdjustments"
        MultAdjustScrapperNotSettlementS[index].ValueMin = adjustMin
        MultAdjustScrapperNotSettlementS[index].ValueMax = adjustMax

        index += 1
    EndWhile

    ; advanced - multithreading
    ThreadLimit.ValueDefault = ThreadManager.NumberOfWorkerThreads
    ThreadLimit.McmId = "iThreadLimit:Advanced"
    ThreadLimit.ValueMin = 1
    ThreadLimit.ValueMax = ThreadManager.NumberOfWorkerThreads

    ; advanced - methodology
    UseDirectMoveRecyclableItemListUpdate.ValueDefault = false
    UseDirectMoveRecyclableItemListUpdate.McmId = "bUseDirectMoveRecyclableItemListUpdate:Advanced"
EndFunction

; reset values of properties that hold settings to their defaults
Function InitSettingsDefaultValues()
    Self._DebugTrace("Initializing settings (default values)")

    ; change thread limit first
    ChangeSetting(ThreadLimit, CurrentChangeType, ThreadLimit.ValueDefault, ModName)
    ThreadManager.SetThreadLimit(ThreadLimit.Value)

    ; add all the settings to an array to pass to the ThreadManager
    var[] settingsToChange = Self.CollectMCMSettings()

    ; set things to defaults
    ThreadManager.ChangeSettingsToDefaults(settingsToChange, CurrentChangeType, ModName)

    ; perform general post-processing
    Self.PerformMCMSettingPostProcessing()
    Self.SetCraftingStation()
EndFunction

; initialize FormList wrappers
Function InitFormListWrappers()
    Self._DebugTrace("Initializing FormList wrappers")

    ComponentListC.Size = ComponentListC.List.GetSize()
    Self._DebugTrace("ComponentListC size = " + ComponentListC.Size)
    ComponentListU.Size = ComponentListU.List.GetSize()
    Self._DebugTrace("ComponentListU size = " + ComponentListU.Size)
    ComponentListR.Size = ComponentListR.List.GetSize()
    Self._DebugTrace("ComponentListR size = " + ComponentListR.Size)
    ComponentListS.Size = ComponentListS.List.GetSize()
    Self._DebugTrace("ComponentListS size = " + ComponentListS.Size)

    ScrapListC.Size = ScrapListC.List.GetSize()
    Self._DebugTrace("ScrapListC size = " + ScrapListC.Size)
    ScrapListU.Size = ScrapListU.List.GetSize()
    Self._DebugTrace("ScrapListU size = " + ScrapListU.Size)
    ScrapListR.Size = ScrapListR.List.GetSize()
    Self._DebugTrace("ScrapListR size = " + ScrapListR.Size)
    ScrapListS.Size = ScrapListS.List.GetSize()
    Self._DebugTrace("ScrapListS size = " + ScrapListS.Size)
EndFunction

; initialize component mapping
Function InitComponentMappings()
    Self._DebugTrace("Initializing component map")

    ; build the component maps with multithreading
    ComponentMap[] componentMapC = ThreadManager.BuildComponentMap(ComponentListC, ScrapListC)
    ComponentMap[] componentMapU = ThreadManager.BuildComponentMap(ComponentListU, ScrapListU)
    ComponentMap[] componentMapR = ThreadManager.BuildComponentMap(ComponentListR, ScrapListR)
    ComponentMap[] componentMapS = ThreadManager.BuildComponentMap(ComponentListS, ScrapListS)

    ; combine the component maps
    ComponentMappings = new ComponentMap[componentMapC.Length + componentMapU.Length + componentMapR.Length + componentMapS.Length]
    ComponentMap tempCMap
    int mapIndex = 0
    int index = 0
    While index < componentMapC.Length
        ComponentMappings[mapIndex] = componentMapC[index]
        mapIndex += 1
        index += 1
    EndWhile
    index = 0
    While index < componentMapU.Length
        ComponentMappings[mapIndex] = componentMapU[index]
        ComponentMappings[mapIndex].Rarity = 1
        mapIndex += 1
        index += 1
    EndWhile
    index = 0
    While index < componentMapR.Length
        ComponentMappings[mapIndex] = componentMapR[index]
        ComponentMappings[mapIndex].Rarity = 2
        mapIndex += 1
        index += 1
    EndWhile
    index = 0
    While index < componentMapS.Length
        ComponentMappings[mapIndex] = componentMapS[index]
        ComponentMappings[mapIndex].Rarity = 3
        mapIndex += 1
        index += 1
    EndWhile

    Self._DebugTrace("ComponentMappings size = " + ComponentMappings.Length)
EndFunction

; initialize the FormList containing all scrap parts
Function InitScrapListAll()
    Self._DebugTrace("Initializing ScrapListAll FormList")

    ; create array to send to multithread system
    MiscObject[] scrapParts = new MiscObject[ComponentMappings.Length]
    int index = 0
    While index < scrapParts.Length
        scrapParts[index] = ComponentMappings[index].ScrapPart
        index += 1
    EndWhile

    ; revert FormList and repopulate it
    ScrapListAll.List.Revert()
    ThreadManager.AddItemsToList(scrapParts as Form[], ScrapListAll)
EndFunction

; initialize the array containing the scrapper perks
Function InitScrapperPerks()
    Self._DebugTrace("Initializing scrapper perks list")

    ; create an array of the scrapper perks
    ScrapperPerks = new Perk[0]

    ; seed array with initial scrapper perk
    ScrapperPerks.Add(Game.GetFormFromFile(0x065E65, "Fallout4.esm") as Perk) ; scrapper rank 1

    ; load perks dynamically, but ignore any perk ranks > the number supported
    int numScrapperRanks = ScrapperPerks[0].GetNumRanks()
    While ScrapperPerks.Length < numScrapperRanks && ScrapperPerks.Length < ScrapperPerkMaxRanksSupported
        ScrapperPerks.Add(ScrapperPerks[ScrapperPerks.Length - 1].GetNextPerk())
    EndWhile

    MCM_Scrapper3Available = ScrapperPerks.Length >= 3
    MCM_Scrapper4Available = ScrapperPerks.Length >= 4
    MCM_Scrapper5Available = ScrapperPerks.Length >= 5

    Self._DebugTrace(ScrapperPerks.Length + " perks loaded:")
    int index = 0
    While index < ScrapperPerks.Length
        Self._DebugTrace(ScrapperPerks[index])
        index += 1
    EndWhile
EndFunction

; load MCM settings
Function LoadAllSettingsFromMCM()
    If ModConfigMenuInstalled
        Self._DebugTrace("Loading settings from MCM")

        ; add all the settings to an array to pass to the ThreadManager
        var[] settingsToLoad = Self.CollectMCMSettings()

        ; load all the settings, multithread to cut down on time
        ThreadManager.LoadMCMSettings(settingsToLoad, ModName)

        ; perform general post-processing
        Self.PerformMCMSettingPostProcessing()
        Self.SetCraftingStation()
        Self.MultAdjustRandomSanityCheck()
    Else
        Self._DebugTrace("Loading settings from MCM; skipping (MCM not enabled)")
    EndIf
EndFunction

; returns an array containing all the MCM settings
var[] Function CollectMCMSettings()
    Self._DebugTrace("Collecting MCM settings")

    var[] toReturn = new var[0]

    ; settings - general
    toReturn.Add(MultBase)
    toReturn.Add(ReturnAtLeastOneComponent)
    toReturn.Add(FractionalComponentHandling)
    toReturn.Add(HasLimitedUses)
    toReturn.Add(NumberOfUses)

    ; settings - adjustment options
    toReturn.Add(GeneralMultAdjust)
    toReturn.Add(IntAffectsMult)
    toReturn.Add(LckAffectsMult)
    toReturn.Add(RngAffectsMult)
    toReturn.Add(ScrapperAffectsMult)

    ; recycler interface - behavior
    toReturn.Add(AutoRecyclingMode)
    toReturn.Add(EnableJunkFilter)
    toReturn.Add(AutoTransferJunk)
    toReturn.Add(TransferLowWeightRatioItems)
    toReturn.Add(UseAlwaysAutoTransferList)
    toReturn.Add(UseNeverAutoTransferList)
    toReturn.Add(EnableAutoTransferListEditing)
    toReturn.Add(EnableBehaviorOverrides)
    toReturn.Add(ReturnItemsSilently)

    ; recycler interface - crafting
    toReturn.Add(CraftingStation)

    ; multiplier adjustments - general
    toReturn.Add(MultAdjustGeneralSettlement)
    toReturn.Add(MultAdjustGeneralSettlementC)
    toReturn.Add(MultAdjustGeneralSettlementU)
    toReturn.Add(MultAdjustGeneralSettlementR)
    toReturn.Add(MultAdjustGeneralSettlementS)

    toReturn.Add(MultAdjustGeneralNotSettlement)
    toReturn.Add(MultAdjustGeneralNotSettlementC)
    toReturn.Add(MultAdjustGeneralNotSettlementU)
    toReturn.Add(MultAdjustGeneralNotSettlementR)
    toReturn.Add(MultAdjustGeneralNotSettlementS)

    ; multiplier adjustments - intelligence
    toReturn.Add(MultAdjustInt)
    toReturn.Add(MultAdjustIntC)
    toReturn.Add(MultAdjustIntU)
    toReturn.Add(MultAdjustIntR)
    toReturn.Add(MultAdjustIntS)

    ; multiplier adjustments - luck
    toReturn.Add(MultAdjustLck)
    toReturn.Add(MultAdjustLckC)
    toReturn.Add(MultAdjustLckU)
    toReturn.Add(MultAdjustLckR)
    toReturn.Add(MultAdjustLckS)

    ; multiplier adjustments - randomness
    toReturn.Add(MultAdjustRandomMin)
    toReturn.Add(MultAdjustRandomMinC)
    toReturn.Add(MultAdjustRandomMinU)
    toReturn.Add(MultAdjustRandomMinR)
    toReturn.Add(MultAdjustRandomMinS)

    toReturn.Add(MultAdjustRandomMax)
    toReturn.Add(MultAdjustRandomMaxC)
    toReturn.Add(MultAdjustRandomMaxU)
    toReturn.Add(MultAdjustRandomMaxR)
    toReturn.Add(MultAdjustRandomMaxS)

    ; multiplier adjustments - scrapper 1-5
    int index = 0
    While index < ScrapperPerkMaxRanksSupported
        toReturn.Add(MultAdjustScrapperSettlement[index])
        toReturn.Add(MultAdjustScrapperSettlementC[index])
        toReturn.Add(MultAdjustScrapperSettlementU[index])
        toReturn.Add(MultAdjustScrapperSettlementR[index])
        toReturn.Add(MultAdjustScrapperSettlementS[index])

        toReturn.Add(MultAdjustScrapperNotSettlement[index])
        toReturn.Add(MultAdjustScrapperNotSettlementC[index])
        toReturn.Add(MultAdjustScrapperNotSettlementU[index])
        toReturn.Add(MultAdjustScrapperNotSettlementR[index])
        toReturn.Add(MultAdjustScrapperNotSettlementS[index])

        index += 1
    EndWhile

    ; advanced - methodology
    toReturn.Add(UseDirectMoveRecyclableItemListUpdate)

    Return toReturn
EndFunction

; do common post-processing tasks when an MCM setting is changed
Function PerformMCMSettingPostProcessing()
    ; set variables that control what the MCM shows
    MCM_GeneralMultAdjustSimple = GeneralMultAdjust.Value == 0
    MCM_GeneralMultAdjustDetailed = GeneralMultAdjust.Value > 0
    MCM_IntAffectsMultSimple = IntAffectsMult.Value == 1
    MCM_IntAffectsMultDetailed = IntAffectsMult.Value > 1
    MCM_LckAffectsMultSimple = LckAffectsMult.Value == 1
    MCM_LckAffectsMultDetailed = LckAffectsMult.Value > 1
    MCM_RngAffectsMultSimple = RngAffectsMult.Value == 1
    MCM_RngAffectsMultDetailed = RngAffectsMult.Value > 1
    MCM_ScrapperAffectsMultSimple = ScrapperAffectsMult.Value == 1
    MCM_ScrapperAffectsMultDetailed = ScrapperAffectsMult.Value > 1
EndFunction

; determine where the crafting recipe lives
Function SetCraftingStation()
    string pluginNameSW = "StandaloneWorkbenches.esp" const
    string pluginNameECO = "ECO.esp" const
    string pluginNameAWKCR = "ArmorKeywords.esm" const
    bool isSWInstalled = Game.IsPluginInstalled(pluginNameSW)
    bool isECOInstalled = Game.IsPluginInstalled(pluginNameECO)
    bool isAWKCRInstalled = Game.IsPluginInstalled(pluginNameAWKCR)

    ; handle 'dynamic' workbenches first
    If (CraftingStation.Value == 5 || CraftingStation.Value == 0) && isSWInstalled
        ; Standalone Workbenches - Utility Workbench (Keyword FExxx81C - wSW_UtilityWorkbench_CraftingKey)
        Self._DebugTrace("Crafting station: Standalone Workbenches - Utility Workbench")
        PortableJunkRecyclerConstructibleObject.SetWorkbenchKeyword(Game.GetFormFromFile(0x81C, pluginNameSW) as Keyword)
    ElseIf (CraftingStation.Value == 9 || CraftingStation.Value == 0) && isECOInstalled
        ; Equipment and Crafting Overhaul - Utility Station (Keyword xx02788D - Dank_Workbench_TypeUtility)
        Self._DebugTrace("Crafting station: Equipment and Crafting Overhaul - Utility Station")
        PortableJunkRecyclerConstructibleObject.SetWorkbenchKeyword(Game.GetFormFromFile(0x02788D, pluginNameECO) as Keyword)
    ElseIf (CraftingStation.Value == 8 || CraftingStation.Value == 0) && isAWKCRInstalled
        ; AWKCR - Utility Workbench (Keyword xx001765 - AEC_ck_UtilityCraftingKey)
        Self._DebugTrace("Crafting station: AWKCR - Utility Workbench")
        PortableJunkRecyclerConstructibleObject.SetWorkbenchKeyword(Game.GetFormFromFile(0x001765, pluginNameAWKCR) as Keyword)

    ; handle other manual workbench choices
    ElseIf CraftingStation.Value == 2 && isSWInstalled
        ; Standalone Workbenches - Electronics Workbench (Keyword FExxx80D - wSW_ElectronicsWorkbench_CraftingKey)
        Self._DebugTrace("Crafting station: Standalone Workbenches - Electronics Workbench")
        PortableJunkRecyclerConstructibleObject.SetWorkbenchKeyword(Game.GetFormFromFile(0x80D, pluginNameSW) as Keyword)
    ElseIf CraftingStation.Value == 3 && isSWInstalled
        ; Standalone Workbenches - Engineering Workbench (Keyword FExxx810 - wSW_EngineeringWorkbench_CraftingKey)
        Self._DebugTrace("Crafting station: Standalone Workbenches - Engineering Workbench")
        PortableJunkRecyclerConstructibleObject.SetWorkbenchKeyword(Game.GetFormFromFile(0x810, pluginNameSW) as Keyword)
    ElseIf CraftingStation.Value == 4 && isSWInstalled
        ; Standalone Workbenches - Manufacturing Workbench (Keyword FExxx822 - wSW_ManufacturingWorkbench_CraftingKey)
        Self._DebugTrace("Crafting station: Standalone Workbenches - Manufacturing Workbench")
        PortableJunkRecyclerConstructibleObject.SetWorkbenchKeyword(Game.GetFormFromFile(0x822, pluginNameSW) as Keyword)
    ElseIf CraftingStation.Value == 6 && isAWKCRInstalled
        ; AWKCR - Advanced Engineering Workbench (Keyword xx00195A - AEC_ck_AdvancedEngineeringCraftingKey)
        Self._DebugTrace("Crafting station: AWKCR - Advanced Engineering Workbench")
        PortableJunkRecyclerConstructibleObject.SetWorkbenchKeyword(Game.GetFormFromFile(0x00195A, pluginNameAWKCR) as Keyword)
    ElseIf CraftingStation.Value == 7 && isAWKCRInstalled
        ; AWKCR - Electronics Workstation (Keyword xx001764 - AEC_ck_ElectronicsCraftingKey)
        Self._DebugTrace("Crafting station: AWKCR - Electronics Workstation")
        PortableJunkRecyclerConstructibleObject.SetWorkbenchKeyword(Game.GetFormFromFile(0x001764, pluginNameAWKCR) as Keyword)

    ; handle everything else, like missing mods, etc
    Else ; CraftingStation.Value == 1
        ; Vanilla - Chemistry Station (Keyword xx102158 - WorkbenchChemlab)
        If CraftingStation.Value >= 2 && CraftingStation.Value <= 5
            Self._DebugTrace("Crafting station: Standalone Workbenches workbench specified but mod not detected; falling back to vanilla")
        ElseIF CraftingStation.Value >= 6 && CraftingStation.Value <= 8
            Self._DebugTrace("Crafting station: AWKCR workbench specified but mod not detected; falling back to vanilla")
        ElseIf CraftingStation.Value == 9
            Self._DebugTrace("Crafting station: ECO workbench specified but mod not detected; falling back to vanilla")
        Else
            Self._DebugTrace("Crafting station: Vanilla - Chemistry Station")
        EndIf
        PortableJunkRecyclerConstructibleObject.SetWorkbenchKeyword(Game.GetFormFromFile(0x102158, "Fallout4.esm") as Keyword)
    EndIf
EndFunction

; register this script for MCM events
Function RegisterForMCMEvents()
    Self._DebugTrace("Attempting to register for MCM events")
    If ModConfigMenuInstalled
        Self._DebugTrace("MCM installed; registering for MCM events")
        string eventName = "OnMCMSettingChange|" + ModName
        string callback = "OnMCMSettingChange"
        RegisterForExternalEvent(eventName, callback)
        Self._DebugTrace("Registered for MCM event '" + eventName + "' with a callback of '" + callback + "'")
        eventName = "OnMCMMenuClose|" + ModName
        callback = "OnMCMMenuClose"
        RegisterForExternalEvent(eventName, callback)
        Self._DebugTrace("Registered for MCM event '" + eventName + "' with a callback of '" + callback + "'")
    Else
        Self._DebugTrace("MCM not installed; skipping", 1)
    EndIf
EndFunction

; callback function for when MCM changes settings
Function OnMCMSettingChange(string asModName, string asControlId)
    If asModName == ModName
        bool doMenuRefresh
        int defaultValue = 2147483647 ; use 32-bit signed integer maximum to serve as a default value
        var oldValue = defaultValue
        var newValue

        ; settings - general
        If asControlId == MultBase.McmId
            oldValue = MultBase.Value
            LoadSettingFromMCM(MultBase, ModName)
            newValue = MultBase.Value
        ElseIf asControlId == ReturnAtLeastOneComponent.McmId
            oldValue = ReturnAtLeastOneComponent.Value
            LoadSettingFromMCM(ReturnAtLeastOneComponent, ModName)
            newValue = ReturnAtLeastOneComponent.Value
        ElseIf asControlId == FractionalComponentHandling.McmId
            oldValue = FractionalComponentHandling.Value
            LoadSettingFromMCM(FractionalComponentHandling, ModName)
            newValue = FractionalComponentHandling.Value
        ElseIf asControlId == HasLimitedUses.McmId
            oldValue = HasLimitedUses.Value
            LoadSettingFromMCM(HasLimitedUses, ModName)
            newValue = HasLimitedUses.Value
        ElseIf asControlId == NumberOfUses.McmId
            oldValue = NumberOfUses.Value
            LoadSettingFromMCM(NumberOfUses, ModName)
            newValue = NumberOfUses.Value

        ; settings - adjustment options
        ElseIf asControlId == GeneralMultAdjust.McmId
            oldValue = GeneralMultAdjust.Value
            LoadSettingFromMCM(GeneralMultAdjust, ModName)
            newValue = GeneralMultAdjust.Value
            doMenuRefresh = true
        ElseIf asControlId == IntAffectsMult.McmId
            oldValue = IntAffectsMult.Value
            LoadSettingFromMCM(IntAffectsMult, ModName)
            newValue = IntAffectsMult.Value
            doMenuRefresh = true
        ElseIf asControlId == LckAffectsMult.McmId
            oldValue = LckAffectsMult.Value
            LoadSettingFromMCM(LckAffectsMult, ModName)
            newValue = LckAffectsMult.Value
            doMenuRefresh = true
        ElseIf asControlId == RngAffectsMult.McmId
            oldValue = RngAffectsMult.Value
            LoadSettingFromMCM(RngAffectsMult, ModName)
            newValue = RngAffectsMult.Value
            doMenuRefresh = true
        ElseIf asControlId == ScrapperAffectsMult.McmId
            oldValue = ScrapperAffectsMult.Value
            LoadSettingFromMCM(ScrapperAffectsMult, ModName)
            newValue = ScrapperAffectsMult.Value
            doMenuRefresh = true

        ; recycler interface - behavior
        ElseIf asControlId == AutoRecyclingMode.McmId
            oldValue = AutoRecyclingMode.Value
            LoadSettingFromMCM(AutoRecyclingMode, ModName)
            newValue = AutoRecyclingMode.Value
        ElseIf asControlId == EnableJunkFilter.McmId
            oldValue = EnableJunkFilter.Value
            LoadSettingFromMCM(EnableJunkFilter, ModName)
            newValue = EnableJunkFilter.Value
        ElseIf asControlId == AutoTransferJunk.McmId
            oldValue = AutoTransferJunk.Value
            LoadSettingFromMCM(AutoTransferJunk, ModName)
            newValue = AutoTransferJunk.Value
        ElseIf asControlId == TransferLowWeightRatioItems.McmId
            oldValue = TransferLowWeightRatioItems.Value
            LoadSettingFromMCM(TransferLowWeightRatioItems, ModName)
            newValue = TransferLowWeightRatioItems.Value
        ElseIf asControlId == UseAlwaysAutoTransferList.McmId
            oldValue = UseAlwaysAutoTransferList.Value
            LoadSettingFromMCM(UseAlwaysAutoTransferList, ModName)
            newValue = UseAlwaysAutoTransferList.Value
        ElseIf asControlId == UseNeverAutoTransferList.McmId
            oldValue = UseNeverAutoTransferList.Value
            LoadSettingFromMCM(UseNeverAutoTransferList, ModName)
            newValue = UseNeverAutoTransferList.Value
        ElseIf asControlId == EnableAutoTransferListEditing.McmId
            oldValue = EnableAutoTransferListEditing.Value
            LoadSettingFromMCM(EnableAutoTransferListEditing, ModName)
            newValue = EnableAutoTransferListEditing.Value
        ElseIf asControlId == EnableBehaviorOverrides.McmId
            oldValue = EnableBehaviorOverrides.Value
            LoadSettingFromMCM(EnableBehaviorOverrides, ModName)
            newValue = EnableBehaviorOverrides.Value
        ElseIf asControlId == ReturnItemsSilently.McmId
            oldValue = ReturnItemsSilently.Value
            LoadSettingFromMCM(ReturnItemsSilently, ModName)
            newValue = ReturnItemsSilently.Value

        ; recycler interface - crafting
        ElseIf asControlId == CraftingStation.McmId
            oldValue = CraftingStation.Value
            LoadSettingFromMCM(CraftingStation, ModName)
            newValue = CraftingStation.Value
            Self.SetCraftingStation()

        ; multiplier adjustments - general
        ElseIf asControlId == MultAdjustGeneralSettlement.McmId
            oldValue = MultAdjustGeneralSettlement.Value
            LoadSettingFromMCM(MultAdjustGeneralSettlement, ModName)
            newValue = MultAdjustGeneralSettlement.Value
        ElseIf asControlId == MultAdjustGeneralSettlementC.McmId
            oldValue = MultAdjustGeneralSettlementC.Value
            LoadSettingFromMCM(MultAdjustGeneralSettlementC, ModName)
            newValue = MultAdjustGeneralSettlementC.Value
        ElseIf asControlId == MultAdjustGeneralSettlementU.McmId
            oldValue = MultAdjustGeneralSettlementU.Value
            LoadSettingFromMCM(MultAdjustGeneralSettlementU, ModName)
            newValue = MultAdjustGeneralSettlementU.Value
        ElseIf asControlId == MultAdjustGeneralSettlementR.McmId
            oldValue = MultAdjustGeneralSettlementR.Value
            LoadSettingFromMCM(MultAdjustGeneralSettlementR, ModName)
            newValue = MultAdjustGeneralSettlementR.Value
        ElseIf asControlId == MultAdjustGeneralSettlementS.McmId
            oldValue = MultAdjustGeneralSettlementS.Value
            LoadSettingFromMCM(MultAdjustGeneralSettlementS, ModName)
            newValue = MultAdjustGeneralSettlementS.Value

        ElseIf asControlId == MultAdjustGeneralNotSettlement.McmId
            oldValue = MultAdjustGeneralNotSettlement.Value
            LoadSettingFromMCM(MultAdjustGeneralNotSettlement, ModName)
            newValue = MultAdjustGeneralNotSettlement.Value
        ElseIf asControlId == MultAdjustGeneralNotSettlementC.McmId
            oldValue = MultAdjustGeneralNotSettlementC.Value
            LoadSettingFromMCM(MultAdjustGeneralNotSettlementC, ModName)
            newValue = MultAdjustGeneralNotSettlementC.Value
        ElseIf asControlId == MultAdjustGeneralNotSettlementU.McmId
            oldValue = MultAdjustGeneralNotSettlementU.Value
            LoadSettingFromMCM(MultAdjustGeneralNotSettlementU, ModName)
            newValue = MultAdjustGeneralNotSettlementU.Value
        ElseIf asControlId == MultAdjustGeneralNotSettlementR.McmId
            oldValue = MultAdjustGeneralNotSettlementR.Value
            LoadSettingFromMCM(MultAdjustGeneralNotSettlementR, ModName)
            newValue = MultAdjustGeneralNotSettlementR.Value
        ElseIf asControlId == MultAdjustGeneralNotSettlementS.McmId
            oldValue = MultAdjustGeneralNotSettlementS.Value
            LoadSettingFromMCM(MultAdjustGeneralNotSettlementS, ModName)
            newValue = MultAdjustGeneralNotSettlementS.Value

        ; multiplier adjustments - intelligence
        ElseIf asControlId == MultAdjustInt.McmId
            oldValue = MultAdjustInt.Value
            LoadSettingFromMCM(MultAdjustInt, ModName)
            newValue = MultAdjustInt.Value
        ElseIf asControlId == MultAdjustIntC.McmId
            oldValue = MultAdjustIntC.Value
            LoadSettingFromMCM(MultAdjustIntC, ModName)
            newValue = MultAdjustIntC.Value
        ElseIf asControlId == MultAdjustIntU.McmId
            oldValue = MultAdjustIntU.Value
            LoadSettingFromMCM(MultAdjustIntU, ModName)
            newValue = MultAdjustIntU.Value
        ElseIf asControlId == MultAdjustIntR.McmId
            oldValue = MultAdjustIntR.Value
            LoadSettingFromMCM(MultAdjustIntR, ModName)
            newValue = MultAdjustIntR.Value
        ElseIf asControlId == MultAdjustIntS.McmId
            oldValue = MultAdjustIntS.Value
            LoadSettingFromMCM(MultAdjustIntS, ModName)
            newValue = MultAdjustIntS.Value

        ; multiplier adjustments - luck
        ElseIf asControlId == MultAdjustLck.McmId
            oldValue = MultAdjustLck.Value
            LoadSettingFromMCM(MultAdjustLck, ModName)
            newValue = MultAdjustLck.Value
        ElseIf asControlId == MultAdjustLckC.McmId
            oldValue = MultAdjustLckC.Value
            LoadSettingFromMCM(MultAdjustLckC, ModName)
            newValue = MultAdjustLckC.Value
        ElseIf asControlId == MultAdjustLckU.McmId
            oldValue = MultAdjustLckU.Value
            LoadSettingFromMCM(MultAdjustLckU, ModName)
            newValue = MultAdjustLckU.Value
        ElseIf asControlId == MultAdjustLckR.McmId
            oldValue = MultAdjustLckR.Value
            LoadSettingFromMCM(MultAdjustLckR, ModName)
            newValue = MultAdjustLckR.Value
        ElseIf asControlId == MultAdjustLckS.McmId
            oldValue = MultAdjustLckS.Value
            LoadSettingFromMCM(MultAdjustLckS, ModName)
            newValue = MultAdjustLckS.Value

        ; multiplier adjustments - randomness
        ElseIf asControlId == MultAdjustRandomMin.McmId
            oldValue = MultAdjustRandomMin.Value
            LoadSettingFromMCM(MultAdjustRandomMin, ModName)
            newValue = MultAdjustRandomMin.Value
        ElseIf asControlId == MultAdjustRandomMinC.McmId
            oldValue = MultAdjustRandomMinC.Value
            LoadSettingFromMCM(MultAdjustRandomMinC, ModName)
            newValue = MultAdjustRandomMinC.Value
        ElseIf asControlId == MultAdjustRandomMinU.McmId
            oldValue = MultAdjustRandomMinU.Value
            LoadSettingFromMCM(MultAdjustRandomMinU, ModName)
            newValue = MultAdjustRandomMinU.Value
        ElseIf asControlId == MultAdjustRandomMinR.McmId
            oldValue = MultAdjustRandomMinR.Value
            LoadSettingFromMCM(MultAdjustRandomMinR, ModName)
            newValue = MultAdjustRandomMinR.Value
        ElseIf asControlId == MultAdjustRandomMinS.McmId
            oldValue = MultAdjustRandomMinS.Value
            LoadSettingFromMCM(MultAdjustRandomMinS, ModName)
            newValue = MultAdjustRandomMinS.Value

        ElseIf asControlId == MultAdjustRandomMax.McmId
            oldValue = MultAdjustRandomMax.Value
            LoadSettingFromMCM(MultAdjustRandomMax, ModName)
            newValue = MultAdjustRandomMax.Value
        ElseIf asControlId == MultAdjustRandomMaxC.McmId
            oldValue = MultAdjustRandomMaxC.Value
            LoadSettingFromMCM(MultAdjustRandomMaxC, ModName)
            newValue = MultAdjustRandomMaxC.Value
        ElseIf asControlId == MultAdjustRandomMaxU.McmId
            oldValue = MultAdjustRandomMaxU.Value
            LoadSettingFromMCM(MultAdjustRandomMaxU, ModName)
            newValue = MultAdjustRandomMaxU.Value
        ElseIf asControlId == MultAdjustRandomMaxR.McmId
            oldValue = MultAdjustRandomMaxR.Value
            LoadSettingFromMCM(MultAdjustRandomMaxR, ModName)
            newValue = MultAdjustRandomMaxR.Value
        ElseIf asControlId == MultAdjustRandomMaxS.McmId
            oldValue = MultAdjustRandomMaxS.Value
            LoadSettingFromMCM(MultAdjustRandomMaxS, ModName)
            newValue = MultAdjustRandomMaxS.Value

        ; advanced - multithreading
        ElseIf asControlId == ThreadLimit.McmId
            oldValue = ThreadLimit.Value
            LoadSettingFromMCM(ThreadLimit, ModName)
            newValue = ThreadLimit.Value
            ThreadManager.SetThreadLimit(ThreadLimit.Value)

        ; advanced - methodology
        ElseIf asControlId == UseDirectMoveRecyclableItemListUpdate.McmId
            oldValue = UseDirectMoveRecyclableItemListUpdate.Value
            LoadSettingFromMCM(UseDirectMoveRecyclableItemListUpdate, ModName)
            newValue = UseDirectMoveRecyclableItemListUpdate.Value

        ; multiplier adjustments - scrapper 1-5
        Else
            int index = 0
            While index < ScrapperPerkMaxRanksSupported && oldValue as int == defaultValue
                If asControlId == MultAdjustScrapperSettlement[index].McmId
                    oldValue = MultAdjustScrapperSettlement[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperSettlement[index], ModName)
                    newValue = MultAdjustScrapperSettlement[index].Value
                ElseIf asControlId == MultAdjustScrapperSettlementC[index].McmId
                    oldValue = MultAdjustScrapperSettlementC[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperSettlementC[index], ModName)
                    newValue = MultAdjustScrapperSettlementC[index].Value
                ElseIf asControlId == MultAdjustScrapperSettlementU[index].McmId
                    oldValue = MultAdjustScrapperSettlementU[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperSettlementU[index], ModName)
                    newValue = MultAdjustScrapperSettlementU[index].Value
                ElseIf asControlId == MultAdjustScrapperSettlementR[index].McmId
                    oldValue = MultAdjustScrapperSettlementR[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperSettlementR[index], ModName)
                    newValue = MultAdjustScrapperSettlementR[index].Value
                ElseIf asControlId == MultAdjustScrapperSettlementS[index].McmId
                    oldValue = MultAdjustScrapperSettlementS[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperSettlementS[index], ModName)
                    newValue = MultAdjustScrapperSettlementS[index].Value

                ElseIf asControlId == MultAdjustScrapperNotSettlement[index].McmId
                    oldValue = MultAdjustScrapperNotSettlement[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperNotSettlement[index], ModName)
                    newValue = MultAdjustScrapperNotSettlement[index].Value
                ElseIf asControlId == MultAdjustScrapperNotSettlementC[index].McmId
                    oldValue = MultAdjustScrapperNotSettlementC[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperNotSettlementC[index], ModName)
                    newValue = MultAdjustScrapperNotSettlementC[index].Value
                ElseIf asControlId == MultAdjustScrapperNotSettlementU[index].McmId
                    oldValue = MultAdjustScrapperNotSettlementU[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperNotSettlementU[index], ModName)
                    newValue = MultAdjustScrapperNotSettlementU[index].Value
                ElseIf asControlId == MultAdjustScrapperNotSettlementR[index].McmId
                    oldValue = MultAdjustScrapperNotSettlementR[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperNotSettlementR[index], ModName)
                    newValue = MultAdjustScrapperNotSettlementR[index].Value
                ElseIf asControlId == MultAdjustScrapperNotSettlementS[index].McmId
                    oldValue = MultAdjustScrapperNotSettlementS[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperNotSettlementS[index], ModName)
                    newValue = MultAdjustScrapperNotSettlementS[index].Value
                EndIf

                index += 1
            EndWhile
        EndIf

        If oldValue as int != defaultValue
            Self._DebugTrace("MCM control ID '" + asControlId + "' was changed. Old value = " + oldValue + \
                ", new value = " + newValue)
            Self.PerformMCMSettingPostProcessing()
            If doMenuRefresh
                MCM.RefreshMenu()
            EndIf
            Else
            Self._DebugTrace("Unknown control ID: " + asControlId, 2)
        EndIf
    EndIf
EndFunction

; callback function for when the user moves to a different MCM menu
Function OnMCMMenuClose()
    Self.MultAdjustRandomSanityCheck()
    MCM.RefreshMenu()
EndFunction

; show the current multipliers for where the player is located right now
Function ShowCurrentMultipliers()
    ; engage a short non-menu-mode wait so that the multiplier isn't calculated until the player comes out of
    ; menu mode in order to take into account any changes that might still be made
    Utility.Wait(0.1)

    Self._DebugTrace("Current multipliers:")
    MultiplierSet currentMults = Self.GetMultipliers(IsPlayerAtOwnedWorkshop())
    If RngAffectsMult.Value == 1
        MessageCurrentMultipliersRng.Show( \
            currentMults.MultC + MultAdjustRandomMin.Value, currentMults.MultC + MultAdjustRandomMax.Value, \
            currentMults.MultU + MultAdjustRandomMin.Value, currentMults.MultU + MultAdjustRandomMax.Value, \
            currentMults.MultR + MultAdjustRandomMin.Value, currentMults.MultR + MultAdjustRandomMax.Value, \
            currentMults.MultS + MultAdjustRandomMin.Value, currentMults.MultS + MultAdjustRandomMax.Value \
        )
    ElseIf RngAffectsMult.Value > 1
        MessageCurrentMultipliersRng.Show( \
            currentMults.MultC + MultAdjustRandomMinC.Value, currentMults.MultC + MultAdjustRandomMaxC.Value, \
            currentMults.MultU + MultAdjustRandomMinU.Value, currentMults.MultU + MultAdjustRandomMaxU.Value, \
            currentMults.MultR + MultAdjustRandomMinR.Value, currentMults.MultR + MultAdjustRandomMaxR.Value, \
            currentMults.MultS + MultAdjustRandomMinS.Value, currentMults.MultS + MultAdjustRandomMaxS.Value \
        )
    Else
        MessageCurrentMultipliers.Show( \
            currentMults.MultC, \
            currentMults.MultU, \
            currentMults.MultR, \
            currentMults.MultS \
        )
    EndIf
EndFunction

; get the number of uses left
Function ShowNumberOfUsesLeft()
    ; engage a short non-menu-mode wait so that the number of uses remaining isn't calculated until the player
    ; comes out of menu mode in order to take into account any changes that might still be made
    Utility.Wait(0.1)

    If HasLimitedUses.Value
        Self._DebugTrace("Number of uses remaining: " + (NumberOfUses.Value - NumberOfTimesUsed))
        MessageUsesLeftLimited.Show(NumberOfUses.Value - NumberOfTimesUsed)
    Else
        Self._DebugTrace("Number of uses remaining: Unlimited")
        MessageUsesLeftUnlimited.Show()
    EndIf
EndFunction

; reset settings
Function ResetToDefaults()
    If ! (MutexRunning || MutexBusy)
        MutexBusy = true
        Debug.StartStackProfiling()
        Self._DebugTrace("Resetting settings to defaults")
        Self.InitSettings(abForce = true)
        Self.InitSettingsSupplemental()
        Self.InitSettingsDefaultValues()
        MCM.RefreshMenu()
        Debug.StopStackProfiling()
        MutexBusy = false
        MessageSettingsReset.Show()
    ElseIf MutexRunning && ! MutexBusy
        Self._DebugTrace("Resetting settings to defaults failed due to a recycling process currently running")
        MessageSettingsResetFailRunning.Show()
    Else
        Self._DebugTrace("Resetting settings to defaults failed due to the control script being busy")
        MessageSettingsResetFailBusy.Show()
    EndIf
EndFunction

; reset the running/busy mutexes
Function ResetMutexes()
    Self._DebugTrace("Resetting Running and Busy mutexes")
    Self._DebugTrace("Current values: MutexRunning=" + MutexRunning + ", MutexBusy=" + MutexBusy)
    MutexRunning = false
    MutexBusy = false
    MessageLocksReset.Show()
EndFunction

; reset the recyclable item and low weight ratio item lists
Function ResetRecyclableItemsLists()
    If ! MutexBusy && ! MutexRunning
        MutexBusy = true
        Self._DebugTrace("Resetting recyclable item and low weight ratio item lists")
        RecyclableItemList.List.Revert()
        RecyclableItemList.Size = RecyclableItemList.List.GetSize()
        LowWeightRatioItemList.List.Revert()
        LowWeightRatioItemList.Size = LowWeightRatioItemList.List.GetSize()
        MutexBusy = false
        MessageRecyclableItemsListsReset.Show()
    ElseIf MutexBusy && ! MutexRunning
        Self._DebugTrace("Failed to reset recyclable item and low weight ratio item lists: Control script busy")
        MessageRecyclableItemsListsResetFailBusy.Show()
    ElseIf MutexRunning
        Self._DebugTrace("Failed to reset recyclable item and low weight ratio item lists: Recycling process running")
        MessageRecyclableItemsListsResetFailRunning.Show()
    EndIf
EndFunction

; reset the recyclable item list
Function ResetAlwaysAutoTransferList()
    If ! MutexBusy && ! MutexRunning
        MutexBusy = true
        Self._DebugTrace("Resetting always auto transfer list")
        AlwaysAutoTransferList.List.Revert()
        AlwaysAutoTransferList.Size = AlwaysAutoTransferList.List.GetSize()
        MutexBusy = false
        MessageAlwaysAutoTransferListReset.Show()
    ElseIf MutexBusy && ! MutexRunning
        Self._DebugTrace("Failed to reset always auto transfer list: Control script busy")
        MessageAlwaysAutoTransferListResetFailBusy.Show()
    ElseIf MutexRunning
        Self._DebugTrace("Failed to reset always auto transfer list: Recycling process running")
        MessageAlwaysAutoTransferListResetFailRunning.Show()
    EndIf
EndFunction

; reset the recyclable item list
Function ResetNeverAutoTransferList()
    If ! MutexBusy && ! MutexRunning
        MutexBusy = true
        Self._DebugTrace("Resetting never auto transfer list")
        NeverAutoTransferList.List.Revert()
        NeverAutoTransferList.Size = NeverAutoTransferList.List.GetSize()
        MutexBusy = false
        MessageNeverAutoTransferListReset.Show()
    ElseIf MutexBusy && ! MutexRunning
        Self._DebugTrace("Failed to reset never auto transfer list: Control script busy")
        MessageNeverAutoTransferListResetFailBusy.Show()
    ElseIf MutexRunning
        Self._DebugTrace("Failed to reset never auto transfer list: Recycling process running")
        MessageNeverAutoTransferListResetFailRunning.Show()
    EndIf
EndFunction

; make sure that MultAdjustRandomMin* properties are less than their MultAdjustRandomMax* counterparts
; not strictly necessary since Utility.RandomFloat() doesn't care, but it looks better in the menus
Function MultAdjustRandomSanityCheck()
    Self._DebugTrace("Running sanity checks on MultAdjustRandom{Min,Max}* properties")
    float tempValue
    If MultAdjustRandomMin.Value > MultAdjustRandomMax.Value
        Self._DebugTrace("Fixing invalid combination: MultAdjustRandomMin=" + MultAdjustRandomMin.Value + \
            "; MultAdjustRandomMax=" + MultAdjustRandomMax.Value)
        tempValue = MultAdjustRandomMin.Value
        ChangeSetting(MultAdjustRandomMin, AvailableChangeTypes.Both, MultAdjustRandomMax.Value, ModName)
        ChangeSetting(MultAdjustRandomMax, AvailableChangeTypes.Both, tempValue, ModName)
    EndIf
    If MultAdjustRandomMinC.Value > MultAdjustRandomMaxC.Value
        Self._DebugTrace("Fixing invalid combination: MultAdjustRandomMinC=" + MultAdjustRandomMinC.Value + \
            "; MultAdjustRandomMaxC=" + MultAdjustRandomMaxC.Value)
        tempValue = MultAdjustRandomMinC.Value
        ChangeSetting(MultAdjustRandomMinC, AvailableChangeTypes.Both, MultAdjustRandomMaxC.Value, ModName)
        ChangeSetting(MultAdjustRandomMaxC, AvailableChangeTypes.Both, tempValue, ModName)
    EndIf
    If MultAdjustRandomMinU.Value > MultAdjustRandomMaxU.Value
        Self._DebugTrace("Fixing invalid combination: MultAdjustRandomMinU=" + MultAdjustRandomMinU.Value + \
            "; MultAdjustRandomMaxU=" + MultAdjustRandomMaxU.Value)
        tempValue = MultAdjustRandomMinU.Value
        ChangeSetting(MultAdjustRandomMinU, AvailableChangeTypes.Both, MultAdjustRandomMaxU.Value, ModName)
        ChangeSetting(MultAdjustRandomMaxU, AvailableChangeTypes.Both, tempValue, ModName)
    EndIf
    If MultAdjustRandomMinR.Value > MultAdjustRandomMaxR.Value
        Self._DebugTrace("Fixing invalid combination: MultAdjustRandomMinR=" + MultAdjustRandomMinR.Value + \
            "; MultAdjustRandomMaxR=" + MultAdjustRandomMaxR.Value)
        tempValue = MultAdjustRandomMinR.Value
        ChangeSetting(MultAdjustRandomMinR, AvailableChangeTypes.Both, MultAdjustRandomMaxR.Value, ModName)
        ChangeSetting(MultAdjustRandomMaxR, AvailableChangeTypes.Both, tempValue, ModName)
    EndIf
    If MultAdjustRandomMinS.Value > MultAdjustRandomMaxS.Value
        Self._DebugTrace("Fixing invalid combination: MultAdjustRandomMinS=" + MultAdjustRandomMinS.Value + \
            "; MultAdjustRandomMaxS=" + MultAdjustRandomMaxS.Value)
        tempValue = MultAdjustRandomMinS.Value
        ChangeSetting(MultAdjustRandomMinS, AvailableChangeTypes.Both, MultAdjustRandomMaxS.Value, ModName)
        ChangeSetting(MultAdjustRandomMaxS, AvailableChangeTypes.Both, tempValue, ModName)
    EndIf
EndFunction

; Canary support
; https://www.nexusmods.com/fallout4/mods/44949
Function CheckForCanary()
    If(Game.IsPluginInstalled("CanarySaveFileMonitor.esl"))
        var[] params = new var[2]
        params[0] = Self as Quest
        params[1] = FullScriptName
        Utility.CallGlobalFunction("Canary:API", "MonitorForDataLoss", params)
        Self._DebugTrace("Canary integration activated")
    EndIf
EndFunction

; returns true if the player is an an owned workshop
bool Function IsPlayerAtOwnedWorkshop()
    WorkshopScript workshopRef = WorkshopParent.GetWorkshopFromLocation(PlayerRef.GetCurrentLocation())
    Return workshopRef && workshopRef.OwnedByPlayer && PlayerRef.IsWithinBuildableArea(workshopRef)
EndFunction

; get the current multipliers
MultiplierSet Function GetMultipliers(bool abPlayerAtOwnedWorkshop)
    Self._DebugTrace("Getting multipliers")
    MultiplierSet toReturn = new MultiplierSet

    toReturn.MultC = MultBase.Value
    toReturn.MultU = MultBase.Value
    toReturn.MultR = MultBase.Value
    toReturn.MultS = MultBase.Value
    Self._DebugTrace("Base multiplier: " + MultBase.Value)

    ; general
    Self._DebugTrace("Player is in an owned settlement: " + abPlayerAtOwnedWorkshop)
    If abPlayerAtOwnedWorkshop
        If GeneralMultAdjust.Value == 0
            ; simple
            toReturn.MultC += MultAdjustGeneralSettlement.Value
            toReturn.MultU += MultAdjustGeneralSettlement.Value
            toReturn.MultR += MultAdjustGeneralSettlement.Value
            toReturn.MultS += MultAdjustGeneralSettlement.Value
            Self._DebugTrace("Adjustment (General: owned settlement): " + MultAdjustGeneralSettlement.Value)
        Else
            ; detailed
            toReturn.MultC += MultAdjustGeneralSettlementC.Value
            Self._DebugTrace("AdjustmentC (General: owned settlement): " + MultAdjustGeneralSettlementC.Value)
            toReturn.MultU += MultAdjustGeneralSettlementU.Value
            Self._DebugTrace("AdjustmentU (General: owned settlement): " + MultAdjustGeneralSettlementU.Value)
            toReturn.MultR += MultAdjustGeneralSettlementR.Value
            Self._DebugTrace("AdjustmentR (General: owned settlement): " + MultAdjustGeneralSettlementR.Value)
            toReturn.MultS += MultAdjustGeneralSettlementS.Value
            Self._DebugTrace("AdjustmentS (General: owned settlement): " + MultAdjustGeneralSettlementS.Value)
        EndIf
    Else
        If GeneralMultAdjust.Value == 0
            ; simple
            toReturn.MultC += MultAdjustGeneralNotSettlement.Value
            toReturn.MultU += MultAdjustGeneralNotSettlement.Value
            toReturn.MultR += MultAdjustGeneralNotSettlement.Value
            toReturn.MultS += MultAdjustGeneralNotSettlement.Value
            Self._DebugTrace("Adjustment (General: not owned settlement): " + MultAdjustGeneralNotSettlement.Value)
        Else
            ; detailed
            toReturn.MultC += MultAdjustGeneralNotSettlementC.Value
            Self._DebugTrace("AdjustmentC (General: not owned settlement): " + MultAdjustGeneralNotSettlementC.Value)
            toReturn.MultU += MultAdjustGeneralNotSettlementU.Value
            Self._DebugTrace("AdjustmentU (General: not owned settlement): " + MultAdjustGeneralNotSettlementU.Value)
            toReturn.MultR += MultAdjustGeneralNotSettlementR.Value
            Self._DebugTrace("AdjustmentR (General: not owned settlement): " + MultAdjustGeneralNotSettlementR.Value)
            toReturn.MultS += MultAdjustGeneralNotSettlementS.Value
            Self._DebugTrace("AdjustmentS (General: not owned settlement): " + MultAdjustGeneralNotSettlementS.Value)
        EndIf
    EndIf

    ; intelligence
    If IntAffectsMult.Value
        int playerInt = PlayerRef.GetValue(Game.GetIntelligenceAV()) as int
        float intAdjust
        If IntAffectsMult.Value == 1
            ; simple
            intAdjust = MultAdjustInt.Value * playerInt
            toReturn.MultC += intAdjust
            toReturn.MultU += intAdjust
            toReturn.MultR += intAdjust
            toReturn.MultS += intAdjust
            Self._DebugTrace("Adjustment (Intelligence): " + MultAdjustInt.Value + " * " + playerInt + " = " + intAdjust)
        Else
            ; detailed
            intAdjust = MultAdjustIntC.Value * playerInt
            toReturn.MultC += intAdjust
            Self._DebugTrace("AdjustmentC (Intelligence): " + MultAdjustIntC.Value + " * " + playerInt + " = " + intAdjust)
            intAdjust = MultAdjustIntU.Value * playerInt
            toReturn.MultU += intAdjust
            Self._DebugTrace("AdjustmentU (Intelligence): " + MultAdjustIntU.Value + " * " + playerInt + " = " + intAdjust)
            intAdjust = MultAdjustIntR.Value * playerInt
            toReturn.MultR += intAdjust
            Self._DebugTrace("AdjustmentR (Intelligence): " + MultAdjustIntR.Value + " * " + playerInt + " = " + intAdjust)
            intAdjust = MultAdjustIntS.Value * playerInt
            toReturn.MultS += intAdjust
            Self._DebugTrace("AdjustmentS (Intelligence): " + MultAdjustIntS.Value + " * " + playerInt + " = " + intAdjust)
        EndIf
    EndIf

    ; luck
    If LckAffectsMult.Value
        int playerLck = PlayerRef.GetValue(Game.GetLuckAV()) as int
        float lckAdjust
        If LckAffectsMult.Value == 1
            ; simple
            lckAdjust = MultAdjustLck.Value * playerLck
            toReturn.MultC += lckAdjust
            toReturn.MultU += lckAdjust
            toReturn.MultR += lckAdjust
            toReturn.MultS += lckAdjust
            Self._DebugTrace("Adjustment (Luck): " + MultAdjustLck.Value + " * " + playerLck + " = " + lckAdjust)
        Else
            ; detailed
            lckAdjust = MultAdjustLckC.Value * playerLck
            toReturn.MultC += lckAdjust
            Self._DebugTrace("AdjustmentC (Luck): " + MultAdjustLckC.Value + " * " + playerLck + " = " + lckAdjust)
            lckAdjust = MultAdjustLckU.Value * playerLck
            toReturn.MultU += lckAdjust
            Self._DebugTrace("AdjustmentU (Luck): " + MultAdjustLckU.Value + " * " + playerLck + " = " + lckAdjust)
            lckAdjust = MultAdjustLckR.Value * playerLck
            toReturn.MultR += lckAdjust
            Self._DebugTrace("AdjustmentR (Luck): " + MultAdjustLckR.Value + " * " + playerLck + " = " + lckAdjust)
            lckAdjust = MultAdjustLckS.Value * playerLck
            toReturn.MultS += lckAdjust
            Self._DebugTrace("AdjustmentS (Luck): " + MultAdjustLckS.Value + " * " + playerLck + " = " + lckAdjust)
        EndIf
    EndIf

    ; random
    toReturn.RandomMin = MultAdjustRandomMin.Value
    toReturn.RandomMax = MultAdjustRandomMax.Value
    toReturn.RandomMinC = MultAdjustRandomMinC.Value
    toReturn.RandomMaxC = MultAdjustRandomMaxC.Value
    toReturn.RandomMinU = MultAdjustRandomMinU.Value
    toReturn.RandomMaxU = MultAdjustRandomMaxU.Value
    toReturn.RandomMinR = MultAdjustRandomMinR.Value
    toReturn.RandomMaxR = MultAdjustRandomMaxR.Value
    toReturn.RandomMinS = MultAdjustRandomMinS.Value
    toReturn.RandomMaxS = MultAdjustRandomMaxS.Value

    ; scrapper
    If ScrapperAffectsMult.Value
        ; get the index of the player's scrapper perk (if any)
        int playerScrapperPerkIndex = -1
        int index = ScrapperPerks.Length - 1
        While index >= 0 && ! PlayerRef.HasPerk(ScrapperPerks[index])
            index -= 1
        EndWhile
        playerScrapperPerkIndex = index
        Self._DebugTrace("Player's Scrapper perk index: " + playerScrapperPerkIndex)

        If playerScrapperPerkIndex >= 0
            If abPlayerAtOwnedWorkshop
                If ScrapperAffectsMult.Value == 1
                    ; simple
                    toReturn.MultC += MultAdjustScrapperSettlement[playerScrapperPerkIndex].Value
                    toReturn.MultU += MultAdjustScrapperSettlement[playerScrapperPerkIndex].Value
                    toReturn.MultR += MultAdjustScrapperSettlement[playerScrapperPerkIndex].Value
                    toReturn.MultS += MultAdjustScrapperSettlement[playerScrapperPerkIndex].Value
                    Self._DebugTrace("Adjustment (Scrapper: owned settlement): " + \
                        MultAdjustScrapperSettlement[playerScrapperPerkIndex].Value)
                Else
                    ; detailed
                    toReturn.MultC += MultAdjustScrapperSettlementC[playerScrapperPerkIndex].Value
                    Self._DebugTrace("AdjustmentC (Scrapper: owned settlement): " + \
                        MultAdjustScrapperSettlementC[playerScrapperPerkIndex].Value)
                    toReturn.MultU += MultAdjustScrapperSettlementU[playerScrapperPerkIndex].Value
                    Self._DebugTrace("AdjustmentU (Scrapper: owned settlement): " + \
                        MultAdjustScrapperSettlementU[playerScrapperPerkIndex].Value)
                    toReturn.MultR += MultAdjustScrapperSettlementR[playerScrapperPerkIndex].Value
                    Self._DebugTrace("AdjustmentR (Scrapper: owned settlement): " + \
                        MultAdjustScrapperSettlementR[playerScrapperPerkIndex].Value)
                    toReturn.MultS += MultAdjustScrapperSettlementS[playerScrapperPerkIndex].Value
                    Self._DebugTrace("AdjustmentS (Scrapper: owned settlement): " + \
                        MultAdjustScrapperSettlementS[playerScrapperPerkIndex].Value)
                EndIf
            Else
                If ScrapperAffectsMult.Value == 1
                    ; simple
                    toReturn.MultC += MultAdjustScrapperNotSettlement[playerScrapperPerkIndex].Value
                    toReturn.MultU += MultAdjustScrapperNotSettlement[playerScrapperPerkIndex].Value
                    toReturn.MultR += MultAdjustScrapperNotSettlement[playerScrapperPerkIndex].Value
                    toReturn.MultS += MultAdjustScrapperNotSettlement[playerScrapperPerkIndex].Value
                    Self._DebugTrace("Adjustment (Scrapper: not owned settlement): " + \
                        MultAdjustScrapperNotSettlement[playerScrapperPerkIndex].Value)
                Else
                    ; detailed
                    toReturn.MultC += MultAdjustScrapperNotSettlementC[playerScrapperPerkIndex].Value
                    Self._DebugTrace("AdjustmentC (Scrapper: not owned settlement): " + \
                        MultAdjustScrapperNotSettlementC[playerScrapperPerkIndex].Value)
                    toReturn.MultU += MultAdjustScrapperNotSettlementU[playerScrapperPerkIndex].Value
                    Self._DebugTrace("AdjustmentU (Scrapper: not owned settlement): " + \
                        MultAdjustScrapperNotSettlementU[playerScrapperPerkIndex].Value)
                    toReturn.MultR += MultAdjustScrapperNotSettlementR[playerScrapperPerkIndex].Value
                    Self._DebugTrace("AdjustmentR (Scrapper: not owned settlement): " + \
                        MultAdjustScrapperNotSettlementR[playerScrapperPerkIndex].Value)
                    toReturn.MultS += MultAdjustScrapperNotSettlementS[playerScrapperPerkIndex].Value
                    Self._DebugTrace("AdjustmentS (Scrapper: not owned settlement): " + \
                        MultAdjustScrapperNotSettlementS[playerScrapperPerkIndex].Value)
                EndIf
            EndIf
        EndIf
    EndIf

    ; it's possible to get a multiplier of < 0, so clamp values to a minimum of 0.0
    Math.Max(0.0, toReturn.MultC)
    Math.Max(0.0, toReturn.MultU)
    Math.Max(0.0, toReturn.MultR)
    Math.Max(0.0, toReturn.MultS)

    Return toReturn
EndFunction

; prep for uninstall of mod
Function Uninstall()
    If ! MutexRunning && ! MutexBusy
        Self._DebugTrace("Uninstallation sequence initialized!", 1)

        ; unregister from all events
        UnregisterForRemoteEvent(PlayerRef, "OnPlayerLoadGame")
        UnregisterForMenuOpenCloseEvent("PauseMenu")
        UnregisterForExternalEvent("OnMCMSettingChange|" + ModName)
        UnregisterForExternalEvent("OnMCMMenuClose|" + ModName)
        UnregisterForKey(LAlt)
        UnregisterForKey(RAlt)
        UnregisterForKey(LCtrl)
        UnregisterForKey(RCtrl)
        UnregisterForKey(LShift)
        UnregisterForKey(RShift)

        ; stop the ThreadManager
        ThreadManager.Uninstall()

        ; remove recycler devices in inventory, if any
        PlayerRef.RemoveItem(Game.GetFormFromFile(0x840, ModName + ".esp"), -1, true)

        ; properties
        ; group Components
        ComponentListC.List.Revert()
        ComponentListC = None
        ComponentListU.List.Revert()
        ComponentListU = None
        ComponentListR.List.Revert()
        ComponentListR = None
        ComponentListS.List.Revert()
        ComponentListS = None
        ScrapListC.List.Revert()
        ScrapListC = None
        ScrapListU.List.Revert()
        ScrapListU = None
        ScrapListR.List.Revert()
        ScrapListR = None
        ScrapListS.List.Revert()
        ScrapListS = None
        ScrapListAll.List.Revert()
        ScrapListAll = None
        DestroyArrayContents(ComponentMappings as var[])
        ComponentMappings = None

        ; group Messages
        MessageF4SENotInstalled = None
        MessageMCMNotInstalled = None
        MessageInitialized = None
        MessageCurrentMultipliers = None
        MessageCurrentMultipliersRng = None
        MessageUsesLeftLimited = None
        MessageUsesLeftUnlimited = None
        MessageSettingsReset = None
        MessageSettingsResetFailBusy = None
        MessageSettingsResetFailRunning = None
        MessageLocksReset = None
        MessageRecyclableItemsListsReset = None
        MessageRecyclableItemsListsResetFailBusy = None
        MessageRecyclableItemsListsResetFailRunning = None
        MessageAlwaysAutoTransferListReset = None
        MessageAlwaysAutoTransferListResetFailBusy = None
        MessageAlwaysAutoTransferListResetFailRunning = None
        MessageNeverAutoTransferListReset = None
        MessageNeverAutoTransferListResetFailBusy = None
        MessageNeverAutoTransferListResetFailRunning = None
        MessageUninstallFailRunning = None
        MessageUninstallFailBusy = None

        ; group Other
        PlayerRef = None
        WorkshopParent = None
        RecyclableItemList.List.Revert()
        RecyclableItemList = None
        LowWeightRatioItemList.List.Revert()
        LowWeightRatioItemList = None
        NeverAutoTransferList.List.Revert()
        NeverAutoTransferList = None
        AlwaysAutoTransferList.List.Revert()
        AlwaysAutoTransferList = None
        ThreadManager = None
        PortableJunkRecyclerConstructibleObject = None

        ; group RuntimeState
        DestroyArrayContents(ScrapperPerks as var[])
        ScrapperPerks = None

        ; group Settings
        ; settings - general
        MultBase = None
        ReturnAtLeastOneComponent = None
        FractionalComponentHandling = None
        HasLimitedUses = None
        NumberOfUses = None
        ; settings - adjustment options
        GeneralMultAdjust = None
        IntAffectsMult = None
        LckAffectsMult = None
        RngAffectsMult = None
        ScrapperAffectsMult = None
        ; recycler interface - behavior
        AutoRecyclingMode = None
        EnableJunkFilter = None
        AutoTransferJunk = None
        TransferLowWeightRatioItems = None
        UseAlwaysAutoTransferList = None
        UseNeverAutoTransferList = None
        EnableAutoTransferListEditing = None
        EnableBehaviorOverrides = None
        ReturnItemsSilently = None
        ; multiplier adjustments - general
        MultAdjustGeneralSettlement = None
        MultAdjustGeneralSettlementC = None
        MultAdjustGeneralSettlementU = None
        MultAdjustGeneralSettlementR = None
        MultAdjustGeneralSettlementS = None
        MultAdjustGeneralNotSettlement = None
        MultAdjustGeneralNotSettlementC = None
        MultAdjustGeneralNotSettlementU = None
        MultAdjustGeneralNotSettlementR = None
        MultAdjustGeneralNotSettlementS = None
        ; multiplier adjustments - intelligence
        MultAdjustInt = None
        MultAdjustIntC = None
        MultAdjustIntU = None
        MultAdjustIntR = None
        MultAdjustIntS = None
        ; multiplier adjustments - luck
        MultAdjustLck = None
        MultAdjustLckC = None
        MultAdjustLckU = None
        MultAdjustLckR = None
        MultAdjustLckS = None
        ; multiplier adjustments - randomness
        MultAdjustRandomMin = None
        MultAdjustRandomMinC = None
        MultAdjustRandomMinU = None
        MultAdjustRandomMinR = None
        MultAdjustRandomMinS = None
        MultAdjustRandomMax = None
        MultAdjustRandomMaxC = None
        MultAdjustRandomMaxU = None
        MultAdjustRandomMaxR = None
        MultAdjustRandomMaxS = None
        ; multiplier adjustments - scrapper
        DestroyArrayContents(MultAdjustScrapperSettlement as var[])
        MultAdjustScrapperSettlement = None
        DestroyArrayContents(MultAdjustScrapperSettlementC as var[])
        MultAdjustScrapperSettlementC = None
        DestroyArrayContents(MultAdjustScrapperSettlementU as var[])
        MultAdjustScrapperSettlementU = None
        DestroyArrayContents(MultAdjustScrapperSettlementR as var[])
        MultAdjustScrapperSettlementR = None
        DestroyArrayContents(MultAdjustScrapperSettlementS as var[])
        MultAdjustScrapperSettlementS = None
        DestroyArrayContents(MultAdjustScrapperNotSettlement as var[])
        MultAdjustScrapperNotSettlement = None
        DestroyArrayContents(MultAdjustScrapperNotSettlementC as var[])
        MultAdjustScrapperNotSettlementC = None
        DestroyArrayContents(MultAdjustScrapperNotSettlementU as var[])
        MultAdjustScrapperNotSettlementU = None
        DestroyArrayContents(MultAdjustScrapperNotSettlementR as var[])
        MultAdjustScrapperNotSettlementR = None
        DestroyArrayContents(MultAdjustScrapperNotSettlementS as var[])
        MultAdjustScrapperNotSettlementS = None
        ; advanced - multithreading
        ThreadLimit = None
        ; advanced - methodology
        UseDirectMoveRecyclableItemListUpdate = None

        ; local variables
        AvailableChangeTypes = None

        ; show uninstalled message
        MessageUninstalled.Show()
        MessageUninstalled = None

        ; stop the quest
        Stop()

        Self._DebugTrace("Uninstallation sequence complete!", 1)
    ElseIf MutexRunning && ! MutexBusy
        ; fail (running)
        MessageUninstallFailRunning.Show()
    Else
        ; fail (busy)
        MessageUninstallFailBusy.Show()
    EndIf
EndFunction