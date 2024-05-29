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



ScriptName PortableJunkRecyclerMk2:PJRM2_EffectManager Extends ActiveMagicEffect
{ script that handles the recycling process }

; import data structures
import PortableJunkRecyclerMk2:PJRM2_DataStructures
; import utility functions
import PortableJunkRecyclerMk2:PJRM2_Utility



; PROPERTIES
; ----------

Group Miscellaneous
    Actor Property PlayerRef Auto Mandatory
    Keyword Property KeywordObjectTypeLooseMod Auto Mandatory
    Keyword Property KeywordUnscrappableObject Auto Mandatory
EndGroup

Group PortableJunkRecycler
    Quest Property PortableRecyclerControl Auto Mandatory
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
    Message Property MessageEditNeverAutoTransferListFinished Auto Mandatory
    Message Property MessageEditAlwaysAutoTransferListModeBox Auto Mandatory
    Message Property MessageEditAlwaysAutoTransferListModeNotification Auto Mandatory
    Message Property MessageEditAlwaysAutoTransferListFinished Auto Mandatory
EndGroup



; VARIABLES
; ---------

PJRM2_ControlManager ControlManager
PJRM2_SettingManager SettingManager
PJRM2_ThreadManager ThreadManager

string ModName
bool EnableLogging = false
bool EnableProfiling = false

bool ProfilingActive = false
ObjectReference TempContainerPrimary
ObjectReference TempContainerSecondary
ObjectReference TempContainerTertiary
bool AsyncSubprocessComplete = false



; EVENTS
; ------

Event OnInit()
    ControlManager = PortableRecyclerControl as PJRM2_ControlManager
    SettingManager = PortableRecyclerControl as PJRM2_SettingManager
    ThreadManager = PortableRecyclerControl as PJRM2_ThreadManager
    ModName = SettingManager.ModName
    EnableLogging = SettingManager.EnableLogging
    EnableProfiling = SettingManager.EnableProfiling
EndEvent

Event OnEffectStart(Actor akTarget, Actor akCaster)
    If ! ControlManager.ScriptExtenderInstalled
        ; F4SE is not found, abort with message
        Self._Log("F4SE is not installed; aborting")
        MessageF4SENotInstalled.Show()
        PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)
    ElseIf ! ControlManager.MutexRunning && ! ControlManager.MutexBusy
        ; normal mode of operation: a recycler process isn't already running nor is the quest busy
        ControlManager.MutexRunning = true
        Self._StartStackProfiling()

        ; record the states of the hotkeys, optionally waiting a moment first
        ; the delay affords time to activate the hotkeys in the case where the device is triggered via the MCM usage hotkey
        float hotkeyReadDelay = SettingManager.ModifierReadDelay
        If (SettingManager.EnableAutoTransferListEditing || SettingManager.EnableBehaviorOverrides) && hotkeyReadDelay > 0.0
            Self._Log("Waiting " + hotkeyReadDelay + " seconds before reading hotkeys")
            Utility.WaitMenuMode(hotkeyReadDelay)
        EndIf
        bool hotkeyRetain = ControlManager.HotkeyForceRetainJunk
        bool hotkeyTransfer = ControlManager.HotkeyForceTransferJunk
        bool hotkeyEdit = ControlManager.HotkeyEditAutoTransferLists
        Self._Log("Hotkeys: hotkeyRetain = " + hotkeyRetain + ", hotkeyTransfer = " + hotkeyTransfer \
            + ", hotkeyEdit = " + hotkeyEdit)

        ; establish some convenience variables
        bool editNeverTransferList = hotkeyEdit && hotkeyRetain && SettingManager.EnableAutoTransferListEditing
        bool editAlwaysTransferList = hotkeyEdit && hotkeyTransfer && SettingManager.EnableAutoTransferListEditing
        bool useFilteredContainer = editNeverTransferList || editAlwaysTransferList || SettingManager.EnableJunkFilter

        ; place temp containers at the player; if the 'Enable Junk Filter' option is turned on, or the player wants to edit an
        ; auto transfer list, a filtered primary container is placed
        If useFilteredContainer
            TempContainerPrimary = PlayerRef.PlaceAtMe(PortableRecyclerContainerFiltered as Form, abForcePersist = true)
        Else
            TempContainerPrimary = PlayerRef.PlaceAtMe(PortableRecyclerContainer as Form, abForcePersist = true)
        EndIf
        Self._Log("Primary temp container " + TempContainerPrimary + " created (filtered: " + useFilteredContainer + ")")
        TempContainerSecondary = PlayerRef.PlaceAtMe(PortableRecyclerContainer as Form, abForcePersist = true)
        Self._Log("Secondary temp container " + TempContainerSecondary + " created")
        TempContainerTertiary = PlayerRef.PlaceAtMe(PortableRecyclerContainer as Form, abForcePersist = true)
        Self._Log("Tertiary temp container " + TempContainerTertiary + " created")

        ObjectReference editListContainer = None

        If editNeverTransferList
            editListContainer = PlayerRef.PlaceAtMe(NeverAutoTransferContainer as Form, abForcePersist = true)
            Self._Log("List edit container " + editListContainer + " created")
            Self._Log("Editing 'Never Automatically Transfer' list")
            Self.EditAutoTransferList(ControlManager.NeverAutoTransferList, editListContainer, \
                MessageEditNeverAutoTransferListModeBox, MessageEditNeverAutoTransferListModeNotification, \
                MessageEditNeverAutoTransferListFinished)
        ElseIf editAlwaysTransferList
            editListContainer = PlayerRef.PlaceAtMe(AlwaysAutoTransferContainer as Form, abForcePersist = true)
            Self._Log("List edit container " + editListContainer + " created")
            Self._Log("Editing 'Always Automatically Transfer' list")
            Self.EditAutoTransferList(ControlManager.AlwaysAutoTransferList, editListContainer, \
                MessageEditAlwaysAutoTransferListModeBox, MessageEditAlwaysAutoTransferListModeNotification, \
                MessageEditAlwaysAutoTransferListFinished)
        Else
            If SettingManager.EnableBehaviorOverrides
                Self.Recycle(hotkeyRetain, hotkeyTransfer)
            Else
                Self.Recycle(false, false)
            EndIf
        EndIf

        ; delete the temp containers
        Self._Log("Removing primary temp container " + TempContainerPrimary)
        TempContainerPrimary.Delete()
        TempContainerPrimary = None
        Self._Log("Removing secondary temp container " + TempContainerSecondary)
        TempContainerSecondary.Delete()
        TempContainerSecondary = None
        Self._Log("Removing tertiary temp container " + TempContainerTertiary)
        TempContainerTertiary.Delete()
        TempContainerTertiary = None

        ; enable the recycle process to be run again
        Self._StopStackProfiling()
        ControlManager.MutexRunning = false
    ElseIf ControlManager.MutexRunning && ! ControlManager.MutexBusy
        ; another recycling process is already running, tell the user
        Self._Log("Recycler process already running")
        MessageAlreadyRunning.Show()
        PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)
    Else
        ; the control script is processing something in the background, tell the user to give it a few seconds to finish
        Self._Log("Quest script is busy")
        MessageBusy.Show()
        PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)
    EndIf
EndEvent



; FUNCTIONS
; ---------

; add a bit of text to traces going into the papyrus user log
Function _Log(string asLogMessage, int aiSeverity = 0, bool abForce = false) DebugOnly
    If EnableLogging || abForce
        Log(ModName, "EffectManager", asLogMessage, aiSeverity)
    EndIf
EndFunction

; start stack profiling
Function _StartStackProfiling() DebugOnly
    If SettingManager.EnableProfiling
        Debug.StartStackProfiling()
        ProfilingActive = true
        Self._Log("Stack profiling started")
    EndIf
EndFunction

; stop stack profiling
Function _StopStackProfiling() DebugOnly
    If ProfilingActive
        Debug.StopStackProfiling()
        Self._Log("Stack profiling stopped")
    EndIf
EndFunction

; handle the recycling functionality of the device
Function Recycle(bool abForceRetainJunk, bool abForceTransferJunk)
    Self._Log("Recycler process started")

    ; set some convenience variables

    ; check to see whether the player is at a player-owned settlement
    bool playerAtOwnedWorkshop = ControlManager.IsPlayerAtOwnedWorkshop()

    ; junk will be automatically transferred under the following conditions:
    ;   - the ForceRetainJunk hotkey IS pressed && the ForceTransferJunk hotkey IS pressed
    ;   - the ForceRetainJunk hotkey IS NOT pressed && the ForceTransferJunk hotkey IS pressed
    ;   - the ForceRetainJunk hotkey IS NOT pressed && the AutoTransferJunk option is ON
    ;   - the ForceRetainJunk hotkey IS NOT pressed && the AutoRecycleMode option is ON
    ; simplified:
    ;   - the ForceTransferJunk hotkey IS pressed
    ;   - the ForceRetainJunk hotkey IS NOT pressed && the AutoTransferJunk option is ON
    ;   - the ForceRetainJunk hotkey IS NOT pressed && the AutoRecycleMode option is ON
    bool transferJunk = abForceTransferJunk || (! abForceRetainJunk && SettingManager.AutoTransferJunk) \
        || (! abForceRetainJunk && SettingManager.AutoRecyclingMode)
    Self._Log("Transfer junk: " + transferJunk)

    ; all junk will be automatically transferred under the following conditions (otherwise just low component weight ratio items):
    ;   - the TransferLowWeightRatioItems option is OFF
    ;   - the ForceTransferJunk hotkey IS pressed && the ForceRetainJunk hotkey IS NOT pressed
    ;   - the player IS in a player-owned settlement && the TransferLowWeightRatioItems option is set to 'not in player-owned settlements'
    ;   - the player IS NOT in a player-owned settlement && the TransferLowWeightRatioItems option is set to 'in player-owned settlements'
    bool transferAllJunk = ! SettingManager.TransferLowWeightRatioItems \
        || (abForceTransferJunk && ! abForceRetainJunk) \
        || (playerAtOwnedWorkshop && SettingManager.TransferLowWeightRatioItems == 2) \
        || (! playerAtOwnedWorkshop && SettingManager.TransferLowWeightRatioItems == 1)
    Self._Log("Transfer ALL junk: " + transferAllJunk)

    ; the recyclable item FormList will be updated under the following conditions:
    ;   - junk will be automatically transferred
    ;   - the Enable Junk Filter option is ON
    bool updateRecyclableList = transferJunk || SettingManager.EnableJunkFilter
    Self._Log("Update recyclables list: " + updateRecyclableList)

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
    bool openContainer = (! SettingManager.AutoRecyclingMode && ! abForceRetainJunk) \
        || (abForceRetainJunk && ! abForceTransferJunk) || (! abForceRetainJunk && abForceTransferJunk)
    Self._Log("Open container: " + openContainer)

    ; get the set of multipliers that will be applied to this recycling run
    MultiplierSet multipliers = ControlManager.GetMultipliers(playerAtOwnedWorkshop)
    Self._Log("Multipliers: C=" + multipliers.MultC + "; U=" + multipliers.MultU + "; R=" + multipliers.MultR \
        + "; S=" + multipliers.MultS)

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
    If ! SettingManager.EnableJunkFilter
        Self._Log("Temporarily moving existing scrap from primary temp container to secondary temp container")
        TempContainerPrimary.RemoveItem(ControlManager.ScrapListAll.List, -1, true, TempContainerSecondary)
    EndIf

    ; do the recycling
    bool itemsRecycled = ThreadManager.RecycleComponents(\
        ControlManager.ComponentMappings, \
        multipliers, \
        TempContainerPrimary, \
        SettingManager.RngAffectsMult, \
        SettingManager.ReturnAtLeastOneComponent, \
        SettingManager.FractionalComponentHandling \
    )
    Self._Log("Items recycled? " + itemsRecycled)

    ; move any previously existing scrap items that were moved into the secondary temp container back to the primary
    ; temp container
    If ! SettingManager.EnableJunkFilter && TempContainerSecondary.GetItemCount()
        Self._Log("Moving previously-existing scrap from secondary temp container to primary temp container")
        TempContainerSecondary.RemoveItem(ControlManager.ScrapListAll.List, -1, true, TempContainerPrimary)
        Utility.WaitMenuMode(0.05)
    EndIf

    ; move items over to the player
    bool itemsToMove = false
    If TempContainerPrimary.GetItemCount()
        itemsToMove = true
    EndIf
    Self._Log("Moving components from primary temp container to player")
    TempContainerPrimary.RemoveItem(ControlManager.ScrapListAll.List, -1, \
        SettingManager.ReturnItemsSilently, PlayerRef)
    Self._Log("Moving all non-components from primary temp container to player")
    Self.RemoveAllItems(TempContainerPrimary, PlayerRef, SettingManager.ReturnItemsSilently)

    ; play an audio cue for the player to know when stuff has been moved
    If itemsToMove
        SoundPickup.Play(PlayerRef)
    EndIf

    ; if 'limited uses' mode is on, run through the scenarios for that, otherwise just show completion message
    ; and re-add the recycler item back to the player's inventory
    If SettingManager.HasLimitedUses
        ; if things were actually recycled, increment the number of times used
        ControlManager.NumberOfTimesUsed += itemsRecycled as int
        Self._Log("Number of times used incremented by " + itemsRecycled as int + " to " \
            + ControlManager.NumberOfTimesUsed)
        If ! itemsRecycled
            ; if nothing was recycled, re-add the recycler item and show a message saying nothing was recycled
            Self._Log("Nothing recycled; adding item back to player's inventory")
            PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)
            MessageFinishedNothingUsesLeft.Show(Math.Max(1.0, SettingManager.NumberOfUses \
                - ControlManager.NumberOfTimesUsed))
        ElseIf ControlManager.NumberOfTimesUsed < SettingManager.NumberOfUses
            ; re-add the portable recycler item if there are uses left
            Self._Log("Items recycled and max usage limit not reached; adding item back to player's inventory")
            PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)
            MessageFinishedUsesLeft.Show(SettingManager.NumberOfUses \
                - ControlManager.NumberOfTimesUsed)
        Else
            ; if the recycler item use limit is reached, reset the number of times used, but don't re-add the item
            Self._Log("Items recycled but max usage limit reached; NOT adding recycler back to player's inventory")
            ControlManager.NumberOfTimesUsed = 0
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

    Self._Log("Recycler process finished")
EndFunction

; function to do work asynchronously (via CallFunctionNoWait) while waiting for the container to open
Function RecycleAsync(bool abUpdateRecyclableList, bool abTransferJunk, bool abTransferAllJunk)
    Self._StartStackProfiling()

    ; update the recyclable item list if needed
    If abUpdateRecyclableList
        If SettingManager.UseDirectMoveRecyclableItemListUpdate
            Self.UpdateRecyclableItemListDirectMove()
        Else
            Self.UpdateRecyclableItemListNoTouch()
        EndIf
    EndIf

    ; transfer (or not) junk to the container
    If abTransferJunk
        If abTransferAllJunk
            ; if all junk is slated to be transferred, transfer everything as long as there are items in the list
            If ControlManager.RecyclableItemList.Size
                PlayerRef.RemoveItem(ControlManager.RecyclableItemList.List, -1, true, TempContainerPrimary)
            EndIf
        Else
            ; transfer items that have low component weight ratios as long as there are items in the list
            If ControlManager.LowWeightRatioItemList.Size
                PlayerRef.RemoveItem(ControlManager.LowWeightRatioItemList.List, -1, true, TempContainerPrimary)
            EndIf
        EndIf
    Else
        If SettingManager.UseAlwaysAutoTransferList && ControlManager.AlwaysAutoTransferList.Size
            PlayerRef.RemoveItem(ControlManager.AlwaysAutoTransferList.List, -1, true, TempContainerPrimary)
        EndIf
    EndIf

    ; if the 'always auto transfer' and the 'never auto transfer' lists have a conflict (i.e. there's the same item
    ; on both), the 'never' list always wins if it's active
    If SettingManager.UseNeverAutoTransferList && ControlManager.NeverAutoTransferList.Size
        TempContainerPrimary.RemoveItem(ControlManager.NeverAutoTransferList.List, -1, true, PlayerRef)
    EndIf

    ; signal that the function is complete
    AsyncSubprocessComplete = true

    Self._StopStackProfiling()
EndFunction

; handles editing an auto transfer list
Function EditAutoTransferList(FormListWrapper akAutoTransferList, ObjectReference akContainer, Message akModeMessageBox, \
        Message akModeMessageNotification, Message akFinishedMessage)
    Self._Log("Started editing Auto Transfer List: " + akAutoTransferList.List)

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
            SettingManager.ReturnItemsSilently)
    EndIf

    ; add the recycler item back to the player
    PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)

    ; show finished message
    akFinishedMessage.Show()

    Self._Log("Finished editing Auto Transfer List")
EndFunction

; function to do work asynchronously (via CallFunctionNoWait) while waiting for the container to open
Function EditAutoTransferListAsync(FormListWrapper akAutoTransferList, ObjectReference akContainer)
    Self._StartStackProfiling()

    ; update the FormList holding the recyclable items
    If SettingManager.UseDirectMoveRecyclableItemListUpdate
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

    Self._StopStackProfiling()
EndFunction

; updates the FormList containing recyclable items
Function UpdateRecyclableItemListDirectMove()
    ; reduce the number of MiscObjects left in the player's inventory in an effort to reduce the number of items
    ; this function will need to iterate over

    ; known recyclable items
    If ControlManager.RecyclableItemList.Size
        Self._Log("Moving currently known recyclable items from player to secondary temp container")
        PlayerRef.RemoveItem(ControlManager.RecyclableItemList.List, -1, true, TempContainerSecondary)
    EndIf
    ; mods
    Self._Log("Moving mods from player to secondary temp container")
    PlayerRef.RemoveItem(KeywordObjectTypeLooseMod, -1, true, TempContainerSecondary)
    ; unscrappable items
    Self._Log("Moving unscrappable items from player to secondary temp container")
    PlayerRef.RemoveItem(KeywordUnscrappableObject, -1, true, TempContainerSecondary)
    ; scrap items
    If ControlManager.ScrapListAll.Size
        Self._Log("Moving scrap items from player to secondary temp container")
        PlayerRef.RemoveItem(ControlManager.ScrapListAll.List, -1, true, TempContainerSecondary)
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
    Self._Log("Pruned " + (oldSize - playerInventory.Length) + " non-MiscObjects from inventory array")

    ; record current size of lists and prep an array of current components
    oldSize = ControlManager.RecyclableItemList.Size
    int oldSize2 = ControlManager.LowWeightRatioItemList.Size
    Component[] components = new Component[0]
    index = 0
    While index < ControlManager.ComponentMappings.Length
        components.Add(ControlManager.ComponentMappings[index].ComponentPart)
        index += 1
    EndWhile

    ; actually add any recyclables to the FormList
    ThreadManager.AddRecyclableItemsToList(playerInventory, ControlManager.RecyclableItemList, \
        ControlManager.LowWeightRatioItemList, ControlManager.ComponentMappings, components)
    playerInventory = None

    ; log any size changes
    Self._Log("Recyclable item list: old size = " + oldSize + ", new size = " \
        + ControlManager.RecyclableItemList.Size)
    Self._Log("Low weight ratio item list: old size = " + oldSize2 + ", new size = " \
        + ControlManager.LowWeightRatioItemList.Size)

    ; move any items that were moved to the secondary temp container back to the player
    ; known recyclable items
    If ControlManager.RecyclableItemList.Size
        Self._Log("Moving recyclable items back from secondary temp container to player")
        TempContainerSecondary.RemoveItem(ControlManager.RecyclableItemList.List, -1, true, PlayerRef)
    EndIf
    ; mods
    Self._Log("Moving mods back from secondary temp container to player")
    TempContainerSecondary.RemoveItem(KeywordUnscrappableObject, -1, true, PlayerRef)
    ; unscrappable items
    Self._Log("Moving unscrappable items back from secondary temp container to player")
    TempContainerSecondary.RemoveItem(KeywordUnscrappableObject, -1, true, PlayerRef)
    ; scrap items
    If ControlManager.ScrapListAll.Size
        Self._Log("Moving scrap items back from secondary temp container to player")
        TempContainerSecondary.RemoveItem(ControlManager.ScrapListAll.List, -1, true, PlayerRef)
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
    Self._Log("Pruned " + (oldSize - playerInventory.Length) + " non-MiscObjects from inventory array")

    ; add 1 of every MiscObject currently left in the array to the secondary temp container
    ThreadManager.AddArrayItemsToInventory(playerInventory, TempContainerSecondary, 1)
    playerInventory = None

    ; remove as many MiscObjects as possible from the inventory to reduce the number of items that this function
    ; needs to iterate over

    ; known recyclable items
    If ControlManager.RecyclableItemList.Size
        Self._Log("Removing currently known recyclable items from the temp container")
        TempContainerSecondary.RemoveItem(ControlManager.RecyclableItemList.List, -1, true, TempContainerTertiary)
    EndIf
    ; mods
    Self._Log("Removing mods from the temp container")
    TempContainerSecondary.RemoveItem(KeywordObjectTypeLooseMod, -1, true, TempContainerTertiary)
    ; unscrappable items
    Self._Log("Removing unscrappable items from the temp container")
    TempContainerSecondary.RemoveItem(KeywordUnscrappableObject, -1, true, TempContainerTertiary)
    ; scrap items
    If ControlManager.ScrapListAll.Size
        Self._Log("Removing scrap items from the temp container")
        TempContainerSecondary.RemoveItem(ControlManager.ScrapListAll.List, -1, true, TempContainerTertiary)
    EndIf

    ; give the game a moment to update the container's inventory data structure, otherwise the returned array
    ; from the GetInventoryItems() call that comes next may still have items in it that were removed by the
    ; previous RemoveItem() calls
    Utility.WaitMenuMode(0.04)

    ; record current size of lists and prep an array of current components
    oldSize = ControlManager.RecyclableItemList.Size
    int oldSize2 = ControlManager.LowWeightRatioItemList.Size
    Component[] components = new Component[0]
    index = 0
    While index < ControlManager.ComponentMappings.Length
        components.Add(ControlManager.ComponentMappings[index].ComponentPart)
        index += 1
    EndWhile

    ; actually add any recyclables to the FormList
    ThreadManager.AddRecyclableItemsToList(TempContainerSecondary.GetInventoryItems(), ControlManager.RecyclableItemList, \
        ControlManager.LowWeightRatioItemList, ControlManager.ComponentMappings, components)

    ; nuke remaining contents of the secondary temp container
    TempContainerSecondary.RemoveAllItems()

    ; log any size changes
    Self._Log("Recyclable item list: old size = " + oldSize + ", new size = " \
        + ControlManager.RecyclableItemList.Size)
    Self._Log("Low weight ratio item list: old size = " + oldSize2 + ", new size = " \
        + ControlManager.LowWeightRatioItemList.Size)
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
        Self._Log("WaitForAsyncSubprocess failsafe triggered!", 2)
    EndIf
EndFunction
