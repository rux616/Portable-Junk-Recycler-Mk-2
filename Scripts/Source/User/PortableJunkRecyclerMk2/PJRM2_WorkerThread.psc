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



ScriptName PortableJunkRecyclerMk2:PJRM2_WorkerThread Extends Quest Hidden

; import data structures
import PortableJunkRecyclerMk2:PJRM2_DataStructures
; import utility functions
import PortableJunkRecyclerMk2:PJRM2_Utility



; VARIABLES
; ---------

string ModName
string WorkerDesignation
bool EnableLogging = false
bool EnableProfiling = false

bool ProfilingActive = false
bool Running = false
var[] Results = None




; FUNCTIONS: UTILITY
; ------------------

; add a bit of text to traces going into the papyrus user log
Function _Log(string asLogMessage, int aiSeverity = 0, bool abForce = false) DebugOnly
    If EnableLogging || abForce
        Log(ModName, "WorkerThread " + WorkerDesignation, asLogMessage, aiSeverity)
    EndIf
EndFunction

; convenience function to set initial values
Function Initialize(string asModName, string abDesignation, bool abEnableLogging, bool abEnableProfiling)
    ModName = asModName
    WorkerDesignation = abDesignation
    EnableLogging = abEnableLogging
    EnableProfiling = abEnableProfiling
EndFunction

; returns whether a thread is running
; true = running
; false = not running
bool Function IsRunning()
    Return Running
EndFunction

; turn logging on or off
; true = on
; false = off
Function SetLogging(bool abEnableLogging)
    If EnableLogging != abEnableLogging
        EnableLogging = abEnableLogging

        If EnableLogging
            Self._Log("Logging enabled", abForce = true)
        Else
            Self._Log("Logging disabled", abForce = true)
        EndIf
    EndIf
EndFunction

; turn profiling on or off
; true = on
; false = off
Function SetProfiling(bool abEnableProfiling)
    If EnableProfiling != abEnableProfiling
        EnableProfiling = abEnableProfiling

        If EnableProfiling
            Self._Log("Profiling enabled")
        Else
            Self._Log("Profiling disabled")
        EndIf
    EndIf
EndFunction

; set log name
Function SetLogName(string asLogName)
    ModName = asLogName
EndFunction

; set thread designation
Function SetDesignation(string asDesignation)
    WorkerDesignation = asDesignation
    Self._Log("WorkerDesignation set")
EndFunction

; get thread designation
string Function GetDesignation()
    Return WorkerDesignation
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
    If EnableProfiling
        Debug.StartStackProfiling()
        ProfilingActive = true
    EndIf
    Results = None
EndFunction

; perform general housekeeping when a work function stops
Function WorkerStop()
    If ProfilingActive
        Debug.StopStackProfiling()
        ProfilingActive = false
    EndIf
    Running = false
EndFunction

; reset a thread
Function Reset()
    Running = false
    Results = None
EndFunction



; FUNCTIONS
; ---------

; adds forms from an array to an object reference in a given quantity
Function AddArrayItemsToInventory(int aiIndex, int aiIndexEnd, var[] akItems, ObjectReference akDestinationRef, int aiQuantity)
    Self.WorkerStart()

    Form[] items = akItems as Form[]
    Self._Log("AddArrayItemsToInventory started: Index (Start) = " + aiIndex + ", Index (End) = " + aiIndexEnd)
    While aiIndex <= aiIndexEnd
        akDestinationRef.AddItem(items[aiIndex], aiQuantity, true)
        aiIndex += 1
    EndWhile
    Self._Log("AddArrayItemsToInventory finished")

    Self.WorkerStop()
EndFunction

; adds forms to a FormList
Function AddItemsToList(int aiIndex, int aiIndexEnd, var[] akItems, FormList akFormList)
    Self.WorkerStart()

    Self._Log("AddItemsToList started: Index (Start) = " + aiIndex + ", Index (End) = " + aiIndexEnd)
    Form[] items = akItems as Form[]
    While aiIndex <= aiIndexEnd
        akFormList.AddForm(items[aiIndex])
        aiIndex += 1
    EndWhile
    Self._Log("AddItemsToList Finished")

    Self.WorkerStop()
EndFunction

; adds forms from a FormList to an object reference in a given quantity
Function AddListItemsToInventory(int aiIndex, int aiIndexEnd, FormList akFormList, ObjectReference akDestinationRef, int aiQuantity)
    Self.WorkerStart()

    Self._Log("AddListItemsToInventory started: Index (Start) = " + aiIndex + ", Index (End) = " + aiIndexEnd)
    While aiIndex <= aiIndexEnd
        akDestinationRef.AddItem(akFormList.GetAt(aiIndex), aiQuantity, true)
        aiIndex += 1
    EndWhile
    Self._Log("AddListItemsToInventory finished")

    Self.WorkerStop()
EndFunction

; adds forms that have components (meaning they can be broken down) to one FormList if the total weight of the
; components adds up to less than the item itself weighs, and a different FormList otherwise
; expects only MiscObjects in akItems
Function AddRecyclableItemsToList(int aiIndex, int aiIndexEnd, var[] akItems, FormList akRecyclableItemList, \
        FormList NetWeightReductionList, var[] akComponentMap, var[] akComponents)
    Self.WorkerStart()

    Self._Log("AddRecyclableItemsToList started: Index (Start) = " + aiIndex + ", Index (End) = " + aiIndexEnd)
    MiscObject[] items = akItems as MiscObject[]
    ComponentMap[] cMap = akComponentMap as ComponentMap[]
    Component[] components = akComponents as Component[]
    MiscObject:MiscComponent[] neededComponents = None
    float itemWeight
    float totalComponentWeight
    int componentIndex
    int index
    While aiIndex <= aiIndexEnd
        neededComponents = items[aiIndex].GetMiscComponents()
        If neededComponents.Length
            ; (re)set variables for the loop to determine whether the weight of the item is greater than the sum of its
            ; components
            itemWeight = items[aiIndex].GetWeight()
            totalComponentWeight = 0
            index = 0
            While index < neededComponents.Length && totalComponentWeight < itemWeight
                ; check if the item component is a known component and store the result
                componentIndex = components.Find(neededComponents[index].object)

                ; if it's a known component, grab the weight from the component mappings, multiply it by how many
                ; there are in the item and add the result to the total component weight
                If componentIndex >= 0
                    totalComponentWeight += cMap[componentIndex].Weight * neededComponents[index].count

                ; if it's an unknown component, look up the scrap item and get the weight of that, then multiply
                ; it by how many there are in the item and add the result to the total component weight; warn
                ; when this happens as it's relatively expensive - has two delayed native function calls
                Else
                    totalComponentWeight += neededComponents[index].object.GetScrapItem().GetWeight() * neededComponents[index].count
                    Self._Log("Component not in component mappings: " + neededComponents[index].object, 1)
                EndIf
                index += 1
            EndWhile

            ; if the combined weight of all the components an item would be broken down into weights less then the item itself,
            ; add it to the NetWeightReductionList FormList
            If totalComponentWeight < itemWeight
                NetWeightReductionList.AddForm(items[aiIndex] as Form)
            EndIf

            ; add the item to the RecyclableItemList FormList as well for filtering purposes
            akRecyclableItemList.AddForm(items[aiIndex] as Form)
        EndIf
        neededComponents = None
        aiIndex += 1
    EndWhile
    Self._Log("AddRecyclableItemsToList finished")

    Self.WorkerStop()
EndFunction

; builds a ComponentMap array for the given component and MiscObject FormLists
Function BuildComponentMap(int aiIndex, int aiIndexEnd, FormList akComponentList, FormList akMiscObjectList)
    Self.WorkerStart()

    Self._Log("BuildComponentMap started: Index (Start) = " + aiIndex + ", Index (End) = " + aiIndexEnd)
    ComponentMap[] toReturn = new ComponentMap[aiIndexEnd - aiIndex + 1]
    int returnIndex = 0
    While aiIndex <= aiIndexEnd
        toReturn[returnIndex] = new ComponentMap
        toReturn[returnIndex].ComponentPart = akComponentList.GetAt(aiIndex) as Component
        toReturn[returnIndex].ComponentPartName = toReturn[returnIndex].ComponentPart.GetName()
        toReturn[returnIndex].ScrapPart = akMiscObjectList.GetAt(aiIndex) as MiscObject
        toReturn[returnIndex].ScrapPartName = toReturn[returnIndex].ScrapPart.GetName()
        toReturn[returnIndex].Weight = toReturn[returnIndex].ScrapPart.GetWeight()
        Self._Log(toReturn[returnIndex].ComponentPart + " (" + toReturn[returnIndex].ComponentPartName + \
            ") is mapped to " + toReturn[returnIndex].ScrapPart + " (" + toReturn[returnIndex].ScrapPartName + ")")
        aiIndex += 1
        returnIndex += 1
    EndWhile
    Results = toReturn as var[]
    Self._Log("BuildComponentMap finished")

    Self.WorkerStop()
EndFunction

; changes settings to defaults
Function ChangeSettingsToDefaults(int aiIndex, int aiIndexEnd, var[] akSettings, int aiChangeType, string asModName)
    Self.WorkerStart()

    Self._Log("ChangeSettingsToDefaults started: Index (Start) = " + aiIndex + ", Index (End) = " + aiIndexEnd)
    While aiIndex <= aiIndexEnd
        ; if/else structure is in order of frequency of setting occurrence
        If akSettings[aiIndex] is SettingFloat
            ChangeSetting(akSettings[aiIndex], aiChangeType, (akSettings[aiIndex] as SettingFloat).ValueDefault, asModName)
        ElseIf akSettings[aiIndex] is SettingBool
            ChangeSetting(akSettings[aiIndex], aiChangeType, (akSettings[aiIndex] as SettingBool).ValueDefault, asModName)
        ElseIf akSettings[aiIndex] is SettingInt
            ChangeSetting(akSettings[aiIndex], aiChangeType, (akSettings[aiIndex] as SettingInt).ValueDefault, asModName)
        ElseIf akSettings[aiIndex] is SettingString
            ChangeSetting(akSettings[aiIndex], aiChangeType, (akSettings[aiIndex] as SettingString).ValueDefault, asModName)
        EndIf
        aiIndex += 1
    EndWhile
    Self._Log("ChangeSettingsToDefaults finished")

    Self.WorkerStop()
EndFunction

; removes all but X items from a container, optionally moving them into a specified one
Function LeaveOnlyXItems(int aiIndex, int aiIndexEnd, var[] akItems, ObjectReference akOriginRef, \
        ObjectReference akDestinationRef, int aiQuantityToLeave, bool abSilent)
    Self.WorkerStart()

    Self._Log("LeaveOnlyXItems started: Index (Start) = " + aiIndex + ", Index (End) = " + aiIndexEnd)
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
    Self._Log("LeaveOnlyXItems finished")

    Self.WorkerStop()
EndFunction

; loads settings from MCM
Function LoadMCMSettings(int aiIndex, int aiIndexEnd, var[] akSettings, string asModName)
    Self.WorkerStart()

    Self._Log("LoadMCMSettings started: Index (Start) = " + aiIndex + ", Index (End) = " + aiIndexEnd)
    While aiIndex <= aiIndexEnd
        LoadSettingFromMCM(akSettings[aiIndex], asModName)
        aiIndex += 1
    EndWhile
    Self._Log("LoadMCMSettings finished")

    Self.WorkerStop()
EndFunction

; recycles components; sets Results[0] to a boolean representing whether any components were recycled
; true = components were recycled
; false = components were NOT recycled
Function RecycleComponents(int aiIndex, int aiIndexEnd, var[] akComponentMap, MultiplierSet akMultiplierSet, \
        ObjectReference akContainerRef, int aiRandomAdjustment, bool abReturnAtLeastOneComponent, \
        int aiFractionalComponentHandling)
    Self.WorkerStart()

    Self._Log("RecycleComponents started: Index (Start) = " + aiIndex + ", Index (End) = " + aiIndexEnd)

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
            Self._Log("Unknown rarity: " + cMap[aiIndex], 2)
        EndIf

        Self._Log(cMap[aiIndex].ComponentPart + " (" + cMap[aiIndex].ComponentPartName + "), " + \
            cMap[aiIndex].ScrapPart + " (" + cMap[aiIndex].ScrapPartName + ")")

        ; get the quantity of a certain component
        componentQuantity = akContainerRef.GetComponentCount(cMap[aiIndex].ComponentPart)
        Self._Log("Component quantity (Initial) = " + componentQuantity)

        if componentQuantity > 0.0
            ; since there are components to work on, signal that recycling happened
            Results[0] = true

            If aiRandomAdjustment
                ; use randomized multiplier adjustment for each individual component
                float randomMultAdjust = Utility.RandomFloat(randomMin, randomMax)
                scrapMultiplier += randomMultAdjust
                Self._Log("Adjustment (Random): " + randomMultAdjust)
                Self._Log("Multiplier: " + scrapMultiplier)
            EndIf

            ; remove all components of the type from the inventory
            akContainerRef.RemoveComponents(cMap[aiIndex].ComponentPart, componentQuantity as int, true)

            ; compute basic multiplied quantity
            componentQuantity *= scrapMultiplier
            Self._Log("Component quantity (Multiplied) = " + componentQuantity)

            ; give at least one component if the option is turned on and quantity <1
            If abReturnAtLeastOneComponent && componentQuantity < 1.0
                componentQuantity = 1.0
            EndIf
            Self._Log("Component quantity (ReturnAtLeastOneComponent) = " + componentQuantity)

            ; round the component quantity per settings
            If aiFractionalComponentHandling == 2           ; round down (floor)
                componentQuantity = Math.Floor(componentQuantity)
                Self._Log("Component quantity (Round Down [floor]) = " + componentQuantity)
            ElseIf aiFractionalComponentHandling == 1       ; round normally
                componentQuantity = (componentQuantity + 0.5) as int
                Self._Log("Component quantity (Round Normally) = " + componentQuantity)
            ElseIf aiFractionalComponentHandling == 0       ; round up (ceiling)
                componentQuantity = Math.Ceiling(componentQuantity)
                Self._Log("Component quantity (Round Up [ceiling]) = " + componentQuantity)
            EndIf

            ; add the modified quantity of components back to the inventory
            akContainerRef.AddItem(cMap[aiIndex].ScrapPart, componentQuantity as int, true)
            Self._Log("Component quantity (Final) = " + componentQuantity as int)
        EndIf

        aiIndex += 1
    EndWhile

    Self._Log("RecycleComponents finished")

    Self.WorkerStop()
EndFunction

Function Uninstall()
    DestroyArrayContents(Results)
    Results = None
EndFunction