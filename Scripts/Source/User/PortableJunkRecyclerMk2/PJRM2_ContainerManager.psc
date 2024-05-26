; Copyright 2023 Dan Cassidy

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



ScriptName PortableJunkRecyclerMk2:PJRM2_ContainerManager Extends Quest

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
    ObjectReference Property PortableRecyclerContainer Auto Mandatory
    FormListWrapper Property PortableRecyclerContents Auto Mandatory
EndGroup

Group Other
    bool Property PreInitialized = false Auto
    bool Property Initialized = false Auto
EndGroup

int Property ItemsProcessing Auto



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
    ControlManager = (Self as Quest) as PJRM2_ControlManager
    SettingManager = (Self as Quest) as PJRM2_SettingManager
    ThreadManager = (Self as Quest) as PJRM2_ThreadManager
    ModName = SettingManager.ModName
    EnableLogging = SettingManager.EnableLogging
    EnableProfiling = SettingManager.EnableProfiling
    Self._StartStackProfiling()
    Self._Log("Beginning onetime init process", abForce = true)
    ; do init stuff
    ; TODO finish init stuff
    PreInitialized = true
    Self._Log("Finished onetime init process", abForce = true)
    Self._StopStackProfiling()
EndEvent

Event ObjectReference.OnItemRemoved(ObjectReference akSourceContainer, Form akBaseItem, int aiItemCount, \
        ObjectReference akItemReference, ObjectReference akDestContainer)
    ; disable havok on the item reference - needed?
    akItemReference.SetMotionType(akItemReference.Motion_Keyframed, True)

    Self._Log("OnItemRemoved: event fired")

    Self._Log("OnItemRemoved: source container: " + akSourceContainer + ", base item: " + akBaseItem + \
        ", item count: " + aiItemCount + ", item reference: " + akItemReference + ", destination container: " + akDestContainer)

    ConstructibleObject:ConstructibleComponent[] item_components = New ConstructibleObject:ConstructibleComponent[0]

    ; get list of mods
    ObjectMod[] mods = akItemReference.GetAllMods()
    Self._Log("OnItemRemoved: mod list: " + mods)
    ; for each mod
    int index = mods.Length - 1
    While index >= 0
        Self._Log("OnItemRemoved: mod index: " + index)
        ObjectMod currentMod = mods[index]
        Self._Log("mod: " + currentMod)
        ; get materials required to make mod
        If currentMod
            ConstructibleObject:ConstructibleComponent[] returned = Self.GetComponents(currentMod)
            int index2 = returned.Length - 1
            While index2 >= 0
                item_components.Add(returned[index2])
                index2 -= 1
            EndWhile
        EndIf
        index -= 1
    EndWhile
    ; get materials required to make base item
    ConstructibleObject[] constructable_objects = SUP_F4SE.GetAllConstructibleObjectsFromForm(akBaseItem)
    Self._Log("OnItemRemoved: base item: " + akBaseItem + ", COBJs: " + constructable_objects)
    index = constructable_objects.Length - 1
    While index >= 0
        ConstructibleObject:ConstructibleComponent[] components = constructable_objects[index].GetConstructibleComponents()
        Self._Log("OnItemRemoved: base item: " + akBaseItem + ", components: " + components)
        ; divide material qty by 10 and apply any bonuses
        int index2 = components.Length - 1
        While index2 >= 0
            float newCount = components[index2].count / 10.0
            Self._Log("OnItemRemoved: base item: " + akBaseItem + ", component: " + components[index2] + ", new count (raw): " + newCount + ", new count (int): " + newCount as int)
            ; TODO apply bonuses
            ; TODO put material into chest to give back
            If (components[index2].Object as Component)
                PlayerRef.AddItem((components[index2].Object as Component).GetScrapItem(), Math.Ceiling(newCount), true)
            Else
                PlayerRef.AddItem(components[index2].Object, Math.Ceiling(newCount), true)
            EndIf
            index2 -= 1
        EndWhile
        index -= 1
    EndWhile
    ; delete item
    akItemReference.Delete()
    Self._Log("OnItemRemoved: reference " + akItemReference + " deleted")
    ItemsProcessing -= 1
    Self._Log("OnItemRemoved: items processing -1, items currently processing: " + ItemsProcessing)
EndEvent



; FUNCTIONS
; ---------

; add a bit of text to traces going into the papyrus user log
Function _Log(string asLogMessage, int aiSeverity = 0, bool abForce = false) DebugOnly
    If EnableLogging || abForce
        Log(ModName, "ContainerManager", asLogMessage, aiSeverity)
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

; consolidated init
Function Initialize(bool abQuestInit = false)
    ; Self.InitVariables(abForce = abQuestInit)
    ; Self.InitSettings(abForce = abQuestInit)
    ; Self.InitSettingsSupplemental()
    ; Self.LoadAllSettingsFromMCM()
    ; ; manually run the Crafting Station callback to resolve any weirdness that may have occurred
    ; ; due to multithreaded loading of the MCM settings
    ; Self.CallbackCraftingStation()
    ; Self.RegisterForMCMEvents()
    ; If abQuestInit
    ;     RegisterForMenuOpenCloseEvent("PauseMenu")
    ; EndIf
    ; Initialized = true
    ; TODO finish init stuff, including registering for drop event
    If abQuestInit
        RegisterForRemoteEvent(PortableRecyclerContainer, "OnItemRemoved")
        ; TODO temporary - remove once good solution for other inventory event filters is in place
        AddInventoryEventFilter(none)
    EndIf
    Self._Log("Initialized", abForce = true)
    Initialized = true
EndFunction

; get components of a COBJ
ConstructibleObject:ConstructibleComponent[] Function GetComponents(Form akItem)
    string function_name = "GetComponents"
    ConstructibleObject[] constructible_objects = SUP_F4SE.GetAllConstructibleObjectsFromForm(akItem)
    Self._Log(function_name + ": item: " + akItem + ", COBJs: " + constructible_objects)
    If constructible_objects.Length > 0
        int index = 0
        ; don't need to set index if length == 1, because it's already 0
        If constructible_objects.Length >= 1
            index = Utility.RandomInt(0, constructible_objects.Length)
        EndIf
        Self._Log(function_name + ": item " + akItem + ", index: " + index + ", COBJ: " + constructible_objects[index])
        Return constructible_objects[index].GetConstructibleComponents()
    Else
        Return New ConstructibleObject:ConstructibleComponent[0]
    EndIf
EndFunction

Function Recycle()
    Self._Log("Recycling contents")
EndFunction
