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



ScriptName PortableJunkRecyclerMk2:PJRM2_ThreadManager Extends Quest
{ script that handles multithreading for the mod }

; import data structures
import PortableJunkRecyclerMk2:PJRM2_DataStructures
; import utility functions
import PortableJunkRecyclerMk2:PJRM2_Utility



; PROPERTIES
; ----------

bool Property Initialized = false Auto Hidden
int Property NumberOfWorkerThreads = 32 AutoReadOnly Hidden
string Property FullScriptName = "PortableJunkRecyclerMk2:PJRM2_ThreadManager" AutoReadOnly Hidden
bool Property DispatcherMutex = false Auto Hidden



; VARIABLES
; ---------

PJRM2_SettingManager SettingManager

string ModName
bool EnableLogging = false
bool EnableProfiling = false
int ThreadLimit

bool ProfilingActive = false
var[] Threads



; EVENTS
; ------

Event OnInit()
    Quest Control = Self as Quest
    SettingManager = Control as PJRM2_SettingManager
    ModName = SettingManager.ModName
    EnableLogging = SettingManager.EnableLogging
    EnableProfiling = SettingManager.EnableProfiling
    Self._StartStackProfiling()
    Self._Log("Beginning onetime init process")
    Threads = new var[NumberOfWorkerThreads]
    int index = 0
    string designation
    While index < NumberOfWorkerThreads
        If index < 10
            designation = "0" + index
        Else
            designation = index
        EndIf
        Threads[index] = Control.CastAs("PortableJunkRecyclerMk2:PJRM2_WorkerThread" + designation)
        (Threads[index] as PJRM2_WorkerThread).Initialize(ModName, designation, EnableLogging, EnableProfiling)
        index += 1
    EndWhile
    ThreadLimit = NumberOfWorkerThreads
    Initialized = true
    Self._Log("Finished onetime init process")
    Self._StopStackProfiling()
EndEvent



; FUNCTIONS: UTILITY
; ------------------

; add a bit of text to traces going into the papyrus user log
Function _Log(string asLogMessage, int aiSeverity = 0, bool abForce = false)
    If EnableLogging || abForce
        Log(ModName, "ThreadManager", asLogMessage, aiSeverity)
    EndIf
EndFunction

; start stack profiling
Function _StartStackProfiling() DebugOnly
    If EnableProfiling
        Debug.StartStackProfiling()
        ProfilingActive = true
        Self._Log("Stack profiling started")
    EndIf
EndFunction

; stop stack profiling
Function _StopStackProfiling() DebugOnly
    If ProfilingActive
        Debug.StopStackProfiling()
        ProfilingActive = false
        Self._Log("Stack profiling stopped")
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
                waitingOnThreads = waitingOnThreads || (akThreads[index] as PJRM2_WorkerThread).IsRunning()
                index += 1
            EndWhile
            ; if any threads are still running, wait for 0.1s
            If waitingOnThreads
                Utility.WaitMenuMode(0.1)
            EndIf
        EndWhile
    EndIf
EndFunction

; set the maximum number of threads to use, auto-clamps if argument out of bounds
; 1 <= aiMaxThreads <= NumberOfWorkerThreads
Function SetThreadLimit(int aiMaxThreads)
    int lowerLimit = 1 const
    int upperLimit = NumberOfWorkerThreads const
    If aiMaxThreads < lowerLimit
        aiMaxThreads = lowerLimit
    ElseIf aiMaxThreads > upperLimit
        aiMaxThreads = upperLimit
    EndIf
    ThreadLimit = aiMaxThreads
    Self._Log("ThreadLimit set to " + ThreadLimit)
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

        int index = 0
        While index < NumberOfWorkerThreads
            (Threads[index] as PJRM2_WorkerThread).SetLogging(EnableLogging)
            index += 1
        EndWhile
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

        int index = 0
        While index < NumberOfWorkerThreads
            (Threads[index] as PJRM2_WorkerThread).SetProfiling(EnableProfiling)
            index += 1
        EndWhile
    EndIf
EndFunction



; FUNCTIONS
; ---------

; handles the actual multithreading of a specified function; designed for data parallelism
; akParams[0] and akParams[1] are reserved for the starting and ending indices respectively; everything else is not proscribed
int Function ThreadDispatcher(string asFunction, int aiNumItems, var[] akParams)
    ; if the mutex is set, park and wait
    While DispatcherMutex
        Utility.WaitMenuMode(0.1)
    EndWhile

    ; set mutex
    DispatcherMutex = true

    ; set up multithreading parameters
    int numThreads = Math.Min(aiNumItems, ThreadLimit) as int
    float numItemsPerThread
    If numThreads > 0
        numItemsPerThread = aiNumItems as float / numThreads
    EndIf
    Self._Log("ThreadDispatcher (" + asFunction + "): " + aiNumItems + " items, using " + numThreads \
        + " threads for processing (" + numItemsPerThread + " items per thread)")

    ; start multithreading
    string threadIndex
    int index = 0
    While index < numThreads
        akParams[0] = (index * numItemsPerThread) as int
        akParams[1] = ((index + 1) * numItemsPerThread) as int - 1
        (Threads[index] as ScriptObject).CallFunctionNoWait(asFunction, akParams)
        If index < 10
            threadIndex = "0" + index
        Else
            threadIndex = index
        EndIf
        Self._Log("Dispatched WorkerThread" + threadIndex + " (" + asFunction + "): Index (Start) = " + akParams[0] \
            + ", Index (End) = " + akParams[1])
        index += 1
    EndWhile

    ; wait for multithreading to finish
    Self.WaitForThreads(Threads, numThreads)
    Self._Log("ThreadDispatcher (" + asFunction + "): Threads finished")

    ; unset mutex
    DispatcherMutex = false

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
    Self.ThreadDispatcher("AddRecyclableItemsToList", akItems.Length, params)

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
        tempResult = (Threads[threadIndex] as PJRM2_WorkerThread).GetResults() as ComponentMap[]
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
        toReturn = (Threads[index] as PJRM2_WorkerThread).GetResults()[0] as bool || toReturn
        index += 1
    EndWhile
    Return toReturn
EndFunction

; prepares the mod for uninstallation
Function Uninstall()
    ; make sure that threads shut down fully
    int index = 0
    While index < NumberOfWorkerThreads
        (Threads[index] as PJRM2_WorkerThread).Uninstall()
        index += 1
    EndWhile

    ; destroy arrays
    DestroyArrayContents(Threads)
    Threads = None

    ; stop the quest
    Stop()
EndFunction
