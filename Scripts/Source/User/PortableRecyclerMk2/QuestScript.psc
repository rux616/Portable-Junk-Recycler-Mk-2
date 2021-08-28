ScriptName PortableRecyclerMk2:QuestScript extends Quest
{ foo }



; PROPERTIES
; ----------

bool Property IsRunning Auto
{ keep track of whether a recycling process is running or not }

;PortableRecyclerSettings Property Settings Auto

Actor Property PlayerRef Auto Const
{ player ref }

Perk Property BaseScrapperPerk Auto Const
{ reference to the base scrapper perk }

; small group of properties to allow MCM to determine which of the rank 3+ scrapper controls to show
Group MCMHiddenSwitcherProperties Collapsed
    bool Property Scrapper03PerkAvailable Auto
    { determines whether to display the controls associated with scrapper rank 3 in the MCM }

    bool Property Scrapper04PerkAvailable Auto
    { determines whether to display the controls associated with scrapper rank 4 in the MCM }

    bool Property Scrapper05PerkAvailable Auto
    { determines whether to display the controls associated with scrapper rank 5 in the MCM }

EndGroup

float Property MultiplierCurrentOwnedSettlement Auto
float Property MultiplierCurrentEverywhereElse Auto

ScrapperPerkDetails Property Scrapper01 Auto
ScrapperPerkDetails Property Scrapper02 Auto
ScrapperPerkDetails Property Scrapper03 Auto
ScrapperPerkDetails Property Scrapper04 Auto
ScrapperPerkDetails Property Scrapper05 Auto



; STRUCTS
; -------

Struct PortableRecyclerSettings
	float MultiplierBaseOwnedSettlement
	float MultiplierBaseEverywhereElse
	bool ScrapperGivesBonus
	float Scrapper1Bonus
	float Scrapper2Bonus
	float Scrapper3Bonus
    float Scrapper4Bonus
    float Scrapper5Bonus
	bool Scrapper1BonusInSettlementsOnly
	bool Scrapper2BonusInSettlementsOnly
	bool Scrapper3BonusInSettlementsOnly
	bool Scrapper4BonusInSettlementsOnly
	bool Scrapper5BonusInSettlementsOnly
EndStruct

Struct Multiplier
    float OwnedSettlement
    float EverywhereElse
EndStruct

Struct ScrapperPerkDetails
    Perk PerkRef
    bool PlayerHas
EndStruct


; VARIABLES
; ---------

Perk[] ScrapperPerks
Multiplier[] CurrentMultipliers


; EVENTS
; ------

Event OnQuestInit()
    RegisterForRemoteEvent(PlayerRef, "OnPlayerLoadGame")
    RuntimeInit()
    RegisterCustomEvents()
    Update()
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    RuntimeInit()
    RegisterCustomEvents()
    Update()
EndEvent



; FUNCTIONS
; ---------

; populate scrapper perk array and determine if scrapper perk ranks >= 3 (and <= 5) are available
Function RuntimeInit()
    ; use the reference to the base scrapper perk to get how many ranks there are
    int numScrapperRanks = BaseScrapperPerk.GetNumRanks()

    ; scrapper rank 3 is available from Far Harbor, and there's a bit of cushion in case additional
    ; ranks are added, for instance as part of a perk overhaul or something
    Scrapper03PerkAvailable = numScrapperRanks >= 3
    Scrapper04PerkAvailable = numScrapperRanks >= 4
    Scrapper05PerkAvailable = numScrapperRanks >= 5

    ; create a scrapper perks array and seed it with the base scrapper perk
    ; intentionally a size of 1 initially so that ScrapperPerks[0] represents having no perk
    ScrapperPerks = new Perk[1]
    ScrapperPerks.Add(BaseScrapperPerk)

    ; add the rest of the scrapper perks to the array
    int currentIndex = 1
    while currentIndex < numScrapperRanks
        ScrapperPerks.Add(ScrapperPerks[currentIndex].GetNextPerk())
        currentIndex += 1
    EndWhile

    ; once all the perks are discovered, reinitialize the mutlipliers
    CurrentMultipliers = new Multiplier[ScrapperPerks.Length]
EndFunction

Function UpdateMultipliers()
    ; get the highest level of scrapper perk the player has
    int index = ScrapperPerks.Length - 1
    While index >= 0 && ! PlayerRef.HasPerk(ScrapperPerks[index])
        index -= 1
    EndWhile
    
    int currentScrapperLevel = index + 1

    ;Multiplier current
    ; currentmultiplier.ownedsettlement = basemodifierownedsettlement + modifier
    ; currentmultiplier.ownedsettlement = basemodifier + everywhereelsescrappermodifier



    ;MultiplierCurrentOwnedSettlement = Settings.MultiplierBaseOwnedSettlement + ( Settings.Scrapper1Bonus * playerRef.HasPerk(ScrapperPerks[0]) as int )
EndFunction

Function RegisterCustomEvents()
    RegisterForExternalEvent("OnMCMOpen", "OnMCMOpen");
    RegisterForExternalEvent("OnMCMSettingChange|PortableRecyclerMarkII", "OnMCMSettingChange")
EndFunction

Function Update()
    ;update whatever variables and properties that are needed by MCM:
    ;(1) when the user loads a saved game, or
    ;(2) when MCM changes your global variables or script properties via controls

    ;;;;;;;;
	; TODO ;
    ;;;;;;;;
EndFunction

Function OnMCMOpen()
    Update()
    MCM.RefreshMenu()
    Debug.Notification("MCM Menu was opened")
EndFunction

Function OnMCMSettingChange(string modName, string id)
    If (modName == "PortableRecyclerMarkII")
        If (id == "control_id")
            Debug.Notification("control_id value was changed!")
        EndIf
    EndIf
EndFunction

; Can be added to the config.json as an action/CallFunction to update internal properties and
; variables after MCM changes any of them
Function MCMApply()
    Update()
EndFunction