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



ScriptName PortableJunkRecyclerMk2:EffectScript Extends ActiveMagicEffect
{ script that handles the recycling process }

; import the base global functions and structs
import PortableJunkRecyclerMk2:Base



; PROPERTIES
; ----------

Group Miscellaneous
    Actor Property PlayerRef Auto Mandatory
    ThreadManager Property ThreadManager Auto Mandatory
EndGroup

Group PortableJunkRecycler
    ControlScript Property PortableRecyclerControl Auto Mandatory
    Container Property PortableRecyclerContainer Auto Mandatory
    Container Property PortableRecyclerContainerFiltered Auto Mandatory
    Potion Property PortableRecyclerItem Auto Mandatory
    FormListWrapper Property PortableRecyclerContents Auto Mandatory
    Container Property NeverAutoTransferContainer Auto Mandatory
    Container Property AlwaysAutoTransferContainer Auto Mandatory
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
    Message Property MessageEditNeverAutoTransferListModeBox Auto Mandatory
    Message Property MessageEditNeverAutoTransferListModeNotification Auto Mandatory
    Message Property MessageEditAlwaysAutoTransferListModeBox Auto Mandatory
    Message Property MessageEditAlwaysAutoTransferListModeNotification Auto Mandatory
EndGroup



; VARIABLES
; ---------

string ModName = "Portable Junk Recycler Mk 2" const
int MaxThreads = 16 const
var[] Threads

ObjectReference TempContainerPrimary
ObjectReference TempContainerSecondary
bool AsyncSubprocessComplete = false



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

        ; record the states of the hotkeys immediately
        bool hotkeyRetain = PortableRecyclerControl.HotkeyForceRetainJunk
        bool hotkeyTransfer = PortableRecyclerControl.HotkeyForceTransferJunk
        bool hotkeyEdit = PortableRecyclerControl.HotkeyEditAutoTransferLists
        Self._DebugTrace("Hotkeys: hotkeyRetain = " + hotkeyRetain + ", hotkeyTransfer = " + hotkeyTransfer + \
            ", hotkeyEdit = " + hotkeyEdit)

        ; establish some convenience variables
        bool editNeverTransferList = hotkeyEdit && hotkeyRetain
        bool editAlwaysTransferList = hotkeyEdit && hotkeyTransfer
        bool useFilteredContainer = editNeverTransferList || editAlwaysTransferList || PortableRecyclerControl.AllowJunkOnly.Value

        ; place temp containers at the player; if the 'Allow Junk Only' option is turned on, or the player wants to edit an
        ; auto transfer list, a filtered container is placed
        If useFilteredContainer
            TempContainerPrimary = PlayerRef.PlaceAtMe(PortableRecyclerContainerFiltered as Form, abForcePersist = true)
        Else
            TempContainerPrimary = PlayerRef.PlaceAtMe(PortableRecyclerContainer as Form, abForcePersist = true)
        EndIf
        Self._DebugTrace("Primary temp container " + TempContainerPrimary + " created (filtered: " + useFilteredContainer + ")")
        TempContainerSecondary = PlayerRef.PlaceAtMe(PortableRecyclerContainer as Form, abForcePersist = true)
        Self._DebugTrace("Secondary temp container " + TempContainerSecondary + " created")

        ObjectReference editListContainer = None

        If editNeverTransferList
            editListContainer = PlayerRef.PlaceAtMe(NeverAutoTransferContainer as Form, abForcePersist = true)
            Self._DebugTrace("List edit container " + editListContainer + " created")
            Self._DebugTrace("Editing 'Never Automatically Transfer' list")
            Self.EditAutoTransferList(PortableRecyclerControl.NeverAutoTransferList, editListContainer, \
                MessageEditNeverAutoTransferListModeBox, MessageEditNeverAutoTransferListModeNotification)
        ElseIf editAlwaysTransferList
            editListContainer = PlayerRef.PlaceAtMe(AlwaysAutoTransferContainer as Form, abForcePersist = true)
            Self._DebugTrace("List edit container " + editListContainer + " created")
            Self._DebugTrace("Editing 'Always Automatically Transfer' list")
            Self.EditAutoTransferList(PortableRecyclerControl.AlwaysAutoTransferList, editListContainer, \
                MessageEditAlwaysAutoTransferListModeBox, MessageEditAlwaysAutoTransferListModeNotification)
        Else
            If PortableRecyclerControl.AllowBehaviorOverrides.Value
                Self.Recycle(hotkeyRetain, hotkeyTransfer)
            Else
                Self.Recycle(false, false)
            EndIf
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
    string baseMessage = "EffectScript: " const
    If aiSeverity == 0
        Debug.TraceUser(ModName, baseMessage + asMessage)
    ElseIf aiSeverity == 1
        Debug.TraceUser(ModName, "WARNING: " + baseMessage + asMessage)
    ElseIf aiSeverity == 2
        Debug.TraceUser(ModName, "ERROR: " + baseMessage + asMessage)
    EndIf
EndFunction

; handle the recycling functionality of the device
Function Recycle(bool abForceRetainJunk, bool abForceTransferJunk)
    Self._DebugTrace("Recycler process started")

    ; set some convenience variables

    ; check to see whether the player is at a player-owned settlement
    bool playerAtOwnedWorkshop = PortableRecyclerControl.IsPlayerAtOwnedWorkshop()

    ; junk will be automatically transferred under the following conditions:
    ;   - the ForceRetainJunk hotkey IS pressed && the ForceTransferJunk hotkey IS pressed
    ;   - the ForceRetainJunk hotkey IS NOT pressed && the ForceTransferJunk hotkey IS pressed
    ;   - the ForceRetainJunk hotkey IS NOT pressed && the AutoTransferJunk option is ON
    ;   - the ForceRetainJunk hotkey IS NOT pressed && the AutoRecycleMode option is ON
    ; simplified:
    ;   - the ForceTransferJunk hotkey IS pressed
    ;   - the ForceRetainJunk hotkey IS NOT pressed && the AutoTransferJunk option is ON
    ;   - the ForceRetainJunk hotkey IS NOT pressed && the AutoRecycleMode option is ON
    bool transferJunk = abForceTransferJunk || (! abForceRetainJunk && PortableRecyclerControl.AutoTransferJunk.Value) || \
        (! abForceRetainJunk && PortableRecyclerControl.AutoRecyclingMode.Value)
    Self._DebugTrace("Transfer junk: " + transferJunk)

    ; all junk will be automatically transferred under the following conditions (otherwise just low component weight ratio items):
    ;   - the TransferLowWeightRatioItems option is OFF
    ;   - the ForceTransferJunk hotkey IS pressed && the ForceRetainJunk hotkey IS NOT pressed
    ;   - the player IS in a player-owned settlement && the TransferLowWeightRatioItems option is set to 'not in player-owned settlements'
    ;   - the player IS NOT in a player-owned settlement && the TransferLowWeightRatioItems option is set to 'in player-owned settlements'
    bool transferAllJunk = ! PortableRecyclerControl.TransferLowWeightRatioItems.Value || \
        (abForceTransferJunk && ! abForceRetainJunk) || \
        (playerAtOwnedWorkshop && PortableRecyclerControl.TransferLowWeightRatioItems.Value == 2) || \
        (! playerAtOwnedWorkshop && PortableRecyclerControl.TransferLowWeightRatioItems.Value == 1)
    Self._DebugTrace("Transfer ALL junk: " + transferAllJunk)

    ; the recyclable item FormList will be updated under the following conditions:
    ;   - junk will be automatically transferred
    ;   - the AllowJunkOnly option is ON
    bool updateRecyclableList = transferJunk || PortableRecyclerControl.AllowJunkOnly.Value
    Self._DebugTrace("Update recyclables list: " + updateRecyclableList)

    ; the container will be opened under the following conditions:
    ;   - the AutoRecyclingMode option is ON && the ForceRetainJunk hotkey IS pressed && the ForceTransferJunk hotkey IS NOT pressed
    ;   - the AutoRecyclingMode option is ON && the ForceRetainJunk hotkey IS NOT pressed && the ForceTransferJunk hotkey IS pressed
    ;   - the AutoRecyclingMode option is OFF && the ForceRetainJunk hotkey IS pressed && the ForceTransferJunk hotkey IS NOT pressed
    ;   - the AutoRecyclingMode option is OFF && the ForceRetainJunk hotkey IS NOT pressed && the ForceTransferJunk hotkey IS pressed
    ;   - the AutoRecyclingMode option is OFF && the ForceRetainJunk hotkey IS NOT pressed && the ForceTransferJunk hotkey IS NOT pressed
    ; simplified:
    ;   - the AutoRecyclingMode option is OFF && the ForceRetainJunk hotkey IS NOT pressed
    ;   - the ForceRetainJunk hotkey IS pressed && the ForceTransferJunk hotkey IS NOT pressed
    ;   - the ForceRetainJunk hotkey IS NOT pressed && the ForceTransferJunk hotkey IS pressed
    bool openContainer = (! PortableRecyclerControl.AutoRecyclingMode.Value && ! abForceRetainJunk) || \
        (abForceRetainJunk && ! abForceTransferJunk) || (! abForceRetainJunk && abForceTransferJunk)
    Self._DebugTrace("Open container: " + openContainer)

    ; get the set of multipliers that will be applied to this recycling run
    MultiplierSet multipliers = PortableRecyclerControl.GetMultipliers(playerAtOwnedWorkshop)
    Self._DebugTrace("Multipliers: C=" + multipliers.MultC + "; U=" + multipliers.MultU + "; R=" + multipliers.MultR + \
        "; S=" + multipliers.MultS)

    ; prepare parameters and call asynchronous subprocess
    var[] params = new var[3]
    params[0] = updateRecyclableList as bool
    params[1] = transferJunk as bool
    params[2] = transferAllJunk as bool
    CallFunctionNoWait("RecycleAsync", params)

    ; open (or not) the container
    If openContainer
        ; activate the container (with 1.0s wait prior to, as specified on
        ; https://www.creationkit.com/fallout4/index.php?title=Activate_-_ObjectReference)
        Utility.Wait(1.0)
        ; wait for the async subprocess to complete
        Self.WaitForAsyncSubprocess()
        TempContainerPrimary.Activate(PlayerRef as ObjectReference, true)

        ; trigger a small wait once the container is open because sometimes, if a player has a boatload of items in the
        ; inventory, it can cause the interface to lag just enough for the script to keep processing
        Utility.WaitMenuMode(0.5)

        ; (triggered once container closes) wait a moment for the container inventory to update
        Utility.Wait(0.1)

    ; otherwise, simply wait a moment for the container inventory to update
    Else
        Self.WaitForAsyncSubprocess(abWaitMenuMode = true)
        Utility.WaitMenuMode(0.1)
    EndIf

    ; play the recycling sound if there are items inside the container
    If TempContainerPrimary.GetItemCount()
        SoundRecycle.Play(PlayerRef as ObjectReference)
    EndIf

    ; move any existing scrap items from the primary temp container to the secondary temp container
    If ! PortableRecyclerControl.AllowJunkOnly.Value
        Self._DebugTrace("Temporarily moving existing scrap from primary temp container to secondary temp container")
        TempContainerPrimary.RemoveItem(PortableRecyclerControl.ScrapListAll.List, -1, true, TempContainerSecondary)
    EndIf

    ; do the recycling
    bool itemsRecycled = ThreadManager.RecycleComponents(\
        PortableRecyclerControl.ComponentMappings, \
        multipliers, \
        TempContainerPrimary, \
        PortableRecyclerControl.RngAffectsMult.Value, \
        PortableRecyclerControl.ReturnAtLeastOneComponent.Value, \
        PortableRecyclerControl.FractionalComponentHandling.Value \
    )
    Self._DebugTrace("Items recycled? " + itemsRecycled)

    ; move any previously existing scrap items that were moved into the secondary temp container back to the primary
    ; temp container
    If ! PortableRecyclerControl.AllowJunkOnly.Value && TempContainerSecondary.GetItemCount()
        Self._DebugTrace("Moving previously-existing scrap from secondary temp container to primary temp container")
        TempContainerSecondary.RemoveItem(PortableRecyclerControl.ScrapListAll.List, -1, true, TempContainerPrimary)
        Utility.WaitMenuMode(0.05)
    EndIf

    ; move items over to the player
    bool itemsToMove = false
    If TempContainerPrimary.GetItemCount()
        itemsToMove = true
    EndIf
    Self._DebugTrace("Moving components from primary temp container to player")
    TempContainerPrimary.RemoveItem(PortableRecyclerControl.ScrapListAll.List, -1, \
        PortableRecyclerControl.ReturnItemsSilently.Value, PlayerRef)
    Self._DebugTrace("Moving all non-components from primary temp container to player")
    Self.RemoveAllItems(TempContainerPrimary, PlayerRef, PortableRecyclerControl.ReturnItemsSilently.Value)

    ; play an audio cue for the player to know when stuff has been moved
    If itemsToMove
        SoundPickup.Play(PlayerRef)
    EndIf

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

; function to do work asynchronously (via CallFunctionNoWait) while waiting for the container to open
Function RecycleAsync(bool abUpdateRecyclableList, bool abTransferJunk, bool abTransferAllJunk)
    Debug.StartStackProfiling()

    ; update the recyclable item list if needed
    If abUpdateRecyclableList
        If PortableRecyclerControl.UseDirectMoveRecyclableItemListUpdate.Value
            Self.UpdateRecyclableItemListDirectMove()
        Else
            Self.UpdateRecyclableItemListNoTouch()
        EndIf
    EndIf

    ; transfer (or not) junk to the container
    If abTransferJunk
        If abTransferAllJunk
            ; if all junk is slated to be transferred, transfer everything as long as there are items in the list
            If PortableRecyclerControl.RecyclableItemList.Size
                PlayerRef.RemoveItem(PortableRecyclerControl.RecyclableItemList.List, -1, true, TempContainerPrimary)
            EndIf
        Else
            ; transfer items that have low component weight ratios as long as there are items in the list
            If PortableRecyclerControl.LowWeightRatioItemList.Size
                PlayerRef.RemoveItem(PortableRecyclerControl.LowWeightRatioItemList.List, -1, true, TempContainerPrimary)
            EndIf
        EndIf
    Else
        If PortableRecyclerControl.UseAlwaysAutoTransferList.Value && PortableRecyclerControl.AlwaysAutoTransferList.Size
            PlayerRef.RemoveItem(PortableRecyclerControl.AlwaysAutoTransferList.List, -1, true, TempContainerPrimary)
        EndIf
    EndIf

    ; if the 'always auto transfer' and the 'never auto transfer' lists have a conflict (i.e. there's the same item
    ; on both), the 'never' list always wins if it's active
    If PortableRecyclerControl.UseNeverAutoTransferList.Value && PortableRecyclerControl.NeverAutoTransferList.Size
        TempContainerPrimary.RemoveItem(PortableRecyclerControl.NeverAutoTransferList.List, -1, true, PlayerRef)
    EndIf

    ; signal that the function is complete
    AsyncSubprocessComplete = true

    Debug.StopStackProfiling()
EndFunction

; handles editing an auto transfer list
Function EditAutoTransferList(FormListWrapper akAutoTransferList, ObjectReference akContainer, Message akModeMessageBox, \
        Message akModeMessageNotification)
    Self._DebugTrace("Started editing Auto Transfer List: " + akAutoTransferList.List)

    ; prepare parameters and call asynchronous subprocess
    var[] params = new var[2]
    params[0] = akAutoTransferList as FormListWrapper
    params[1] = akContainer as ObjectReference
    CallFunctionNoWait("EditAutoTransferListAsync", params)

    ; activate the container (with 1.0s wait prior to, as specified on
    ; https://www.creationkit.com/fallout4/index.php?title=Activate_-_ObjectReference)
    Utility.Wait(1.0)
    ; wait for async subprocess
    Self.WaitForAsyncSubprocess()
    ; show notification stating the player is in list editing mode if the list size is not 0
    If akAutoTransferList.Size
        akModeMessageNotification.Show()
    EndIf
    akContainer.Activate(PlayerRef as ObjectReference, true)

    ; show message box stating the player is in list editing mode if the list size is 0
    If ! akAutoTransferList.Size
        akModeMessageBox.Show()
    EndIf

    ; trigger a small wait once the container is open because sometimes, if a player has a boatload of items in the
    ; inventory, it can cause the interface to lag just enough for the script to keep processing
    Utility.WaitMenuMode(0.5)

    ; (triggered once container closes) wait a moment for the container inventory to update
    Utility.Wait(0.1)

    ; clear and re-populate the FormList
    Form[] containerInventory = akContainer.GetInventoryItems()
    akAutoTransferList.List.Revert()
    ThreadManager.AddItemsToList(containerInventory, akAutoTransferList)

    ; move excess (>1) items back to the player
    If containerInventory.Length
        ThreadManager.LeaveOnlyXItems(containerInventory, akContainer, PlayerRef, 1, \
            PortableRecyclerControl.ReturnItemsSilently.Value)
    EndIf

    ; add the recycler item back to the player
    PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)

    Self._DebugTrace("Finished editing Auto Transfer List")
EndFunction

; function to do work asynchronously (via CallFunctionNoWait) while waiting for the container to open
Function EditAutoTransferListAsync(FormListWrapper akAutoTransferList, ObjectReference akContainer)
    Debug.StartStackProfiling()

    ; update the FormList holding the recyclable items
    If PortableRecyclerControl.UseDirectMoveRecyclableItemListUpdate.Value
        Self.UpdateRecyclableItemListDirectMove()
    Else
        Self.UpdateRecyclableItemListNoTouch()
    EndIf

    ; populate the container with 1 of every item in the list
    If akAutoTransferList.Size
        ThreadManager.AddListItemsToInventory(akAutoTransferList, akContainer, 1)
    EndIf

    ; signal that the function is complete
    AsyncSubprocessComplete = true

    Debug.StopStackProfiling()
EndFunction

; updates the FormList containing recyclable items
Function UpdateRecyclableItemListDirectMove()
    ; reduce the number of MiscObjects left in the player's inventory in an effort to reduce the number of items
    ; this function will need to iterate over
    ; known recyclable items
    If PortableRecyclerControl.RecyclableItemList.Size
        Self._DebugTrace("Moving currently known recyclable items from player to secondary temp container")
        PlayerRef.RemoveItem(PortableRecyclerControl.RecyclableItemList.List, -1, true, TempContainerSecondary)
    EndIf
    ; mods
    Self._DebugTrace("Moving mods from player to secondary temp container")
    PlayerRef.RemoveItem(Game.GetFormFromFile(0x135C17, "Fallout4.esm"), -1, true, TempContainerSecondary)
    ; scrap items
    If PortableRecyclerControl.ScrapListAll.Size
        Self._DebugTrace("Moving scrap items from player to secondary temp container")
        PlayerRef.RemoveItem(PortableRecyclerControl.ScrapListAll.List, -1, true, TempContainerSecondary)
    EndIf

    ; give the game a moment to update the player's inventory data structure, otherwise the returned array
    ; from the GetInventoryItems() call that comes next may still have items in it that were removed by the
    ; previous RemoveItem() calls
    Utility.WaitMenuMode(0.04)

    ; get the list of forms in the player's inventory
    Form[] playerInventory = PlayerRef.GetInventoryItems()

    ; throw out all forms that are not MiscObjects
    int oldSize = playerInventory.Length
    int index = playerInventory.Length - 1
    While index >= 0
        If ! playerInventory[index] is MiscObject
            playerInventory.Remove(index)
        EndIf
        index -= 1
    EndWhile
    Self._DebugTrace("Pruned " + (oldSize - playerInventory.Length) + " non-MiscObjects from inventory array")

    ; record current size of lists and prep an array of current components
    oldSize = PortableRecyclerControl.RecyclableItemList.Size
    int oldSize2 = PortableRecyclerControl.LowWeightRatioItemList.Size
    Component[] components = new Component[0]
    index = 0
    While index < PortableRecyclerControl.ComponentMappings.Length
        components.Add(PortableRecyclerControl.ComponentMappings[index].ComponentPart)
        index += 1
    EndWhile

    ; actually add any recyclables to the FormList
    ThreadManager.AddRecyclableItemsToList(playerInventory, PortableRecyclerControl.RecyclableItemList, \
        PortableRecyclerControl.LowWeightRatioItemList, PortableRecyclerControl.ComponentMappings, components)
    playerInventory = None

    ; log any size changes
    Self._DebugTrace("Recyclable item list: old size = " + oldSize + ", new size = " + \
        PortableRecyclerControl.RecyclableItemList.Size)
    Self._DebugTrace("Low weight ratio item list: old size = " + oldSize2 + ", new size = " + \
        PortableRecyclerControl.LowWeightRatioItemList.Size)

    ; move any items that were moved to the secondary temp container back to the player
    ; known recyclable items
    If PortableRecyclerControl.RecyclableItemList.Size
        Self._DebugTrace("Moving recyclable items back from secondary temp container to player")
        TempContainerSecondary.RemoveItem(PortableRecyclerControl.RecyclableItemList.List, -1, true, PlayerRef)
    EndIf
    ; mods
    Self._DebugTrace("Moving mods back from secondary temp container to player")
    PlayerRef.RemoveItem(Game.GetFormFromFile(0x135C17, "Fallout4.esm"), -1, true, TempContainerSecondary)
    ; scrap items
    If PortableRecyclerControl.ScrapListAll.Size
        Self._DebugTrace("Moving scrap items back from secondary temp container to player")
        TempContainerSecondary.RemoveItem(PortableRecyclerControl.ScrapListAll.List, -1, true, PlayerRef)
    EndIf
EndFunction

; updates the FormList containing recyclable items without moving any items from the player inventory, but
; is a bit slower
Function UpdateRecyclableItemListNoTouch()
    ; get the list of forms in the player's inventory
    Form[] playerInventory = PlayerRef.GetInventoryItems()

    ; throw out all forms that are not MiscObjects
    int oldSize = playerInventory.Length
    int index = playerInventory.Length - 1
    While index >= 0
        If ! playerInventory[index] is MiscObject
            playerInventory.Remove(index)
        EndIf
        index -= 1
    EndWhile
    Self._DebugTrace("Pruned " + (oldSize - playerInventory.Length) + " non-MiscObjects from inventory array")

    ; add 1 of every MiscObject currently left in the array to the secondary temp container
    ThreadManager.AddArrayItemsToInventory(playerInventory, TempContainerSecondary, 1)
    playerInventory = None

    ; remove as many MiscObjects as possible from the inventory to reduce the number of items that this function
    ; needs to iterate over
    ; known recyclable items
    If PortableRecyclerControl.RecyclableItemList.Size
        Self._DebugTrace("Removing currently known recyclable items from the temp container")
        TempContainerSecondary.RemoveItem(PortableRecyclerControl.RecyclableItemList.List, -1, true, None)
    EndIf
    ; mods
    Self._DebugTrace("Removing mods from the temp container")
    TempContainerSecondary.RemoveItem(Game.GetFormFromFile(0x135C17, "Fallout4.esm"), -1, true, None)
    ; scrap items
    If PortableRecyclerControl.ScrapListAll.Size
        Self._DebugTrace("Removing scrap items from the temp container")
        TempContainerSecondary.RemoveItem(PortableRecyclerControl.ScrapListAll.List, -1, true, None)
    EndIf

    ; give the game a moment to update the container's inventory data structure, otherwise the returned array
    ; from the GetInventoryItems() call that comes next may still have items in it that were removed by the
    ; previous RemoveItem() calls
    Utility.WaitMenuMode(0.04)

    ; record current size of lists and prep an array of current components
    oldSize = PortableRecyclerControl.RecyclableItemList.Size
    int oldSize2 = PortableRecyclerControl.LowWeightRatioItemList.Size
    Component[] components = new Component[0]
    index = 0
    While index < PortableRecyclerControl.ComponentMappings.Length
        components.Add(PortableRecyclerControl.ComponentMappings[index].ComponentPart)
        index += 1
    EndWhile

    ; actually add any recyclables to the FormList
    ThreadManager.AddRecyclableItemsToList(TempContainerSecondary.GetInventoryItems(), PortableRecyclerControl.RecyclableItemList, \
        PortableRecyclerControl.LowWeightRatioItemList, PortableRecyclerControl.ComponentMappings, components)

    ; nuke remaining contents of the secondary temp container
    TempContainerSecondary.RemoveAllItems()

    ; log any size changes
    Self._DebugTrace("Recyclable item list: old size = " + oldSize + ", new size = " + \
        PortableRecyclerControl.RecyclableItemList.Size)
    Self._DebugTrace("Low weight ratio item list: old size = " + oldSize2 + ", new size = " + \
        PortableRecyclerControl.LowWeightRatioItemList.Size)
EndFunction

; remove all items from the origin container to the destination container
; inspired by code written by DieFeM on the Nexus forums:
; https://forums.nexusmods.com/index.php?/topic/7090211-removing-the-notifications-from-removeallitems-used-on-player/page-4#entry64900091
Function RemoveAllItems(ObjectReference akOriginRef, ObjectReference akDestinationRef, bool abSilent = true)
    ; add any items in the container to the list so they can be moved
    ThreadManager.AddItemsToList(akOriginRef.GetInventoryItems(), PortableRecyclerContents)

    ; if the list size is non-zero, there's something to transfer
    If(PortableRecyclerContents.Size)
        akOriginRef.RemoveItem(PortableRecyclerContents.List, -1, abSilent, akDestinationRef)

        ; avoid keeping stuff in the FormList
        PortableRecyclerContents.List.Revert()
        PortableRecyclerContents.Size = 0
    EndIf
EndFunction

; waits up to 20s for an asynchronous subprocess to complete
Function WaitForAsyncSubprocess(bool abWaitMenuMode = false)
    float waitTime = 0.1 const
    int failsafe = 200 ; 20 seconds
    While failsafe > 0 && ! AsyncSubprocessComplete
        If abWaitMenuMode
            Utility.WaitMenuMode(waitTime)
        Else
            Utility.Wait(waitTime)
        EndIf
        failsafe -= 1
    EndWhile
    If failsafe <= 0
        Self._DebugTrace("WaitForAsyncSubprocess failsafe triggered!", 2)
    EndIf
EndFunction