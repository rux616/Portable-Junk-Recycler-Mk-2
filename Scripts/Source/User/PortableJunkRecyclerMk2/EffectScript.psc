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


; PROPERTIES
; ----------

Actor                   Property PlayerRef                  Auto Const
{ player ref }
Container               Property PortableRecyclerContainer  Auto Const
{ container to open to put items in for recycling }
Potion                  Property PortableRecyclerItem       Auto Const
{ the recycler item itself }
QuestScript             Property PortableRecyclerQuest      Auto Const
{ the quest script which holds all the data for this mod }
Sound                   Property SoundRecycle      Auto Const
{ the sound to play when recycling things }

Message Property MessageAlreadyRunning Auto Const
Message Property MessageBusy Auto Const
Message Property MessageFinished Auto Const
Message Property MessageFinishedNothing Auto Const
Message Property MessageFinishedUsesLeft Auto Const
Message Property MessageFinishedNothingUsesLeft Auto Const



; VARIABLES
; ---------

string ModName = "Portable Junk Recycler Mk 2" const
FormList ScriptFilledFormList



; EVENTS
; ------

Event OnEffectStart(Actor akTarget, Actor akCaster)
    If ! PortableRecyclerQuest.MutexRunning && ! PortableRecyclerQuest.MutexBusy
        PortableRecyclerQuest.MutexRunning = true
        Self._DebugTrace("Recycler process started")

        bool itemsRecycled = false

        ; get the set of multipliers that will be applied to this recycling run
        MultiplierSet multipliers = PortableRecyclerQuest.GetMultipliers()
        Self._DebugTrace("Multipliers: C=" + multipliers.MultC + "; U=" + multipliers.MultU + "; R=" + multipliers.MultR + \
            "; S=" + multipliers.MultS)
        
        ; place the container at the player, wait, then activate it and wait a moment again
        ObjectReference containerRef = PlayerRef.PlaceAtMe(PortableRecyclerContainer as Form)
        Utility.Wait(1.0)
        Self._DebugTrace("Temporary container " + containerRef + " created")
        containerRef.Activate(PlayerRef as ObjectReference, true)
        Utility.Wait(0.1)

        ; play the recyling sound
        SoundRecycle.Play(PlayerRef as ObjectReference)
        
        ; determine whether the recycling function will add randomized adjustments
        bool randomAdjustment = PortableRecyclerQuest.RngAffectsMult.Value
        float randomMin = 0.0
        float randomMax = 0.0
        If PortableRecyclerQuest.RngAffectsMult.Value == 1
            randomMin = PortableRecyclerQuest.MultAdjustRandomMin.Value
            randomMax = PortableRecyclerQuest.MultAdjustRandomMax.Value
        EndIf

        ; remove existing scrap parts from the container and record quantities
        ExistingScrap[] existingScrapQuantitiesC = CleanExistingScrap(PortableRecyclerQuest.ComponentMapC, containerRef)
        Self._DebugTrace("Cleaned existing scrap from ComponentMapC: " + existingScrapQuantitiesC)
        ExistingScrap[] existingScrapQuantitiesU = CleanExistingScrap(PortableRecyclerQuest.ComponentMapU, containerRef)
        Self._DebugTrace("Cleaned existing scrap from ComponentMapU: " + existingScrapQuantitiesU)
        ExistingScrap[] existingScrapQuantitiesR = CleanExistingScrap(PortableRecyclerQuest.ComponentMapR, containerRef)
        Self._DebugTrace("Cleaned existing scrap from ComponentMapR: " + existingScrapQuantitiesR)
        ExistingScrap[] existingScrapQuantitiesS = CleanExistingScrap(PortableRecyclerQuest.ComponentMapS, containerRef)
        Self._DebugTrace("Cleaned existing scrap from ComponentMapS: " + existingScrapQuantitiesS)

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
                existingScrapQuantitiesC[index].ScrapPart + " re-added")
            index += 1
        EndWhile
        index = 0
        While (index < existingScrapQuantitiesU.Length)
            containerRef.AddItem(existingScrapQuantitiesU[index].ScrapPart, existingScrapQuantitiesU[index].ScrapQuantity, true)
            Self._DebugTrace(existingScrapQuantitiesU[index].ScrapQuantity + " existing " + \
                existingScrapQuantitiesU[index].ScrapPart + " re-added")
            index += 1
        EndWhile
        index = 0
        While (index < existingScrapQuantitiesR.Length)
            containerRef.AddItem(existingScrapQuantitiesR[index].ScrapPart, existingScrapQuantitiesR[index].ScrapQuantity, true)
            Self._DebugTrace(existingScrapQuantitiesR[index].ScrapQuantity + " existing " + \
                existingScrapQuantitiesR[index].ScrapPart + " re-added")
            index += 1
        EndWhile
        index = 0
        While (index < existingScrapQuantitiesS.Length)
            containerRef.AddItem(existingScrapQuantitiesS[index].ScrapPart, existingScrapQuantitiesS[index].ScrapQuantity, true)
            Self._DebugTrace(existingScrapQuantitiesS[index].ScrapQuantity + " existing " + \
                existingScrapQuantitiesS[index].ScrapPart + " re-added")
            index += 1
        EndWhile

        ; move items over to the intermediate container player
        Self._DebugTrace("Moving components from temp container to player")
        ScriptFilledFormList = Game.GetFormFromFile(0x0818, ModName + ".esp") as FormList
        Self.RemoveAllItems(containerRef, PlayerRef)
        ; containerRef.RemoveAllItems(PlayerRef as ObjectReference)

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
        MessageAlreadyRunning.Show()
        Self._DebugTrace("Recycler process already running")
        PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)
    Else
        ; the quest script is processing something in the background, tell the user to give it a few seconds to finish
        MessageBusy.Show()
        Self._DebugTrace("Quest script is busy")
        PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)
    EndIf
EndEvent



; FUNCTIONS
; ---------

; add a bit of text to traces going into the papyrus user log
Function _DebugTrace(string asMessage, int aiSeverity = 0) DebugOnly
    Debug.TraceUser(ModName, "EffectScript: " + asMessage, aiSeverity)
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
            akContainerRef.RemoveItem(toAdd.ScrapPart, toAdd.ScrapQuantity, true)
            Self._DebugTrace(toAdd.ScrapQuantity + " existing " + toAdd.ScrapPart + " found and removed")
        EndIf
        index += 1
    EndWhile

    Return toReturn
EndFunction

; recycle the components contained in the passed componentmap array
; returns true if any components were actually recycled
bool Function RecycleComponents(ComponentMap[] akComponentMap, float afScrapMultiplier, ObjectReference akContainerRef, \
    bool abRandomAdjustment, float afRandomMin, float afRandomMax)
    bool toReturn = false
    float componentQuantity = 0.0

    ; set basic multiplier value
    float scrapMultiplier = afScrapMultiplier

    int index = 0
    While index < akComponentMap.Length
        Self._DebugTrace("Component: " + ConvertIDToHex(akComponentMap[index].ComponentPart.GetFormID()) + \
            ", Scrap: " + ConvertIDToHex(akComponentMap[index].ScrapPart.GetFormID()))

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

bool Function FillFormList(Form[] akItems)
	ScriptFilledFormList.Revert()
	int i = 0
	While i < akItems.Length
        ScriptFilledFormList.AddForm(akItems[i])
		i += 1
	EndWhile
	Return ScriptFilledFormList.GetSize()
EndFunction

Function RemoveAllItems(ObjectReference akOriginContainerRef, ObjectReference akDestContainerRef, bool abSilent = true)
	If(FillFormList(akOriginContainerRef.GetInventoryItems()))
		akOriginContainerRef.RemoveItem(ScriptFilledFormList, -1, abSilent, akDestContainerRef)
	EndIf
EndFunction