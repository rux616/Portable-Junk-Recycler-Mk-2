ScriptName PortableJunkRecyclerMk2:QuestScript extends Quest
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

; populate scrapper perk array and determine if scrapper perk rank 3 is available
Function RuntimeInit()
    ; create a scrapper perks array and seed it with the base scrapper perk
    ScrapperPerks = new Perk[0]
    ScrapperPerks.Add(Game.GetFormFromFile(0x00065E65, "Fallout4.esm") as Perk) ; scrapper rank 1
    ScrapperPerks.Add(Game.GetFormFromFile(0x001D2483, "Fallout4.esm") as Perk) ; scrapper rank 2
    ScrapperPerks.Add(Game.GetFormFromFile(0x000423A5, "DLCCoast.esm") as Perk) ; scrapper rank 3

    ; if Far Harbor isn't installed, remove the last perk as it will be "none"
    If ScrapperPerks[ScrapperPerks.Length - 1] == None
        ScrapperPerks.RemoveLast()
    EndIf

    ; use the reference to the base scrapper perk to get how many ranks there are
    int numScrapperRanks = ScrapperPerks.Length

    ; once all the perks are discovered, reinitialize the mutlipliers
    CurrentMultipliers = new Multiplier[ScrapperPerks.Length]
EndFunction

Function GlobalToMcmBridge()

EndFunction

Function GetCurrentMultipliers()
    ; code
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
    RegisterForExternalEvent("OnMCMSettingChange|Portable Recycler Mk 2", "OnMCMSettingChange")
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
    If (modName == "Portable Recycler Mk 2")
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