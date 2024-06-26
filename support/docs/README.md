Portable Junk Recycler Mk 2
===========================
by rux616

Version: 1.3.0

Table Of Contents
-----------------
- [Portable Junk Recycler Mk 2](#portable-junk-recycler-mk-2)
    - [Table Of Contents](#table-of-contents)
- [Overview](#overview)
    - [Summary](#summary)
    - [Features](#features)
    - [Requirements](#requirements)
    - [Installation](#installation)
    - [Load Order](#load-order)
    - [Uninstallation](#uninstallation)
    - [Crafting Materials Required](#crafting-materials-required)
- [Mod Information](#mod-information)
    - [Hotkeys](#hotkeys)
    - [Crafting](#crafting)
    - [Scrap Return Formula](#scrap-return-formula)
    - [Known Issues](#known-issues)
- [Interesting Configurations](#interesting-configurations)
    - [Brainiac](#brainiac)
    - [Leprechaun](#leprechaun)
    - [Loot Piñata](#loot-piñata)
    - [Magnum Opus Wabbajack Modlist](#magnum-opus-wabbajack-modlist)
    - [No Bonuses](#no-bonuses)
    - [No Scrapper, No Scrap](#no-scrapper-no-scrap)
    - [OG Portable Junk Recycler](#og-portable-junk-recycler)
    - [Punishing Field Use](#punishing-field-use)
    - [The Gambler](#the-gambler)
- [Technical Details](#technical-details)
    - [Plugin FormID Layout](#plugin-formid-layout)
    - [Limited Uses](#limited-uses)
    - [Scrap Categories](#scrap-categories)
    - [Settings Layout in MCM](#settings-layout-in-mcm)
- [Troubleshooting Info](#troubleshooting-info)
    - [Enable Debug Logging (Fallout 4)](#enable-debug-logging-fallout-4)
    - [Enable Debug Logging (Portable Junk Recycler Mk 2)](#enable-debug-logging-portable-junk-recycler-mk-2)
    - [Log Location](#log-location)
- [Copyright and Licenses](#copyright-and-licenses)
- [Credits and Thanks](#credits-and-thanks)
- [Contact](#contact)


Overview
========

Summary
-------
A highly configurable device that will scrap junk items transferred into its inventory, returning the component parts.

I created this mod because while I really liked the original [Portable Junk Recycler by Kentington](https://www.nexusmods.com/fallout4/mods/14110), I wanted something that I could customize and additionally I wanted to see if I could fix the crash issue.

**Note:** Sadly, armor and weapon scrapping is not possible through scripting yet. Anything that is _not_ a junk item (like armor, weapons, chems, etc.) will simply get returned if they are put in the device inventory.

By default the Mk 2 functions like the original, that is, you use it, exit the Pip-boy, move the junk objects you want to be recycled into the container that then opens, close said container, and then you get a bunch of components back. However it has the following bonuses by default:

- You get a 1% bonus to the number of components returned for each point of Intelligence
- You get a 1% bonus to the number of components returned for each point of Luck
- You get a 10% bonus to the number of components returned per Scrapper perk rank, but _only_ in player-owned settlements

You can heavily customize all these options and more via the MCM.

This mod **REQUIRES** both F4SE and MCM and will not work without them. I had to do this in order to prevent the freezing bug found in the original. Sorry, console players, you're out of luck. This mod also supports the [Canary](https://www.nexusmods.com/fallout4/mods/44949) mod to alert in the event of save game corruption.

Also by default, the Portable Junk Recycler Mk 2 will detect whether the [Standalone Workbenches](https://www.nexusmods.com/fallout4/mods/41832), [ECO](https://www.nexusmods.com/fallout4/mods/55503), or [AWKCR v5.0+](https://www.nexusmods.com/fallout4/mods/6091) mods are installed and will dynamically set itself to be crafted at the respective "Utility" workbenches, or at the vanilla "Chemistry Station" if none are installed. If more than one of the preceding mods are installed, the Standalone Workbenches Utility Workbench takes priority, followed by the ECO Utility Station, then the AWKCR Utility Workbench. The device can be found under the "UTILITY" category (or one of the other categories based on whether any of the category changer addon plugins are active or not).

This mod (plus all of its extra bits like images, build scripts, etc.) is also available at the [GitHub project](https://github.com/rux616/Portable-Junk-Recycler-Mk-2).

([TOC](#table-of-contents))

Features
--------
- Extremely customizable via the Mod Config Menu
- Can automatically move junk items to the recycler inventory
- Can be set to only automatically move items that when recycled, will save weight
- Configurable "Always Automatically Transfer" and "Never Automatically Transfer" lists
- Has a fully automatic mode (just activate the device and it processes junk items in your inventory)
- Dynamically supports crafting the device at the "Utility Workbench" from Standalone Workbenches, the "Utility Station" from ECO, or the "Utility Workbench" from AWKCR (order of priority is Standalone Workbenches > ECO > AWKCR), can also be crafted at a number of other workbenches
- Additional plugins included to change the crafting category of the Mk 2
- Can be activated via an MCM hotkey
- Can be configured to only have a limited number uses
- Sane defaults, so even if not customized, it will work well out of the box
- Customized low- and high-res textures
- Doesn't require any DLC
- Dynamic support of up to 5 ranks of the Scrapper perk (if you have some mod that adds them)
- The mesh used for the device has physics, so it won't just hang in the air if you ever drop it from your inventory
- Can be configured to move Mk 2 device back to the player's inventory if the last one gets removed, optionally asking first
- [Canary](https://www.nexusmods.com/fallout4/mods/44949) save file monitor support

([TOC](#table-of-contents))

Requirements
------------
- [Fallout 4 Script Extender (F4SE)](https://f4se.silverlock.org/)
- [Mod Configuration Menu (MCM)](https://www.nexusmods.com/fallout4/mods/21497)

([TOC](#table-of-contents))

Installation
------------
I **highly** recommend that you use a mod manager to install this mod, as there is a FOMOD installer included. I personally recommend Mod Organizer 2, but Vortex is fine too. If you must, however, this mod can be installed by unzipping it directly into the Data folder of your Fallout 4 installation.

([TOC](#table-of-contents))

Load Order
----------
The plugins in this mod touch nothing directly and so can go pretty much anywhere in your load order as long as masters are respected.

([TOC](#table-of-contents))

Uninstallation
--------------
Note that uninstallation is technically unsupported because this mod uses scripts which will embed data in your save. That being said, if you still want to uninstall, here is a process which attempts to minimize complications.

To uninstall this mod, make sure that a recycling process is not underway, then follow these steps:
- Go to the Pause Menu
- Go into the Mod Config menu
- Find "Portable Junk Recycler Mk 2" and go into the "Advanced" page
- Disengage the safeguard (click "Show The "Uninstall Mod" Button")
- Click the "Uninstall Mod" button
- Close the Pause Menu
- Wait a few seconds for the pop up message to appear
- Save your game
- Exit the game
- Disable or remove this mod and its files

([TOC](#table-of-contents))

Crafting Materials Required
---------------------------
- Enhanced Targeting Card x1
- Fusion Core x1
- High-powered Magnet x1
- Power Relay Coil x2
- Screws x12
- Sensor Module x1
- Steel x20

([TOC](#table-of-contents))


Mod Information
===============

Hotkeys
-------
All hotkeys in this mod work as modifiers, except for the "Activate Portable Junk Recycler Mk 2" hotkey. This means that in order for the effect of the hotkey to take place, said hotkey(s) need to be pressed at the time the Portable Junk Recycler Mk 2 is activated.

By default, the mod comes with the "Behavior Override" option set to `OFF`; to enabled overriding the behavior of the Portable Junk Recycler Mk 2, turn that option `ON`:
- If both `[CTRL]` and `[SHIFT]` are pressed when the recycler is activated, the recycler inventory will not open and instead, all recyclable junk items, except for those items on the "Never Automatically Transfer" list (unless the use of that list is turned `OFF`) and maybe those items in the Low Weight Ratio list, depending on how your options are set, will be broken down and their component parts returned. This is identical in functionality to having the "Automatic Recycling Mode" option set to `ON`.
- If only `[SHIFT]` is pressed when the recycler is activated, the recycler inventory will open and all recyclable junk items from the player inventory will be moved into it, except for those items on the "Never Automatically Transfer" list (unless the use of that list is turned OFF). This is identical in functionality to having the "Automatically Transfer Junk" option set to `ON`.
- If only `[CTRL]` is pressed when the recycler is activated, the recycler inventory will open and no recyclable junk items from the player inventory will be moved into it, except for those items on the "Always Automatically Transfer" list (unless the use of that list is turned OFF). This is identical in functionality to having the "Automatically Transfer Junk" option set to `OFF`.

Editing the "Never/Always Automatically Transfer" lists is also `OFF` by default; to enable editing these lists, turn that option `ON`:
- To edit the "Never Automatically Transfer" list, ensure that `[ALT]` and `[CTRL]` are both pressed when the recycler is activated.
- To edit the "Always Automatically Transfer" list, ensure that `[ALT]` and `[SHIFT]` are both pressed when the recycler is activated.

([TOC](#table-of-contents))

Crafting
--------
The Mk 2 can be crafted at a number of different workbenches from different mods depending on user preference. Currently supported workbenches are as follows:

**From Standalone Workbenches:**
- Electronics Workbench
- Engineering Workbench
- Manufacturing Workbench
- Utility Workbench

**From ECO:**
- Utility Station

**From AWKCR:**
- Adv. Engineering Workbench
- Electronics Workstation
- Utility Workbench

**From vanilla:**
- Chemistry Station

Note that the default option is "Dynamic", which will automatically attempt to use the following workbenches with decreasing priority:
- Utility Workbench (Standalone Workbenches)
- Utility Station (ECO)
- Utility Workbench (AWKCR v5.0+)
- Chemistry Station (vanilla)

([TOC](#table-of-contents))

Scrap Return Formula
--------------------
The Mk 2 works off of a multiplier for different scrap rarities, which are organized into four categories: Common, Uncommon, Rare, and Special. (See the lists below for details about which components are in which category by default.) This multiplier is composed of several different elements, and in the most basic configuration will be the same for each category.

Overall, it is a simple formula:

    NumberOfComponentsReturned = NumberOfComponentsToRecycle * Multiplier

`Multiplier` is the sum of the following:
- Base Multiplier [Default = `1.0`, Min = `0.0`, Max = `2.0`]
- General Multiplier Adjustment [Default = `0.0`, Min = `-2.0`, Max = `2.0`]
- Intelligence Multiplier Adjustment [Default Per Point = `0.01`, Min = `0.0`, Max = `1.0`]
- Luck Multiplier Adjustment [Default Per Point = `0.01`, Min = `0.0`, Max = `1.0`]
- Random Multiplier Adjustment [Default Minimum = `-0.1`, Default Maximum = `0.1`, Min = `-6.0`, Max = `6.0`]
- Scrapper Perk Multiplier Adjustment [Default = `(depends on rank)`, Min = `-2.0`, Max = `2.0`]

The General Multiplier Adjustment and the Scrapper Perk Multiplier Adjustment both have additional configurability with regard to what multiplier to apply dependent upon whether the player is in a player-owned settlement or not.

Additionally, the right hand side of the formula (`NumberOfComponentsToRecycle * Multiplier`) can be modified in a couple different ways before the final value of `NumberOfComponentsReturned` is reached:
- If the "Always Return At Least One Component" option is `ON` and `NumberOfComponentsToRecycle` is not 0, then `NumberOfComponentsReturned` will always be at least 1, even if the formula would normally have rounded things to 0. In effect, changes the formula to be

      NumberOfComponentsReturned = max( 1, NumberOfComponentsToRecycle * Multiplier )

- The "Fractional Component Handling" option specifies whether to round down (floor), normally, or up (ceiling), so a value of 5.1 would be rounded to 5.0, 5.0, or 6.0, respectively. In effect, changes the formula to be

      NumberOfComponentsReturned = floor/round/ceiling( NumberOfComponentsToRecycle * Multiplier )

- If combined, the effective formula is

      NumberOfComponentsReturned = floor/round/ceiling( max( 1, NumberOfComponentsToRecycle * Multiplier ) )

([TOC](#table-of-contents))

Known Issues
------------
- If the "Return Items Silently" option is set to `OFF` and you add scrap items (acid, bone, adhesive, ceramic, etc.) to the recycler, when the recycling process is complete, you may receive more than one notification for those scrap items that you added. I can't do anything about that without compromising the speed of the recycler (it could add almost an entire extra second to the processing time, at least), so if it is undesired behavior, you can set the "Return Items Silently" option to `ON` or you can set the "Enable Junk Filter" option to `ON` so that scrap items cannot be added to the container in the first place, or both. (Both of those options are `ON` by default.) Alternatively, you can simply choose not to add scrap items.
- Uncommonly, when activating the device it will simply be consumed and not actually do anything. This is not a bug in the mod, and is caused because events are being blocked. In my experience, that's usually due to a certain flag not getting unset by Workshop Plus. The usual fix for this is to go to an owned settlement, go into workshop mode and stay there for a moment (10-15 seconds ought to do it), then leave workshop mode. To give yourself the item back, open the console and type `player.additem FExxx840`, where 'xxx' is the mod index in your load order.

([TOC](#table-of-contents))


Interesting Configurations
==========================
Given how customizable the Mk 2 is, there are _myriad_ ways in which to configure it. Here are a few I've thought of. Note that some of these have the potential to boost the multiplier to ridiculous levels, and I can't recommend them as balanced. That being said, my goal is to give you, the player, ways in which to have fun and customize this mod to _your_ liking.

([TOC](#table-of-contents))

Brainiac
--------
Ur smrt. Liek rly smrt.

- Set "Multiplier Adjustments > Intelligence > Adjustment Per Point Of Intelligence" to `0.2`.

([TOC](#table-of-contents))

Leprechaun
----------
Luck is _really_ important to you. So much so that you set it to be the only multiplier adjustment you use.

- Set "Settings > Adjustment Options > (everything not Luck)" to `OFF` if it can be
- Set "Settings > Multiplier Adjustments > Adjustment Per Point Of Luck" to `0.5`

([TOC](#table-of-contents))

Loot Piñata
-----------
All junk items now explode in showers of components (figuratively).

- Set "Multiplier Adjustments > (everything)" to max

([TOC](#table-of-contents))

Magnum Opus Wabbajack Modlist
-----------------------------
If you use Wabbajack to install the Magnum Opus modlist by Lively, you can set the Portable Junk Recycler Mk 2 to mimic the way the Scrapper perk works.

- Set "Multiplier Adjustments > Scrapper: Rank 1 > In Player-Owned Settlements" to `0.2`
- Set "Multiplier Adjustments > Scrapper: Rank 2 > In Player-Owned Settlements" to `0.2`
- Set "Multiplier Adjustments > Scrapper: Rank 3 > In Player-Owned Settlements" to `0.5`

([TOC](#table-of-contents))

No Bonuses
----------
You just want to junk items on the go, no muss, no fuss, don't care about bonuses.

- Set "Settings > Adjustment Options > Intelligence Affects Multiplier" to `OFF`
- Set "Settings > Adjustment Options > Luck Affects Multiplier" to `OFF`
- Set "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" to `OFF`

([TOC](#table-of-contents))

No Scrapper, No Scrap
---------------------
Configures the Mk 2 so that you don't get any components unless you have at least 1 rank in the Scrapper perk.

- Set "Settings > General Options > Base Multiplier" to `0.0`
- Set "Settings > Adjustment Options > (everything not Scrapper)" to `OFF` if it can be
- Set "Multiplier Adjustments > Scrapper: Rank X" to `1.0`/`1.1`/`1.2`/etc. for Scrapper rank 1/2/3/etc.

([TOC](#table-of-contents))

OG Portable Junk Recycler
-------------------------
You want to experience the original Portable Junk Recycler once again (minus the crashy bits), complete with everything that entails, including no automatic movement of junk items.

- Set "Settings > Adjustment Options > Intelligence Affects Multiplier" to `OFF`
- Set "Settings > Adjustment Options > Luck Affects Multiplier" to `OFF`
- Set "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" to `OFF`
- Set "Recycler Interface > Behavior > Enable Junk Filter" to `OFF`
- Set "Recycler Interface > Behavior > Automatically Transfer Junk" to `OFF`
- Set "Recycler Interface > Behavior > Enable "Always Automatically Transfer" List" to `OFF`
- Set "Recycler Interface > Behavior > Enable "Never Automatically Transfer" List" to `OFF`
- Set "Recycler Interface > Behavior > Return Items Silently" to `OFF`

([TOC](#table-of-contents))

Punishing Field Use
-------------------
Heavily incentivize the use of settlements.

- Set "Multiplier Adjustments > General > Everywhere Else"  to `-0.9`.

([TOC](#table-of-contents))

The Gambler
-----------
Submit yourself to the will of RNGesus.

- Set "Settings > Adjustment Options > Randomness" to `ON (Simple)`
- Set "Settings > Adjustment Options > (everything not Randomness)" to `OFF` if it can be.
- Set "Multiplier Adjustments > Randomness > Minimum" to `-1.0`
- Set "Multiplier Adjustments > Randomness > Maximum" to `1.0`

([TOC](#table-of-contents))


Technical Details
=================

Plugin FormID Layout
--------------------
**Recycler Item FormID:**
- `FExxx840`

**General FormIDs:**
- `FExxx80*` Quest
- `FExxx81*` FormID List
- `FExxx82*` Magic Effect
- `FExxx83*` Container
- `FExxx84*` Ingestible
- `FExxx85*` Transform
- `FExxx86*` Constructable Object
- `FExxx87*` Keyword
- `FExxx9**` Message

**Note:** "xxx" is the load order position of the mod.

([TOC](#table-of-contents))

Limited Uses
------------
In "Limited Use" mode, the number of uses left isn't tracked specifically per device, but rather by tracking how many times a recycling process has occurred. This was a design decision made because of how ingestible items work in the game and due to the events and timing of said events surrounding their use. Therefore it doesn't matter whether several Mk 2's are crafted and used, the number of uses will tick up until it reaches the configured threshold and the item simply won't be returned to you after that recycling process finishes.

**Note:** The number of uses is not incremented when there is no junk to break down.

([TOC](#table-of-contents))

Scrap Categories
----------------
**Common:**
- Bone
- Ceramic
- Cloth
- Concrete
- Leather
- Plastic
- Rubber
- Steel
- Wood

**Uncommon:**
- Adhesive
- Aluminum
- Copper
- Cork
- Fertilizer
- Fiberglass
- Gears
- Glass
- Lead
- Oil
- Screws
- Silver
- Springs

**Rare:**
- Acid
- Ballistic Fiber
- Antiseptic
- Asbestos
- Circuitry
- Crystal
- Fiber Optics
- Gold
- Nuclear Material

**Special:**
- (None)

The "Special" category is intended for modders to add components that might not fit into other categories.

If changing any FormList associated with any of the scrap categories, make sure that the contents of the lists match in length and have the corresponding Component and MiscObject forms at the same position in the list. For example, in the "PJRM2_ComponentsC" `[FLST:FExxx810]` list, the first entry is "c_Bone" `[Fallout4.esm:CMPO:xx01FA98]`, which matches the first entry in the "PJRM2_ScrapC" `[FLST:FExxx814]` list, "c_Bone_scrap" `[Fallout4.esm:MISC:xx0AEC5D]`.

These lists are reread every time a game is loaded.

([TOC](#table-of-contents))

Settings Layout in MCM
----------------------
<details><summary>Click to show layout</summary>

**Settings:**
- General Options
    - Base Multiplier [Default = `1.0`, Minimum = `0.0`, Maximum = `2.0`, Step = `0.01`]
    - Always Return At Least One Component [Default = `ON`, Possible Values = `OFF`/`ON`]
    - Fractional Component Handling [Default = `Round Down`, Possible Values = `Round Up`/`Round Normally`/`Round Down`]
    - Has Limited Uses [Default = `OFF`, Possible Values = `OFF`/`ON`]
        - Number Of Uses [Default = `50`, Minimum = `1`, Maximum = `200`, Step = `1`]
- Adjustment Options
    - General Adjustments [Default = `Simple`, Possible Values = `Simple`/`Detailed`]
    - Intelligence Affects Multiplier [Default = `ON (Simple)`, Possible Values = `OFF`/`ON (Simple)`/`ON (Detailed)`]
    - Luck Affects Multiplier [Default = `ON (Simple)`, Possible Values = `OFF`/`ON (Simple)`/`ON (Detailed)`]
    - Add Randomness To Multiplier [Default = `OFF`, Possible Values = `OFF`/`ON (Simple)`/`ON (Detailed)`]
    - Scrapper Perk Affects Multiplier [Default = `ON (Simple)`, Possible Values = `OFF`/`ON (Simple)`/`ON (Detailed)`]

**Recycler Interface:**
- Behavior
    - Automatic Recycling Mode [Default = `OFF`, Possible Values = `OFF`/`ON`]
    - Enable Junk Filter [Default = `ON`, Possible Values = `OFF`/`ON`]
    - Automatically Transfer Junk [Default = `ON`, Possible Values = `OFF`/`ON`]
        - Only Transfer Low Component Weight Ratio Items [Default = `OFF`, Possible Values = `OFF`/`In Player-Owned Settlements`/`Not In Player-Owned Settlements`/`Everywhere`]
    - Enable "Always Automatically Transfer" List [Default = `ON`, Possible Values = `OFF`/`ON`]
    - Enable "Never Automatically Transfer" List [Default = `ON`, Possible Values = `OFF`/`ON`]
    - Enable Automatic Transfer List Editing [Default = `OFF`, Possible Values = `OFF`/`ON`]
    - Enable Behavior Overrides [Default = `OFF`, Possible Values = `OFF`/`ON`]
    - Modifier Hotkey Read Delay [Default = `0.3`, Minimum = `0.0`, Maximum = `1.0`, Step = `0.1`]
    - Return Items Silently [Default = `ON`, Possible Values = `OFF`/`ON`]
    - Inventory Removal Protection [Default = `OFF`, Possible Values = `OFF`/`Ask First`/`Automatic`]
- Crafting
    - Use Simple Crafting Recipe [Default = `OFF`, Possible Values = `OFF`/`ON`]
    - Crafting Station [Default = `Dynamic`, Possible Values = `Dynamic`/`Chemistry Station (Vanilla)`/`Electronics Workbench (SW)`/`Engineering Workbench (SW)`/`Manufacturing Workbench (SW)`/`Utility Workbench (SW)`/`Adv. Engineering Workbench AWKCR)`/`Electronics Workstation (AWKCR)`/`Utility Workbench (AWKCR)`/`Utility Station (ECO)`]
- Hotkeys
    - Activate Portable Junk Recycler Mk 2 [Default = `None`]
    - Behavior Override: Force Automatic Recycling Mode [Default = `Ctrl-Shift`, Possible Values = `(locked)`]
    - Behavior Override: Force Transfer Junk [Default = `Shift`, Possible Values = `(locked)`]
    - Behavior Override: Force Retain Junk [Default = `Ctrl`, Possible Values = `(locked)`]
    - Modifier: Edit "Always Automatically Transfer" List [Default = `Alt-Shift`, Possible Values = `(locked)`]
    - Modifier: Edit "Never Automatically Transfer" List [Default = `Alt-Ctrl`, Possible Values = `(locked)`]

**Multiplier Adjustments:**
- General
    - (If "Settings > Adjustment Options > General Adjustments" is set to `Simple`)
    - In Player-Owned Settlements [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - (If "Settings > Adjustment Options > General Adjustments" is set to `Detailed`)
    - Components: Common
        - In Player-Owned Settlements [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Components: Uncommon
        - In Player-Owned Settlements [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Components: Rare
        - In Player-Owned Settlements [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Components: Special
        - In Player-Owned Settlements [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
- (If "Settings > Adjustment Options > Intelligence Affects Multiplier" is not set to `OFF`)
- Intelligence
    - (If "Settings > Adjustment Options > Intelligence Affects Multiplier" is set to `ON (Simple)`)
    - Adjustment Per Point Of Intelligence [Default = `0.01`, Minimum = `0.0`, Maximum = `1.0`, Step = `0.005`]
    - (If "Settings > Adjustment Options > Intelligence Affects Multiplier" is set to `ON (Detailed)`)
    - Components: Common
        - Adjustment Per Point Of Intelligence [Default = `0.01`, Minimum = `0.0`, Maximum = `1.0`, Step = `0.005`]
    - Components: Uncommon
        - Adjustment Per Point Of Intelligence [Default = `0.01`, Minimum = `0.0`, Maximum = `1.0`, Step = `0.005`]
    - Components: Rare
        - Adjustment Per Point Of Intelligence [Default = `0.01`, Minimum = `0.0`, Maximum = `1.0`, Step = `0.005`]
    - Components: Special
        - Adjustment Per Point Of Intelligence [Default = `0.0`, Minimum = `0.0`, Maximum = `1.0`, Step = `0.005`]
- (If "Settings > Adjustment Options > Luck Affects Multiplier" is not set to `OFF`)
- Luck
    - (If "Settings > Adjustment Options > Luck Affects Multiplier" is set to `ON (Simple)`)
    - Adjustment Per Point Of Luck [Default = `0.01`, Minimum = `0.0`, Maximum = `1.0`, Step = `0.005`]
    - (If "Settings > Adjustment Options > Luck Affects Multiplier" is set to `ON (Detailed)`)
    - Components: Common
        - Adjustment Per Point Of Luck [Default = `0.01`, Minimum = `0.0`, Maximum = `1.0`, Step = `0.005`]
    - Components: Uncommon
        - Adjustment Per Point Of Luck [Default = `0.01`, Minimum = `0.0`, Maximum = `1.0`, Step = `0.005`]
    - Components: Rare
        - Adjustment Per Point Of Luck [Default = `0.01`, Minimum = `0.0`, Maximum = `1.0`, Step = `0.005`]
    - Components: Special
        - Adjustment Per Point Of Luck [Default = `0.0`, Minimum = `0.0`, Maximum = `1.0`, Step = `0.005`]
- (If "Settings > Adjustment Options > Add Randomness To Multiplier" is not set to `OFF`)
- Randomness
    - (If "Settings > Adjustment Options > Add Randomness To Multiplier" is set to `ON (Simple)`)
    - Minimum [Default = `-0.1`, Minimum = `-6.0`, Maximum = `6.0`, Step = `0.01`]
    - Maximum [Default = `0.1`, Minimum = `-6.0`, Maximum = `6.0`, Step = `0.01`]
    - (If "Settings > Adjustment Options > Add Randomness To Multiplier" is set to `ON (Detailed)`)
    - Components: Common
        - Minimum [Default = `-0.1`, Minimum = `-6.0`, Maximum = `6.0`, Step = `0.01`]
        - Maximum [Default = `0.1`, Minimum = `-6.0`, Maximum = `6.0`, Step = `0.01`]
    - Components: Uncommon
        - Minimum [Default = `-0.1`, Minimum = `-6.0`, Maximum = `6.0`, Step = `0.01`]
        - Maximum [Default = `0.1`, Minimum = `-6.0`, Maximum = `6.0`, Step = `0.01`]
    - Components: Rare
        - Minimum [Default = `-0.1`, Minimum = `-6.0`, Maximum = `6.0`, Step = `0.01`]
        - Maximum [Default = `0.1`, Minimum = `-6.0`, Maximum = `6.0`, Step = `0.01`]
    - Components: Special
        - Minimum [Default = `0.0`, Minimum = `-6.0`, Maximum = `6.0`, Step = `0.01`]
        - Maximum [Default = `0.1`, Minimum = `-6.0`, Maximum = `6.0`, Step = `0.01`]
- (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is not set to `OFF`)
- Scrapper: Rank 1
    - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is set to `ON (Simple)`)
    - In Player-Owned Settlements [Default = `0.1`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is set to `ON (Detailed)`)
    - Components: Common
        - In Player-Owned Settlements [Default = `0.1`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Components: Uncommon
        - In Player-Owned Settlements [Default = `0.1`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Components: Rare
        - In Player-Owned Settlements [Default = `0.1`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Components: Special
        - In Player-Owned Settlements [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
- (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is not set to `OFF`)
- Scrapper: Rank 2
    - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is set to `ON (Simple)`)
    - In Player-Owned Settlements [Default = `0.2`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is set to `ON (Detailed)`)
    - Components: Common
        - In Player-Owned Settlements [Default = `0.2`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Components: Uncommon
        - In Player-Owned Settlements [Default = `0.2`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Components: Rare
        - In Player-Owned Settlements [Default = `0.2`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Components: Special
        - In Player-Owned Settlements [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
- (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is not set to `OFF` and Scrapper Rank 3 perk exists)
- Scrapper: Rank 3
    - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is set to `ON (Simple)`)
    - In Player-Owned Settlements [Default = `0.3`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is set to `ON (Detailed)`)
    - Components: Common
        - In Player-Owned Settlements [Default = `0.3`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Components: Uncommon
        - In Player-Owned Settlements [Default = `0.3`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Components: Rare
        - In Player-Owned Settlements [Default = `0.3`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Components: Special
        - In Player-Owned Settlements [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
- (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is not set to `OFF` and Scrapper Rank 4 perk exists)
- Scrapper: Rank 4
    - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is set to `ON (Simple)`)
    - In Player-Owned Settlements [Default = `0.4`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is set to `ON (Detailed)`)
    - Components: Common
        - In Player-Owned Settlements [Default = `0.4`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Components: Uncommon
        - In Player-Owned Settlements [Default = `0.4`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Components: Rare
        - In Player-Owned Settlements [Default = `0.4`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Components: Special
        - In Player-Owned Settlements [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
- (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is not set to `OFF` and Scrapper Rank 5 perk exists)
- Scrapper: Rank 5
    - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is set to `ON (Simple)`)
    - In Player-Owned Settlements [Default = `0.5`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is set to `ON (Detailed)`)
    - Components: Common
        - In Player-Owned Settlements [Default = `0.5`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Components: Uncommon
        - In Player-Owned Settlements [Default = `0.5`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Components: Rare
        - In Player-Owned Settlements [Default = `0.5`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
    - Components: Special
        - In Player-Owned Settlements [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]
        - Everywhere Else [Default = `0.0`, Minimum = `-2.0`, Maximum = `2.0`, Step = `0.01`]

**Advanced:**
- General Options
    - Max Number Of Threads To Use [Default = `32`, Minimum = `1`, Maximum = `32`, Step = `1`]
    - Enable Script Logging [Default = `OFF`, Possible Values = `OFF`/`ON`]
    - Enable Script Profiling [Default = `OFF`, Possible Values = `OFF`/`ON`]
- Methodology
    - Use "Direct Move" Method To Update Recyclable Item List [Default = `OFF`, Possible Values = `OFF`/`ON`]
- Resets
    - Reset Settings To Defaults [Button]
    - Reset Locks [Button]
    - Reset Lists: Recyclable Items and Low Weight Ratio Items [Button]
    - Reset List: Always Automatically Transfer [Button]
    - Reset List: Never Automatically Transfer [Button]
- Uninstall
    - Show "Uninstall Mod" Button
        - Uninstall Mod [Button]

</details>

([TOC](#table-of-contents))


Troubleshooting Info
====================

Enable Debug Logging (Fallout 4)
------------------------------------------
**Note:** If you are using Mod Organizer 2, use the built-in INI editor via the "Tools" menu > "Tool Plugins" sub-menu > "INI Editor" option.

By default, Fallout 4 has its debug logging capabilities disabled. To enable them, follow the instructions on the [Enable Debug Logging](https://falloutck.uesp.net/wiki/Enable_Debug_Logging) page on the Creation Kit wiki.

([TOC](#table-of-contents))

Enable Debug Logging (Portable Junk Recycler Mk 2)
--------------------------------------------------
Also by default, the logging and profiling capabilities of the mod are disabled. To enable them, go into the Mod Config menu, then to the Portable Junk Recycler Mk 2 mod, then to the "Advanced" page. The "Enable Script Logging" option is probably what you're looking for, but the "Enable Script Profiling" option is also there as well.

([TOC](#table-of-contents))

Log Location
------------
The most recent log generated by this mod will be at `%HOMEPATH%\Documents\My Games\Fallout4\Logs\Script\User\Portable Junk Recycler Mk 2.0.log`.

Profile logs will be in `%HOMEPATH%\Documents\My Games\Fallout4\Logs\Script\Profiling\`.

([TOC](#table-of-contents))


Copyright and Licenses
======================
Copyright 2021 Dan Cassidy

All my code in this mod is licensed under the [GPL 3.0](https://www.gnu.org/licenses/gpl-3.0.en.html) or later.

Everything else in this mod created by me is [CC-BY-SA](https://creativecommons.org/licenses/by-sa/4.0/legalcode) licensed.

([TOC](#table-of-contents))


Credits and Thanks
==================
- **Bethesda**: For the base low res texture and the meshes used; also for Fallout 4
- **SavrenX**: For the textures from [SavrenX HD Settlement and Clutters](https://www.nexusmods.com/fallout4/mods/40485)
- **pra**: For some feature ideas based on [Scrapping Machine](https://www.nexusmods.com/fallout4/mods/35793)
- **Kentington**: For the OG [Portable Junk Recycler](https://www.nexusmods.com/fallout4/mods/14110)
- **DieFeM**: For the [code inspiration](https://forums.nexusmods.com/index.php?/topic/7090211-removing-the-notifications-from-removeallitems-used-on-player/page-4#entry64900091) to relatively quickly transfer items from one container to another while bypassing the `ObjectReference.RemoveAllItems()` function to avoid the crash associated with it
- **Lively**: For allowing me to post the beta of this mod on his Discord server to get some play testing done, and for [Lively's Keyword Resource](https://www.nexusmods.com/fallout4/mods/51510)
- **kinggath**: For save file monitoring via [Canary](https://www.nexusmods.com/fallout4/mods/44949)
- **Whisper**: For [Standalone Workbenches](https://www.nexusmods.com/fallout4/mods/41832)
- **Gambit77, Valdacil, Thirdstorm**: For [AWKCR](https://www.nexusmods.com/fallout4/mods/6091)
- **F4SE team**: For [F4SE](https://f4se.silverlock.org/), without which this mod would not exist
- **fireundubh**: For [pyro](https://github.com/fireundubh/pyro), which made developing the scripts for this mod so much easier
- **Neanka, reg2k, shadowslasher410**: For the [Mod Configuration Menu](https://www.nexusmods.com/fallout4/mods/21497/)
- **Joel Day**: For the VS Code [Papyrus extension](https://marketplace.visualstudio.com/items?itemName=joelday.papyrus-lang-vscode)
- **Dank Rafft**: For [Equipment and Crafting Overhaul (ECO)](https://www.nexusmods.com/fallout4/mods/55503)

([TOC](#table-of-contents))


Contact
=======
If you find a bug or have a question about the mod, please post it on the [mod page at Nexus Mods](https://www.nexusmods.com/fallout4/mods/54138), or in the [GitHub project](https://github.com/rux616/Portable-Junk-Recycler-Mk-2).

If you need to contact me personally, I can be reached through one of the following means:
- **Nexus Mods**: [rux616](https://www.nexusmods.com/users/124191) (Send a message via the "CONTACT" button.)
- **Email**: rux616-at-pm-dot-me (replace `-at-` with `@` and `-dot-` with `.`)
- **Discord**: rux616#0950 (I tend to hang out on the [Nexus Mods](https://discord.gg/nexusmods) and [Wabbajack](https://discord.gg/wabbajack) servers, amongst others.)

([TOC](#table-of-contents))
