ScriptName PortableJunkRecyclerMk2:EffectScript Extends ActiveMagicEffect
{ script that handles the recycling process }

; import the base global functions and structs
import PortableJunkRecyclerMk2:Base



; PROPERTIES
; ----------

Group Miscellaneous
    Actor Property PlayerRef Auto Mandatory
    Quest Property ThreadContainer Auto Mandatory
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
    Message Property MessageEditAutoTransferExemptionsMode Auto Mandatory
EndGroup



; VARIABLES
; ---------

string ModName = "Portable Junk Recycler Mk 2" const
int MaxThreads = 16 const
var[] Threads

ObjectReference TempContainerPrimary
ObjectReference TempContainerSecondary



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

        ; record the status of the behavior overrides/modifiers immediately
        bool forceRetainJunk = PortableRecyclerControl.BehaviorOverrideForceRetainJunk
        bool forceTransferJunk = PortableRecyclerControl.BehaviorOverrideForceTransferJunk
        bool editAutoTransferExemptions = PortableRecyclerControl.EditAutoTransferExemptions

        ; set up multithreading pool
        Threads = new var[MaxThreads]
        Threads[0x0] = ThreadContainer as WorkerThread0x0
        Threads[0x1] = ThreadContainer as WorkerThread0x1
        Threads[0x2] = ThreadContainer as WorkerThread0x2
        Threads[0x3] = ThreadContainer as WorkerThread0x3
        Threads[0x4] = ThreadContainer as WorkerThread0x4
        Threads[0x5] = ThreadContainer as WorkerThread0x5
        Threads[0x6] = ThreadContainer as WorkerThread0x6
        Threads[0x7] = ThreadContainer as WorkerThread0x7
        Threads[0x8] = ThreadContainer as WorkerThread0x8
        Threads[0x9] = ThreadContainer as WorkerThread0x9
        Threads[0xA] = ThreadContainer as WorkerThread0xA
        Threads[0xB] = ThreadContainer as WorkerThread0xB
        Threads[0xC] = ThreadContainer as WorkerThread0xC
        Threads[0xD] = ThreadContainer as WorkerThread0xD
        Threads[0xE] = ThreadContainer as WorkerThread0xE
        Threads[0xF] = ThreadContainer as WorkerThread0xF

        ; place temp containers at the player; if the 'Allow Junk Only' option is turned on, or the player wants to edit the
        ; auto transfer exemptions list, a filtered container is placed
        If PortableRecyclerControl.AllowJunkOnly.Value || editAutoTransferExemptions
            TempContainerPrimary = PlayerRef.PlaceAtMe(PortableRecyclerContainerFiltered as Form, abForcePersist = true)
        Else
            TempContainerPrimary = PlayerRef.PlaceAtMe(PortableRecyclerContainer as Form, abForcePersist = true)
        EndIf
        Self._DebugTrace("Primary temp container " + TempContainerPrimary + " created (filtered: " + \
            PortableRecyclerControl.AllowJunkOnly.Value + ")")
        TempContainerSecondary = PlayerRef.PlaceAtMe(PortableRecyclerContainer as Form, abForcePersist = true)
        Self._DebugTrace("Secondary temp container " + TempContainerSecondary + " created")

        If ! editAutoTransferExemptions
            Self.Recycle(forceRetainJunk, forceTransferJunk)
        Else
            Self.EditAutoTransferExemptions()
        EndIf

        ; delete the temp containers
        Self._DebugTrace("Removing primary temp container " + TempContainerPrimary)
        TempContainerPrimary.Delete()
        TempContainerPrimary = None
        Self._DebugTrace("Removing secondary temp container " + TempContainerSecondary)
        TempContainerSecondary.Delete()
        TempContainerSecondary = None

        ; enable the recycle process to be run again
        Debug.StopStackProfiling()
        PortableRecyclerControl.MutexRunning = false
    ElseIf PortableRecyclerControl.MutexRunning && ! PortableRecyclerControl.MutexBusy
        ; another recycling process is already running, tell the user
        Self._DebugTrace("Recycler process already running")
        MessageAlreadyRunning.Show()
        PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)
    Else
        ; the control script is processing something in the background, tell the user to give it a few seconds to finish
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

; handles multithread coordination for the "RecycleComponents" function
; recycle the components contained in the passed ComponentMap array
; returns true if any components were actually recycled
; bool Function RecycleComponentsCoordinator(ObjectReference akContainerRef, MultiplierSet akMultipliers)
bool Function RecycleComponentsCoordinator(ComponentMap[] akComponentMap, MultiplierSet akMultiplierSet, \
       ObjectReference akContainerRef, int aiRandomAdjustment, bool abReturnAtLeastOneComponent, \
       int aiFractionalComponentHandling)

    bool toReturn = false

    ; create array to hold function arguments
    var[] params = new var[8]
    params[0] = Utility.VarArrayToVar(akComponentMap as var[])
    params[3] = akMultiplierSet as MultiplierSet
    params[4] = akContainerRef as ObjectReference
    params[5] = aiRandomAdjustment as int
    params[6] = abReturnAtLeastOneComponent as bool
    params[7] = aiFractionalComponentHandling as int

    ; set up multithreading parameters
    string functionToCall = "RecycleComponents"
    int numItems = akComponentMap.Length
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
    WaitForThreads(Threads, numThreads)

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
	If(Self.AddItemsToListCoordinator(akOriginRef.GetInventoryItems(), PortableRecyclerItemList))
		akOriginRef.RemoveItem(PortableRecyclerItemList, -1, abSilent, akDestinationRef)

        ; play an audio cue for the player to know when stuff has been moved
        If abSilent
            SoundPickup.Play(PlayerRef as ObjectReference)
        EndIf

        ; avoid keeping stuff in the FormList
        PortableRecyclerItemList.Revert()
	EndIf
EndFunction

; add items to a FormList
bool Function AddItemsToListCoordinator(Form[] akItems, FormList akFormList)
    ; create array to hold function arguments
    var[] params = new var[4]
    params[0] = Utility.VarArrayToVar(akItems as var[]) as var
    params[3] = akFormList as FormList

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
    WaitForThreads(Threads, numThreads)

    Self._DebugTrace(numItems + " items added to FormList")
    Return numItems
EndFunction

; handle the recycling functionality of the device
Function Recycle(bool abForceRetainJunk, bool abForceTransferJunk)
    Self._DebugTrace("Recycler process started")

    ; set some convenience variables
    ; determines whether junk is going to be transferred to the container or not
    bool transferJunk = ! abForceRetainJunk && (abForceTransferJunk || PortableRecyclerControl.AutoTransferJunk.Value || \
        PortableRecyclerControl.AutoRecyclingMode.Value)
    Self._DebugTrace("Transfer junk: " + transferJunk)
    ; determines whether the recyclable item FormList needs to be updated or not
    bool updateRecyclableList = transferJunk || PortableRecyclerControl.AllowJunkOnly.Value
    Self._DebugTrace("Update recyclables list: " + updateRecyclableList)
    ; determines whether the container will be opened
    bool openContainer = ! PortableRecyclerControl.AutoRecyclingMode.Value || abForceTransferJunk || abForceRetainJunk
    Self._DebugTrace("Open container: " + openContainer)

    ; get the set of multipliers that will be applied to this recycling run
    MultiplierSet multipliers = PortableRecyclerControl.GetMultipliers()
    Self._DebugTrace("Multipliers: C=" + multipliers.MultC + "; U=" + multipliers.MultU + "; R=" + multipliers.MultR + \
        "; S=" + multipliers.MultS)

    ; once the containers have been created, if updateRecyclableList is set to true, the FormList holding the recyclable
    ; items needs to be updated
    If updateRecyclableList
        Self.UpdateRecyclableItemList(transferJunk)
    EndIf

    ; if the AutoRecyclingMode option is false or one of the 'force{Retain,Transfer}Junk' overrides is being triggered,
    ; open the container
    If openContainer
        ; activate the container (with 1.0s wait prior to, as specified on
        ; https://www.creationkit.com/fallout4/index.php?title=Activate_-_ObjectReference)
        Utility.Wait(1.0)
        TempContainerPrimary.Activate(PlayerRef as ObjectReference, true)

        ; trigger a small wait once the container is open because sometimes, if a player has a boatload of items in the
        ; inventory, it can cause the interface to lag just enough for the script to keep processing
        Utility.WaitMenuMode(0.5)

        ; (triggered once container closes) wait a moment for the container inventory to update
        Utility.Wait(0.1)

    ; otherwise, simply wait a moment for the container inventory to update
    Else
        Utility.WaitMenuMode(0.1)
    EndIf

    ; play the recycling sound if there are items inside the container
    If TempContainerPrimary.GetInventoryItems().Length
        SoundRecycle.Play(PlayerRef as ObjectReference)
    EndIf

    ; move any existing scrap items from the primary temp container to the secondary temp container
    If ! PortableRecyclerControl.AllowJunkOnly.Value
        Self._DebugTrace("Temporarily moving existing scrap from primary temp container to secondary temp container")
        TempContainerPrimary.RemoveItem(PortableRecyclerControl.ScrapListAll.List, -1, true, TempContainerSecondary)
    EndIf

    ; do the recycling
    ;bool itemsRecycled = Self.RecycleComponentsCoordinator(TempContainerPrimary, multipliers)
    bool itemsRecycled = Self.RecycleComponentsCoordinator(PortableRecyclerControl.ComponentMappings, multipliers, \
        TempContainerPrimary, PortableRecyclerControl.RngAffectsMult.Value, \
        PortableRecyclerControl.ReturnAtLeastOneComponent.Value, PortableRecyclerControl.FractionalComponentHandling.Value)

    ; move any previously existing scrap items that were moved into the secondary temp container back to the primary
    ; temp container
    If ! PortableRecyclerControl.AllowJunkOnly.Value && TempContainerSecondary.GetInventoryItems().Length
        Self._DebugTrace("Moving previously-existing scrap from secondary temp container to primary temp container")
        TempContainerSecondary.RemoveItem(PortableRecyclerControl.ScrapListAll.List, -1, true, TempContainerPrimary)
        Utility.WaitMenuMode(0.05)
    EndIf

    ; move items over to the player
    Self._DebugTrace("Moving components from primary temp container to player")
    TempContainerPrimary.RemoveItem(PortableRecyclerControl.ScrapListAll.List, -1, \
        PortableRecyclerControl.ReturnItemsSilently.Value, PlayerRef)
    Self.RemoveAllItems(TempContainerPrimary, PlayerRef, PortableRecyclerControl.ReturnItemsSilently.Value)

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
EndFunction

; updates the FormList containing recyclable items
Function UpdateRecyclableItemList(bool abTransferJunk)
    ; if the recyclable items FormList already has items in it, move any of those items in the player's inventory to the primary
    ; temp container in order to reduce the number of items that this function will need to iterate over
    If PortableRecyclerControl.RecyclableItemList.Size
        Self._DebugTrace("Moving current recyclable items from player to primary temp container")
        PlayerRef.RemoveItem(PortableRecyclerControl.RecyclableItemList.List, -1, true, TempContainerPrimary)
    EndIf

    ; move all scrap items from the player to the secondary temp container to avoid them being added to the
    ; recyclable items list
    If PortableRecyclerControl.ScrapListAll.Size
        Self._DebugTrace("Moving scrap items from player to secondary temp container")
        PlayerRef.RemoveItem(PortableRecyclerControl.ScrapListAll.List, -1, true, TempContainerSecondary)
    EndIf

    ; give the game a moment to update the player's inventory data structure, otherwise the returned array
    ; from the PlayerRef.GetInventoryItems() call that comes next may still have items in it that were
    ; removed by the previous PlayerRef.RemoveItem() calls
    Utility.WaitMenuMode(0.05)

    ; actually add any recyclables to the FormList
    AddRecyclableItemsToListCoordinator(PlayerRef.GetInventoryItems(), PortableRecyclerControl.RecyclableItemList.List)

    ; log any size change and update RecyclableItemList.Size
    int oldSize = PortableRecyclerControl.RecyclableItemList.Size
    PortableRecyclerControl.RecyclableItemList.Size = PortableRecyclerControl.RecyclableItemList.List.GetSize()
    Self._DebugTrace("Old size of list = " + oldSize + ", new size of list = " + \
        PortableRecyclerControl.RecyclableItemList.Size)

    ; if the abTransferJunk flag is false, then any items moved to the primary temp container to aid in
    ; increasing the processing speed of this function need to be restored to the player inventory
    If ! abTransferJunk
        Self._DebugTrace("Moving recyclable items from primary temp container back to player as per settings")
        If PortableRecyclerControl.RecyclableItemList.Size
            TempContainerPrimary.RemoveItem(PortableRecyclerControl.RecyclableItemList.List, -1, true, PlayerRef)
        EndIf

    ; alternatively, if the abTransferJunk flag is true, then any items that were newly added to the recyclable
    ; items list need to get moved over to the primary temp container, and exempt items need to be moved back
    Else
        If PortableRecyclerControl.RecyclableItemList.Size
            Self._DebugTrace("Moving any newly found recyclable items from player to primary temp container")
            PlayerRef.RemoveItem(PortableRecyclerControl.RecyclableItemList.List, -1, true, TempContainerPrimary)
        EndIf
        If PortableRecyclerControl.AutoTransferExemptionsList.Size
            Self._DebugTrace("Moving any auto transfer exempt items from primary temp container to player")
            TempContainerPrimary.RemoveItem(PortableRecyclerControl.AutoTransferExemptionsList.List, -1, true, PlayerRef)
        EndIf
    EndIf

    ; move scrap items back to player
    If PortableRecyclerControl.ScrapListAll.Size
        Self._DebugTrace("Moving scrap items back from secondary temp container to player")
        TempContainerSecondary.RemoveItem(PortableRecyclerControl.ScrapListAll.List, -1, true, PlayerRef)
    EndIf
EndFunction

; handles multithread coordination for the "AddRecyclableItemsToList" function
; checks items that are passed in to see if they are recyclable and if so, add them to the specified FormList
Function AddRecyclableItemsToListCoordinator(Form[] akItems, FormList akFormList)
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
    params[3] = akFormList as FormList

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
    WaitForThreads(Threads, numThreads)
    Self._DebugTrace("Threads finished")
EndFunction

; handles editing the auto transfer exemptions list
Function EditAutoTransferExemptions()
    Self._DebugTrace("Started editing Auto Transfer Exemptions")

    ; update the FormList holding the recyclable items
    Self.UpdateRecyclableItemList(false)

    ; populate the container with 1 of every item in the exemptions list
    If PortableRecyclerControl.AutoTransferExemptionsList.Size
        Self.AddItemsCoordinator(PortableRecyclerControl.AutoTransferExemptionsList, TempContainerPrimary, 1)
    EndIf

    ; activate the container (with 1.0s wait prior to, as specified on
    ; https://www.creationkit.com/fallout4/index.php?title=Activate_-_ObjectReference)
    Utility.Wait(1.0)
    TempContainerPrimary.Activate(PlayerRef as ObjectReference, true)

    ; show message stating the player is in exemption list editing mode
    MessageEditAutoTransferExemptionsMode.Show()

    ; trigger a small wait once the container is open because sometimes, if a player has a boatload of items in the
    ; inventory, it can cause the interface to lag just enough for the script to keep processing
    Utility.WaitMenuMode(0.5)

    ; (triggered once container closes) wait a moment for the container inventory to update
    Utility.Wait(0.1)

    ; clear and re-populate the exemptions FormList
    Form[] tempContainerPrimaryInventory = TempContainerPrimary.GetInventoryItems()
    PortableRecyclerControl.AutoTransferExemptionsList.List.Revert()
    Self.AddItemsToListCoordinator(tempContainerPrimaryInventory, PortableRecyclerControl.AutoTransferExemptionsList.List)
    PortableRecyclerControl.AutoTransferExemptionsList.Size = tempContainerPrimaryInventory.Length

    ; move excess (>1) items back to the player
    If tempContainerPrimaryInventory.Length
        Self.LeaveOnlyXItemsCoordinator(tempContainerPrimaryInventory, TempContainerPrimary, PlayerRef, 1, \
            PortableRecyclerControl.ReturnItemsSilently.Value)
    EndIf

    PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)

    Self._DebugTrace("Finished editing Auto Transfer Exemptions")
EndFunction

; handles multithread coordination for the "AddItems" function
; adds a quantity of items in the passed in FormList to the inventory of the specified object reference
Function AddItemsCoordinator(FormListWrapper akFormList, ObjectReference akDestinationRef, int aiQuantity)
    ; create array to hold function arguments
    var[] params = new var[5]
    params[0] = akFormList as FormListWrapper
    params[3] = akDestinationRef as ObjectReference
    params[4] = aiQuantity as int

    ; set up multithreading parameters
    string functionToCall = "AddItems"
    int numItems = akFormList.Size
    int numThreads = Math.Min(numItems, MaxThreads) as int
    float numItemsPerThread
    If numThreads
        numItemsPerThread = numItems as float / numThreads
    EndIf
    Self._DebugTrace("Adding " + aiQuantity + " each of " + numItems + " items; Using " + numThreads + \
        " threads for processing (" + numItemsPerThread + " items per thread)")

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
    WaitForThreads(Threads, numThreads)
    Self._DebugTrace("Threads finished")
EndFunction

; handles multithread coordination for the "LeaveOnlyXItems" function
; removes all but X number of items from the origin, optionally moving them to the destination
Function LeaveOnlyXItemsCoordinator(Form[] akItems, ObjectReference akOriginRef, ObjectReference akDestinationRef, \
        int aiQuantityToLeave, bool abSilent)
    ; create array to hold function arguments
    var[] params = new var[7]
    params[0] = Utility.VarArrayToVar(akItems as var[]) as var
    params[3] = akOriginRef as ObjectReference
    params[4] = akDestinationRef as ObjectReference
    params[5] = aiQuantityToLeave as int
    params[6] = abSilent as bool

    ; set up multithreading parameters
    string functionToCall = "LeaveOnlyXItems"
    int numItems = akItems.Length
    int numThreads = Math.Min(numItems, MaxThreads) as int
    float numItemsPerThread
    If numThreads
        numItemsPerThread = numItems as float / numThreads
    EndIf
    Self._DebugTrace("Leaving only " + aiQuantityToLeave + " each of " + numItems + " items; Using " + numThreads + \
        " threads for processing (" + numItemsPerThread + " items per thread)")

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
    WaitForThreads(Threads, numThreads)
    Self._DebugTrace("Threads finished")
EndFunction