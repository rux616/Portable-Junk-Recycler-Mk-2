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

Group Other
    Actor Property PlayerRef Auto Mandatory
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
    Message Property MessageRecyclableItemListReset Auto Mandatory
    Message Property MessageRecyclableItemListResetFailBusy Auto Mandatory
    Message Property MessageRecyclableItemListResetFailRunning Auto Mandatory
    Message Property MessageBehaviorOverridesReset Auto Mandatory
    Message Property MessageUninstalled Auto Mandatory
    WorkshopParentScript Property WorkshopParent Auto Mandatory
    { the workshop parent script
      enables this script to determine whether its in a player-owned settlement or not }

    FormListWrapper Property RecyclableItemList Auto Mandatory
    int Property LShift = 160 AutoReadOnly Hidden
    int Property LCtrl = 162 AutoReadOnly Hidden
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

    bool Property BehaviorOverrideForceMoveJunk Auto Hidden
    bool Property BehaviorOverrideForceNotMoveJunk Auto Hidden
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

    ; settings - recycler behavior
    SettingBool Property AutoRecyclingMode Auto Hidden
    SettingBool Property AllowJunkOnly Auto Hidden
    SettingBool Property AutoMoveJunk Auto Hidden
    SettingBool Property AllowBehaviorOverrides Auto Hidden
    SettingBool Property ReturnItemsSilently Auto Hidden

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
EndGroup

int Property iSaveFileMonitor Auto Hidden ; Do not mess with ever - this is used by Canary to track data loss
{ Canary support
  https://www.nexusmods.com/fallout4/mods/44949 }



; VARIABLES
; ---------

string ModName = "Portable Junk Recycler Mk 2" const
string ModVersion = "0.4.0 beta" const
string FullScriptName = "PortableJunkRecyclerMk2:ControlScript" const
int ScrapperPerkMaxRanksSupported = 5 const
SettingChangeType AvailableChangeTypes
int CurrentChangeType
int MaxThreads = 16 const
var[] Threads = None



; EVENTS
; ------

Event OnQuestInit()
    MutexBusy = true
    Debug.StartStackProfiling()
    Debug.OpenUserLog(ModName)
    Self._DebugTrace(modName + " v" + ModVersion)
    Self._DebugTrace("Beginning onetime init process")
    Self.CheckForCanary()
    Self.InitVariables(abForce = true)
    Self.CheckForF4SE()
    Self.CheckForMCM()
    Self.InitSettings(abForce = true)
    Self.InitSettingsSupplemental()
    Self.InitFormListWrappers()
    Self.InitComponentMappings()
    Self.InitScrapListAll()
    Self.InitScrapperPerks()
    Self.LoadAllSettingsFromMCM()
    RegisterForRemoteEvent(PlayerRef, "OnPlayerLoadGame")
    Self.RegisterForMCMEvents()
    If ! ModConfigMenuInstalled
        Self.InitSettingsDefaultValues()
    EndIf
    Self.RegisterForMenuOpenCloseEvent("PauseMenu")
    MessageInitialized.Show()
    Self._DebugTrace("Finished onetime init process")
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
    float waitTime = 3.0
    While (MutexRunning || MutexBusy) && waitTimeLeft > 0
    MutexWaiting = true
    Self._DebugTrace("OnPlayerLoadGame: Waiting on mutex release. Time left = " + waitTimeLeft)
    Utility.Wait(waitTime)
    waitTimeLeft -= waitTime as int
    EndWhile

    ; lock function in case user exits game while recycling process is running or this same function is running
    If ! (MutexRunning || MutexBusy)
        MutexBusy = true
        Self._DebugTrace(modName + " v" + ModVersion)
        Self._DebugTrace("Beginning runtime init process")
        Self.CheckForCanary()
        Self.InitVariables()
        Self.CheckForF4SE()
        Self.CheckForMCM()
        Self.InitSettings()
        Self.InitSettingsSupplemental()
        Self.InitFormListWrappers()
        Self.InitComponentMappings()
        Self.InitScrapListAll()
        Self.InitScrapperPerks()
        Self.LoadAllSettingsFromMCM()
        Self.RegisterForMCMEvents()
        Self._DebugTrace("Finished runtime init process")
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
    If AllowBehaviorOverrides.Value
        If aiKeyCode == LShift
            Self._DebugTrace("OnKeyDown: LShift (" + LShift + ")")
            BehaviorOverrideForceMoveJunk = true
        ElseIf aiKeyCode == LCtrl
            Self._DebugTrace("OnKeyDown: LCtrl (" + LCtrl + ")")
            BehaviorOverrideForceNotMoveJunk = true
        EndIf
    EndIf
EndEvent

Event OnKeyUp(int aiKeyCode, float afTime)
    If AllowBehaviorOverrides.Value
        If aiKeyCode == LShift
            Self._DebugTrace("OnKeyUp: LShift (" + LShift + ")")
            BehaviorOverrideForceMoveJunk = false
        ElseIf aiKeyCode == LCtrl
            Self._DebugTrace("OnKeyUp: LCtrl (" + LCtrl + ")")
            BehaviorOverrideForceNotMoveJunk = false
        EndIf
    EndIf
EndEvent



; FUNCTIONS
; ---------

; add a bit of text to traces going into the papyrus user log
Function _DebugTrace(string asMessage, int aiSeverity = 0) DebugOnly
    Debug.TraceUser(ModName, "QuestScript: " + asMessage, aiSeverity)
EndFunction

; initialize script-internal variables
Function InitVariables(bool abForce = false)
    Self._DebugTrace("Initializing variables")
    If abForce || ! AvailableChangeTypes
        Self._DebugTrace("Initializing AvailableChangeTypes")
        AvailableChangeTypes = new SettingChangeType
    EndIf

    If abForce || Threads == None || Threads.Length != MaxThreads
        Self._DebugTrace("Initializing Threads")
        Threads = new var[MaxThreads]
        Threads[0x0] = (Self as Quest) as WorkerThread0x0
        Threads[0x1] = (Self as Quest) as WorkerThread0x1
        Threads[0x2] = (Self as Quest) as WorkerThread0x2
        Threads[0x3] = (Self as Quest) as WorkerThread0x3
        Threads[0x4] = (Self as Quest) as WorkerThread0x4
        Threads[0x5] = (Self as Quest) as WorkerThread0x5
        Threads[0x6] = (Self as Quest) as WorkerThread0x6
        Threads[0x7] = (Self as Quest) as WorkerThread0x7
        Threads[0x8] = (Self as Quest) as WorkerThread0x8
        Threads[0x9] = (Self as Quest) as WorkerThread0x9
        Threads[0xA] = (Self as Quest) as WorkerThread0xA
        Threads[0xB] = (Self as Quest) as WorkerThread0xB
        Threads[0xC] = (Self as Quest) as WorkerThread0xC
        Threads[0xD] = (Self as Quest) as WorkerThread0xD
        Threads[0xE] = (Self as Quest) as WorkerThread0xE
        Threads[0xF] = (Self as Quest) as WorkerThread0xF
    EndIf
EndFunction

; check to see if F4SE is installed
Function CheckForF4SE()
    Debug.Trace("PortableJunkRecyclerMk2:QuestScript: Checking if F4SE is installed...")
    Self._DebugTrace("Checking if F4SE is installed...")
    ScriptExtenderInstalled = F4SE.GetVersionRelease() as bool
    If ScriptExtenderInstalled
        Debug.Trace("PortableJunkRecyclerMk2:QuestScript: F4SE installed")
        Self._DebugTrace("F4SE v" + F4SE.GetVersion() + "." + F4SE.GetVersionMinor() + "." + F4SE.GetVersionBeta() + "." + \
            F4SE.GetVersionRelease() + " installed (script version " + F4SE.GetScriptVersionRelease() + ")")
    Else
        Debug.Trace("PortableJunkRecyclerMk2:QuestScript: F4SE not installed", 1)
        Self._DebugTrace("F4SE not installed", 1)
        MessageF4SENotInstalled.Show()
    EndIf
EndFunction

; check to see if MCM is installed; depends on F4SE
Function CheckForMCM()
    Debug.Trace("PortableJunkRecyclerMk2:QuestScript: Checking if MCM is installed...")
    Self._DebugTrace("Checking if MCM is installed...")
    ModConfigMenuInstalled = MCM.IsInstalled() as bool
    If ModConfigMenuInstalled && ScriptExtenderInstalled
        Debug.Trace("PortableJunkRecyclerMk2:QuestScript: MCM installed")
        Self._DebugTrace("MCM installed (version code " + MCM.GetVersionCode() + ")")
        CurrentChangeType = AvailableChangeTypes.Both
    ElseIf ModConfigMenuInstalled && ! ScriptExtenderInstalled
        Debug.Trace("PortableJunkRecyclerMk2:QuestScript: MCM installed, but F4SE is not; disabling support")
        Self._DebugTrace("MCM installed, but F4SE is not; disabling support")
        ModConfigMenuInstalled = false
        CurrentChangeType = AvailableChangeTypes.ValueOnly
    Else
        Debug.Trace("PortableJunkRecyclerMk2:QuestScript: MCM not installed")
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

    ; settings - recycler behavior
    If abForce || ! AutoRecyclingMode
        Self._DebugTrace("Initializing AutoRecyclingMode")
        AutoRecyclingMode = new SettingBool
    EndIf
    If abForce || ! AllowJunkOnly
        Self._DebugTrace("Initializing AllowJunkOnly")
        AllowJunkOnly = new SettingBool
    EndIf
    If abForce || ! AutoMoveJunk
        Self._DebugTrace("Initializing AutoMoveJunk")
        AutoMoveJunk = new SettingBool
    EndIf
    If abForce || ! AllowBehaviorOverrides
        Self._DebugTrace("Initializing AllowBehaviorOverrides")
        AllowBehaviorOverrides = new SettingBool
    EndIf
    If abForce || ! ReturnItemsSilently
        Self._DebugTrace("Initializing ReturnItemsSilently")
        ReturnItemsSilently = new SettingBool
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
EndFunction

; perform supplemental initialization on properties that hold settings
Function InitSettingsSupplemental()
    Self._DebugTrace("Initializing settings (supplemental)")

    ; settings - general
    MultBase.ValueDefault = 1.0
    MultBase.McmId = "fMultBase:General"
    MultBase.ValueMin = 0.0
    MultBase.ValueMax = 2.0

    ReturnAtLeastOneComponent.ValueDefault = true
    ReturnAtLeastOneComponent.McmId = "bReturnAtLeastOneComponent:General"

    FractionalComponentHandling.ValueDefault = 2
    FractionalComponentHandling.McmId = "iFractionalComponentHandling:General"
    FractionalComponentHandling.ValueMin = 0
    FractionalComponentHandling.ValueMax = 2

    HasLimitedUses.ValueDefault = false
    HasLimitedUses.McmId = "bHasLimitedUses:General"

    NumberOfUses.ValueDefault = 50
    NumberOfUses.McmId = "iNumberOfUses:General"
    NumberOfUses.ValueMin = 1
    NumberOfUses.ValueMax = 200

    ; settings - adjustment options
    GeneralMultAdjust.ValueDefault = 0
    GeneralMultAdjust.McmId = "iGeneralMultAdjust:General"
    GeneralMultAdjust.ValueMin = 0
    GeneralMultAdjust.ValueMax = 1

    IntAffectsMult.ValueDefault = 1
    IntAffectsMult.McmId = "iIntAffectsMult:General"
    IntAffectsMult.ValueMin = 0
    IntAffectsMult.ValueMax = 2

    LckAffectsMult.ValueDefault = 1
    LckAffectsMult.McmId = "iLckAffectsMult:General"
    LckAffectsMult.ValueMin = 0
    LckAffectsMult.ValueMax = 2

    RngAffectsMult.ValueDefault = 0
    RngAffectsMult.McmId = "iRngAffectsMult:General"
    RngAffectsMult.ValueMin = 0
    RngAffectsMult.ValueMax = 2

    ScrapperAffectsMult.ValueDefault = 1
    ScrapperAffectsMult.McmId = "iScrapperAffectsMult:General"
    ScrapperAffectsMult.ValueMin = 0
    ScrapperAffectsMult.ValueMax = 2

    ; settings - recycler behavior
    AutoRecyclingMode.ValueDefault = false
    AutoRecyclingMode.McmId = "bAutoRecyclingMode:General"

    AllowJunkOnly.ValueDefault = true
    AllowJunkOnly.McmId = "bAllowJunkOnly:General"

    AutoMoveJunk.ValueDefault = true
    AutoMoveJunk.McmId = "bAutoMoveJunk:General"

    AllowBehaviorOverrides.ValueDefault = true
    AllowBehaviorOverrides.McmId = "bAllowBehaviorOverrides:General"

    ReturnItemsSilently.ValueDefault = true
    ReturnItemsSilently.McmId = "bReturnItemsSilently:General"

    ; multiplier adjustments - general
    MultAdjustGeneralSettlement.ValueDefault = 0.0
    MultAdjustGeneralSettlement.McmId = "fMultAdjustGeneralSettlement:Adjustments"
    MultAdjustGeneralSettlement.ValueMin = -1.0
    MultAdjustGeneralSettlement.ValueMax = 1.0

    MultAdjustGeneralSettlementC.ValueDefault = 0.0
    MultAdjustGeneralSettlementC.McmId = "fMultAdjustGeneralSettlementC:Adjustments"
    MultAdjustGeneralSettlementC.ValueMin = -1.0
    MultAdjustGeneralSettlementC.ValueMax = 1.0

    MultAdjustGeneralSettlementU.ValueDefault = 0.0
    MultAdjustGeneralSettlementU.McmId = "fMultAdjustGeneralSettlementU:Adjustments"
    MultAdjustGeneralSettlementU.ValueMin = -1.0
    MultAdjustGeneralSettlementU.ValueMax = 1.0

    MultAdjustGeneralSettlementR.ValueDefault = 0.0
    MultAdjustGeneralSettlementR.McmId = "fMultAdjustGeneralSettlementR:Adjustments"
    MultAdjustGeneralSettlementR.ValueMin = -1.0
    MultAdjustGeneralSettlementR.ValueMax = 1.0

    MultAdjustGeneralSettlementS.ValueDefault = 0.0
    MultAdjustGeneralSettlementS.McmId = "fMultAdjustGeneralSettlementS:Adjustments"
    MultAdjustGeneralSettlementS.ValueMin = -1.0
    MultAdjustGeneralSettlementS.ValueMax = 1.0

    MultAdjustGeneralNotSettlement.ValueDefault = 0.0
    MultAdjustGeneralNotSettlement.McmId = "fMultAdjustGeneralNotSettlement:Adjustments"
    MultAdjustGeneralNotSettlement.ValueMin = -1.0
    MultAdjustGeneralNotSettlement.ValueMax = 1.0

    MultAdjustGeneralNotSettlementC.ValueDefault = 0.0
    MultAdjustGeneralNotSettlementC.McmId = "fMultAdjustGeneralNotSettlementC:Adjustments"
    MultAdjustGeneralNotSettlementC.ValueMin = -1.0
    MultAdjustGeneralNotSettlementC.ValueMax = 1.0

    MultAdjustGeneralNotSettlementU.ValueDefault = 0.0
    MultAdjustGeneralNotSettlementU.McmId = "fMultAdjustGeneralNotSettlementU:Adjustments"
    MultAdjustGeneralNotSettlementU.ValueMin = -1.0
    MultAdjustGeneralNotSettlementU.ValueMax = 1.0

    MultAdjustGeneralNotSettlementR.ValueDefault = 0.0
    MultAdjustGeneralNotSettlementR.McmId = "fMultAdjustGeneralNotSettlementR:Adjustments"
    MultAdjustGeneralNotSettlementR.ValueMin = -1.0
    MultAdjustGeneralNotSettlementR.ValueMax = 1.0

    MultAdjustGeneralNotSettlementS.ValueDefault = 0.0
    MultAdjustGeneralNotSettlementS.McmId = "fMultAdjustGeneralNotSettlementS:Adjustments"
    MultAdjustGeneralNotSettlementS.ValueMin = -1.0
    MultAdjustGeneralNotSettlementS.ValueMax = 1.0

    ; multiplier adjustments - intelligence
    MultAdjustInt.ValueDefault = 0.01
    MultAdjustInt.McmId = "fMultAdjustInt:Adjustments"
    MultAdjustInt.ValueMin = 0.0
    MultAdjustInt.ValueMax = 1.0

    MultAdjustIntC.ValueDefault = 0.01
    MultAdjustIntC.McmId = "fMultAdjustIntC:Adjustments"
    MultAdjustIntC.ValueMin = 0.0
    MultAdjustIntC.ValueMax = 1.0

    MultAdjustIntU.ValueDefault = 0.01
    MultAdjustIntU.McmId = "fMultAdjustIntU:Adjustments"
    MultAdjustIntU.ValueMin = 0.0
    MultAdjustIntU.ValueMax = 1.0

    MultAdjustIntR.ValueDefault = 0.01
    MultAdjustIntR.McmId = "fMultAdjustIntR:Adjustments"
    MultAdjustIntR.ValueMin = 0.0
    MultAdjustIntR.ValueMax = 1.0

    MultAdjustIntS.ValueDefault = 0.0
    MultAdjustIntS.McmId = "fMultAdjustIntS:Adjustments"
    MultAdjustIntS.ValueMin = 0.0
    MultAdjustIntS.ValueMax = 1.0

    ; multiplier adjustments - luck
    MultAdjustLck.ValueDefault = 0.01
    MultAdjustLck.McmId = "fMultAdjustLck:Adjustments"
    MultAdjustLck.ValueMin = 0.0
    MultAdjustLck.ValueMax = 1.0

    MultAdjustLckC.ValueDefault = 0.01
    MultAdjustLckC.McmId = "fMultAdjustLckC:Adjustments"
    MultAdjustLckC.ValueMin = 0.0
    MultAdjustLckC.ValueMax = 1.0

    MultAdjustLckU.ValueDefault = 0.01
    MultAdjustLckU.McmId = "fMultAdjustLckU:Adjustments"
    MultAdjustLckU.ValueMin = 0.0
    MultAdjustLckU.ValueMax = 1.0

    MultAdjustLckR.ValueDefault = 0.01
    MultAdjustLckR.McmId = "fMultAdjustLckR:Adjustments"
    MultAdjustLckR.ValueMin = 0.0
    MultAdjustLckR.ValueMax = 1.0

    MultAdjustLckS.ValueDefault = 0.0
    MultAdjustLckS.McmId = "fMultAdjustLckS:Adjustments"
    MultAdjustLckS.ValueMin = 0.0
    MultAdjustLckS.ValueMax = 1.0

    ; multiplier adjustments - randomness
    MultAdjustRandomMin.ValueDefault = -0.1
    MultAdjustRandomMin.McmId = "fMultAdjustRandomMin:Adjustments"
    MultAdjustRandomMin.ValueMin = -1.0
    MultAdjustRandomMin.ValueMax = 1.0

    MultAdjustRandomMinC.ValueDefault = -0.1
    MultAdjustRandomMinC.McmId = "fMultAdjustRandomMinC:Adjustments"
    MultAdjustRandomMinC.ValueMin = -1.0
    MultAdjustRandomMinC.ValueMax = 1.0

    MultAdjustRandomMinU.ValueDefault = -0.1
    MultAdjustRandomMinU.McmId = "fMultAdjustRandomMinU:Adjustments"
    MultAdjustRandomMinU.ValueMin = -1.0
    MultAdjustRandomMinU.ValueMax = 1.0

    MultAdjustRandomMinR.ValueDefault = -0.1
    MultAdjustRandomMinR.McmId = "fMultAdjustRandomMinR:Adjustments"
    MultAdjustRandomMinR.ValueMin = -1.0
    MultAdjustRandomMinR.ValueMax = 1.0

    MultAdjustRandomMinS.ValueDefault = 0.0
    MultAdjustRandomMinS.McmId = "fMultAdjustRandomMinS:Adjustments"
    MultAdjustRandomMinS.ValueMin = -1.0
    MultAdjustRandomMinS.ValueMax = 1.0

    MultAdjustRandomMax.ValueDefault = 0.1
    MultAdjustRandomMax.McmId = "fMultAdjustRandomMax:Adjustments"
    MultAdjustRandomMax.ValueMin = -1.0
    MultAdjustRandomMax.ValueMax = 1.0

    MultAdjustRandomMaxC.ValueDefault = 0.1
    MultAdjustRandomMaxC.McmId = "fMultAdjustRandomMaxC:Adjustments"
    MultAdjustRandomMaxC.ValueMin = -1.0
    MultAdjustRandomMaxC.ValueMax = 1.0

    MultAdjustRandomMaxU.ValueDefault = 0.1
    MultAdjustRandomMaxU.McmId = "fMultAdjustRandomMaxU:Adjustments"
    MultAdjustRandomMaxU.ValueMin = -1.0
    MultAdjustRandomMaxU.ValueMax = 1.0

    MultAdjustRandomMaxR.ValueDefault = 0.1
    MultAdjustRandomMaxR.McmId = "fMultAdjustRandomMaxR:Adjustments"
    MultAdjustRandomMaxR.ValueMin = -1.0
    MultAdjustRandomMaxR.ValueMax = 1.0

    MultAdjustRandomMaxS.ValueDefault = 0.0
    MultAdjustRandomMaxS.McmId = "fMultAdjustRandomMaxS:Adjustments"
    MultAdjustRandomMaxS.ValueMin = -1.0
    MultAdjustRandomMaxS.ValueMax = 1.0

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
        MultAdjustScrapperSettlement[index].McmId = "fMultAdjustScrapperSettlement" + (index+1) + ":Adjustments"
        MultAdjustScrapperSettlement[index].ValueMin = -1.0
        MultAdjustScrapperSettlement[index].ValueMax = 1.0

        MultAdjustScrapperSettlementC[index].ValueDefault = scrapperSettlementDefaults[index]
        MultAdjustScrapperSettlementC[index].McmId = "fMultAdjustScrapperSettlementC" + (index+1) + ":Adjustments"
        MultAdjustScrapperSettlementC[index].ValueMin = -1.0
        MultAdjustScrapperSettlementC[index].ValueMax = 1.0

        MultAdjustScrapperSettlementU[index].ValueDefault = scrapperSettlementDefaults[index]
        MultAdjustScrapperSettlementU[index].McmId = "fMultAdjustScrapperSettlementU" + (index+1) + ":Adjustments"
        MultAdjustScrapperSettlementU[index].ValueMin = -1.0
        MultAdjustScrapperSettlementU[index].ValueMax = 1.0

        MultAdjustScrapperSettlementR[index].ValueDefault = scrapperSettlementDefaults[index]
        MultAdjustScrapperSettlementR[index].McmId = "fMultAdjustScrapperSettlementR" + (index+1) + ":Adjustments"
        MultAdjustScrapperSettlementR[index].ValueMin = -1.0
        MultAdjustScrapperSettlementR[index].ValueMax = 1.0

        MultAdjustScrapperSettlementS[index].ValueDefault = 0.0
        MultAdjustScrapperSettlementS[index].McmId = "fMultAdjustScrapperSettlementS" + (index+1) + ":Adjustments"
        MultAdjustScrapperSettlementS[index].ValueMin = -1.0
        MultAdjustScrapperSettlementS[index].ValueMax = 1.0

        MultAdjustScrapperNotSettlement[index].ValueDefault = 0.0
        MultAdjustScrapperNotSettlement[index].McmId = "fMultAdjustScrapperNotSettlement" + (index+1) + ":Adjustments"
        MultAdjustScrapperNotSettlement[index].ValueMin = -1.0
        MultAdjustScrapperNotSettlement[index].ValueMax = 1.0

        MultAdjustScrapperNotSettlementC[index].ValueDefault = 0.0
        MultAdjustScrapperNotSettlementC[index].McmId = "fMultAdjustScrapperNotSettlementC" + (index+1) + ":Adjustments"
        MultAdjustScrapperNotSettlementC[index].ValueMin = -1.0
        MultAdjustScrapperNotSettlementC[index].ValueMax = 1.0

        MultAdjustScrapperNotSettlementU[index].ValueDefault = 0.0
        MultAdjustScrapperNotSettlementU[index].McmId = "fMultAdjustScrapperNotSettlementU" + (index+1) + ":Adjustments"
        MultAdjustScrapperNotSettlementU[index].ValueMin = -1.0
        MultAdjustScrapperNotSettlementU[index].ValueMax = 1.0

        MultAdjustScrapperNotSettlementR[index].ValueDefault = 0.0
        MultAdjustScrapperNotSettlementR[index].McmId = "fMultAdjustScrapperNotSettlementR" + (index+1) + ":Adjustments"
        MultAdjustScrapperNotSettlementR[index].ValueMin = -1.0
        MultAdjustScrapperNotSettlementR[index].ValueMax = 1.0

        MultAdjustScrapperNotSettlementS[index].ValueDefault = 0.0
        MultAdjustScrapperNotSettlementS[index].McmId = "fMultAdjustScrapperNotSettlementS" + (index+1) + ":Adjustments"
        MultAdjustScrapperNotSettlementS[index].ValueMin = -1.0
        MultAdjustScrapperNotSettlementS[index].ValueMax = 1.0

        index += 1
    EndWhile
EndFunction

; reset values of properties that hold settings to their defaults
Function InitSettingsDefaultValues()
    Self._DebugTrace("Initializing settings (default values)")

    var[] settingsToChange = new var[0]

    ; settings - general
    settingsToChange.Add(MultBase)
    settingsToChange.Add(ReturnAtLeastOneComponent)
    settingsToChange.Add(FractionalComponentHandling)
    settingsToChange.Add(HasLimitedUses)
    settingsToChange.Add(NumberOfUses)

    ; settings - adjustment options
    settingsToChange.Add(GeneralMultAdjust)
    settingsToChange.Add(IntAffectsMult)
    settingsToChange.Add(LckAffectsMult)
    settingsToChange.Add(RngAffectsMult)
    settingsToChange.Add(ScrapperAffectsMult)

    ; settings - recycler behavior
    settingsToChange.Add(AutoRecyclingMode)
    settingsToChange.Add(AllowJunkOnly)
    settingsToChange.Add(AutoMoveJunk)
    settingsToChange.Add(AllowBehaviorOverrides)
    settingsToChange.Add(ReturnItemsSilently)

    ; multiplier adjustments - general
    settingsToChange.Add(MultAdjustGeneralSettlement)
    settingsToChange.Add(MultAdjustGeneralSettlementC)
    settingsToChange.Add(MultAdjustGeneralSettlementU)
    settingsToChange.Add(MultAdjustGeneralSettlementR)
    settingsToChange.Add(MultAdjustGeneralSettlementS)

    settingsToChange.Add(MultAdjustGeneralNotSettlement)
    settingsToChange.Add(MultAdjustGeneralNotSettlementC)
    settingsToChange.Add(MultAdjustGeneralNotSettlementU)
    settingsToChange.Add(MultAdjustGeneralNotSettlementR)
    settingsToChange.Add(MultAdjustGeneralNotSettlementS)

    ; multiplier adjustments - intelligence
    settingsToChange.Add(MultAdjustInt)
    settingsToChange.Add(MultAdjustIntC)
    settingsToChange.Add(MultAdjustIntU)
    settingsToChange.Add(MultAdjustIntR)
    settingsToChange.Add(MultAdjustIntS)

    ; multiplier adjustments - luck
    settingsToChange.Add(MultAdjustLck)
    settingsToChange.Add(MultAdjustLckC)
    settingsToChange.Add(MultAdjustLckU)
    settingsToChange.Add(MultAdjustLckR)
    settingsToChange.Add(MultAdjustLckS)

    ; multiplier adjustments - randomness
    settingsToChange.Add(MultAdjustRandomMin)
    settingsToChange.Add(MultAdjustRandomMinC)
    settingsToChange.Add(MultAdjustRandomMinU)
    settingsToChange.Add(MultAdjustRandomMinR)
    settingsToChange.Add(MultAdjustRandomMinS)

    settingsToChange.Add(MultAdjustRandomMax)
    settingsToChange.Add(MultAdjustRandomMaxC)
    settingsToChange.Add(MultAdjustRandomMaxU)
    settingsToChange.Add(MultAdjustRandomMaxR)
    settingsToChange.Add(MultAdjustRandomMaxS)

    ; multiplier adjustments - scrapper 1-5
    int index = 0
    While index < ScrapperPerkMaxRanksSupported
        settingsToChange.Add(MultAdjustScrapperSettlement[index])
        settingsToChange.Add(MultAdjustScrapperSettlementC[index])
        settingsToChange.Add(MultAdjustScrapperSettlementU[index])
        settingsToChange.Add(MultAdjustScrapperSettlementR[index])
        settingsToChange.Add(MultAdjustScrapperSettlementS[index])

        settingsToChange.Add(MultAdjustScrapperNotSettlement[index])
        settingsToChange.Add(MultAdjustScrapperNotSettlementC[index])
        settingsToChange.Add(MultAdjustScrapperNotSettlementU[index])
        settingsToChange.Add(MultAdjustScrapperNotSettlementR[index])
        settingsToChange.Add(MultAdjustScrapperNotSettlementS[index])

        index += 1
    EndWhile

    ; create array to hold function arguments
    var[] params = new var[5]
    params[0] = Utility.VarArrayToVar(settingsToChange as var[]) as var
    params[3] = CurrentChangeType as int
    params[4] = ModName as string

    ; set up multithreading parameters
    string functionToCall = "ChangeSettingsToDefaults"
    int numItems = settingsToChange.Length
    int numThreads = Math.Min(numItems, MaxThreads) as int
    float numItemsPerThread
    If numThreads
        numItemsPerThread = numItems as float / numThreads
    EndIf
    Self._DebugTrace("Changing " + numItems + " settings to defaults; Using " + numThreads + " threads for processing (" + \
        numItemsPerThread + " settings per thread)")

    ; start multithreading
    index = 0
    While index < numThreads
        params[1] = (index * numItemsPerThread) as int
        params[2] = ((index + 1) * numItemsPerThread) as int - 1
        (Threads[index] as ScriptObject).CallFunctionNoWait(functionToCall, params)
        Self._DebugTrace("Called thread " + index + " (" + functionToCall + "): Index (Start) = " + params[1] + \
            ", Index (End) = " + params[2])
        index += 1
    EndWhile

    ; wait for multithreading to finish
    Self.WaitForThreads(Threads, numThreads)

    ; perform general post-processing
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
    If AllowBehaviorOverrides.Value
        RegisterForKey(LShift)
        RegisterForKey(LCtrl)
    Else
        UnregisterForKey(LShift)
        UnregisterForKey(LCtrl)
        BehaviorOverrideForceMoveJunk = false
        BehaviorOverrideForceNotMoveJunk = false
    EndIf
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
    string functionToCall = "BuildComponentMap"
    var[] params = new var[2]
    params[0] = ComponentListC
    params[1] = ScrapListC
    Self._DebugTrace("Initializing componentMapC")
    (Threads[0x0] as ScriptObject).CallFunctionNoWait(functionToCall, params)
    params[0] = ComponentListU
    params[1] = ScrapListU
    Self._DebugTrace("Initializing componentMapU")
    (Threads[0x1] as ScriptObject).CallFunctionNoWait(functionToCall, params)
    params[0] = ComponentListR
    params[1] = ScrapListR
    Self._DebugTrace("Initializing componentMapR")
    (Threads[0x2] as ScriptObject).CallFunctionNoWait(functionToCall, params)
    params[0] = ComponentListS
    params[1] = ScrapListS
    Self._DebugTrace("Initializing componentMapS")
    (Threads[0x3] as ScriptObject).CallFunctionNoWait(functionToCall, params)

    Self.WaitForThreads(Threads, 4)

    ComponentMap[] componentMapC = (Threads[0x0] as WorkerThreadBase).GetResults() as ComponentMap[]
    ComponentMap[] componentMapU = (Threads[0x1] as WorkerThreadBase).GetResults() as ComponentMap[]
    ComponentMap[] componentMapR = (Threads[0x2] as WorkerThreadBase).GetResults() as ComponentMap[]
    ComponentMap[] componentMapS = (Threads[0x3] as WorkerThreadBase).GetResults() as ComponentMap[]

    ; combine the component maps
    ComponentMappings = new ComponentMap[0]
    ComponentMap tempCMap
    int index = 0
    While index < componentMapC.Length
        tempCMap = new ComponentMap
        tempCMap.ComponentPart = componentMapC[index].ComponentPart
        tempCMap.ComponentPartName = componentMapC[index].ComponentPartName
        tempCMap.ScrapPart = componentMapC[index].ScrapPart
        tempCMap.ScrapPartName = componentMapC[index].ScrapPartName
        tempCMap.Rarity = 0
        ComponentMappings.Add(tempCMap)
        index += 1
    EndWhile
    index = 0
    While index < componentMapU.Length
        tempCMap = new ComponentMap
        tempCMap.ComponentPart = componentMapU[index].ComponentPart
        tempCMap.ComponentPartName = componentMapU[index].ComponentPartName
        tempCMap.ScrapPart = componentMapU[index].ScrapPart
        tempCMap.ScrapPartName = componentMapU[index].ScrapPartName
        tempCMap.Rarity = 1
        ComponentMappings.Add(tempCMap)
        index += 1
    EndWhile
    index = 0
    While index < componentMapR.Length
        tempCMap = new ComponentMap
        tempCMap.ComponentPart = componentMapR[index].ComponentPart
        tempCMap.ComponentPartName = componentMapR[index].ComponentPartName
        tempCMap.ScrapPart = componentMapR[index].ScrapPart
        tempCMap.ScrapPartName = componentMapR[index].ScrapPartName
        tempCMap.Rarity = 2
        ComponentMappings.Add(tempCMap)
        index += 1
    EndWhile
    index = 0
    While index < componentMapS.Length
        tempCMap = new ComponentMap
        tempCMap.ComponentPart = componentMapS[index].ComponentPart
        tempCMap.ComponentPartName = componentMapS[index].ComponentPartName
        tempCMap.ScrapPart = componentMapS[index].ScrapPart
        tempCMap.ScrapPartName = componentMapS[index].ScrapPartName
        tempCMap.Rarity = 3
        ComponentMappings.Add(tempCMap)
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

    ; create array to hold function arguments
    var[] params = new var[4]
    params[0] = Utility.VarArrayToVar(scrapParts as var[])
    params[3] = ScrapListAll.List as FormList

    ; add all the scrap items to the FormList
    string functionToCall = "AddItemsToList"
    int numItems = ComponentMappings.Length
    int numThreads = Math.Min(numItems, MaxThreads) as int
    float numItemsPerThread
    If numThreads
        numItemsPerThread = numItems as float / numThreads
    EndIf
    Self._DebugTrace("There are " + numItems + " components; Using " + numThreads + \
        " threads for processing (" + numItemsPerThread + " items per thread)")
    index = 0
    While index < numThreads
        params[1] = (index * numItemsPerThread) as int
        params[2] = ((index + 1) * numItemsPerThread) as int - 1
        (Threads[index] as ScriptObject).CallFunctionNoWait(functionToCall, params)
        Self._DebugTrace("Called thread " + index + " (" + functionToCall + "): Index (Start) = " + params[1] + \
            ", Index (End) = " + params[2])
        index += 1
    EndWhile

    Self.WaitForThreads(Threads, numThreads)

    ScrapListAll.Size = ScrapListAll.List.GetSize()
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

        var[] settingsToLoad = new var[0]

        ; settings - general
        settingsToLoad.Add(MultBase)
        settingsToLoad.Add(ReturnAtLeastOneComponent)
        settingsToLoad.Add(FractionalComponentHandling)
        settingsToLoad.Add(HasLimitedUses)
        settingsToLoad.Add(NumberOfUses)

        ; settings - adjustment options
        settingsToLoad.Add(GeneralMultAdjust)
        settingsToLoad.Add(IntAffectsMult)
        settingsToLoad.Add(LckAffectsMult)
        settingsToLoad.Add(RngAffectsMult)
        settingsToLoad.Add(ScrapperAffectsMult)

        ; settings - recycler behavior
        settingsToLoad.Add(AutoRecyclingMode)
        settingsToLoad.Add(AllowJunkOnly)
        settingsToLoad.Add(AutoMoveJunk)
        settingsToLoad.Add(AllowBehaviorOverrides)
        settingsToLoad.Add(ReturnItemsSilently)

        ; multiplier adjustments - general
        settingsToLoad.Add(MultAdjustGeneralSettlement)
        settingsToLoad.Add(MultAdjustGeneralSettlementC)
        settingsToLoad.Add(MultAdjustGeneralSettlementU)
        settingsToLoad.Add(MultAdjustGeneralSettlementR)
        settingsToLoad.Add(MultAdjustGeneralSettlementS)

        settingsToLoad.Add(MultAdjustGeneralNotSettlement)
        settingsToLoad.Add(MultAdjustGeneralNotSettlementC)
        settingsToLoad.Add(MultAdjustGeneralNotSettlementU)
        settingsToLoad.Add(MultAdjustGeneralNotSettlementR)
        settingsToLoad.Add(MultAdjustGeneralNotSettlementS)

        ; multiplier adjustments - intelligence
        settingsToLoad.Add(MultAdjustInt)
        settingsToLoad.Add(MultAdjustIntC)
        settingsToLoad.Add(MultAdjustIntU)
        settingsToLoad.Add(MultAdjustIntR)
        settingsToLoad.Add(MultAdjustIntS)

        ; multiplier adjustments - luck
        settingsToLoad.Add(MultAdjustLck)
        settingsToLoad.Add(MultAdjustLckC)
        settingsToLoad.Add(MultAdjustLckU)
        settingsToLoad.Add(MultAdjustLckR)
        settingsToLoad.Add(MultAdjustLckS)

        ; multiplier adjustments - randomness
        settingsToLoad.Add(MultAdjustRandomMin)
        settingsToLoad.Add(MultAdjustRandomMinC)
        settingsToLoad.Add(MultAdjustRandomMinU)
        settingsToLoad.Add(MultAdjustRandomMinR)
        settingsToLoad.Add(MultAdjustRandomMinS)

        settingsToLoad.Add(MultAdjustRandomMax)
        settingsToLoad.Add(MultAdjustRandomMaxC)
        settingsToLoad.Add(MultAdjustRandomMaxU)
        settingsToLoad.Add(MultAdjustRandomMaxR)
        settingsToLoad.Add(MultAdjustRandomMaxS)

        ; multiplier adjustments - scrapper 1-5
        int index = 0
        While index < ScrapperPerkMaxRanksSupported
            settingsToLoad.Add(MultAdjustScrapperSettlement[index])
            settingsToLoad.Add(MultAdjustScrapperSettlementC[index])
            settingsToLoad.Add(MultAdjustScrapperSettlementU[index])
            settingsToLoad.Add(MultAdjustScrapperSettlementR[index])
            settingsToLoad.Add(MultAdjustScrapperSettlementS[index])

            settingsToLoad.Add(MultAdjustScrapperNotSettlement[index])
            settingsToLoad.Add(MultAdjustScrapperNotSettlementC[index])
            settingsToLoad.Add(MultAdjustScrapperNotSettlementU[index])
            settingsToLoad.Add(MultAdjustScrapperNotSettlementR[index])
            settingsToLoad.Add(MultAdjustScrapperNotSettlementS[index])

            index += 1
        EndWhile

        ; create array to hold function arguments
        var[] params = new var[4]
        params[0] = Utility.VarArrayToVar(settingsToLoad as var[]) as var
        params[3] = ModName as string

        ; set up multithreading parameters
        string functionToCall = "LoadMCMSettings"
        int numItems = settingsToLoad.Length
        int numThreads = Math.Min(numItems, MaxThreads) as int
        float numItemsPerThread
        If numThreads
            numItemsPerThread = numItems as float / numThreads
        EndIf
        Self._DebugTrace("Loading " + numItems + " settings from MCM; Using " + numThreads + " threads for processing (" + \
            numItemsPerThread + " settings per thread)")

        ; start multithreading
        index = 0
        While index < numThreads
            params[1] = (index * numItemsPerThread) as int
            params[2] = ((index + 1) * numItemsPerThread) as int - 1
            (Threads[index] as ScriptObject).CallFunctionNoWait(functionToCall, params)
            Self._DebugTrace("Called thread " + index + " (" + functionToCall + "): Index (Start) = " + params[1] + \
                ", Index (End) = " + params[2])
            index += 1
        EndWhile

        ; wait for multithreading to finish
        Self.WaitForThreads(Threads, numThreads)

        ; perform general post-processing
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
        If AllowBehaviorOverrides.Value
            RegisterForKey(LShift)
            RegisterForKey(LCtrl)
        Else
            UnregisterForKey(LShift)
            UnregisterForKey(LCtrl)
            BehaviorOverrideForceMoveJunk = false
            BehaviorOverrideForceNotMoveJunk = false
        EndIf
        MultAdjustRandomSanityCheck()
    Else
        Self._DebugTrace("Loading settings from MCM; skipping (MCM not enabled)")
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
    Self._DebugTrace("MCM setting changed")
    If asModName == ModName
        var oldValue
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
            MCM_GeneralMultAdjustSimple = GeneralMultAdjust.Value == 0
            MCM_GeneralMultAdjustDetailed = GeneralMultAdjust.Value > 0
            MCM.RefreshMenu()
        ElseIf asControlId == IntAffectsMult.McmId
            oldValue = IntAffectsMult.Value
            LoadSettingFromMCM(IntAffectsMult, ModName)
            newValue = IntAffectsMult.Value
            MCM_IntAffectsMultSimple = IntAffectsMult.Value == 1
            MCM_IntAffectsMultDetailed = IntAffectsMult.Value > 1
            MCM.RefreshMenu()
        ElseIf asControlId == LckAffectsMult.McmId
            oldValue = LckAffectsMult.Value
            LoadSettingFromMCM(LckAffectsMult, ModName)
            newValue = LckAffectsMult.Value
            MCM_LckAffectsMultSimple = LckAffectsMult.Value == 1
            MCM_LckAffectsMultDetailed = LckAffectsMult.Value > 1
            MCM.RefreshMenu()
        ElseIf asControlId == RngAffectsMult.McmId
            oldValue = RngAffectsMult.Value
            LoadSettingFromMCM(RngAffectsMult, ModName)
            newValue = RngAffectsMult.Value
            MCM_RngAffectsMultSimple = RngAffectsMult.Value == 1
            MCM_RngAffectsMultDetailed = RngAffectsMult.Value > 1
            MCM.RefreshMenu()
        ElseIf asControlId == ScrapperAffectsMult.McmId
            oldValue = ScrapperAffectsMult.Value
            LoadSettingFromMCM(ScrapperAffectsMult, ModName)
            newValue = ScrapperAffectsMult.Value
            MCM_ScrapperAffectsMultSimple = ScrapperAffectsMult.Value == 1
            MCM_ScrapperAffectsMultDetailed = ScrapperAffectsMult.Value > 1
            MCM.RefreshMenu()

        ; settings - recycler behavior
        ElseIf asControlId == AutoRecyclingMode.McmId
            oldValue = AutoRecyclingMode.Value
            LoadSettingFromMCM(AutoRecyclingMode, ModName)
            newValue = AutoRecyclingMode.Value
        ElseIf asControlId == AllowJunkOnly.McmId
            oldValue = AllowJunkOnly.Value
            LoadSettingFromMCM(AllowJunkOnly, ModName)
            newValue = AllowJunkOnly.Value
        ElseIf asControlId == AutoMoveJunk.McmId
            oldValue = AutoMoveJunk.Value
            LoadSettingFromMCM(AutoMoveJunk, ModName)
            newValue = AutoMoveJunk.Value
        ElseIf asControlId == AllowBehaviorOverrides.McmId
            oldValue = AllowBehaviorOverrides.Value
            LoadSettingFromMCM(AllowBehaviorOverrides, ModName)
            newValue = AllowBehaviorOverrides.Value
            If AllowBehaviorOverrides.Value
                RegisterForKey(LShift)
                RegisterForKey(LCtrl)
            Else
                UnregisterForKey(LShift)
                UnregisterForKey(LCtrl)
                BehaviorOverrideForceMoveJunk = false
                BehaviorOverrideForceNotMoveJunk = false
            EndIf
        ElseIf asControlId == ReturnItemsSilently.McmId
            oldValue = ReturnItemsSilently.Value
            LoadSettingFromMCM(ReturnItemsSilently, ModName)
            newValue = ReturnItemsSilently.Value

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

        ; multiplier adjustments - scrapper 1-5
        Else
            bool controlFound = false
            int index = 0
            While index < ScrapperPerkMaxRanksSupported && ! controlFound
                If asControlId == MultAdjustScrapperSettlement[index].McmId
                    oldValue = MultAdjustScrapperSettlement[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperSettlement[index], ModName)
                    newValue = MultAdjustScrapperSettlement[index].Value
                    controlFound = true
                ElseIf asControlId == MultAdjustScrapperSettlementC[index].McmId
                    oldValue = MultAdjustScrapperSettlementC[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperSettlementC[index], ModName)
                    newValue = MultAdjustScrapperSettlementC[index].Value
                    controlFound = true
                ElseIf asControlId == MultAdjustScrapperSettlementU[index].McmId
                    oldValue = MultAdjustScrapperSettlementU[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperSettlementU[index], ModName)
                    newValue = MultAdjustScrapperSettlementU[index].Value
                    controlFound = true
                ElseIf asControlId == MultAdjustScrapperSettlementR[index].McmId
                    oldValue = MultAdjustScrapperSettlementR[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperSettlementR[index], ModName)
                    newValue = MultAdjustScrapperSettlementR[index].Value
                    controlFound = true
                ElseIf asControlId == MultAdjustScrapperSettlementS[index].McmId
                    oldValue = MultAdjustScrapperSettlementS[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperSettlementS[index], ModName)
                    newValue = MultAdjustScrapperSettlementS[index].Value
                    controlFound = true

                ElseIf asControlId == MultAdjustScrapperNotSettlement[index].McmId
                    oldValue = MultAdjustScrapperNotSettlement[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperNotSettlement[index], ModName)
                    newValue = MultAdjustScrapperNotSettlement[index].Value
                    controlFound = true
                ElseIf asControlId == MultAdjustScrapperNotSettlementC[index].McmId
                    oldValue = MultAdjustScrapperNotSettlementC[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperNotSettlementC[index], ModName)
                    newValue = MultAdjustScrapperNotSettlementC[index].Value
                    controlFound = true
                ElseIf asControlId == MultAdjustScrapperNotSettlementU[index].McmId
                    oldValue = MultAdjustScrapperNotSettlementU[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperNotSettlementU[index], ModName)
                    newValue = MultAdjustScrapperNotSettlementU[index].Value
                    controlFound = true
                ElseIf asControlId == MultAdjustScrapperNotSettlementR[index].McmId
                    oldValue = MultAdjustScrapperNotSettlementR[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperNotSettlementR[index], ModName)
                    newValue = MultAdjustScrapperNotSettlementR[index].Value
                    controlFound = true
                ElseIf asControlId == MultAdjustScrapperNotSettlementS[index].McmId
                    oldValue = MultAdjustScrapperNotSettlementS[index].Value
                    LoadSettingFromMCM(MultAdjustScrapperNotSettlementS[index], ModName)
                    newValue = MultAdjustScrapperNotSettlementS[index].Value
                    controlFound = true
                EndIf

                index += 1
            EndWhile

            if ! controlFound
                Self._DebugTrace("Unknown control ID: " + asControlId, 2)
                Return
            EndIf
        EndIf
        Self._DebugTrace("MCM control ID '" + asControlId + "' was changed. old value = " + oldValue + \
            ", new value = " + newValue)
    EndIf
EndFunction

; callback function for when the user moves to a different MCM menu
Function OnMCMMenuClose()
    Self.MultAdjustRandomSanityCheck()
    MCM.RefreshMenu()
EndFunction

; show the current multipliers for where the player is located right now
Function ShowCurrentMultipliers()
    Self._DebugTrace("Current multipliers:")
    MultiplierSet currentMults = Self.GetMultipliers()
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
        MessageSettingsReset.Show()
        Debug.StopStackProfiling()
        MutexBusy = false
        MCM.RefreshMenu()
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

; reset the recyclable item list
Function ResetRecyclableItemList()
    If ! MutexBusy && ! MutexRunning
        MutexBusy = true
        Self._DebugTrace("Resetting recyclable item list")
        RecyclableItemList.List.Revert()
        MessageRecyclableItemListReset.Show()
        MutexBusy = false
    ElseIf MutexBusy && ! MutexRunning
        Self._DebugTrace("Failed to reset recyclable item list: Control script busy")
        MessageRecyclableItemListResetFailBusy.Show()
    ElseIf MutexRunning
        Self._DebugTrace("Failed to reset recyclable item list: Recycling process running")
        MessageRecyclableItemListResetFailRunning.Show()
    EndIf
EndFunction

; reset the behavior override flags
Function ResetBehaviorOverrides()
    Self._DebugTrace("Resetting behavior override flags")
    BehaviorOverrideForceMoveJunk = false
    BehaviorOverrideForceNotMoveJunk = false
    MessageBehaviorOverridesReset.Show()
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
MultiplierSet Function GetMultipliers()
    Self._DebugTrace("Getting multipliers")
    MultiplierSet toReturn = new MultiplierSet

    toReturn.MultC = MultBase.Value
    toReturn.MultU = MultBase.Value
    toReturn.MultR = MultBase.Value
    toReturn.MultS = MultBase.Value
    Self._DebugTrace("Base multiplier: " + MultBase.Value)

    ; general
    bool playerAtOwnedWorkshop = IsPlayerAtOwnedWorkshop()
    Self._DebugTrace("Player is in an owned settlement: " + playerAtOwnedWorkshop)
    If playerAtOwnedWorkshop
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
            If playerAtOwnedWorkshop
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

; this function waits for a specified number of threads to finish before returning
Function WaitForThreads(var[] akThreads, int aiNumThreads)
    Utility.WaitMenuMode(0.1)

    bool waitingOnThreads = true
    int index
    While waitingOnThreads
        index = 0
        waitingOnThreads = false
        While ! waitingOnThreads && index < aiNumThreads
            waitingOnThreads = waitingOnThreads || (akThreads[index] as WorkerThreadBase).IsRunning()
            index += 1
        EndWhile
        If waitingOnThreads
            Self._DebugTrace("waiting for threads to finish")
            Utility.WaitMenuMode(0.1)
        EndIf
    EndWhile
EndFunction

; prep for uninstall of mod
Function Uninstall()
    Self._DebugTrace("Uninstallation sequence initialized!", 1)

    ; unregister from all events
    UnregisterForRemoteEvent(PlayerRef, "OnPlayerLoadGame")
    UnregisterForMenuOpenCloseEvent("PauseMenu")
    UnregisterForExternalEvent("OnMCMSettingChange|" + ModName)
    UnregisterForExternalEvent("OnMCMMenuClose|" + ModName)
    If AllowBehaviorOverrides.Value
        Self.UnregisterForKey(LShift)
        Self.UnregisterForKey(LCtrl)
    EndIf

    ; properties
    ; group Components
    ComponentListC = None
    ComponentListU = None
    ComponentListR = None
    ComponentListS = None
    ScrapListC = None
    ScrapListU = None
    ScrapListR = None
    ScrapListS = None
    ScrapListAll = None
    Self.DestroyObjectArray(ComponentMappings as var[])
    ComponentMappings = None

    ; group Other
    PlayerRef = None
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
    MessageRecyclableItemListReset = None
    MessageRecyclableItemListResetFailBusy = None
    MessageRecyclableItemListResetFailRunning = None
    MessageBehaviorOverridesReset = None
    WorkshopParent = None
    RecyclableItemList = None

    ; group RuntimeState
    Self.DestroyObjectArray(ScrapperPerks as var[])
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
    ; settings - recycler behavior
    AutoRecyclingMode = None
    AllowJunkOnly = None
    AutoMoveJunk = None
    AllowBehaviorOverrides = None
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
    Self.DestroyObjectArray(MultAdjustScrapperSettlement as var[])
    MultAdjustScrapperSettlement = None
    Self.DestroyObjectArray(MultAdjustScrapperSettlementC as var[])
    MultAdjustScrapperSettlementC = None
    Self.DestroyObjectArray(MultAdjustScrapperSettlementU as var[])
    MultAdjustScrapperSettlementU = None
    Self.DestroyObjectArray(MultAdjustScrapperSettlementR as var[])
    MultAdjustScrapperSettlementR = None
    Self.DestroyObjectArray(MultAdjustScrapperSettlementS as var[])
    MultAdjustScrapperSettlementS = None
    Self.DestroyObjectArray(MultAdjustScrapperNotSettlement as var[])
    MultAdjustScrapperNotSettlement = None
    Self.DestroyObjectArray(MultAdjustScrapperNotSettlementC as var[])
    MultAdjustScrapperNotSettlementC = None
    Self.DestroyObjectArray(MultAdjustScrapperNotSettlementU as var[])
    MultAdjustScrapperNotSettlementU = None
    Self.DestroyObjectArray(MultAdjustScrapperNotSettlementR as var[])
    MultAdjustScrapperNotSettlementR = None
    Self.DestroyObjectArray(MultAdjustScrapperNotSettlementS as var[])
    MultAdjustScrapperNotSettlementS = None

    ; local variables
    AvailableChangeTypes = None
    Self.DestroyObjectArray(Threads)
    Threads = None

    ; show uninstalled message
    MessageUninstalled.Show()
    MessageUninstalled = None

    ; stop the quest
    Stop()

    Self._DebugTrace("Uninstallation sequence complete!")
EndFunction

; fully destroy the contents of an array of objects and the array itself
Function DestroyObjectArray(var[] akArray)
    int index = akArray.Length - 1
    While index >= 0
        akArray[index] = None
        akArray.Remove(index)
        index -= 1
    EndWhile
    akArray = None
EndFunction