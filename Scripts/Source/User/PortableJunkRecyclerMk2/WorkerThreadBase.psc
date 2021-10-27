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



; FUNCTIONS: WORK
; ---------------

; adds forms that have components (meaning they can be broken down) to a FormList
; expects only MiscObjects in akItems
Function AddRecyclableItemsToList(var[] akItems, int aiIndex, int aiIndexEnd, FormList akFormList)
    Self.WorkerStart()

    Form[] items = akItems as Form[]
    Self._DebugTrace("Started: Items = " + items.Length + ", Index (Start) = " + aiIndex + ", Index (End) = " + \
        aiIndexEnd + ", FormList = " + akFormList)
	While aiIndex <= aiIndexEnd
        If (items[aiIndex] as MiscObject).GetMiscComponents()
            akFormList.AddForm(items[aiIndex])
        EndIf
		aiIndex += 1
	EndWhile
    Self._DebugTrace("Finished")

    Self.WorkerStop()
EndFunction

; adds forms to a FormList
Function AddItemsToList(var[] akItems, int aiIndex, int aiIndexEnd, FormList akFormList)
    Self.WorkerStart()

    Form[] items = akItems as Form[]
    Self._DebugTrace("Started: Items = " + items.Length + ", Index (Start) = " + aiIndex + ", Index (End) = " + \
        aiIndexEnd + ", FormList = " + akFormList)
	While aiIndex <= aiIndexEnd
        akFormList.AddForm(items[aiIndex])
		aiIndex += 1
	EndWhile
    Self._DebugTrace("Finished")

    Self.WorkerStop()
EndFunction

; recycles components; sets Results[0] to a boolean representing whether any components were recycled
; true = components were recycled
; false = components were NOT recycled
Function RecycleComponents(var[] akComponentMap, int aiIndex, int aiIndexEnd, MultiplierSet akMultiplierSet, \
        ObjectReference akContainerRef, int aiRandomAdjustment, bool abReturnAtLeastOneComponent, \
        int aiFractionalComponentHandling)
    Self.WorkerStart()

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

    Self.WorkerStop()
EndFunction

; builds a ComponentMap array for the given component and MiscObject FormLists
Function BuildComponentMap(FormListWrapper akComponentList, FormListWrapper akMiscObjectList)
    Self.WorkerStart()

    Self._DebugTrace("Building ComponentMap array from " + akComponentList.List + " (Components) and " + \
        akMiscObjectList.List + " (MiscObjects)")

    ComponentMap[] toReturn = new ComponentMap[akComponentList.Size]

    If toReturn.Length != akMiscObjectList.Size
        Self._DebugTrace("Component/MiscObject list size mismatch!", 2)
    EndIf

    int index = 0
    While index < toReturn.Length
        toReturn[index] = new ComponentMap
        toReturn[index].ComponentPart = akComponentList.List.GetAt(index) as Component
        toReturn[index].ComponentPartName = toReturn[index].ComponentPart.GetName()
        toReturn[index].ScrapPart = akMiscObjectList.List.GetAt(index) as MiscObject
        toReturn[index].ScrapPartName = toReturn[index].ScrapPart.GetName()
        Self._DebugTrace(toReturn[index].ComponentPart + " (" + toReturn[index].ComponentPartName + ") is mapped to " + \
            toReturn[index].ScrapPart + " (" + toReturn[index].ScrapPartName + ")")
        index += 1
    EndWhile

    Results = toReturn as var[]

    Self.WorkerStop()
EndFunction

; loads settings from MCM
Function LoadMCMSettings(var[] akSettings, int aiIndex, int aiIndexEnd, string asModName)
    Self.WorkerStart()

    Self._DebugTrace("Started: Settings = " + akSettings.Length + ", Index (Start) = " + aiIndex + ", Index (End) = " + \
        aiIndexEnd)
	While aiIndex <= aiIndexEnd
        LoadSettingFromMCM(akSettings[aiIndex], asModName)
		aiIndex += 1
	EndWhile
    Self._DebugTrace("Finished")

    Self.WorkerStop()
EndFunction

; changes settings to defaults
Function ChangeSettingsToDefaults(var[] akSettings, int aiIndex, int aiIndexEnd, int aiChangeType, string asModName)
    Self.WorkerStart()

    Self._DebugTrace("Started: Settings = " + akSettings.Length + ", Index (Start) = " + aiIndex + ", Index (End) = " + \
        aiIndexEnd)
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
    Self._DebugTrace("Finished")

    Self.WorkerStop()
EndFunction