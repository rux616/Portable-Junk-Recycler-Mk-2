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



ScriptName PortableJunkRecyclerMk2:WorkerThreadBase Extends Quest Hidden

; import the base global functions and structs
import PortableJunkRecyclerMk2:Base



; PROPERTIES
; ----------

string Property ModName = "Portable Junk Recycler Mk 2" AutoReadOnly Hidden



; VARIABLES
; ---------
bool Running = false
var[] Results = None



; FUNCTIONS: UTILITY
; ------------------

; returns whether a thread is running
; true = running
; false = not running
bool Function IsRunning()
    Return Running
EndFunction

; returns any results that have been stored from a work function
var[] Function GetResults(bool clearResults = true)
    var[] toReturn = Results

    If clearResults
        Results = None
    EndIf

    Return toReturn
EndFunction

; perform general housekeeping when a work function starts
Function WorkerStart()
    Running = true
    Debug.StartStackProfiling()
    Results = None
EndFunction

; perform general housekeeping when a work function stops
Function WorkerStop()
    Running = False
    Debug.StopStackProfiling()
EndFunction

; reset a thread
Function Reset()
    Running = false
    Results = None
EndFunction

; add a bit of text to traces going into the papyrus user log
Function _DebugTrace(string asMessage, int aiSeverity = 0) DebugOnly
    Debug.TraceUser(ModName, "WorkerThread Base: " + asMessage, aiSeverity)
EndFunction



; FUNCTIONS
; ---------

; adds forms from an array to an object reference in a given quantity
Function AddArrayItemsToInventory(var[] akItems, int aiIndex, int aiIndexEnd, ObjectReference akDestinationRef, int aiQuantity)
    Self.WorkerStart()

    Form[] items = akItems as Form[]
    Self._DebugTrace("AddArrayItemsToInventory started: Index (Start) = " + aiIndex + ", Index (End) = " + aiIndexEnd)
	While aiIndex <= aiIndexEnd
        akDestinationRef.AddItem(items[aiIndex], aiQuantity, true)
		aiIndex += 1
	EndWhile
    Self._DebugTrace("AddArrayItemsToInventory finished")

    Self.WorkerStop()
EndFunction

; adds forms to a FormList
Function AddItemsToList(int aiIndex, int aiIndexEnd, var[] akItems, FormList akFormList)
    Self.WorkerStart()

    Self._DebugTrace("AddItemsToList started: Index (Start) = " + aiIndex + ", Index (End) = " + aiIndexEnd)
    Form[] items = akItems as Form[]
	While aiIndex <= aiIndexEnd
        akFormList.AddForm(items[aiIndex])
		aiIndex += 1
	EndWhile
    Self._DebugTrace("AddItemsToList Finished")

    Self.WorkerStop()
EndFunction

; adds forms from a FormList to an object reference in a given quantity
Function AddListItemsToInventory(int aiIndex, int aiIndexEnd, FormList akFormList, ObjectReference akDestinationRef, int aiQuantity)
    Self.WorkerStart()

    Self._DebugTrace("AddListItemsToInventory started: Index (Start) = " + aiIndex + ", Index (End) = " + aiIndexEnd)
	While aiIndex <= aiIndexEnd
        akDestinationRef.AddItem(akFormList.GetAt(aiIndex), aiQuantity, true)
		aiIndex += 1
	EndWhile
    Self._DebugTrace("AddListItemsToInventory finished")

    Self.WorkerStop()
EndFunction

; adds forms that have components (meaning they can be broken down) to a FormList
; expects only MiscObjects in akItems
Function AddRecyclableItemsToList(int aiIndex, int aiIndexEnd, var[] akItems, FormList akFormList)
    Self.WorkerStart()

    Self._DebugTrace("AddRecyclableItemsToList started: Index (Start) = " + aiIndex + ", Index (End) = " + aiIndexEnd)
    Form[] items = akItems as Form[]
	While aiIndex <= aiIndexEnd
        If (items[aiIndex] as MiscObject).GetMiscComponents()
            akFormList.AddForm(items[aiIndex])
        EndIf
		aiIndex += 1
	EndWhile
    Self._DebugTrace("AddRecyclableItemsToList finished")

    Self.WorkerStop()
EndFunction

; builds a ComponentMap array for the given component and MiscObject FormLists
Function BuildComponentMap(int aiIndex, int aiIndexEnd, FormList akComponentList, FormList akMiscObjectList)
    Self.WorkerStart()

    Self._DebugTrace("BuildComponentMap started: Index (Start) = " + aiIndex + ", Index (End) = " + aiIndexEnd)
    ComponentMap[] toReturn = new ComponentMap[aiIndexEnd - aiIndex + 1]
    int returnIndex = 0
    While aiIndex <= aiIndexEnd
        toReturn[returnIndex] = new ComponentMap
        toReturn[returnIndex].ComponentPart = akComponentList.GetAt(aiIndex) as Component
        toReturn[returnIndex].ComponentPartName = toReturn[returnIndex].ComponentPart.GetName()
        toReturn[returnIndex].ScrapPart = akMiscObjectList.GetAt(aiIndex) as MiscObject
        toReturn[returnIndex].ScrapPartName = toReturn[returnIndex].ScrapPart.GetName()
        Self._DebugTrace(toReturn[returnIndex].ComponentPart + " (" + toReturn[returnIndex].ComponentPartName + \
            ") is mapped to " + toReturn[returnIndex].ScrapPart + " (" + toReturn[returnIndex].ScrapPartName + ")")
        aiIndex += 1
        returnIndex += 1
    EndWhile
    Results = toReturn as var[]
    Self._DebugTrace("BuildComponentMap finished")

    Self.WorkerStop()
EndFunction

; changes settings to defaults
Function ChangeSettingsToDefaults(int aiIndex, int aiIndexEnd, var[] akSettings, int aiChangeType, string asModName)
    Self.WorkerStart()

    Self._DebugTrace("ChangeSettingsToDefaults started: Index (Start) = " + aiIndex + ", Index (End) = " + aiIndexEnd)
	While aiIndex <= aiIndexEnd
        If akSettings[aiIndex] is SettingFloat
            ChangeSetting(akSettings[aiIndex], aiChangeType, (akSettings[aiIndex] as SettingFloat).ValueDefault, asModName)
        ElseIf akSettings[aiIndex] is SettingBool
            ChangeSetting(akSettings[aiIndex], aiChangeType, (akSettings[aiIndex] as SettingBool).ValueDefault, asModName)
        ElseIf akSettings[aiIndex] is SettingInt
            ChangeSetting(akSettings[aiIndex], aiChangeType, (akSettings[aiIndex] as SettingInt).ValueDefault, asModName)
        EndIf
		aiIndex += 1
	EndWhile
    Self._DebugTrace("ChangeSettingsToDefaults finished")

    Self.WorkerStop()
EndFunction

; removes all but X items from a container, optionally moving them into a specified one
Function LeaveOnlyXItems(int aiIndex, int aiIndexEnd, var[] akItems, ObjectReference akOriginRef, \
        ObjectReference akDestinationRef, int aiQuantityToLeave, bool abSilent)
    Self.WorkerStart()

    Self._DebugTrace("LeaveOnlyXItems started: Index (Start) = " + aiIndex + ", Index (End) = " + aiIndexEnd)
    Form[] items = akItems as Form[]
    int currentQuantity
    int quantityToMove
    While aiIndex <= aiIndexEnd
        currentQuantity = akOriginRef.GetItemCount(items[aiIndex])
        quantityToMove = currentQuantity - aiQuantityToLeave
        If quantityToMove > 0
            akOriginRef.RemoveItem(items[aiIndex], quantityToMove, abSilent, akDestinationRef)
        EndIf
        aiIndex += 1
    EndWhile
    Self._DebugTrace("LeaveOnlyXItems finished")

    Self.WorkerStop()
EndFunction

; loads settings from MCM
Function LoadMCMSettings(int aiIndex, int aiIndexEnd, var[] akSettings, string asModName)
    Self.WorkerStart()

    Self._DebugTrace("LoadMCMSettings started: Index (Start) = " + aiIndex + ", Index (End) = " + aiIndexEnd)
	While aiIndex <= aiIndexEnd
        LoadSettingFromMCM(akSettings[aiIndex], asModName)
		aiIndex += 1
	EndWhile
    Self._DebugTrace("LoadMCMSettings finished")

    Self.WorkerStop()
EndFunction

; recycles components; sets Results[0] to a boolean representing whether any components were recycled
; true = components were recycled
; false = components were NOT recycled
Function RecycleComponents(int aiIndex, int aiIndexEnd, var[] akComponentMap, MultiplierSet akMultiplierSet, \
        ObjectReference akContainerRef, int aiRandomAdjustment, bool abReturnAtLeastOneComponent, \
        int aiFractionalComponentHandling)
    Self.WorkerStart()

    Self._DebugTrace("RecycleComponents started: Index (Start) = " + aiIndex + ", Index (End) = " + aiIndexEnd)

    Results = new var[1]
    Results[0] = false

    ComponentMap[] cMap = akComponentMap as ComponentMap[]

    float componentQuantity = 0.0
    float scrapMultiplier
    float randomMin
    float randomMax

    While aiIndex <= aiIndexEnd
        ; set basic multiplier values
        If aiRandomAdjustment == 1
            randomMin = akMultiplierSet.RandomMin
            randomMax = akMultiplierSet.RandomMax
        EndIf
        If cMap[aiIndex].Rarity == 0
            scrapMultiplier = akMultiplierSet.MultC
            If aiRandomAdjustment > 1
                randomMin = akMultiplierSet.RandomMinC
                randomMax = akMultiplierSet.RandomMaxC
            EndIf
        ElseIf cMap[aiIndex].Rarity == 1
            scrapMultiplier = akMultiplierSet.MultU
            If aiRandomAdjustment > 1
                randomMin = akMultiplierSet.RandomMinU
                randomMax = akMultiplierSet.RandomMaxU
            EndIf
        ElseIf cMap[aiIndex].Rarity == 2
            scrapMultiplier = akMultiplierSet.MultR
            If aiRandomAdjustment > 1
                randomMin = akMultiplierSet.RandomMinR
                randomMax = akMultiplierSet.RandomMaxR
            EndIf
        ElseIf cMap[aiIndex].Rarity == 3
            scrapMultiplier = akMultiplierSet.MultS
            If aiRandomAdjustment > 1
                randomMin = akMultiplierSet.RandomMinS
                randomMax = akMultiplierSet.RandomMaxS
            EndIf
        Else
            Self._DebugTrace("Unknown rarity: " + cMap[aiIndex], 2)
        EndIf

        Self._DebugTrace(cMap[aiIndex].ComponentPart + " (" + cMap[aiIndex].ComponentPartName + "), " + \
            cMap[aiIndex].ScrapPart + " (" + cMap[aiIndex].ScrapPartName + ")")

        ; get the quantity of a certain component
        componentQuantity = akContainerRef.GetComponentCount(cMap[aiIndex].ComponentPart)
        Self._DebugTrace("Component quantity (Initial) = " + componentQuantity)

        if componentQuantity > 0.0
            ; since there are components to work on, signal that recycling happened
            Results[0] = true

            If aiRandomAdjustment
                ; use randomized multiplier adjustment for each individual component
                float randomMultAdjust = Utility.RandomFloat(randomMin, randomMax)
                scrapMultiplier += randomMultAdjust
                Self._DebugTrace("Adjustment (Random): " + randomMultAdjust)
                Self._DebugTrace("Multiplier: " + scrapMultiplier)
            EndIf

            ; remove all components of the type from the inventory
            akContainerRef.RemoveComponents(cMap[aiIndex].ComponentPart, componentQuantity as int, true)

            ; compute basic multiplied quantity
            componentQuantity *= scrapMultiplier
            Self._DebugTrace("Component quantity (Multiplied) = " + componentQuantity)

            ; give at least one component if the option is turned on and quantity <1
            If abReturnAtLeastOneComponent && componentQuantity < 1.0
                componentQuantity = 1.0
            EndIf
            Self._DebugTrace("Component quantity (ReturnAtLeastOneComponent) = " + componentQuantity)

            ; round the component quantity per settings
            If aiFractionalComponentHandling == 2           ; round down (floor)
                componentQuantity = Math.Floor(componentQuantity)
                Self._DebugTrace("Component quantity (Round Down [floor]) = " + componentQuantity)
            ElseIf aiFractionalComponentHandling == 1       ; round normally
                componentQuantity = (componentQuantity + 0.5) as int
                Self._DebugTrace("Component quantity (Round Normally) = " + componentQuantity)
            ElseIf aiFractionalComponentHandling == 0       ; round up (ceiling)
                componentQuantity = Math.Ceiling(componentQuantity)
                Self._DebugTrace("Component quantity (Round Up [ceiling]) = " + componentQuantity)
            EndIf

            ; add the modified quantity of components back to the inventory
            akContainerRef.AddItem(cMap[aiIndex].ScrapPart, componentQuantity as int, true)
            Self._DebugTrace("Component quantity (Final) = " + componentQuantity as int)
        EndIf

        aiIndex += 1
    EndWhile

    Self._DebugTrace("RecycleComponents finished")

    Self.WorkerStop()
EndFunction