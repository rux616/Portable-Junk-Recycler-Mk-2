ScriptName PortableJunkRecyclerMk2:EffectScript Extends ActiveMagicEffect

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

		

		float fScrapMultiplier

		int iVersion = 12
		If IsPlayerAtOwnedWorkshop()
			fScrapMultiplier = 10.0
			Debug.MessageBox("v" + iVersion + ": Friendly! Mult set to " + fScrapMultiplier)
		Else
			fScrapMultiplier = 1.0
			Debug.MessageBox("v" + iVersion + ": Not friendly! Mult set to " + fScrapMultiplier)
		EndIf

		ObjectReference kContainerRef = PlayerRef.PlaceAtMe(PortableRecyclerContainer as Form)
		Utility.Wait(1.0)

		kContainerRef.Activate(PlayerRef as ObjectReference, true)
		Utility.Wait(0.1)

		If kContainerRef.GetInventoryItems().Length > 0
			PortableRecyclerSound.Play(PlayerRef as ObjectReference)
		EndIf
		
		; only scrap things if the scrap multiplier is > 0, otherwise everything will just be lost
		If fScrapMultiplier > 0.0
			int iCurrentComponent = 0
			int iNumComponents = Components.Length
			float fComponentQuantity = 0
			While iCurrentComponent < iNumComponents
				fComponentQuantity = kContainerRef.GetComponentCount(Components[iCurrentComponent].ComponentPart)
				kContainerRef.RemoveComponents(Components[iCurrentComponent].ComponentPart, fComponentQuantity as int, true)
				; TODO add support for 'always return at least one component' mode
				; TODO add support for 'allow partial componenent' mode
				; fComponentQuantity = Math.Max(bAlwaysReturnAtLeastOneComponent, fComponentQuantity * fScrapMultiplier)
				; If bAllowPartialComponents
				;     fComponentQuantity = Math.Ciel(fComponentQuantity)
				; Else
				;     fComponentQuantity = Math.Floor(fComponentQuantity)
				; EndIf
				kContainerRef.AddItem(Components[iCurrentComponent].ScrapPart, fComponentQuantity as int, true)
				iCurrentComponent += 1
			EndWhile
		Else
			; TODO show a notification 
		EndIf

		kContainerRef.RemoveAllItems(PlayerRef as ObjectReference, false)
		kContainerRef.Delete()
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
