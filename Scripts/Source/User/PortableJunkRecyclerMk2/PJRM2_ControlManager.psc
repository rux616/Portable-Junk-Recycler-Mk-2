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



ScriptName PortableJunkRecyclerMk2:PJRM2_ControlManager extends Quest

; import data structures
import PortableJunkRecyclerMk2:PJRM2_DataStructures
; import utility functions
import PortableJunkRecyclerMk2:PJRM2_Utility



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

    string Property FullScriptName = "PortableJunkRecyclerMk2:PJRM2_ControlManager" AutoReadOnly Hidden
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

    int Property CurrentChangeType Auto Hidden
EndGroup

int Property iSaveFileMonitor Auto Hidden ; Do not mess with ever - this is used by Canary to track data loss
{ Canary support
  https://www.nexusmods.com/fallout4/mods/44949 }



; VARIABLES
; ---------

PJRM2_SettingManager SettingManager
PJRM2_ThreadManager ThreadManager
string ModVersion = "1.0.3" const
SettingChangeType AvailableChangeTypes
string ModName
bool EnableLogging = false
bool EnableProfiling = false

; DirectX scan codes: https://www.creationkit.com/fallout4/index.php?title=DirectX_Scan_Codes
int LShift = 160 const
int RShift = 161 const
int LCtrl = 162 const
int RCtrl = 163 const
int LAlt = 164 const
int RAlt = 165 const

bool ProfilingActive = false



; EVENTS
; ------

Event OnInit()
    SettingManager = (Self as Quest) as PJRM2_SettingManager
    ThreadManager = (Self as Quest) as PJRM2_ThreadManager
    ModName = SettingManager.ModName
    EnableLogging = SettingManager.EnableLogging
    EnableProfiling = SettingManager.EnableProfiling
    AvailableChangeTypes = new SettingChangeType
EndEvent

Event OnQuestInit()
    MutexBusy = true
    Self._StartStackProfiling()

    Self.Initialize(abQuestInit = true)

    Self._StopStackProfiling()
    MutexBusy = false
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    Self._StartStackProfiling()

    ; immediately abort if there's already a thread waiting on mutex release
    If MutexWaiting
        Self._Log("OnPlayerLoadGame: Already a thread waiting on mutex release; aborting")
        Return
    EndIf

    ; wait for mutexes to release
    int waitTimeLeft = 30
    float waitTime = 3.0 const
    While (MutexRunning || MutexBusy) && waitTimeLeft > 0
        MutexWaiting = true
        Self._Log("OnPlayerLoadGame: Waiting on mutex release. Time left = " + waitTimeLeft)
        Utility.Wait(waitTime)
        waitTimeLeft -= waitTime as int
    EndWhile

    ; lock function in case user exits game while recycling process is running or this same function is running
    If ! (MutexRunning || MutexBusy)
        MutexBusy = true

        Self.Initialize()

        MutexBusy = false
    Else
        Self._Log("OnPlayerLoadGame: Mutexes didn't release within time limit", 1)
    EndIf

    Self._StopStackProfiling()
    MutexWaiting = false
EndEvent

Event OnKeyDown(int aiKeyCode)
    If aiKeyCode == LAlt || aiKeyCode == RAlt
        Self._Log("OnKeyDown: Alt (" + aiKeyCode + ")")
        HotkeyEditAutoTransferLists = true
    ElseIf aiKeyCode == LCtrl || aiKeyCode == RCtrl
        Self._Log("OnKeyDown: Ctrl (" + aiKeyCode + ")")
        HotkeyForceRetainJunk = true
    ElseIf aiKeyCode == LShift || aiKeyCode == RShift
        Self._Log("OnKeyDown: Shift (" + aiKeyCode + ")")
        HotkeyForceTransferJunk = true
    EndIf
EndEvent

Event OnKeyUp(int aiKeyCode, float afTime)
    If aiKeyCode == LAlt || aiKeyCode == RAlt
        Self._Log("OnKeyDown: Alt (" + aiKeyCode + ")")
        HotkeyEditAutoTransferLists = false
    ElseIf aiKeyCode == LCtrl || aiKeyCode == RCtrl
        Self._Log("OnKeyUp: Ctrl (" + aiKeyCode + ")")
        HotkeyForceRetainJunk = false
    ElseIf aiKeyCode == LShift || aiKeyCode == RShift
        Self._Log("OnKeyUp: Shift (" + aiKeyCode + ")")
        HotkeyForceTransferJunk = false
    EndIf
EndEvent



; FUNCTIONS
; ---------

; add a bit of text to traces going into the papyrus user log
Function _Log(string asLogMessage, int aiSeverity = 0, bool abForce = false) DebugOnly
    If EnableLogging || abForce
        Log(ModName, "ControlManager", asLogMessage, aiSeverity)
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

; turn logging on or off
; true = on
; false = off
Function SetLogging(bool abEnableLogging)
    If EnableLogging != abEnableLogging
        EnableLogging = abEnableLogging

        If EnableLogging
            Self._Log("Logging enabled", abForce = true)
        Else
            Self._Log("Logging disabled", abForce = true)
        EndIf
    EndIf
EndFunction

; turn profiling on or off
; true = on
; false = off
Function SetProfiling(bool abEnableProfiling)
    If EnableProfiling != abEnableProfiling
        EnableProfiling = abEnableProfiling

        If EnableProfiling
            Self._Log("Profiling enabled")
        Else
            Self._Log("Profiling disabled")
        EndIf
    EndIf
EndFunction

; consolidated init
Function Initialize(bool abQuestInit = false)
    Self._Log("SettingManager pre-initialization complete: " + SettingManager.PreInitialized)
    Self._Log("ThreadManager initialization complete: " + ThreadManager.Initialized)
    Self._Log(SettingManager.ModName + " v" + ModVersion, abForce = true)
    If ! EnableLogging
        Self._Log("Logging disabled", abForce = true)
    EndIf
    If abQuestInit
        Self._Log("Beginning onetime init process")
    Else
        Self._Log("Beginning runtime init process")
    EndIf
    Self.CheckForCanary()
    Self.CheckForF4SE()
    Self.CheckForMCM()
    SettingManager.Initialize(abQuestInit = abQuestInit)
    Self.InitFormListWrappers()
    Self.InitComponentMappings()
    Self.InitScrapListAll()
    Self.InitScrapperPerks()
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
        MessageInitialized.Show()
        Self._Log("Finished onetime init process")
    Else
        Self._Log("Finished runtime init process")
    EndIf
EndFunction

; check to see if F4SE is installed
Function CheckForF4SE()
    Debug.Trace(FullScriptName + ": Checking if F4SE is installed...")
    Self._Log("Checking if F4SE is installed...", abForce = true)
    ScriptExtenderInstalled = F4SE.GetVersionRelease() as bool
    If ScriptExtenderInstalled
        Debug.Trace(FullScriptName + ": F4SE installed")
        Self._Log("F4SE v" + F4SE.GetVersion() + "." + F4SE.GetVersionMinor() + "." + F4SE.GetVersionBeta() + "." \
            + F4SE.GetVersionRelease() + " installed (script version " + F4SE.GetScriptVersionRelease() + ")", abForce = true)
    Else
        Debug.Trace(FullScriptName + ": F4SE not installed", 1)
        Self._Log("F4SE not installed", 1, abForce = true)
        MessageF4SENotInstalled.Show()
    EndIf
EndFunction

; check to see if MCM is installed; depends on F4SE
Function CheckForMCM()
    Debug.Trace(FullScriptName + ": Checking if MCM is installed...")
    Self._Log("Checking if MCM is installed...", abForce = true)
    ModConfigMenuInstalled = MCM.IsInstalled() as bool
    If ModConfigMenuInstalled && ScriptExtenderInstalled
        Debug.Trace(FullScriptName + ": MCM installed")
        Self._Log("MCM installed (version code " + MCM.GetVersionCode() + ")", abForce = true)
        CurrentChangeType = AvailableChangeTypes.Both
    ElseIf ModConfigMenuInstalled && ! ScriptExtenderInstalled
        Debug.Trace(FullScriptName + ": MCM installed, but F4SE is not; disabling support")
        Self._Log("MCM installed, but F4SE is not; disabling support", abForce = true)
        ModConfigMenuInstalled = false
        CurrentChangeType = AvailableChangeTypes.ValueOnly
    Else
        Debug.Trace(FullScriptName + ": MCM not installed")
        Self._Log("MCM not installed", abForce = true)
        CurrentChangeType = AvailableChangeTypes.ValueOnly
        MessageMCMNotInstalled.Show()
    EndIf
EndFunction

; initialize FormList wrappers
Function InitFormListWrappers()
    Self._Log("Initializing FormList wrappers")

    ComponentListC.Size = ComponentListC.List.GetSize()
    Self._Log("ComponentListC size = " + ComponentListC.Size)
    ComponentListU.Size = ComponentListU.List.GetSize()
    Self._Log("ComponentListU size = " + ComponentListU.Size)
    ComponentListR.Size = ComponentListR.List.GetSize()
    Self._Log("ComponentListR size = " + ComponentListR.Size)
    ComponentListS.Size = ComponentListS.List.GetSize()
    Self._Log("ComponentListS size = " + ComponentListS.Size)

    ScrapListC.Size = ScrapListC.List.GetSize()
    Self._Log("ScrapListC size = " + ScrapListC.Size)
    ScrapListU.Size = ScrapListU.List.GetSize()
    Self._Log("ScrapListU size = " + ScrapListU.Size)
    ScrapListR.Size = ScrapListR.List.GetSize()
    Self._Log("ScrapListR size = " + ScrapListR.Size)
    ScrapListS.Size = ScrapListS.List.GetSize()
    Self._Log("ScrapListS size = " + ScrapListS.Size)
EndFunction

; initialize component mapping
Function InitComponentMappings()
    Self._Log("Initializing component map")

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

    Self._Log("ComponentMappings size = " + ComponentMappings.Length)
EndFunction

; initialize the FormList containing all scrap parts
Function InitScrapListAll()
    Self._Log("Initializing ScrapListAll FormList")

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
    Self._Log("Initializing scrapper perks list")

    ; create an array of the scrapper perks
    ScrapperPerks = new Perk[0]

    ; seed array with initial scrapper perk
    ScrapperPerks.Add(Game.GetFormFromFile(0x065E65, "Fallout4.esm") as Perk) ; scrapper rank 1

    ; load perks dynamically, but ignore any perk ranks > the number supported
    int numScrapperRanks = ScrapperPerks[0].GetNumRanks()
    While ScrapperPerks.Length < numScrapperRanks && ScrapperPerks.Length < SettingManager.ScrapperPerkMaxRanksSupported
        ScrapperPerks.Add(ScrapperPerks[ScrapperPerks.Length - 1].GetNextPerk())
    EndWhile

    MCM_Scrapper3Available = ScrapperPerks.Length >= 3
    MCM_Scrapper4Available = ScrapperPerks.Length >= 4
    MCM_Scrapper5Available = ScrapperPerks.Length >= 5

    Self._Log(ScrapperPerks.Length + " perks loaded:")
    int index = 0
    While index < ScrapperPerks.Length
        Self._Log(ScrapperPerks[index])
        index += 1
    EndWhile
EndFunction

; show the current multipliers for where the player is located right now
Function ShowCurrentMultipliers()
    ; engage a short non-menu-mode wait so that the multiplier isn't calculated until the player comes out of
    ; menu mode in order to take into account any changes that might still be made
    Utility.Wait(0.1)

    Self._Log("Current multipliers:")
    MultiplierSet currentMults = Self.GetMultipliers(IsPlayerAtOwnedWorkshop())
    If SettingManager.RngAffectsMult == 1
        MessageCurrentMultipliersRng.Show( \
            currentMults.MultC + SettingManager.MultAdjustRandomMin, currentMults.MultC + SettingManager.MultAdjustRandomMax, \
            currentMults.MultU + SettingManager.MultAdjustRandomMin, currentMults.MultU + SettingManager.MultAdjustRandomMax, \
            currentMults.MultR + SettingManager.MultAdjustRandomMin, currentMults.MultR + SettingManager.MultAdjustRandomMax, \
            currentMults.MultS + SettingManager.MultAdjustRandomMin, currentMults.MultS + SettingManager.MultAdjustRandomMax \
        )
    ElseIf SettingManager.RngAffectsMult > 1
        MessageCurrentMultipliersRng.Show( \
            currentMults.MultC + SettingManager.MultAdjustRandomMinC, currentMults.MultC + SettingManager.MultAdjustRandomMaxC, \
            currentMults.MultU + SettingManager.MultAdjustRandomMinU, currentMults.MultU + SettingManager.MultAdjustRandomMaxU, \
            currentMults.MultR + SettingManager.MultAdjustRandomMinR, currentMults.MultR + SettingManager.MultAdjustRandomMaxR, \
            currentMults.MultS + SettingManager.MultAdjustRandomMinS, currentMults.MultS + SettingManager.MultAdjustRandomMaxS \
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

    If SettingManager.HasLimitedUses
        float usesRemaining = Math.Max(1.0, SettingManager.NumberOfUses - NumberOfTimesUsed)
        Self._Log("Number of uses remaining: " + usesRemaining)
        MessageUsesLeftLimited.Show(usesRemaining)
    Else
        Self._Log("Number of uses remaining: Unlimited")
        MessageUsesLeftUnlimited.Show()
    EndIf
EndFunction

; reset settings
Function ResetToDefaults()
    If ! (MutexRunning || MutexBusy)
        MutexBusy = true
        Self._Log("Resetting settings to defaults")
        SettingManager.InitSettings(abForce = true)
        SettingManager.InitSettingsSupplemental()
        SettingManager.InitSettingsDefaultValues()
        MCM.RefreshMenu()
        MutexBusy = false
        MessageSettingsReset.Show()
    ElseIf MutexRunning && ! MutexBusy
        Self._Log("Resetting settings to defaults failed due to a recycling process currently running")
        MessageSettingsResetFailRunning.Show()
    Else
        Self._Log("Resetting settings to defaults failed due to the control script being busy")
        MessageSettingsResetFailBusy.Show()
    EndIf
EndFunction

; reset the running/busy mutexes
Function ResetMutexes()
    Self._Log("Resetting Running and Busy mutexes")
    Self._Log("Current values: MutexRunning=" + MutexRunning + ", MutexBusy=" + MutexBusy)
    MutexRunning = false
    MutexBusy = false
    MessageLocksReset.Show()
EndFunction

; reset the recyclable item and low weight ratio item lists
Function ResetRecyclableItemsLists()
    If ! MutexBusy && ! MutexRunning
        MutexBusy = true
        Self._Log("Resetting recyclable item and low weight ratio item lists")
        RecyclableItemList.List.Revert()
        RecyclableItemList.Size = RecyclableItemList.List.GetSize()
        LowWeightRatioItemList.List.Revert()
        LowWeightRatioItemList.Size = LowWeightRatioItemList.List.GetSize()
        MutexBusy = false
        MessageRecyclableItemsListsReset.Show()
    ElseIf MutexBusy && ! MutexRunning
        Self._Log("Failed to reset recyclable item and low weight ratio item lists: Control script busy")
        MessageRecyclableItemsListsResetFailBusy.Show()
    ElseIf MutexRunning
        Self._Log("Failed to reset recyclable item and low weight ratio item lists: Recycling process running")
        MessageRecyclableItemsListsResetFailRunning.Show()
    EndIf
EndFunction

; reset the recyclable item list
Function ResetAlwaysAutoTransferList()
    If ! MutexBusy && ! MutexRunning
        MutexBusy = true
        Self._Log("Resetting always auto transfer list")
        AlwaysAutoTransferList.List.Revert()
        AlwaysAutoTransferList.Size = AlwaysAutoTransferList.List.GetSize()
        MutexBusy = false
        MessageAlwaysAutoTransferListReset.Show()
    ElseIf MutexBusy && ! MutexRunning
        Self._Log("Failed to reset always auto transfer list: Control script busy")
        MessageAlwaysAutoTransferListResetFailBusy.Show()
    ElseIf MutexRunning
        Self._Log("Failed to reset always auto transfer list: Recycling process running")
        MessageAlwaysAutoTransferListResetFailRunning.Show()
    EndIf
EndFunction

; reset the recyclable item list
Function ResetNeverAutoTransferList()
    If ! MutexBusy && ! MutexRunning
        MutexBusy = true
        Self._Log("Resetting never auto transfer list")
        NeverAutoTransferList.List.Revert()
        NeverAutoTransferList.Size = NeverAutoTransferList.List.GetSize()
        MutexBusy = false
        MessageNeverAutoTransferListReset.Show()
    ElseIf MutexBusy && ! MutexRunning
        Self._Log("Failed to reset never auto transfer list: Control script busy")
        MessageNeverAutoTransferListResetFailBusy.Show()
    ElseIf MutexRunning
        Self._Log("Failed to reset never auto transfer list: Recycling process running")
        MessageNeverAutoTransferListResetFailRunning.Show()
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
        Self._Log("Canary integration activated")
    EndIf
EndFunction

; returns true if the player is an an owned workshop
bool Function IsPlayerAtOwnedWorkshop()
    WorkshopScript workshopRef = WorkshopParent.GetWorkshopFromLocation(PlayerRef.GetCurrentLocation())
    Return workshopRef && workshopRef.OwnedByPlayer && PlayerRef.IsWithinBuildableArea(workshopRef)
EndFunction

; get the current multipliers
MultiplierSet Function GetMultipliers(bool abPlayerAtOwnedWorkshop)
    Self._Log("Getting multipliers")
    MultiplierSet toReturn = new MultiplierSet

    toReturn.MultC = SettingManager.MultBase
    toReturn.MultU = SettingManager.MultBase
    toReturn.MultR = SettingManager.MultBase
    toReturn.MultS = SettingManager.MultBase
    Self._Log("Base multiplier: " + SettingManager.MultBase)

    ; general
    Self._Log("Player is in an owned settlement: " + abPlayerAtOwnedWorkshop)
    If abPlayerAtOwnedWorkshop
        If SettingManager.GeneralMultAdjust == 0
            ; simple
            toReturn.MultC += SettingManager.MultAdjustGeneralSettlement
            toReturn.MultU += SettingManager.MultAdjustGeneralSettlement
            toReturn.MultR += SettingManager.MultAdjustGeneralSettlement
            toReturn.MultS += SettingManager.MultAdjustGeneralSettlement
            Self._Log("Adjustment (General: owned settlement): " + SettingManager.MultAdjustGeneralSettlement)
        Else
            ; detailed
            toReturn.MultC += SettingManager.MultAdjustGeneralSettlementC
            Self._Log("AdjustmentC (General: owned settlement): " + SettingManager.MultAdjustGeneralSettlementC)
            toReturn.MultU += SettingManager.MultAdjustGeneralSettlementU
            Self._Log("AdjustmentU (General: owned settlement): " + SettingManager.MultAdjustGeneralSettlementU)
            toReturn.MultR += SettingManager.MultAdjustGeneralSettlementR
            Self._Log("AdjustmentR (General: owned settlement): " + SettingManager.MultAdjustGeneralSettlementR)
            toReturn.MultS += SettingManager.MultAdjustGeneralSettlementS
            Self._Log("AdjustmentS (General: owned settlement): " + SettingManager.MultAdjustGeneralSettlementS)
        EndIf
    Else
        If SettingManager.GeneralMultAdjust == 0
            ; simple
            toReturn.MultC += SettingManager.MultAdjustGeneralNotSettlement
            toReturn.MultU += SettingManager.MultAdjustGeneralNotSettlement
            toReturn.MultR += SettingManager.MultAdjustGeneralNotSettlement
            toReturn.MultS += SettingManager.MultAdjustGeneralNotSettlement
            Self._Log("Adjustment (General: not owned settlement): " + SettingManager.MultAdjustGeneralNotSettlement)
        Else
            ; detailed
            toReturn.MultC += SettingManager.MultAdjustGeneralNotSettlementC
            Self._Log("AdjustmentC (General: not owned settlement): " + SettingManager.MultAdjustGeneralNotSettlementC)
            toReturn.MultU += SettingManager.MultAdjustGeneralNotSettlementU
            Self._Log("AdjustmentU (General: not owned settlement): " + SettingManager.MultAdjustGeneralNotSettlementU)
            toReturn.MultR += SettingManager.MultAdjustGeneralNotSettlementR
            Self._Log("AdjustmentR (General: not owned settlement): " + SettingManager.MultAdjustGeneralNotSettlementR)
            toReturn.MultS += SettingManager.MultAdjustGeneralNotSettlementS
            Self._Log("AdjustmentS (General: not owned settlement): " + SettingManager.MultAdjustGeneralNotSettlementS)
        EndIf
    EndIf

    ; intelligence
    If SettingManager.IntAffectsMult
        int playerInt = PlayerRef.GetValue(Game.GetIntelligenceAV()) as int
        float intAdjust
        If SettingManager.IntAffectsMult == 1
            ; simple
            intAdjust = SettingManager.MultAdjustInt * playerInt
            toReturn.MultC += intAdjust
            toReturn.MultU += intAdjust
            toReturn.MultR += intAdjust
            toReturn.MultS += intAdjust
            Self._Log("Adjustment (Intelligence): " + SettingManager.MultAdjustInt + " * " + playerInt + " = " + intAdjust)
        Else
            ; detailed
            intAdjust = SettingManager.MultAdjustIntC * playerInt
            toReturn.MultC += intAdjust
            Self._Log("AdjustmentC (Intelligence): " + SettingManager.MultAdjustIntC + " * " + playerInt + " = " + intAdjust)
            intAdjust = SettingManager.MultAdjustIntU * playerInt
            toReturn.MultU += intAdjust
            Self._Log("AdjustmentU (Intelligence): " + SettingManager.MultAdjustIntU + " * " + playerInt + " = " + intAdjust)
            intAdjust = SettingManager.MultAdjustIntR * playerInt
            toReturn.MultR += intAdjust
            Self._Log("AdjustmentR (Intelligence): " + SettingManager.MultAdjustIntR + " * " + playerInt + " = " + intAdjust)
            intAdjust = SettingManager.MultAdjustIntS * playerInt
            toReturn.MultS += intAdjust
            Self._Log("AdjustmentS (Intelligence): " + SettingManager.MultAdjustIntS + " * " + playerInt + " = " + intAdjust)
        EndIf
    EndIf

    ; luck
    If SettingManager.LckAffectsMult
        int playerLck = PlayerRef.GetValue(Game.GetLuckAV()) as int
        float lckAdjust
        If SettingManager.LckAffectsMult == 1
            ; simple
            lckAdjust = SettingManager.MultAdjustLck * playerLck
            toReturn.MultC += lckAdjust
            toReturn.MultU += lckAdjust
            toReturn.MultR += lckAdjust
            toReturn.MultS += lckAdjust
            Self._Log("Adjustment (Luck): " + SettingManager.MultAdjustLck + " * " + playerLck + " = " + lckAdjust)
        Else
            ; detailed
            lckAdjust = SettingManager.MultAdjustLckC * playerLck
            toReturn.MultC += lckAdjust
            Self._Log("AdjustmentC (Luck): " + SettingManager.MultAdjustLckC + " * " + playerLck + " = " + lckAdjust)
            lckAdjust = SettingManager.MultAdjustLckU * playerLck
            toReturn.MultU += lckAdjust
            Self._Log("AdjustmentU (Luck): " + SettingManager.MultAdjustLckU + " * " + playerLck + " = " + lckAdjust)
            lckAdjust =SettingManager. MultAdjustLckR * playerLck
            toReturn.MultR += lckAdjust
            Self._Log("AdjustmentR (Luck): " + SettingManager.MultAdjustLckR + " * " + playerLck + " = " + lckAdjust)
            lckAdjust = SettingManager.MultAdjustLckS * playerLck
            toReturn.MultS += lckAdjust
            Self._Log("AdjustmentS (Luck): " + SettingManager.MultAdjustLckS + " * " + playerLck + " = " + lckAdjust)
        EndIf
    EndIf

    ; random
    toReturn.RandomMin = SettingManager.MultAdjustRandomMin
    toReturn.RandomMax = SettingManager.MultAdjustRandomMax
    toReturn.RandomMinC = SettingManager.MultAdjustRandomMinC
    toReturn.RandomMaxC = SettingManager.MultAdjustRandomMaxC
    toReturn.RandomMinU = SettingManager.MultAdjustRandomMinU
    toReturn.RandomMaxU = SettingManager.MultAdjustRandomMaxU
    toReturn.RandomMinR = SettingManager.MultAdjustRandomMinR
    toReturn.RandomMaxR = SettingManager.MultAdjustRandomMaxR
    toReturn.RandomMinS = SettingManager.MultAdjustRandomMinS
    toReturn.RandomMaxS = SettingManager.MultAdjustRandomMaxS

    ; scrapper
    If SettingManager.ScrapperAffectsMult
        ; get the index of the player's scrapper perk (if any)
        int playerScrapperPerkIndex = -1
        int index = ScrapperPerks.Length - 1
        While index >= 0 && ! PlayerRef.HasPerk(ScrapperPerks[index])
            index -= 1
        EndWhile
        playerScrapperPerkIndex = index
        Self._Log("Player's Scrapper perk index: " + playerScrapperPerkIndex)

        If playerScrapperPerkIndex >= 0
            If abPlayerAtOwnedWorkshop
                If SettingManager.ScrapperAffectsMult == 1
                    ; simple
                    toReturn.MultC += SettingManager.MultAdjustScrapperSettlement[playerScrapperPerkIndex]
                    toReturn.MultU += SettingManager.MultAdjustScrapperSettlement[playerScrapperPerkIndex]
                    toReturn.MultR += SettingManager.MultAdjustScrapperSettlement[playerScrapperPerkIndex]
                    toReturn.MultS += SettingManager.MultAdjustScrapperSettlement[playerScrapperPerkIndex]
                    Self._Log("Adjustment (Scrapper: owned settlement): " \
                        + SettingManager.MultAdjustScrapperSettlement[playerScrapperPerkIndex])
                Else
                    ; detailed
                    toReturn.MultC += SettingManager.MultAdjustScrapperSettlementC[playerScrapperPerkIndex]
                    Self._Log("AdjustmentC (Scrapper: owned settlement): " \
                        + SettingManager.MultAdjustScrapperSettlementC[playerScrapperPerkIndex])
                    toReturn.MultU += SettingManager.MultAdjustScrapperSettlementU[playerScrapperPerkIndex]
                    Self._Log("AdjustmentU (Scrapper: owned settlement): " \
                        + SettingManager.MultAdjustScrapperSettlementU[playerScrapperPerkIndex])
                    toReturn.MultR += SettingManager.MultAdjustScrapperSettlementR[playerScrapperPerkIndex]
                    Self._Log("AdjustmentR (Scrapper: owned settlement): " \
                        + SettingManager.MultAdjustScrapperSettlementR[playerScrapperPerkIndex])
                    toReturn.MultS += SettingManager.MultAdjustScrapperSettlementS[playerScrapperPerkIndex]
                    Self._Log("AdjustmentS (Scrapper: owned settlement): " \
                        + SettingManager.MultAdjustScrapperSettlementS[playerScrapperPerkIndex])
                EndIf
            Else
                If SettingManager.ScrapperAffectsMult == 1
                    ; simple
                    toReturn.MultC += SettingManager.MultAdjustScrapperNotSettlement[playerScrapperPerkIndex]
                    toReturn.MultU += SettingManager.MultAdjustScrapperNotSettlement[playerScrapperPerkIndex]
                    toReturn.MultR += SettingManager.MultAdjustScrapperNotSettlement[playerScrapperPerkIndex]
                    toReturn.MultS += SettingManager.MultAdjustScrapperNotSettlement[playerScrapperPerkIndex]
                    Self._Log("Adjustment (Scrapper: not owned settlement): " \
                        + SettingManager.MultAdjustScrapperNotSettlement[playerScrapperPerkIndex])
                Else
                    ; detailed
                    toReturn.MultC += SettingManager.MultAdjustScrapperNotSettlementC[playerScrapperPerkIndex]
                    Self._Log("AdjustmentC (Scrapper: not owned settlement): " \
                        + SettingManager.MultAdjustScrapperNotSettlementC[playerScrapperPerkIndex])
                    toReturn.MultU += SettingManager.MultAdjustScrapperNotSettlementU[playerScrapperPerkIndex]
                    Self._Log("AdjustmentU (Scrapper: not owned settlement): " \
                        + SettingManager.MultAdjustScrapperNotSettlementU[playerScrapperPerkIndex])
                    toReturn.MultR += SettingManager.MultAdjustScrapperNotSettlementR[playerScrapperPerkIndex]
                    Self._Log("AdjustmentR (Scrapper: not owned settlement): " \
                        + SettingManager.MultAdjustScrapperNotSettlementR[playerScrapperPerkIndex])
                    toReturn.MultS += SettingManager.MultAdjustScrapperNotSettlementS[playerScrapperPerkIndex]
                    Self._Log("AdjustmentS (Scrapper: not owned settlement): " \
                        + SettingManager.MultAdjustScrapperNotSettlementS[playerScrapperPerkIndex])
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
        MutexBusy = true
        Self._Log("Uninstallation sequence initialized!", 1, abForce = true)

        ; unregister from all events
        UnregisterForRemoteEvent(PlayerRef, "OnPlayerLoadGame")
        UnregisterForKey(LAlt)
        UnregisterForKey(RAlt)
        UnregisterForKey(LCtrl)
        UnregisterForKey(RCtrl)
        UnregisterForKey(LShift)
        UnregisterForKey(RShift)

        ; shut down the ThreadManager
        ThreadManager.Uninstall()
        ; shut down the SettingManager
        SettingManager.Uninstall()

        ; remove recycler devices in inventory, if any
        PlayerRef.RemoveItem(Game.GetFormFromFile(0x840, SettingManager.ModName + ".esp"), -1, true)

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

        ; group RuntimeState
        DestroyArrayContents(ScrapperPerks as var[])
        ScrapperPerks = None

        ; local variables
        AvailableChangeTypes = None

        ; show uninstalled message
        MessageUninstalled.Show()
        MessageUninstalled = None

        ; stop the quest
        Stop()

        Self._Log("Uninstallation sequence complete!", 1, abForce = true)

        ; finish clearing out references to other scripts
        ThreadManager = None
        SettingManager = None
    ElseIf MutexRunning && ! MutexBusy
        ; fail (running)
        MessageUninstallFailRunning.Show()
    Else
        ; fail (busy)
        MessageUninstallFailBusy.Show()
    EndIf
EndFunction
