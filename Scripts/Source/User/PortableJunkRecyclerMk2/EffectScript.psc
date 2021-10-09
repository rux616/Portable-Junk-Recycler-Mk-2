ScriptName PortableJunkRecyclerMk2:EffectScript Extends ActiveMagicEffect
{ script that handles the recycling process }

; import the base script to get access to the common structs
import PortableJunkRecyclerMk2:Base

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

        ; move items over to the intermediate container player
        containerRef.RemoveAllItems(PlayerRef as ObjectReference)

        ; delete the containers
        containerRef.Delete()

        ; if 'limited uses' mode is on, run through the scenarios for that, otherwise just show completion message
        ; and re-add the recycler item back to the player's inventory
        If PortableRecyclerQuest.HasLimitedUses.Value
            ; if things were actually recycled, increment the number of times used
            PortableRecyclerQuest.NumberOfTimesUsed += itemsRecycled as int
            If ! itemsRecycled
                ; if nothing was recycled, re-add the recycler item and show a message saying nothing was recycled
                PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)
                MessageFinishedNothingUsesLeft.Show(PortableRecyclerQuest.NumberOfUses.Value - \
                    PortableRecyclerQuest.NumberOfTimesUsed)
            ElseIf PortableRecyclerQuest.NumberOfTimesUsed < PortableRecyclerQuest.NumberOfUses.Value
                ; re-add the portable recycler item if there are uses left
                PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)
                MessageFinishedUsesLeft.Show(PortableRecyclerQuest.NumberOfUses.Value - \
                    PortableRecyclerQuest.NumberOfTimesUsed)
            Else
                ; if the recycler item use limit is reached, reset the number of times used, but don't re-add the item
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

; recycle the components contained in the passed componentmap array
; returns true if any components were actually recycled
bool Function RecycleComponents(ComponentMap[] akComponentMap, float afScrapMultiplier, ObjectReference akContainerRef, \
    bool abRandomAdjustment, float afRandomMin, float afRandomMax)
    bool toReturn = false
    float componentQuantity = 0.0
    int existingScrapQuantity = 0

    ; set basic multiplier value
    float scrapMultiplier = afScrapMultiplier

    int index = 0
    While index < akComponentMap.Length
        Self._DebugTrace("Component: " + ConvertIDToHex(akComponentMap[index].ComponentPart.GetFormID()) + \
            ", Scrap: " + ConvertIDToHex(akComponentMap[index].ScrapPart.GetFormID()))

        ; get the quantity of a certain component
        componentQuantity = akContainerRef.GetComponentCount(akComponentMap[index].ComponentPart)
        Self._DebugTrace("Component quantity (Initial) = " + componentQuantity)

        ; get the quantity of any scrap parts put into the container
        existingScrapQuantity = akContainerRef.GetItemCount(akComponentMap[index].ScrapPart)
        Self._DebugTrace("Scrap quantity already in container = " + existingScrapQuantity)

        if componentQuantity - existingScrapQuantity > 0.0
            ; since there are components to work on, signal that recycling happened
            toReturn = true

            If abRandomAdjustment
                ; use randomized multiplier adjustment for each individual component
                float randomMultAdjust = Utility.RandomFloat(afRandomMin, afRandomMax)
                scrapMultiplier = afScrapMultiplier + randomMultAdjust
                Self._DebugTrace("Adjustment (Random): " + randomMultAdjust)
                Self._DebugTrace("Multiplier: " + scrapMultiplier)
            EndIf

            ; remove that quantity of component from the inventory
            akContainerRef.RemoveComponents(akComponentMap[index].ComponentPart, componentQuantity as int, true)

            ; remove existing scrap parts from calculations
            componentQuantity -= existingScrapQuantity

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

            ; add the modified quantity of components plus any scrap parts back to the inventory
            akContainerRef.AddItem(akComponentMap[index].ScrapPart, componentQuantity as int + existingScrapQuantity, true)
            Self._DebugTrace("Component quantity (Final) = " + componentQuantity as int)
        EndIf  

        index += 1
    EndWhile

    Return toReturn
EndFunction