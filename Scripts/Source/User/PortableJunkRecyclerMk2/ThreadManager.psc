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

int MaxThreads = 16 const
var[] Threads
string[] HexNumbers



; EVENTS
; ------

Event OnInit()
    Debug.OpenUserLog(ModName)
    Self._DebugTrace("Beginning onetime init process")
    Threads = new var[MaxThreads]
    Threads[0x0] = (Self as Quest) as WorkerThread0x0
    Threads[0x1] = (Self as Quest) as WorkerThread0x1
    Threads[0x2] = (Self as Quest) as WorkerThread0x2
    Threads[0x3] = (Self as Quest) as WorkerThread0x3
    Threads[0x4] = (Self as Quest) as WorkerThread0x4
    Threads[0x5] = (Self as Quest) as WorkerThread0x5
    Threads[0x6] = (Self as Quest) as WorkerThread0x6
    Threads[0x7] = (Self as Quest) as WorkerThread0x7
    Threads[0x8] = (Self as Quest) as WorkerThread0x8
    Threads[0x9] = (Self as Quest) as WorkerThread0x9
    Threads[0xA] = (Self as Quest) as WorkerThread0xA
    Threads[0xB] = (Self as Quest) as WorkerThread0xB
    Threads[0xC] = (Self as Quest) as WorkerThread0xC
    Threads[0xD] = (Self as Quest) as WorkerThread0xD
    Threads[0xE] = (Self as Quest) as WorkerThread0xE
    Threads[0xF] = (Self as Quest) as WorkerThread0xF
    HexNumbers = new string[16]
    HexNumbers[0x0] = "0x0"
    HexNumbers[0x1] = "0x1"
    HexNumbers[0x2] = "0x2"
    HexNumbers[0x3] = "0x3"
    HexNumbers[0x4] = "0x4"
    HexNumbers[0x5] = "0x5"
    HexNumbers[0x6] = "0x6"
    HexNumbers[0x7] = "0x7"
    HexNumbers[0x8] = "0x8"
    HexNumbers[0x9] = "0x9"
    HexNumbers[0xA] = "0xA"
    HexNumbers[0xB] = "0xB"
    HexNumbers[0xC] = "0xC"
    HexNumbers[0xD] = "0xD"
    HexNumbers[0xE] = "0xE"
    HexNumbers[0xF] = "0xF"
    Initialized = true
    Self._DebugTrace("Finished onetime init process")
EndEvent



; FUNCTIONS: UTILITY
; ------------------

; add a bit of text to traces going into the papyrus user log
Function _DebugTrace(string asMessage, int aiSeverity = 0) DebugOnly
    Debug.TraceUser(ModName, "ThreadManager: " + asMessage, aiSeverity)
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
int Function MultiThread(string asFunction, int aiNumItems, var[] akParams)
    ; set up multithreading parameters
    int numThreads = Math.Min(aiNumItems, MaxThreads) as int
    float numItemsPerThread
    If numThreads
        numItemsPerThread = aiNumItems as float / numThreads
    EndIf
    Self._DebugTrace("MultiThread (" + asFunction + "): " + aiNumItems + " items, using " + numThreads + " threads for processing (" + \
        numItemsPerThread + " items per thread)")

    ; start multithreading
    int index = 0
    While index < numThreads
        akParams[0] = (index * numItemsPerThread) as int
        akParams[1] = ((index + 1) * numItemsPerThread) as int - 1
        (Threads[index] as ScriptObject).CallFunctionNoWait(asFunction, akParams)
        Self._DebugTrace("Called WorkerThread " + HexNumbers[index] + " (" + asFunction + "): Index (Start) = " + akParams[0] + \
            ", Index (End) = " + akParams[1])
        index += 1
    EndWhile

    ; wait for multithreading to finish
    Self.WaitForThreads(Threads, numThreads)
    Self._DebugTrace("MultiThread (" + asFunction + "): Threads finished")
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
    Self.MultiThread("AddArrayItemsToInventory", akItems.Length, params)
EndFunction

; (multithreaded) add items to a FormList
Function AddItemsToList(Form[] akItems, FormListWrapper akFormList)
    ; create array to hold function arguments
    var[] params = new var[4]
    params[2] = Utility.VarArrayToVar(akItems as var[]) as var
    params[3] = akFormList.List as FormList

    ; do the actual multithreading
    Self.MultiThread("AddItemsToList", akItems.Length, params)

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
    Self.MultiThread("AddListItemsToInventory", akFormList.Size, params)
EndFunction

; (multithreaded) checks items that are passed in to see if they are recyclable and if so, add them to the specified FormList
Function AddRecyclableItemsToList(Form[] akItems, FormListWrapper akFormList)
    ; create array to hold function arguments
    var[] params = new var[4]
    params[2] = Utility.VarArrayToVar(akItems as var[]) as var
    params[3] = akFormList.List as FormList

    ; do the actual multithreading
    Self.MultiThread("AddRecyclableItemsToList", akItems.Length, params)

    ; update the size of the FormList
    akFormList.Size = akFormList.List.GetSize()
EndFunction

; (multithreaded) build a component map from a FormList of components and a FormList of MiscObjects
ComponentMap[] Function BuildComponentMap(FormListWrapper akComponentList, FormListWrapper akMiscObjectList)
    ; create array to hold function arguments
    var[] params = new var[4]
    params[2] = akComponentList.List as FormList
    params[3] = akMiscObjectList.List as FormList

    ; do the actual multithreading
    int numThreadsUsed = Self.MultiThread("BuildComponentMap", akComponentList.Size, params)

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
    Self.MultiThread("ChangeSettingsToDefaults", akSettingsToChange.Length, params)
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
    Self.MultiThread("LeaveOnlyXItems", akItems.Length, params)
EndFunction

; (multithreaded) load MCM settings
Function LoadMCMSettings(var[] akSettingsToLoad, string asModName)
    ; create array to hold function arguments
    var[] params = new var[4]
    params[2] = Utility.VarArrayToVar(akSettingsToLoad as var[]) as var
    params[3] = asModName as string

     ; do the actual multithreading
     Self.MultiThread("LoadMCMSettings", akSettingsToLoad.Length, params)
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
    int numThreadsUsed = Self.MultiThread("RecycleComponents", akComponentMap.Length, params)

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