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



ScriptName PortableJunkRecyclerMk2:ThreadManager Extends Quest
{ script that handles multithreading for the mod }

; import the base global functions and structs
import PortableJunkRecyclerMk2:Base



; PROPERTIES
; ----------

bool Property Initialized = false Auto



; VARIABLES
; ---------

string ModName = "Portable Junk Recycler Mk 2" const

int MaxThreads = 32 const
var[] Threads
string[] HexNumbers



; EVENTS
; ------

Event OnInit()
    Debug.OpenUserLog(ModName)
    Self._DebugTrace("Beginning onetime init process")
    Threads = new var[MaxThreads]
    Threads[00] = (Self as Quest) as WorkerThread00
    Threads[01] = (Self as Quest) as WorkerThread01
    Threads[02] = (Self as Quest) as WorkerThread02
    Threads[03] = (Self as Quest) as WorkerThread03
    Threads[04] = (Self as Quest) as WorkerThread04
    Threads[05] = (Self as Quest) as WorkerThread05
    Threads[06] = (Self as Quest) as WorkerThread06
    Threads[07] = (Self as Quest) as WorkerThread07
    Threads[08] = (Self as Quest) as WorkerThread08
    Threads[09] = (Self as Quest) as WorkerThread09
    Threads[10] = (Self as Quest) as WorkerThread10
    Threads[11] = (Self as Quest) as WorkerThread11
    Threads[12] = (Self as Quest) as WorkerThread12
    Threads[13] = (Self as Quest) as WorkerThread13
    Threads[14] = (Self as Quest) as WorkerThread14
    Threads[15] = (Self as Quest) as WorkerThread15
    Threads[16] = (Self as Quest) as WorkerThread16
    Threads[17] = (Self as Quest) as WorkerThread17
    Threads[18] = (Self as Quest) as WorkerThread18
    Threads[19] = (Self as Quest) as WorkerThread19
    Threads[20] = (Self as Quest) as WorkerThread20
    Threads[21] = (Self as Quest) as WorkerThread21
    Threads[22] = (Self as Quest) as WorkerThread22
    Threads[23] = (Self as Quest) as WorkerThread23
    Threads[24] = (Self as Quest) as WorkerThread24
    Threads[25] = (Self as Quest) as WorkerThread25
    Threads[26] = (Self as Quest) as WorkerThread26
    Threads[27] = (Self as Quest) as WorkerThread27
    Threads[28] = (Self as Quest) as WorkerThread28
    Threads[29] = (Self as Quest) as WorkerThread29
    Threads[30] = (Self as Quest) as WorkerThread30
    Threads[31] = (Self as Quest) as WorkerThread31
    Initialized = true
    Self._DebugTrace("Finished onetime init process")
EndEvent



; FUNCTIONS: UTILITY
; ------------------

; add a bit of text to traces going into the papyrus user log
Function _DebugTrace(string asMessage, int aiSeverity = 0) DebugOnly
    string baseMessage = "ThreadManager: " const
    If aiSeverity == 0
        Debug.TraceUser(ModName, baseMessage + asMessage)
    ElseIf aiSeverity == 1
        Debug.TraceUser(ModName, "WARNING: " + baseMessage + asMessage)
    ElseIf aiSeverity == 2
        Debug.TraceUser(ModName, "ERROR: " + baseMessage + asMessage)
    EndIf
EndFunction

; waits for a specified number of threads to finish before returning
Function WaitForThreads(var[] akThreads, int aiNumThreads)
    ; only wait if threads were started
    If aiNumThreads
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
                Utility.WaitMenuMode(0.1)
            EndIf
        EndWhile
    EndIf
EndFunction



; FUNCTIONS
; ---------

; handles the actual multithreading of a specified function; designed for data parallelism
; akParams[0] and akParams[1] are reserved for the starting and ending indices respectively; everything else is not proscribed
int Function ThreadDispatcher(string asFunction, int aiNumItems, var[] akParams)
    ; set up multithreading parameters
    int numThreads = Math.Min(aiNumItems, MaxThreads) as int
    float numItemsPerThread
    If numThreads
        numItemsPerThread = aiNumItems as float / numThreads
    EndIf
    Self._DebugTrace("ThreadDispatcher (" + asFunction + "): " + aiNumItems + " items, using " + numThreads + " threads for processing (" + \
        numItemsPerThread + " items per thread)")

    ; start multithreading
    int index = 0
    While index < numThreads
        akParams[0] = (index * numItemsPerThread) as int
        akParams[1] = ((index + 1) * numItemsPerThread) as int - 1
        (Threads[index] as ScriptObject).CallFunctionNoWait(asFunction, akParams)
        Self._DebugTrace("Called WorkerThread " + index + " (" + asFunction + "): Index (Start) = " + akParams[0] + \
            ", Index (End) = " + akParams[1])
        index += 1
    EndWhile

    ; wait for multithreading to finish
    Self.WaitForThreads(Threads, numThreads)
    Self._DebugTrace("ThreadDispatcher (" + asFunction + "): Threads finished")
    Return numThreads
EndFunction

; (multithreaded) adds a quantity of items in the passed in FormList to the inventory of the specified object reference
Function AddArrayItemsToInventory(Form[] akItems, ObjectReference akDestinationRef, int aiQuantity)
    ; create array to hold function arguments
    var[] params = new var[5]
    params[2] = Utility.VarArrayToVar(akItems as var[]) as var
    params[3] = akDestinationRef as ObjectReference
    params[4] = aiQuantity as int

    ; do the actual multithreading
    Self.ThreadDispatcher("AddArrayItemsToInventory", akItems.Length, params)
EndFunction

; (multithreaded) add items to a FormList
Function AddItemsToList(Form[] akItems, FormListWrapper akFormList)
    ; create array to hold function arguments
    var[] params = new var[4]
    params[2] = Utility.VarArrayToVar(akItems as var[]) as var
    params[3] = akFormList.List as FormList

    ; do the actual multithreading
    Self.ThreadDispatcher("AddItemsToList", akItems.Length, params)

    ; update the size of the FormList
    akFormList.Size = akFormList.List.GetSize()
EndFunction

; (multithreaded) adds a quantity of items in the passed in FormList to the inventory of the specified object reference
Function AddListItemsToInventory(FormListWrapper akFormList, ObjectReference akDestinationRef, int aiQuantity)
    ; create array to hold function arguments
    var[] params = new var[5]
    params[2] = akFormList.List as FormList
    params[3] = akDestinationRef as ObjectReference
    params[4] = aiQuantity as int

    ; do the actual multithreading
    Self.ThreadDispatcher("AddListItemsToInventory", akFormList.Size, params)
EndFunction

; (multithreaded) checks items that are passed in to see if they are recyclable and if so, add them to the specified FormList
Function AddRecyclableItemsToList(Form[] akItems, FormListWrapper akRecyclableItemsList, FormListWrapper akNetWeightReductionList, \
        ComponentMap[] akComponentMap, Component[] akComponents)
    ; create array to hold function arguments
    var[] params = new var[7]
    params[2] = Utility.VarArrayToVar(akItems as var[]) as var
    params[3] = akRecyclableItemsList.List as FormList
    params[4] = akNetWeightReductionList.List as FormList
    params[5] = Utility.VarArrayToVar(akComponentMap as var[]) as var
    params[6] = Utility.VarArrayToVar(akComponents as var[]) as var

    ; do the actual multithreading
    Self.ThreadDispatcher("AddRecyclableItemsToList2", akItems.Length, params)

    ; update the size of the FormList
    akRecyclableItemsList.Size = akRecyclableItemsList.List.GetSize()
    akNetWeightReductionList.Size = akNetWeightReductionList.List.GetSize()
EndFunction

; (multithreaded) build a component map from a FormList of components and a FormList of MiscObjects
ComponentMap[] Function BuildComponentMap(FormListWrapper akComponentList, FormListWrapper akMiscObjectList)
    ; create array to hold function arguments
    var[] params = new var[4]
    params[2] = akComponentList.List as FormList
    params[3] = akMiscObjectList.List as FormList

    ; do the actual multithreading
    int numThreadsUsed = Self.ThreadDispatcher("BuildComponentMap", akComponentList.Size, params)

    ; collect results
    ComponentMap[] toReturn = new ComponentMap[akComponentList.Size]
    int returnIndex = 0
    int threadIndex = 0
    int resultIndex
    ComponentMap[] tempResult
    While threadIndex < numThreadsUsed
        resultIndex = 0
        tempResult = (Threads[threadIndex] as WorkerThreadBase).GetResults() as ComponentMap[]
        While resultIndex < tempResult.Length
            toReturn[returnIndex] = tempResult[resultIndex]
            resultIndex += 1
            returnIndex += 1
        EndWhile
        threadIndex += 1
    EndWhile

    Return toReturn
EndFunction

; (multithreaded) revert the passed in settings to their default values
Function ChangeSettingsToDefaults(var[] akSettingsToChange, int aiCurrentChangeType, string asModName)
    ; create array to hold function arguments
    var[] params = new var[5]
    params[2] = Utility.VarArrayToVar(akSettingsToChange as var[]) as var
    params[3] = aiCurrentChangeType as int
    params[4] = asModName as string

    ; do the actual multithreading
    Self.ThreadDispatcher("ChangeSettingsToDefaults", akSettingsToChange.Length, params)
EndFunction

; (multithreaded) removes all but X number of items from the origin, optionally moving them to the destination
Function LeaveOnlyXItems(Form[] akItems, ObjectReference akOriginRef, ObjectReference akDestinationRef, \
        int aiQuantityToLeave, bool abSilent)
    ; create array to hold function arguments
    var[] params = new var[7]
    params[2] = Utility.VarArrayToVar(akItems as var[]) as var
    params[3] = akOriginRef as ObjectReference
    params[4] = akDestinationRef as ObjectReference
    params[5] = aiQuantityToLeave as int
    params[6] = abSilent as bool

    ; do the actual multithreading
    Self.ThreadDispatcher("LeaveOnlyXItems", akItems.Length, params)
EndFunction

; (multithreaded) load MCM settings
Function LoadMCMSettings(var[] akSettingsToLoad, string asModName)
    ; create array to hold function arguments
    var[] params = new var[4]
    params[2] = Utility.VarArrayToVar(akSettingsToLoad as var[]) as var
    params[3] = asModName as string

     ; do the actual multithreading
     Self.ThreadDispatcher("LoadMCMSettings", akSettingsToLoad.Length, params)
EndFunction

; (multithreaded) recycle the components contained in the passed ComponentMap array
; returns true if any components were actually recycled
bool Function RecycleComponents(ComponentMap[] akComponentMap, MultiplierSet akMultiplierSet, \
       ObjectReference akContainerRef, int aiRandomAdjustment, bool abReturnAtLeastOneComponent, \
       int aiFractionalComponentHandling)
    ; create array to hold function arguments
    var[] params = new var[8]
    params[2] = Utility.VarArrayToVar(akComponentMap as var[])
    params[3] = akMultiplierSet as MultiplierSet
    params[4] = akContainerRef as ObjectReference
    params[5] = aiRandomAdjustment as int
    params[6] = abReturnAtLeastOneComponent as bool
    params[7] = aiFractionalComponentHandling as int

    ; do the actual multithreading
    int numThreadsUsed = Self.ThreadDispatcher("RecycleComponents", akComponentMap.Length, params)

    ; collect results
    bool toReturn = false
    int index = 0
    While index < numThreadsUsed
        toReturn = (Threads[index] as WorkerThreadBase).GetResults()[0] as bool || toReturn
        index += 1
    EndWhile
    Return toReturn
EndFunction

; prepares the mod for uninstallation
Function Uninstall()
    ; destroy arrays
    DestroyArrayContents(Threads)
    Threads = None
    HexNumbers = None

    ; stop the quest
    Stop()
EndFunction