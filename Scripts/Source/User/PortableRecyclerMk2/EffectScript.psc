ScriptName PortableRecyclerMk2:EffectScript Extends ActiveMagicEffect

;-- Properties --------------------------------------
QuestScript Property PortableRecyclerQuest Auto Const
Potion Property PortableRecyclerItem Auto Const



Actor Property PlayerRef Auto Const
Container Property PortableRecyclerContainer Auto Const
Sound Property PortableRecyclerSound Auto Const
WorkshopParentScript Property WorkshopParent Auto Const
ComponentMap[] Property Components Auto Const

Struct ComponentMap
	Component ComponentPart
	MiscObject ScrapPart
EndStruct


;-- Variables ---------------------------------------

;-- Functions ---------------------------------------

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If ! PortableRecyclerQuest.IsRunning
		; naively try and prevent multiple activations - it could potentially still happen while
		; under heavy script load, but this script _should_ be not terrible about that
		PortableRecyclerQuest.IsRunning = true
		Debug.MessageBox("Portable Recycler Running")

		

		float scrapMultiplier

		int version = 12
		If IsPlayerAtOwnedWorkshop()
			scrapMultiplier = 10.0
			Debug.MessageBox("v" + version + ": Friendly! Mult set to " + scrapMultiplier)
		Else
			scrapMultiplier = 1.0
			Debug.MessageBox("v" + version + ": Not friendly! Mult set to " + scrapMultiplier)
		EndIf

		ObjectReference containerRef = PlayerRef.PlaceAtMe(PortableRecyclerContainer as Form)
		Utility.Wait(1.0)

		containerRef.Activate(PlayerRef as ObjectReference, true)
		Utility.Wait(0.1)

		If containerRef.GetInventoryItems().Length > 0
			PortableRecyclerSound.Play(PlayerRef as ObjectReference)
		EndIf
		
		; only scrap things if the scrap multiplier is > 0, otherwise everything will just be lost
		If scrapMultiplier > 0.0
			int currentComponent = 0
			int numComponents = Components.Length
			int componentQuantity = 0
			While currentComponent < numComponents
				componentQuantity = containerRef.GetComponentCount(Components[currentComponent].ComponentPart)
				containerRef.RemoveComponents(Components[currentComponent].ComponentPart, componentQuantity, true)
				; TODO maybe use Math.Ciel() instead?
				containerRef.AddItem(Components[currentComponent].ScrapPart, Math.Floor(componentQuantity * scrapMultiplier), true)
				currentComponent += 1
			EndWhile
		Else
			; TODO show a notification 
		EndIf

		containerRef.RemoveAllItems(PlayerRef as ObjectReference, false)
		containerRef.Delete()
		PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)
		PortableRecyclerQuest.IsRunning = false
		Debug.MessageBox("Portable Recycler Finished")
	Else
		PlayerRef.AddItem(PortableRecyclerItem as Form, 1, true)
	EndIf
EndEvent

; returns true if the player is an an owned workshop
bool Function IsPlayerAtOwnedWorkshop()
	Location PlayerLocation = PlayerRef.GetCurrentLocation()
	;bool HasWorkshopRef = PlayerLocation.HasRefType()
	;Keyword[] LocKeywords = PlayerLocation.GetKeywords()
	;int numKeywords = PlayerLocation.GetKeywords().Length
	;Debug.MessageBox("# Location Keywords: " + PlayerLocation.GetKeywords().Length)
	;int currentIndex = 0
	;while currentIndex < numKeywords
	;	Debug.MessageBox("Keyword " + currentIndex + " data: " + PlayerLocation.GetKeywordData(LocKeywords[currentIndex]))
	;	currentIndex += 1
	;endwhile
	;Debug.MessageBox("Number of Workshop Locations: " + WorkshopParent.WorkshopLocations.Length)
	WorkshopScript workshopRef = WorkshopParent.GetWorkshopFromLocation(PlayerLocation)
	Debug.MessageBox("Location: " + PlayerLocation.GetFormID() + "; WorkshopRef: " + workshopRef.GetFormID() + "; OwnedByPlayer: " + workshopRef.OwnedByPlayer)
	If workshopRef && workshopRef.OwnedByPlayer && PlayerRef.IsWithinBuildableArea(workshopRef)
		Return true
	Else
		Return false
	EndIf
EndFunction
