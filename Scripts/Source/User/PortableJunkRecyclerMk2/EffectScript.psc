ScriptName PortableJunkRecyclerMk2:EffectScript Extends ActiveMagicEffect
{ script that handles the recycling process }

; import the base global functions and structs
import PortableJunkRecyclerMk2:Base



; PROPERTIES
; ----------

Group Miscellaneous
    Actor Property PlayerRef Auto Mandatory
EndGroup

Group PortableJunkRecycler
    ControlScript Property PortableRecyclerControl Auto Mandatory
    Container Property PortableRecyclerContainer Auto Mandatory
    Container Property PortableRecyclerContainerFiltered Auto Mandatory
    Potion Property PortableRecyclerItem Auto Mandatory
    FormList Property PortableRecyclerItemList Auto Mandatory
EndGroup

Group Sounds
    Sound Property SoundRecycle Auto Mandatory
    Sound Property SoundPickup Auto Mandatory
EndGroup

Group Messages
    Message Property MessageAlreadyRunning Auto Mandatory
    Message Property MessageBusy Auto Mandatory
    Message Property MessageFinished Auto Mandatory
    Message Property MessageFinishedNothing Auto Mandatory
    Message Property MessageFinishedUsesLeft Auto Mandatory
    Message Property MessageFinishedNothingUsesLeft Auto Mandatory
    Message Property MessageF4SENotInstalled Auto Mandatory
EndGroup



; VARIABLES
; ---------

string ModName = "Portable Junk Recycler Mk 2" const
int MaxThreads = 16 const
var[] Threads



; EVENTS
; ------

Event OnEffectStart(Actor akTarget, Actor akCaster)
    If ! PortableRecyclerControl.ScriptExtenderInstalled
        ; F4SE is not found, abort with message
        Self._DebugTrace("F4SE is not installed; aborting")
        MessageF4SENotInstalled.Show()
        PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)
    ElseIf ! PortableRecyclerControl.MutexRunning && ! PortableRecyclerControl.MutexBusy
        ; normal mode of operation: a recycler process isn't already running nor is the quest busy
        PortableRecyclerControl.MutexRunning = true
        Debug.StartStackProfiling()

        ; record the status of the behavior overrides immediately
        bool forceMoveJunk = false
        bool forceNotMoveJunk = false
        If PortableRecyclerControl.AllowBehaviorOverrides.Value
            forceMoveJunk = PortableRecyclerControl.BehaviorOverrideForceMoveJunk
            forceNotMoveJunk = PortableRecyclerControl.BehaviorOverrideForceNotMoveJunk
        EndIf

        Self._DebugTrace("Recycler process started")

        ; set up multithreading pool
        Threads = new var[MaxThreads]
        Threads[0x0] = (PortableRecyclerControl as Quest) as WorkerThread0x0
        Threads[0x1] = (PortableRecyclerControl as Quest) as WorkerThread0x1
        Threads[0x2] = (PortableRecyclerControl as Quest) as WorkerThread0x2
        Threads[0x3] = (PortableRecyclerControl as Quest) as WorkerThread0x3
        Threads[0x4] = (PortableRecyclerControl as Quest) as WorkerThread0x4
        Threads[0x5] = (PortableRecyclerControl as Quest) as WorkerThread0x5
        Threads[0x6] = (PortableRecyclerControl as Quest) as WorkerThread0x6
        Threads[0x7] = (PortableRecyclerControl as Quest) as WorkerThread0x7
        Threads[0x8] = (PortableRecyclerControl as Quest) as WorkerThread0x8
        Threads[0x9] = (PortableRecyclerControl as Quest) as WorkerThread0x9
        Threads[0xA] = (PortableRecyclerControl as Quest) as WorkerThread0xA
        Threads[0xB] = (PortableRecyclerControl as Quest) as WorkerThread0xB
        Threads[0xC] = (PortableRecyclerControl as Quest) as WorkerThread0xC
        Threads[0xD] = (PortableRecyclerControl as Quest) as WorkerThread0xD
        Threads[0xE] = (PortableRecyclerControl as Quest) as WorkerThread0xE
        Threads[0xF] = (PortableRecyclerControl as Quest) as WorkerThread0xF

        ; get the set of multipliers that will be applied to this recycling run
        MultiplierSet multipliers = PortableRecyclerControl.GetMultipliers()
        Self._DebugTrace("Multipliers: C=" + multipliers.MultC + "; U=" + multipliers.MultU + "; R=" + multipliers.MultR + \
            "; S=" + multipliers.MultS)

        ; place a (possibly filtered) temporary container at the player
        ObjectReference primaryTempContainerRef
        ObjectReference secondaryTempContainerRef
        If PortableRecyclerControl.AllowJunkOnly.Value
            primaryTempContainerRef = PlayerRef.PlaceAtMe(PortableRecyclerContainerFiltered as Form, abForcePersist = true)
        Else
            primaryTempContainerRef = PlayerRef.PlaceAtMe(PortableRecyclerContainer as Form, abForcePersist = true)
        EndIf
        Self._DebugTrace("Primary temp container " + primaryTempContainerRef + " created (filtered: " + \
            PortableRecyclerControl.AllowJunkOnly.Value + ")")
        secondaryTempContainerRef = PlayerRef.PlaceAtMe(PortableRecyclerContainer as Form, abForcePersist = true)
        Self._DebugTrace("Secondary temp container " + secondaryTempContainerRef + " created")

        ; once the containers have been created, evaluate some options and take action based on the results: if either
        ; AllowJunkOnly or AutoMoveJunk is true, the FormList holding the recyclable items needs to be updated
        If PortableRecyclerControl.AllowJunkOnly.Value || PortableRecyclerControl.AutoMoveJunk.Value || forceMoveJunk || \
                PortableRecyclerControl.AutoRecyclingMode.Value
            ; if the recyclable items FormList already has items in it, move any of those items in the player's
            ; inventory to the primary temp container in order to reduce the number of items that
            ; Self.PopulateRecyclablesList() will need to iterate over
            If PortableRecyclerControl.RecyclableItemList.Size
                Self._DebugTrace("Moving current recyclable items from player to primary temp container")
                PlayerRef.RemoveItem(PortableRecyclerControl.RecyclableItemList.List, -1, true, primaryTempContainerRef)
            EndIf
            ; move all scrap items from the player to the secondary temp container to avoid them being added to the
            ; recyclable items list
            If PortableRecyclerControl.ScrapListAll.Size
                Self._DebugTrace("Moving scrap items from player to secondary temp container")
                PlayerRef.RemoveItem(PortableRecyclerControl.ScrapListAll.List, -1, true, secondaryTempContainerRef)
            EndIf
            ; give the game a moment to update the player's inventory data structure, otherwise the returned array
            ; from the PlayerRef.GetInventoryItems() call that comes next may still have items in it that were
            ; removed by the previous PlayerRef.RemoveItem() calls
            Utility.WaitMenuMode(0.05)
            ; populate the recyclable items list
            Self.PopulateRecyclablesList(PlayerRef.GetInventoryItems())
            ; if the AutoMoveJunk option is false, the AutoRecyclingMode option is false, and the 'forceNotMoveJunk'
            ; behavior override isn't being triggered, then any items moved to the primary temp container to aid in
            ; increasing the processing speed of PopulateRecyclablesList() need to be restored to the player inventory
            If ! (PortableRecyclerControl.AutoMoveJunk.Value || PortableRecyclerControl.AutoRecyclingMode.Value || forceMoveJunk) || \
                    forceNotMoveJunk
                Self._DebugTrace("Moving recyclable items from primary temp container back to player as per settings")
                If PortableRecyclerControl.RecyclableItemList.Size
                    primaryTempContainerRef.RemoveItem(PortableRecyclerControl.RecyclableItemList.List, -1, true, PlayerRef)
                EndIf
            ; if the AutoMoveJunk option is true, then any items that were newly added to the recyclable items list
            ; need to get moved over to the primary temp container
            Else
                If PortableRecyclerControl.RecyclableItemList.Size
                    Self._DebugTrace("Moving any newly found recyclable items from player to primary temp container")
                    PlayerRef.RemoveItem(PortableRecyclerControl.RecyclableItemList.List, -1, true, primaryTempContainerRef)
                EndIf
            EndIf
            ; move scrap items back to player
            If PortableRecyclerControl.ScrapListAll.Size
                Self._DebugTrace("Moving scrap items back from secondary temp container to player")
                secondaryTempContainerRef.RemoveItem(PortableRecyclerControl.ScrapListAll.List, -1, true, PlayerRef)
            EndIf
        EndIf

        ; if the AutoRecyclingMode option is false or one of the 'force(Not)MoveJunk' overrides is being triggered,
        ; open the container
        If ! PortableRecyclerControl.AutoRecyclingMode.Value || forceMoveJunk || forceNotMoveJunk
            ; activate the container (with 1.0s wait prior to, as specified on
            ; https://www.creationkit.com/fallout4/index.php?title=Activate_-_ObjectReference)
            Utility.Wait(1.0)
            primaryTempContainerRef.Activate(PlayerRef as ObjectReference, true)

            ; trigger a small wait because sometimes, if a player has a boatload of items in the inventory, it can cause
            ; the interface to lag just enough for the script to keep processing
            Utility.WaitMenuMode(0.5)

            ; wait a moment for the container to close and inventory to update
            Utility.Wait(0.1)
        ; otherwise, wait a moment for the container to update
        Else
            Utility.WaitMenuMode(0.1)
        EndIf

        ; play the recycling sound if there are items inside the container
        If primaryTempContainerRef.GetInventoryItems().Length
            SoundRecycle.Play(PlayerRef as ObjectReference)
        EndIf

        ; move any existing scrap items from the primary temp container to the secondary temp container
        If ! PortableRecyclerControl.AllowJunkOnly.Value
            Self._DebugTrace("Temporarily moving existing scrap from primary temp container to secondary temp container")
            primaryTempContainerRef.RemoveItem(PortableRecyclerControl.ScrapListAll.List, -1, true, secondaryTempContainerRef)
        EndIf

        ; do the recycling
        bool itemsRecycled = Self.RecycleComponents(primaryTempContainerRef, multipliers)

        ; move any previously existing scrap items that were moved into the secondary temp container back to the primary
        ; temp container
        If ! PortableRecyclerControl.AllowJunkOnly.Value && secondaryTempContainerRef.GetInventoryItems().Length
            Self._DebugTrace("Moving previously-existing scrap from secondary temp container to primary temp container")
            secondaryTempContainerRef.RemoveItem(PortableRecyclerControl.ScrapListAll.List, -1, true, primaryTempContainerRef)
            Utility.WaitMenuMode(0.05)
        EndIf

        ; move items over to the player
        Self._DebugTrace("Moving components from primary temp container to player")
        primaryTempContainerRef.RemoveItem(PortableRecyclerControl.ScrapListAll.List, -1, \
            PortableRecyclerControl.ReturnItemsSilently.Value, PlayerRef)
        Self.RemoveAllItems(primaryTempContainerRef, PlayerRef, PortableRecyclerControl.ReturnItemsSilently.Value)

        ; delete the temp containers
        Self._DebugTrace("Removing primary temp container " + primaryTempContainerRef)
        primaryTempContainerRef.Delete()
        Self._DebugTrace("Removing secondary temp container " + secondaryTempContainerRef)
        secondaryTempContainerRef.Delete()

        ; if 'limited uses' mode is on, run through the scenarios for that, otherwise just show completion message
        ; and re-add the recycler item back to the player's inventory
        If PortableRecyclerControl.HasLimitedUses.Value
            ; if things were actually recycled, increment the number of times used
            PortableRecyclerControl.NumberOfTimesUsed += itemsRecycled as int
            Self._DebugTrace("Number of times used incremented by " + itemsRecycled as int + " to " + \
                PortableRecyclerControl.NumberOfTimesUsed)
            If ! itemsRecycled
                ; if nothing was recycled, re-add the recycler item and show a message saying nothing was recycled
                Self._DebugTrace("Nothing recycled; adding item back to player's inventory")
                PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)
                MessageFinishedNothingUsesLeft.Show(Math.Max(1.0, PortableRecyclerControl.NumberOfUses.Value - \
                    PortableRecyclerControl.NumberOfTimesUsed))
            ElseIf PortableRecyclerControl.NumberOfTimesUsed < PortableRecyclerControl.NumberOfUses.Value
                ; re-add the portable recycler item if there are uses left
                Self._DebugTrace("Items recycled and max usage limit not reached; adding item back to player's inventory")
                PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)
                MessageFinishedUsesLeft.Show(PortableRecyclerControl.NumberOfUses.Value - \
                    PortableRecyclerControl.NumberOfTimesUsed)
            Else
                ; if the recycler item use limit is reached, reset the number of times used, but don't re-add the item
                Self._DebugTrace("Items recycled but max usage limit reached; NOT adding recycler back to player's inventory")
                PortableRecyclerControl.NumberOfTimesUsed = 0
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
        Debug.StopStackProfiling()
        PortableRecyclerControl.MutexRunning = false
    ElseIf PortableRecyclerControl.MutexRunning && ! PortableRecyclerControl.MutexBusy
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

; recycle the components contained in the passed ComponentMap array
; returns true if any components were actually recycled
bool Function RecycleComponents(ObjectReference akContainerRef, MultiplierSet akMultipliers)
    bool toReturn = false

    ; create array to hold function arguments
    var[] params = new var[8]
    params[0] = Utility.VarArrayToVar(PortableRecyclerControl.ComponentMappings as var[])
    params[3] = akMultipliers as MultiplierSet
    params[4] = akContainerRef as ObjectReference
    params[5] = PortableRecyclerControl.RngAffectsMult.Value as int
    params[6] = PortableRecyclerControl.ReturnAtLeastOneComponent.Value as bool
    params[7] = PortableRecyclerControl.FractionalComponentHandling.Value as int

    ; set up multithreading parameters
    string functionToCall = "RecycleComponents"
    int numItems = PortableRecyclerControl.ComponentMappings.Length
    int numThreads = Math.Min(numItems, MaxThreads) as int
    float numItemsPerThread
    If numThreads
        numItemsPerThread = numItems as float / numThreads
    EndIf
    Self._DebugTrace("There are " + numItems + " types of components to recycle; Using " + numThreads + \
        " threads for processing (" + numItemsPerThread + " components per thread)")

    ; start multithreading
    int index = 0
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

    ; go through and get the results (whether there was anything recycled or not), clearing said results from threads
    ; as a side effect
    index = 0
    While index < numThreads
        toReturn = (Threads[index] as WorkerThreadBase).GetResults()[0] as bool || toReturn
        index += 1
    EndWhile

    Return toReturn
EndFunction

; remove all items from the origin container to the destination container
; adapted from code by DieFeM on the Nexus forums:
; https://forums.nexusmods.com/index.php?/topic/7090211-removing-the-notifications-from-removeallitems-used-on-player/page-4#entry64900091
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
; adapted from code by DieFeM on the Nexus forums:
; https://forums.nexusmods.com/index.php?/topic/7090211-removing-the-notifications-from-removeallitems-used-on-player/page-4#entry64900091
bool Function PopulateRecyclerContentsList(Form[] akItems)
    ; create array to hold function arguments
    var[] params = new var[4]
    params[0] = Utility.VarArrayToVar(akItems as var[]) as var
    params[3] = PortableRecyclerItemList as FormList

    ; set up multithreading parameters
    string functionToCall = "AddItemsToList"
    int numItems = akItems.Length
    int numThreads = Math.Min(numItems, MaxThreads) as int
    float numItemsPerThread
    If numThreads
        numItemsPerThread = numItems as float / numThreads
    EndIf
    Self._DebugTrace("Passed array has " + numItems + " items; Using " + numThreads + " threads for processing (" + \
        numItemsPerThread + " items per thread)")

    ; start multithreading
    int index = 0
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

    Self._DebugTrace(numItems + " items added to recycler contents FormList")
    Return numItems
EndFunction

; finds recyclable items in the passed array and adds them to a list
Function PopulateRecyclablesList(Form[] akItems)
    ; run through the array of items and remove any that aren't MiscObjects
    int index = akItems.Length - 1
    While index >= 0
        If ! akItems[index] is MiscObject
            akItems.Remove(index)
        EndIf
        index -= 1
    EndWhile

    ; create array to hold function arguments
    var[] params = new var[4]
    params[0] = Utility.VarArrayToVar(akItems as var[]) as var
    params[3] = PortableRecyclerControl.RecyclableItemList.List as FormList

    ; set up multithreading parameters
    string functionToCall = "AddRecyclableItemsToList"
    int numItems = akItems.Length
    int numThreads = Math.Min(numItems, MaxThreads) as int
    float numItemsPerThread
    If numThreads
        numItemsPerThread = numItems as float / numThreads
    EndIf
    Self._DebugTrace("Player inventory has " + numItems + " potential junk items; Using " + numThreads + \
        " threads for processing (" + numItemsPerThread + " items per thread)")

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
    Self._DebugTrace("Threads finished")

    ; log any size change and update RecyclableItemList.Size
    int oldSize = PortableRecyclerControl.RecyclableItemList.Size
    PortableRecyclerControl.RecyclableItemList.Size = PortableRecyclerControl.RecyclableItemList.List.GetSize()
    Self._DebugTrace("Old size of list = " + oldSize + ", new size of list = " + \
        PortableRecyclerControl.RecyclableItemList.Size)
EndFunction

; this function waits for a specified number of threads to finish before returning
Function WaitForThreads(var[] akThreads, int aiNumThreads)
    ; wait for 0.1s for threads to start up
    Utility.WaitMenuMode(0.1)

    bool waitingOnThreads = true
    int index
    ; loop until threads are finished running
    While waitingOnThreads
        index = 0
        waitingOnThreads = false
        ; check every thread to see if it's still running; short-circuits if one is found running
        While ! waitingOnThreads && index < aiNumThreads
            waitingOnThreads = waitingOnThreads || (akThreads[index] as WorkerThreadBase).IsRunning()
            index += 1
        EndWhile
        ; if any threads are still running, wait for 0.1s
        If waitingOnThreads
            Self._DebugTrace("Waiting for threads to finish")
            Utility.WaitMenuMode(0.1)
        EndIf
    EndWhile
EndFunction