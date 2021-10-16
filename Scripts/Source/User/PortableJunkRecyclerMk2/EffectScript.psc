ScriptName PortableJunkRecyclerMk2:EffectScript Extends ActiveMagicEffect
{ script that handles the recycling process }

; import the base script to get access to the common structs
import PortableJunkRecyclerMk2:Base



; STRUCTS
; -------

Struct ExistingScrap
    MiscObject ScrapPart
    int ScrapQuantity
EndStruct



; VARIABLES
; ---------

string ModName = "Portable Junk Recycler Mk 2" const

; using internal variables instead of properties to avoid issues when loading auto-saves that is
; created after a player uses the recycler device and leaves the pip-boy
Actor PlayerRef
QuestScript PortableRecyclerQuest
Container PortableRecyclerContainer
Potion PortableRecyclerItem
FormList PortableRecyclerItemList
Sound SoundRecycle
Sound SoundPickup

Message MessageAlreadyRunning
Message MessageBusy
Message MessageFinished
Message MessageFinishedNothing
Message MessageFinishedUsesLeft
Message MessageFinishedNothingUsesLeft
Message MessageF4SENotInstalled

; EVENTS
; ------

Event OnEffectStart(Actor akTarget, Actor akCaster)
    PortableRecyclerQuest = Game.GetFormFromFile(0x800, ModName + ".esp") as QuestScript

    If ! PortableRecyclerQuest.ScriptExtenderInstalled
        ; F4SE is not found, abort with message
        Self._DebugTrace("F4SE is not installed; aborting")
        Self.InitVariables()
        MessageF4SENotInstalled.Show()
        PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)
    ElseIf ! PortableRecyclerQuest.MutexRunning && ! PortableRecyclerQuest.MutexBusy
        ; normal mode of operation: a recycler process isn't already running nor is the quest busy
        PortableRecyclerQuest.MutexRunning = true
        Self._DebugTrace("Recycler process started")
        Self.InitVariables()

        bool itemsRecycled = false

        ; get the set of multipliers that will be applied to this recycling run
        MultiplierSet multipliers = PortableRecyclerQuest.GetMultipliers()
        Self._DebugTrace("Multipliers: C=" + multipliers.MultC + "; U=" + multipliers.MultU + "; R=" + multipliers.MultR + \
            "; S=" + multipliers.MultS)

        ; place a temporary container at the player, wait, then activate it and wait a moment again
        ObjectReference containerRef = PlayerRef.PlaceAtMe(PortableRecyclerContainer as Form, abForcePersist = true)
        Utility.Wait(1.0)
        Self._DebugTrace("Temporary container " + containerRef + " created")
        containerRef.Activate(PlayerRef as ObjectReference, true)
        Utility.Wait(0.1)

        ; play the recycling sound
        If containerRef.GetInventoryItems().Length
            SoundRecycle.Play(PlayerRef as ObjectReference)
        EndIf

        ; determine whether the recycling function will add randomized adjustments
        bool randomAdjustment = PortableRecyclerQuest.RngAffectsMult.Value
        float randomMin = 0.0
        float randomMax = 0.0
        If PortableRecyclerQuest.RngAffectsMult.Value == 1
            randomMin = PortableRecyclerQuest.MultAdjustRandomMin.Value
            randomMax = PortableRecyclerQuest.MultAdjustRandomMax.Value
        EndIf

        ; remove existing scrap parts from the container and record quantities
        Self._DebugTrace("Cleaning existing scrap from ComponentMapC")
        ExistingScrap[] existingScrapQuantitiesC = CleanExistingScrap(PortableRecyclerQuest.ComponentMapC, containerRef)
        Self._DebugTrace("Cleaning existing scrap from ComponentMapU")
        ExistingScrap[] existingScrapQuantitiesU = CleanExistingScrap(PortableRecyclerQuest.ComponentMapU, containerRef)
        Self._DebugTrace("Cleaning existing scrap from ComponentMapR")
        ExistingScrap[] existingScrapQuantitiesR = CleanExistingScrap(PortableRecyclerQuest.ComponentMapR, containerRef)
        Self._DebugTrace("Cleaning existing scrap from ComponentMapS")
        ExistingScrap[] existingScrapQuantitiesS = CleanExistingScrap(PortableRecyclerQuest.ComponentMapS, containerRef)

        ; do the recycling
        Self._DebugTrace("Recycling components from ComponentMapC")
        If PortableRecyclerQuest.RngAffectsMult.Value > 1
            randomMin = PortableRecyclerQuest.MultAdjustRandomMinC.Value
            randomMax = PortableRecyclerQuest.MultAdjustRandomMaxC.Value
        EndIf
        itemsRecycled = Self.RecycleComponents(PortableRecyclerQuest.ComponentMapC, multipliers.MultC, \
            containerRef, randomAdjustment, randomMin, randomMax) || itemsRecycled
        Self._DebugTrace("Recycling components from ComponentMapU")
        If PortableRecyclerQuest.RngAffectsMult.Value > 1
            randomMin = PortableRecyclerQuest.MultAdjustRandomMinU.Value
            randomMax = PortableRecyclerQuest.MultAdjustRandomMaxU.Value
        EndIf
        itemsRecycled = Self.RecycleComponents(PortableRecyclerQuest.ComponentMapU, multipliers.MultU, \
            containerRef, randomAdjustment, randomMin, randomMax) || itemsRecycled
        Self._DebugTrace("Recycling components from ComponentMapR")
        If PortableRecyclerQuest.RngAffectsMult.Value > 1
            randomMin = PortableRecyclerQuest.MultAdjustRandomMinR.Value
            randomMax = PortableRecyclerQuest.MultAdjustRandomMaxR.Value
        EndIf
        itemsRecycled = Self.RecycleComponents(PortableRecyclerQuest.ComponentMapR, multipliers.MultR, \
            containerRef, randomAdjustment, randomMin, randomMax) || itemsRecycled
        Self._DebugTrace("Recycling components from ComponentMapS")
        If PortableRecyclerQuest.RngAffectsMult.Value > 1
            randomMin = PortableRecyclerQuest.MultAdjustRandomMinS.Value
            randomMax = PortableRecyclerQuest.MultAdjustRandomMaxS.Value
        EndIf
        itemsRecycled = Self.RecycleComponents(PortableRecyclerQuest.ComponentMapS, multipliers.MultS, \
            containerRef, randomAdjustment, randomMin, randomMax) || itemsRecycled

        ; add previously existing scrap back to the container
        int index = 0
        While (index < existingScrapQuantitiesC.Length)
            containerRef.AddItem(existingScrapQuantitiesC[index].ScrapPart, existingScrapQuantitiesC[index].ScrapQuantity, true)
            Self._DebugTrace(existingScrapQuantitiesC[index].ScrapQuantity + " existing " + \
                existingScrapQuantitiesC[index].ScrapPart + " (" + existingScrapQuantitiesC[index].ScrapPart.GetName() + \
                ") re-added")
            index += 1
        EndWhile
        index = 0
        While (index < existingScrapQuantitiesU.Length)
            containerRef.AddItem(existingScrapQuantitiesU[index].ScrapPart, existingScrapQuantitiesU[index].ScrapQuantity, true)
            Self._DebugTrace(existingScrapQuantitiesU[index].ScrapQuantity + " existing " + \
                existingScrapQuantitiesU[index].ScrapPart + " (" + existingScrapQuantitiesU[index].ScrapPart.GetName() + \
                ") re-added")
            index += 1
        EndWhile
        index = 0
        While (index < existingScrapQuantitiesR.Length)
            containerRef.AddItem(existingScrapQuantitiesR[index].ScrapPart, existingScrapQuantitiesR[index].ScrapQuantity, true)
            Self._DebugTrace(existingScrapQuantitiesR[index].ScrapQuantity + " existing " + \
                existingScrapQuantitiesR[index].ScrapPart + " )" + existingScrapQuantitiesR[index].ScrapPart.GetName() + \
                ") re-added")
            index += 1
        EndWhile
        index = 0
        While (index < existingScrapQuantitiesS.Length)
            containerRef.AddItem(existingScrapQuantitiesS[index].ScrapPart, existingScrapQuantitiesS[index].ScrapQuantity, true)
            Self._DebugTrace(existingScrapQuantitiesS[index].ScrapQuantity + " existing " + \
                existingScrapQuantitiesS[index].ScrapPart + " )" + existingScrapQuantitiesS[index].ScrapPart.GetName() + \
                ") re-added")
            index += 1
        EndWhile

        ; move items over to the player
        Self._DebugTrace("Moving components from temporary container to player")
        Self.RemoveAllItems(containerRef, PlayerRef, PortableRecyclerQuest.ReturnItemsSilently.Value)

        ; delete the containers
        Self._DebugTrace("Removing temporary container " + containerRef)
        containerRef.Delete()

        ; if 'limited uses' mode is on, run through the scenarios for that, otherwise just show completion message
        ; and re-add the recycler item back to the player's inventory
        If PortableRecyclerQuest.HasLimitedUses.Value
            ; if things were actually recycled, increment the number of times used
            PortableRecyclerQuest.NumberOfTimesUsed += itemsRecycled as int
            Self._DebugTrace("Number of times used incremented by " + itemsRecycled as int + " to " + \
                PortableRecyclerQuest.NumberOfTimesUsed)
            If ! itemsRecycled
                ; if nothing was recycled, re-add the recycler item and show a message saying nothing was recycled
                Self._DebugTrace("Nothing recycled; adding item back to player's inventory")
                PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)
                MessageFinishedNothingUsesLeft.Show(PortableRecyclerQuest.NumberOfUses.Value - \
                    PortableRecyclerQuest.NumberOfTimesUsed)
            ElseIf PortableRecyclerQuest.NumberOfTimesUsed < PortableRecyclerQuest.NumberOfUses.Value
                ; re-add the portable recycler item if there are uses left
                Self._DebugTrace("Items recycled and max usage limit not reached; adding item back to player's inventory")
                PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)
                MessageFinishedUsesLeft.Show(PortableRecyclerQuest.NumberOfUses.Value - \
                    PortableRecyclerQuest.NumberOfTimesUsed)
            Else
                ; if the recycler item use limit is reached, reset the number of times used, but don't re-add the item
                Self._DebugTrace("Items recycled but max usage limit reached; NOT adding item back to player's inventory")
                PortableRecyclerQuest.NumberOfTimesUsed = 0
                MessageFinishedUsesLeft.Show(0)
            EndIf
        Else
            If itemsRecycled
                MessageFinished.Show()
            Else
                MessageFinishedNothing.Show()
            EndIf
            PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)
        EndIf

        Self._DebugTrace("Recycler process finished")

        ; enable the recycle process to be run again
        PortableRecyclerQuest.MutexRunning = false
    ElseIf PortableRecyclerQuest.MutexRunning && ! PortableRecyclerQuest.MutexBusy
        ; another recycling process is already running, tell the user
        Self._DebugTrace("Recycler process already running")
        MessageAlreadyRunning.Show()
        PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)
    Else
        ; the quest script is processing something in the background, tell the user to give it a few seconds to finish
        Self._DebugTrace("Quest script is busy")
        MessageBusy.Show()
        PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)
    EndIf
EndEvent



; FUNCTIONS
; ---------

; add a bit of text to traces going into the papyrus user log
Function _DebugTrace(string asMessage, int aiSeverity = 0) DebugOnly
    Debug.TraceUser(ModName, "EffectScript: " + asMessage, aiSeverity)
EndFunction

; function to load forms
Function InitVariables()
    Self._DebugTrace("Initializing EffectScript variables")

    PlayerRef = Game.GetPlayer()
    PortableRecyclerContainer = Game.GetFormFromFile(0x830, ModName + ".esp") as Container
    PortableRecyclerItem = Game.GetFormFromFile(0x840, ModName + ".esp") as Potion
    PortableRecyclerItemList = Game.GetFormFromFile(0x818, ModName + ".esp") as FormList
    SoundRecycle = Game.GetFormFromFile(0x179F5B, "Fallout4.esm") as Sound
    SoundPickup = Game.GetFormFromFile(0x0802A6, "Fallout4.esm") as Sound

    MessageF4SENotInstalled = Game.GetFormFromFile(0x900, ModName + ".esp") as Message
    MessageAlreadyRunning = Game.GetFormFromFile(0x903, ModName + ".esp") as Message
    MessageBusy = Game.GetFormFromFile(0x904, ModName + ".esp") as Message
    MessageFinished = Game.GetFormFromFile(0x905, ModName + ".esp") as Message
    MessageFinishedNothing = Game.GetFormFromFile(0x906, ModName + ".esp") as Message
    MessageFinishedUsesLeft = Game.GetFormFromFile(0x907, ModName + ".esp") as Message
    MessageFinishedNothingUsesLeft = Game.GetFormFromFile(0x908, ModName + ".esp") as Message
EndFunction

; removes existing scrap components and returns an array of quantities removed
ExistingScrap[] Function CleanExistingScrap(ComponentMap[] akComponentMap, ObjectReference akContainerRef)
    ExistingScrap[] toReturn = new ExistingScrap[0]
    int existingScrapQuantity = 0
    ExistingScrap toAdd

    int index = 0
    While index < akComponentMap.Length
        existingScrapQuantity = akContainerRef.GetItemCount(akComponentMap[index].ScrapPart)
        If existingScrapQuantity
            toAdd = new ExistingScrap
            toAdd.ScrapPart = akComponentMap[index].ScrapPart
            toAdd.ScrapQuantity = existingScrapQuantity
            toReturn.Add(toAdd)
            akContainerRef.RemoveItem(toAdd.ScrapPart, -1, true)
            Self._DebugTrace(toAdd.ScrapQuantity + " existing " + toAdd.ScrapPart + " (" + toAdd.ScrapPart.GetName() + \
                ") found and temporarily removed")
        EndIf
        index += 1
    EndWhile

    Return toReturn
EndFunction

; recycle the components contained in the passed ComponentMap array
; returns true if any components were actually recycled
bool Function RecycleComponents(ComponentMap[] akComponentMap, float afScrapMultiplier, ObjectReference akContainerRef, \
    bool abRandomAdjustment, float afRandomMin, float afRandomMax)
    bool toReturn = false
    float componentQuantity = 0.0

    ; set basic multiplier value
    float scrapMultiplier = afScrapMultiplier

    int index = 0
    While index < akComponentMap.Length
        Self._DebugTrace(akComponentMap[index].ComponentPart + " (" + akComponentMap[index].ComponentPart.GetName() + "), " + \
            akComponentMap[index].ScrapPart + " (" + akComponentMap[index].ScrapPart.GetName() + ")")

        ; get the quantity of a certain component
        componentQuantity = akContainerRef.GetComponentCount(akComponentMap[index].ComponentPart)
        Self._DebugTrace("Component quantity (Initial) = " + componentQuantity)

        if componentQuantity > 0.0
            ; since there are components to work on, signal that recycling happened
            toReturn = true

            If abRandomAdjustment
                ; use randomized multiplier adjustment for each individual component
                float randomMultAdjust = Utility.RandomFloat(afRandomMin, afRandomMax)
                scrapMultiplier = afScrapMultiplier + randomMultAdjust
                Self._DebugTrace("Adjustment (Random): " + randomMultAdjust)
                Self._DebugTrace("Multiplier: " + scrapMultiplier)
            EndIf

            ; remove all components of the type from the inventory
            akContainerRef.RemoveComponents(akComponentMap[index].ComponentPart, componentQuantity as int, true)

            ; compute basic multiplied quantity
            componentQuantity *= scrapMultiplier
            Self._DebugTrace("Component quantity (Multiplied) = " + componentQuantity)

            ; give at least one component if the option is turned on and quantity <1
            If PortableRecyclerQuest.ReturnAtLeastOneComponent.Value && componentQuantity < 1.0
                componentQuantity = 1.0
            EndIf
            Self._DebugTrace("Component quantity (ReturnAtLeastOneComponent) = " + componentQuantity)

            ; round the component quantity per settings
            If PortableRecyclerQuest.FractionalComponentHandling.Value == 0         ; round up (ceiling)
                componentQuantity += (componentQuantity != componentQuantity as int) as int
                Self._DebugTrace("Component quantity (Round Up [ceiling]) = " + componentQuantity)
            ElseIf PortableRecyclerQuest.FractionalComponentHandling.Value == 1     ; round normally
                componentQuantity += 0.5
                Self._DebugTrace("Component quantity (Round Normally) = " + componentQuantity)
            ElseIf PortableRecyclerQuest.FractionalComponentHandling.Value == 2     ; round down (floor)
                componentQuantity = componentQuantity as int
                Self._DebugTrace("Component quantity (Round Down [floor]) = " + componentQuantity)
            EndIf

            ; add the modified quantity of components back to the inventory
            akContainerRef.AddItem(akComponentMap[index].ScrapPart, componentQuantity as int, true)
            Self._DebugTrace("Component quantity (Final) = " + componentQuantity as int)
        EndIf

        index += 1
    EndWhile

    Return toReturn
EndFunction

; remove all items from the origin container to the destination container
; adapted from code by DieFeM on the Nexus forums https://forums.nexusmods.com/index.php?/topic/7090211-removing-the-notifications-from-removeallitems-used-on-player/page-4#entry64900091
Function RemoveAllItems(ObjectReference akOriginRef, ObjectReference akDestinationRef, bool abSilent = true)
	If(Self.PopulateRecyclerContentsList(akOriginRef.GetInventoryItems()))
		akOriginRef.RemoveItem(PortableRecyclerItemList, -1, abSilent, akDestinationRef)

        ; play an audio cue for the player to know when stuff has been moved
        If abSilent
            SoundPickup.Play(PlayerRef as ObjectReference)
        EndIf

        ; avoid keeping stuff in the FormList
        PortableRecyclerItemList.Revert()
	EndIf
EndFunction

; add items to the portable recycler FormList
; adapted from code by DieFeM on the Nexus forums https://forums.nexusmods.com/index.php?/topic/7090211-removing-the-notifications-from-removeallitems-used-on-player/page-4#entry64900091
bool Function PopulateRecyclerContentsList(Form[] akItems)
	int index = 0
	While index < akItems.Length
        PortableRecyclerItemList.AddForm(akItems[index])
		index += 1
	EndWhile

    Self._DebugTrace(index + " forms added to item list")

	Return index
EndFunction