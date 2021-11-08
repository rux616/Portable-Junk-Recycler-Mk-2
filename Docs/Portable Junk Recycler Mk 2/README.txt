# Portable Junk Recycler Mk 2
by rux616

- [Portable Junk Recycler Mk 2](#portable-junk-recycler-mk-2)
- [Overview](#overview)
  - [Features](#features)
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [Uninstallation](#uninstallation)
  - [Crafting Materials Required](#crafting-materials-required)
  - [Summary (TL;DR)](#summary-tldr)
- [Mod Information](#mod-information)
  - [Hotkeys](#hotkeys)
  - [Multiplier Adjustment](#multiplier-adjustment)
  - [Known Issues](#known-issues)
- [Technical Details](#technical-details)
  - [Plugin FormID Layout](#plugin-formid-layout)
  - [Scrap Categories](#scrap-categories)
  - [Settings Layout in MCM](#settings-layout-in-mcm)
- [Credits and Thanks](#credits-and-thanks)


# Overview

A fast, highly configurable device used to break down junk items into their component parts.

I created this mod because while I really liked the original Portable Junk Recycler by Kentington, I wanted something that I could customize and additionally I wanted to see if I could fix the crash issue.

## Features
- Extremely customizable via the Mod Config Menu (MCM)
- Fast
- Can automatically move junk items to the recycler inventory
- Can be set to only automatically move items that when recycled, will save weight
- Configurable "Always Automatically Transfer" and "Never Automatically Transfer" lists
- Has a fully automatic mode (just activate it, and it processes junk items in your inventory)
- Dynamically supports crafting the item at the "Utility Workbench" from Standalone Workbenches or AWKCR (Standalone Workbenches takes priority if both are installed), can also be crafted at a number of other workbenches
- Can be configured to only have a limited number uses
- Sane defaults, so even if not customized, it will work well out of the box
- Customized low- and high-res textures
- Doesn't require any DLC
- Dynamic support of up to 5 ranks of the Scrapper perk (if you have some mod that adds them)
- Portable Junk Recycler Mk 2 mesh now has physics, so it won't just hang in the air if you ever drop it from your inventory
- Canary save file monitor support (https://www.nexusmods.com/fallout4/mods/44949)

## Requirements
- Fallout 4 Script Extender (F4SE): https://f4se.silverlock.org/
- Mod Configuration Menu (MCM): https://www.nexusmods.com/fallout4/mods/21497

## Installation
I **highly** recommend that you use a mod manager to install this mod, as there is a FOMOD installer included. I personally recommend Mod Organizer 2, but Vortex is fine too. If you must, however, this mod can be installed by unzipping it directly into the Data folder of your Fallout 4 installation.

## Uninstallation
To uninstall this mod, make sure that a recycling process is not underway, then follow these steps:
- Go to the Pause Menu (hit ESCAPE)
- Go into the Mod Config menu
- Find "Portable Junk Recycler Mk 2" and go into the "Advanced" page
- Disengage the safeguard (click 'Show The "Uninstall Mod" Button')
- Click the "Uninstall Mod" button
- Close the Pause Menu
- Wait a few seconds for the pop up message to appear
- Save your game
- Exit the game
- Disable or remove this mod and its files

## Crafting Materials Required
- Enhanced Targeting Card x1
- Fusion Core x1
- High-powered Magnet x1
- Power Relay Coil x2
- Screws x12
- Sensor Module x1
- Steel x20

## Summary (TL;DR)
Here's the TL;DR if you don't care about the details and just want to get on with it. By default the Mk 2 functions like the original, that is, you use it, exit the Pip-boy, move the junk objects you want to be recycled into the container that then opens, close said container, and then you get a bunch of components back. However it has the following bonuses by default:

- You get a 1% bonus to the number of components returned for each point of Intelligence
- You get a 1% bonus to the number of components returned for each point of Luck
- You get a 10% bonus to the number of components returned per Scrapper perk rank, but _only_ in player-owned settlements

You can heavily customize all these settings and more via the MCM.

This mod *REQUIRES* F4SE and MCM and will not work without them. I had to do this in order to prevent the freezing bug found in the original. Sorry, console players, you're out of luck. This mod also supports the Canary mod (https://www.nexusmods.com/fallout4/mods/44949) to alert in the case of save game corruption.

By default, the Portable Junk Recycler Mk 2 will detect whether the Standalone Workbenches mod (https://www.nexusmods.com/fallout4/mods/41832) or the AWKCR mod (https://www.nexusmods.com/fallout4/mods/6091) is installed and will dynamically set itself to be crafted at the respective "Utility Workbench", or at the vanilla "Chemistry Station" if neither are installed. The Standalone Workbenches Utility Workbench takes priority if both are installed. The device can be found under the "UTILITY" category.


# Mod Information

## Hotkeys
All hotkeys in this mod work as modifiers, meaning that in order for the effect of the hotkey to take place, said hotkey(s) need to be pressed at the time the Portable Junk Recycler Mk 2 is activated.

By default, the mod comes with the "Behavior Override" option set to ON, which enables overriding the behavior of the Portable Junk Recycler Mk 2:
- If both [CTRL] and [SHIFT] are pressed when the recycler is activated, the recycler inventory will not open and instead, all recyclable junk items, except for those items on the "Never Automatically Transfer" list (unless the use of that list is turned OFF) and maybe those items in the Low Weight Ratio list, depending on your settings, will be broken down and their component parts returned. This is identical in functionality to having the "Automatic Recycling Mode" option set to ON.
- If only [SHIFT] is pressed when the recycler is activated, the recycler inventory will open and all recyclable junk items from the player inventory will be moved into it, except for those items on the "Never Automatically Transfer" list (unless the use of that list is turned OFF). This is identical in functionality to having the "Automatically Transfer Junk" option set to ON.
- If only [CTRL] is pressed when the recycler is activated, the recycler inventory will open and no recyclable junk items from the player inventory will be moved into it, except for those items on the "Always Automatically Transfer" list (unless the use of that list is turned OFF). This is identical in functionality to having the "Automatically Transfer Junk" option set to OFF.

To edit the "Never Automatically Transfer" list, ensure that [ALT] and [CTRL] are both pressed when the recycler is activated.

To edit the "Always Automatically Transfer" list, ensure that [ALT] and [SHIFT] are both pressed when the recycler is activated.

## Multiplier Adjustment
The Mk 2 works off of a multiplier for different scrap rarities, which are organized into four categories: Common, Uncommon, Rare, and Special. (See the lists below for details about which components are in which category by default.) This multiplier is composed from several different factors, and in the most basic configuration will be the same for each category.

Overall, it is a simple formula: NumberOfComponentsToRecycle * Multiplier = NumberOfComponentsReturned

The Multiplier is composed of the following:
- Base Multiplier [Default = 1.0, Min = 0.0, Max = 2.0]
- General Multiplier Adjustment [Default = 0.0, Min = -1.0, Max = 1.0]
- Intelligence Multiplier Adjustment [Default Per Point = 0.01, Min = 0.0, Max = 1.0]
- Luck Multiplier Adjustment [Default Per Point = 0.01, Min = 0.0, Max = 1.0]
- Random Multiplier Adjustment [Default Minimum = -0.1, Default Maximum = 0.1, Min = -1.0, Max = 1.0]
- Scrapper Perk Multiplier Adjustment [Default = 0.0, Min = -1.0, Max = 1.0]

The General Multiplier Adjustment and the Scrapper Perk Multiplier Adjustment both have additional configurability for what multiplier to apply whether the player is in a player-owned settlement or not.

## Known Issues
- If the 'Return Items Silently' option is set to OFF and you add scrap items (acid, bone, adhesive, ceramic, etc.) to the recycler, when the recycling process is complete, you may receive more than one notification for those scrap items that you added. I can't do anything about that without compromising the speed of the recycler (it would add almost an entire extra second to the processing time, at least), so if it is undesired behavior, you can set the 'Return Items Silently' option to ON or you can set the 'Allow Junk Only' option to ON to disallow adding scrap items to the container in the first place, or both. (Both of those options are ON by default.) Alternatively, you can simply choose not to add scrap items.


# Technical Details

## Plugin FormID Layout
Recycler Item Form ID:
- FExxx840

General FormIDs:
- FExxx80* Quest
- FExxx81* FormID List
- FExxx82* Magic Effect
- FExxx83* Container
- FExxx84* Ingestible
- FExxx85* Transform
- FExxx86* Constructable Object
- FExxx9** Message

Note: 'xxx' is the load order position of the mod.

## Scrap Categories
Common:
- Bone
- Ceramic
- Cloth
- Concrete
- Leather
- Plastic
- Rubber
- Steel
- Wood

Uncommon:
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

Rare:
- Acid
- Ballistic Fiber
- Antiseptic
- Asbestos
- Circuitry
- Crystal
- Fiber Optics
- Gold
- Nuclear Material

Special:
- (None)

Note: The "Special" category is intended for modders to add components that might not fit into other categories.

## Settings Layout in MCM
- Settings
    - General Options
        - Base Multiplier [Default = 1.0, Minimum = 0.0, Maximum = 2.0, Step = 0.01]
        - Always Return At Least One Component [Default = ON, Possible Values = OFF/ON]
        - Fractional Component Handling [Default = Round Down, Possible Values = Round Up/Round Normally/Round Down]
        - Has Limited Uses [Default = OFF, Possible Values = OFF/ON]
            - Number Of Uses [Default = 50, Minimum = 1, Maximum = 200, Step = 1]

    - Adjustment Options
        - General Adjustments [Default = Simple, Possible Values = Simple/Detailed]
        - Intelligence Affects Multiplier [Default = ON (Simple), Possible Values = OFF/ON (Simple)/ON (Detailed)]
        - Luck Affects Multiplier [Default = ON (Simple), Possible Values = OFF/ON (Simple)/ON (Detailed)]
        - Add Randomness To Multiplier [Default = OFF, Possible Values = OFF/ON (Simple)/ON (Detailed)]
        - Scrapper Perk Affects Multiplier [Default = ON (Simple), Possible Values = OFF/ON (Simple)/ON (Detailed)]

- Recycler Interface
    - Behavior
        - Automatic Recycling Mode [Default = OFF, Possible Values = OFF/ON]
        - Allow Junk Only [Default = ON, Possible Values = OFF/ON]
        - Automatically Transfer Junk [Default = ON, Possible Values = OFF/ON]
            - Only Transfer Low Component Weight Ratio Items [Default = OFF, Possible Values = OFF/In Player-Owned Settlements/Not In Player-Owned Settlements/Everywhere]
        - Enable "Always Automatically Transfer" List [Default = ON, Possible Values = OFF/ON]
        - Enable "Never Automatically Transfer" List [Default = ON, Possible Values = OFF/ON]
        - Allow Behavior Overrides [Default = ON, Possible Values = OFF/ON]
        - Return Items Silently [Default = ON, Possible Values = OFF/ON]

    - Crafting
        - Crafting Station [Default = Dynamic, Possible Values = Dynamic/Electronics Workbench (SW)/Engineering Workbench (SW)/Manufacturing Workbench (SW)/Utility Workbench (SW)/Adv. Engineering Workbench AWKCR)/Electronics Workstation (AWKCR)/Utility Workbench (AWKCR)/Chemistry Station (Vanilla)]

    - Hotkeys
        - Behavior Override: Force Automatic Recycling Mode [Default = Ctrl-Shift, Possible Values = (locked)]
        - Behavior Override: Force Transfer Junk [Default = Shift, Possible Values = (locked)]
        - Behavior Override: Force Retain Junk [Default = Ctrl, Possible Values = (locked)]
        - Modifier: Edit "Always Automatically Transfer" List [Default = Alt-Shift, Possible Values = (locked)]
        - Modifier: Edit "Never Automatically Transfer" List [Default = Alt-Ctrl, Possible Values = (locked)]

- Multiplier Adjustments
    - General
        - (If "Settings > Adjustment Options > General Adjustments" is set to "Simple")
        - In Player-Owned Settlements [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]

        - (If "Settings > Adjustment Options > General Adjustments" is set to "Detailed")
        - Components: Common
            - In Player-Owned Settlements [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Components: Uncommon
            - In Player-Owned Settlements [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Components: Rare
            - In Player-Owned Settlements [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Components: Special
            - In Player-Owned Settlements [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]

    - (If "Settings > Adjustment Options > Intelligence Affects Multiplier" is not set to "OFF")
    - Intelligence
        - (If "Settings > Adjustment Options > Intelligence Affects Multiplier" is set to "ON (Simple)")
        - Adjustment Per Point Of Intelligence [Default = 0.01, Minimum = 0.0, Maximum = 1.0, Step = 0.005]
        - (If "Settings > Adjustment Options > Intelligence Affects Multiplier" is set to "ON (Detailed)")
        - Components: Common
            - Adjustment Per Point Of Intelligence [Default = 0.01, Minimum = 0.0, Maximum = 1.0, Step = 0.005]
        - Components: Uncommon
            - Adjustment Per Point Of Intelligence [Default = 0.01, Minimum = 0.0, Maximum = 1.0, Step = 0.005]
        - Components: Rare
            - Adjustment Per Point Of Intelligence [Default = 0.01, Minimum = 0.0, Maximum = 1.0, Step = 0.005]
        - Components: Special
            - Adjustment Per Point Of Intelligence [Default = 0.0, Minimum = 0.0, Maximum = 1.0, Step = 0.005]

    - (If "Settings > Adjustment Options > Luck Affects Multiplier" is not set to "OFF")
    - Luck
        - (If "Settings > Adjustment Options > Luck Affects Multiplier" is set to "ON (Simple)")
        - Adjustment Per Point Of Luck [Default = 0.01, Minimum = 0.0, Maximum = 1.0, Step = 0.005]

        - (If "Settings > Adjustment Options > Luck Affects Multiplier" is set to "ON (Detailed)")
        - Components: Common
            - Adjustment Per Point Of Luck [Default = 0.01, Minimum = 0.0, Maximum = 1.0, Step = 0.005]
        - Components: Uncommon
            - Adjustment Per Point Of Luck [Default = 0.01, Minimum = 0.0, Maximum = 1.0, Step = 0.005]
        - Components: Rare
            - Adjustment Per Point Of Luck [Default = 0.01, Minimum = 0.0, Maximum = 1.0, Step = 0.005]
        - Components: Special
            - Adjustment Per Point Of Luck [Default = 0.0, Minimum = 0.0, Maximum = 1.0, Step = 0.005]

    - (If "Settings > Adjustment Options > Add Randomness To Multiplier" is not set to "OFF")
    - Randomness
        - (If "Settings > Adjustment Options > Add Randomness To Multiplier" is set to "ON (Simple)")
        - Minimum [Default = -0.1, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Maximum [Default = 0.1, Minimum = -1.0, Maximum = 1.0, Step = 0.01]

        - (If "Settings > Adjustment Options > Add Randomness To Multiplier" is set to "ON (Detailed)")
        - Components: Common
            - Minimum [Default = -0.1, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Maximum [Default = 0.1, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Components: Uncommon
            - Minimum [Default = -0.1, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Maximum [Default = 0.1, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Components: Rare
            - Minimum [Default = -0.1, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Maximum [Default = 0.1, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Components: Special
            - Minimum [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Maximum [Default = 0.1, Minimum = -1.0, Maximum = 1.0, Step = 0.01]

    - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is not set to "OFF")
    - Scrapper: Rank 1
        - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is set to "ON (Simple)")
        - In Player-Owned Settlements [Default = 0.1, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]

        - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is set to "ON (Detailed)")
        - Components: Common
            - In Player-Owned Settlements [Default = 0.1, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Components: Uncommon
            - In Player-Owned Settlements [Default = 0.1, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Components: Rare
            - In Player-Owned Settlements [Default = 0.1, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Components: Special
            - In Player-Owned Settlements [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]

    - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is not set to "OFF")
    - Scrapper: Rank 2
        - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is set to "ON (Simple)")
        - In Player-Owned Settlements [Default = 0.2, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]

        - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is set to "ON (Detailed)")
        - Components: Common
            - In Player-Owned Settlements [Default = 0.2, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Components: Uncommon
            - In Player-Owned Settlements [Default = 0.2, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Components: Rare
            - In Player-Owned Settlements [Default = 0.2, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Components: Special
            - In Player-Owned Settlements [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]

    - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is not set to "OFF" and Scrapper Rank 3 perk exists)
    - Scrapper: Rank 3
        - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is set to "ON (Simple)")
        - In Player-Owned Settlements [Default = 0.3, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]

        - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is set to "ON (Detailed)")
        - Components: Common
            - In Player-Owned Settlements [Default = 0.3, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Components: Uncommon
            - In Player-Owned Settlements [Default = 0.3, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Components: Rare
            - In Player-Owned Settlements [Default = 0.3, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Components: Special
            - In Player-Owned Settlements [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]

    - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is not set to "OFF" and Scrapper Rank 4 perk exists)
    - Scrapper: Rank 4
        - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is set to "ON (Simple)")
        - In Player-Owned Settlements [Default = 0.4, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]

        - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is set to "ON (Detailed)")
        - Components: Common
            - In Player-Owned Settlements [Default = 0.4, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Components: Uncommon
            - In Player-Owned Settlements [Default = 0.4, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Components: Rare
            - In Player-Owned Settlements [Default = 0.4, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Components: Special
            - In Player-Owned Settlements [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]

    - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is not set to "OFF" and Scrapper Rank 5 perk exists)
    - Scrapper: Rank 5
        - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is set to "ON (Simple)")
        - In Player-Owned Settlements [Default = 0.5, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]

        - (If "Settings > Adjustment Options > Scrapper Perk Affects Multiplier" is set to "ON (Detailed)")
        - Components: Common
            - In Player-Owned Settlements [Default = 0.5, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Components: Uncommon
            - In Player-Owned Settlements [Default = 0.5, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Components: Rare
            - In Player-Owned Settlements [Default = 0.5, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
        - Components: Special
            - In Player-Owned Settlements [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]
            - Everywhere Else [Default = 0.0, Minimum = -1.0, Maximum = 1.0, Step = 0.01]

# Credits and Thanks
- SavrenX: For the textures from the "SavrenX HD Settlement and Clutters" mod (https://www.nexusmods.com/fallout4/mods/40485)
- pra: For some feature ideas based on their "Scrapping Machine" mod (https://www.nexusmods.com/fallout4/mods/35793)
- Kentington: For the OG "Portable Junk Recycler" mod (https://www.nexusmods.com/fallout4/mods/14110)
- DieFeM: For the code inspiration to relatively quickly transfer items from one container to another while bypassing the ObjectReference.RemoveAllItems() function to avoid the freeze associated with it (https://forums.nexusmods.com/index.php?/topic/7090211-removing-the-notifications-from-removeallitems-used-on-player/page-4#entry64900091)
- Lively: For allowing me to post the beta of this mod on his Discord server to get some play testing done, and for the Lively's Keyword Resource mod (https://www.nexusmods.com/fallout4/mods/51510)
- kinggath: For the Canary save file monitoring mod (https://www.nexusmods.com/fallout4/mods/44949)
- Whisper: For the Standalone Workbenches mod (https://www.nexusmods.com/fallout4/mods/41832)
- Gambit77, Valdacil, Thirdstorm: For the AWKCR mod (https://www.nexusmods.com/fallout4/mods/6091)
- F4SE team: For F4SE, without which this mod would not exist (https://f4se.silverlock.org/)
- fireundubh: For pyro, which made developing the scripts for this mod so much easier (https://github.com/fireundubh/pyro)
- Neanka, reg2k, shadowslasher410: For the Mod Configuration Menu (https://www.nexusmods.com/fallout4/mods/21497/)
- Joel Day: For the Papyrus extension for Visual Studio Code (https://marketplace.visualstudio.com/items?itemName=joelday.papyrus-lang-vscode)