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
    Message Property MessageEditNeverAutoTransferListMode Auto Mandatory
    Message Property MessageEditAlwaysAutoTransferListMode Auto Mandatory
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
        bool forceRetainJunk = PortableRecyclerControl.HotkeyForceRetainJunk
        bool forceTransferJunk = PortableRecyclerControl.HotkeyForceTransferJunk
        bool editAutoTransferLists = PortableRecyclerControl.HotkeyEditAutoTransferLists

        ; place temp containers at the player; if the 'Allow Junk Only' option is turned on, or the player wants to edit the
        ; auto transfer exemptions list, a filtered container is placed
        If PortableRecyclerControl.AllowJunkOnly.Value || editAutoTransferLists
            TempContainerPrimary = PlayerRef.PlaceAtMe(PortableRecyclerContainerFiltered as Form, abForcePersist = true)
        Else
            TempContainerPrimary = PlayerRef.PlaceAtMe(PortableRecyclerContainer as Form, abForcePersist = true)
        EndIf
        Self._DebugTrace("Primary temp container " + TempContainerPrimary + " created (filtered: " + \
            PortableRecyclerControl.AllowJunkOnly.Value + ")")
        TempContainerSecondary = PlayerRef.PlaceAtMe(PortableRecyclerContainer as Form, abForcePersist = true)
        Self._DebugTrace("Secondary temp container " + TempContainerSecondary + " created")

        If editAutoTransferLists && forceRetainJunk
            Self.EditAutoTransferList(PortableRecyclerControl.NeverAutoTransferList, MessageEditNeverAutoTransferListMode)
        ElseIf editAutoTransferLists && forceTransferJunk
            Self.EditAutoTransferList(PortableRecyclerControl.AlwaysAutoTransferList, MessageEditAlwaysAutoTransferListMode)
        Else
            If PortableRecyclerControl.AllowBehaviorOverrides.Value
                Self.Recycle(forceRetainJunk, forceTransferJunk)
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
    Debug.TraceUser(ModName, "EffectScript: " + asMessage, aiSeverity)
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
        Self.UpdateRecyclableItemList()
    EndIf

    ; TODO? - add second FormList ('PrunedRecyclableItemList'?)that has contents of RecyclableItemList minus the
    ; contents of NeverAutoTransferList?

    ; transfer (or not) junk to the container. if the 'always auto transfer' and the 'never auto transfer' lists have
    ; a conflict (i.e. there's the same item on both), the 'never' list always wins
    If transferJunk
        If PortableRecyclerControl.RecyclableItemList.Size
            PlayerRef.RemoveItem(PortableRecyclerControl.RecyclableItemList.List, -1, true, TempContainerPrimary)
        EndIf
        If PortableRecyclerControl.UseNeverAutoTransferList.Value && PortableRecyclerControl.NeverAutoTransferList.Size
            TempContainerPrimary.RemoveItem(PortableRecyclerControl.NeverAutoTransferList.List, -1, true, PlayerRef)
        EndIf
    Else
        If PortableRecyclerControl.UseAlwaysAutoTransferList.Value && PortableRecyclerControl.AlwaysAutoTransferList.Size
            PlayerRef.RemoveItem(PortableRecyclerControl.AlwaysAutoTransferList.List, -1, true, TempContainerPrimary)
        EndIf
        If PortableRecyclerControl.UseNeverAutoTransferList.Value && PortableRecyclerControl.NeverAutoTransferList.Size
            TempContainerPrimary.RemoveItem(PortableRecyclerControl.NeverAutoTransferList.List, -1, true, PlayerRef)
        EndIf
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

; handles editing an auto transfer list
Function EditAutoTransferList(FormListWrapper akAutoTransferList, Message akModeMessage)
    Self._DebugTrace("Started editing Auto Transfer List")

    ; update the FormList holding the recyclable items
    Self.UpdateRecyclableItemList()

    ; populate the container with 1 of every item in the list
    If akAutoTransferList.Size
        ThreadManager.AddListItemsToInventory(akAutoTransferList, TempContainerPrimary, 1)
    EndIf

    ; activate the container (with 1.0s wait prior to, as specified on
    ; https://www.creationkit.com/fallout4/index.php?title=Activate_-_ObjectReference)
    Utility.Wait(1.0)
    TempContainerPrimary.Activate(PlayerRef as ObjectReference, true)

    ; show message stating the player is in list editing mode
    akModeMessage.Show()

    ; trigger a small wait once the container is open because sometimes, if a player has a boatload of items in the
    ; inventory, it can cause the interface to lag just enough for the script to keep processing
    Utility.WaitMenuMode(0.5)

    ; (triggered once container closes) wait a moment for the container inventory to update
    Utility.Wait(0.1)

    ; clear and re-populate the FormList
    Form[] tempContainerPrimaryInventory = TempContainerPrimary.GetInventoryItems()
    akAutoTransferList.List.Revert()
    ThreadManager.AddItemsToList(tempContainerPrimaryInventory, akAutoTransferList)

    ; move excess (>1) items back to the player
    If tempContainerPrimaryInventory.Length
        ThreadManager.LeaveOnlyXItems(tempContainerPrimaryInventory, TempContainerPrimary, PlayerRef, 1, \
            PortableRecyclerControl.ReturnItemsSilently.Value)
    EndIf

    PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)

    Self._DebugTrace("Finished editing Auto Transfer List")
EndFunction

; updates the FormList containing recyclable items
Function UpdateRecyclableItemList()
    ; if the recyclable items FormList already has items in it, move any of those items in the player's inventory
    ; to the primary temp container in order to reduce the number of items that this function will need to iterate over
    If PortableRecyclerControl.RecyclableItemList.Size
        Self._DebugTrace("Moving current recyclable items from player to primary temp container")
        PlayerRef.RemoveItem(PortableRecyclerControl.RecyclableItemList.List, -1, true, TempContainerPrimary)
    EndIf

    ; move all scrap items from the player to the primary temp container to avoid them being added to the
    ; recyclable items list
    If PortableRecyclerControl.ScrapListAll.Size
        Self._DebugTrace("Moving scrap items from player to primary temp container")
        PlayerRef.RemoveItem(PortableRecyclerControl.ScrapListAll.List, -1, true, TempContainerPrimary)
    EndIf

    ; give the game a moment to update the player's inventory data structure, otherwise the returned array
    ; from the GetInventoryItems() call that comes next may still have items in it that were removed by the
    ; previous RemoveItem() calls
    Utility.WaitMenuMode(0.05)

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

    ; actually add any recyclables to the FormList
    oldSize = PortableRecyclerControl.RecyclableItemList.Size
    ThreadManager.AddRecyclableItemsToList(playerInventory, PortableRecyclerControl.RecyclableItemList)
    playerInventory = None

    ; log any size change
    Self._DebugTrace("Old size of list = " + oldSize + ", new size of list = " + \
        PortableRecyclerControl.RecyclableItemList.Size)

    ; move junk items that were moved to the primary temp container back to the player inventory
    If PortableRecyclerControl.RecyclableItemList.Size
        Self._DebugTrace("Moving recyclable items back from primary temp container to player")
        TempContainerPrimary.RemoveItem(PortableRecyclerControl.RecyclableItemList.List, -1, true, PlayerRef)
    EndIf

    ; move scrap items that were moved to the primary temp container back to player
    If PortableRecyclerControl.ScrapListAll.Size
        Self._DebugTrace("Moving scrap items back from primary temp container to player")
        TempContainerPrimary.RemoveItem(PortableRecyclerControl.ScrapListAll.List, -1, true, PlayerRef)
    EndIf
EndFunction

; updates the FormList containing recyclable items without moving any items from the player inventory
; currently not used because it's much slower, but since the work is done and there might be an unforeseen
; reason it needs to get used in the future, it stays
Function UpdateRecyclableItemList2()
    ; add temporary container
    ObjectReference tempContainer = PlayerRef.PlaceAtMe(PortableRecyclerContainer, 1, true)

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
    ThreadManager.AddArrayItemsToInventory(playerInventory, tempContainer, 1)
    playerInventory = None

    ; if the recyclable items FormList already has items in it, remove any of those items in the container's
    ; inventory in order to reduce the number of items that this function will need to iterate over
    If PortableRecyclerControl.RecyclableItemList.Size
        Self._DebugTrace("Removing current recyclable items from the secondary temp container")
        tempContainer.RemoveItem(PortableRecyclerControl.RecyclableItemList.List, -1, true, None)
    EndIf

    ; remove all scrap items from the container to avoid them being added to the recyclable items list
    If PortableRecyclerControl.ScrapListAll.Size
        Self._DebugTrace("Removing scrap items from the secondary temp container")
        tempContainer.RemoveItem(PortableRecyclerControl.ScrapListAll.List, -1, true, None)
    EndIf

    ; give the game a moment to update the container's inventory data structure, otherwise the returned array
    ; from the GetInventoryItems() call that comes next may still have items in it that were removed by the
    ; previous RemoveItem() calls
    Utility.WaitMenuMode(0.05)

    ; actually add any recyclables to the FormList
    oldSize = PortableRecyclerControl.RecyclableItemList.Size
    ThreadManager.AddRecyclableItemsToList(tempContainer.GetInventoryItems(), PortableRecyclerControl.RecyclableItemList)

    ; nuke the temp container
    tempContainer.Delete()
    tempContainer = None

    ; log any size change
    Self._DebugTrace("Old size of list = " + oldSize + ", new size of list = " + \
        PortableRecyclerControl.RecyclableItemList.Size)
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