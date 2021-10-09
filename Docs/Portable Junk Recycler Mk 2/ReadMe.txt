Portable Junk Recycler Mk 2 by rux616
-------------------------------------
I created this mod because while I really liked the original Portable Junk Recycler by Kentington, I wanted something that I could customize.


Features
--------
- Super customizable in how junk items get recycled
- Portable Junk Recycler Mk 2 mesh now has physics, so it won't just hang in the air if you ever drop it from your inventory
- Customized low- and high-res textures
- Configurable via the Mod Control Manager and settings holotape
- Doesn't require any DLC
- Supports up to 5 ranks of the Scrapper perk (if you have some other mod that adds them and F4SE is installed)
- Canary save file monitor support
- Can be configured to only have a limited number uses
- Sane defaults, so even if not customized, it will work out of the box


Summary (TL;DR)
---------------
Here's the TL;DR if you don't care about the details and just want to get on with it. By default the Mk 2 functions like the original, that is, you use it, exit the Pip-boy, move the junk objects you want to be recycled into the container that then opens, close said container, and then you get a bunch of components back. However it has the following bonuses by default:

- You get a 1% bonus to the number of components returned for each point in Intelligence
- You get a 1% bonus to the number of components returned for each point in Luck
- You get a 10% bonus to the number of components returned per Scrapper perk rank, but _only_ in player-owned settlements

This mod does not _require_ F4SE or the Mod Configuration Menu, but will make use of them if they are installed. This mod also supports the Canary mod to alert in the case of save game corruption. (Check it out here: https://www.nexusmods.com/fallout4/mods/44949)

The Portable Junk Recycler Mk 2 and its settings holotape are craftable at the chemistry station in the "Utility" section. You can adjust the settings either via the afore-mentioned settings holotape, or via the Mod Configuration Menu if you have it installed.


Detailed Information
--------------------
Now, if you'd like to know more about how things work in this mod and how best to customize it to your liking, read on.

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


Settings Rundown
----------------
Settings
    (General Options)
    Base Multiplier [Default = 1.0, Minimum = 0.0, Maximum = 2.0, Step = 0.01]
    Always Return At Least One Component [Default = ON, Possible Values = OFF/ON]
    Fractional Component Handling [Default = Round Down, Possible Values = Round Up/Round Normally/Round Down]
    Has Limited Uses [Default = OFF, Possible Values = OFF/ON]
    Number Of Uses [Default = 50, Minimum = 1, Maximum = 200, Step = 1]
    (Adjustment Options)
    General Adjustments [Default = Simple, Possible Values = Simple/Detailed]
    Intelligence Affects Multiplier [Default = ON (Simple), Possible Values = OFF/ON (Simple)/ON (Detailed)]
    Luck Affects Multiplier [Default = ON (Simple), Possible Values = OFF/ON (Simple)/ON (Detailed)]
    Add Randomness To Multiplier [Default = OFF, Possible Values = OFF/ON (Simple)/ON (Detailed)]
    Scrapper Perk Affects Multiplier [Default = ON (Simple), Possible Values = OFF/ON (Simple)/ON (Detailed)]
Multiplier Adjustments
    General
        (If "Settings (Adjustment Options) > General Adjustments" is set to "Simple")
        In Player-Owned Settlements
        Everywhere Else
        (If "Settings (Adjustment Options) > General Adjustments" is set to "Detailed")
        Components: Common
            In Player-Owned Settlements
            Everywhere Else
        Components: Uncommon
            In Player-Owned Settlements
            Everywhere Else
        Components: Rare
            In Player-Owned Settlements
            Everywhere Else
        Components: Special
            In Player-Owned Settlements
            Everywhere Else
    (If "Settings (Adjustment Options) > Intelligence Affects Multiplier" is not set to "OFF")
    Intelligence
        (If "Settings (Adjustment Options) > Intelligence Affects Multiplier" is set to "ON (Simple)")
        Adjustment Per Point Of Intelligence
        (If "Settings (Adjustment Options) > Intelligence Affects Multiplier" is set to "ON (Detailed)")
        Components: Common
            Adjustment Per Point Of Intelligence
        Components: Uncommon
            Adjustment Per Point Of Intelligence
        Components: Rare
            Adjustment Per Point Of Intelligence
        Components: Special
            Adjustment Per Point Of Intelligence
    (If "Settings (Adjustment Options) > Luck Affects Multiplier" is not set to "OFF")
    Luck
        (If "Settings (Adjustment Options) > Luck Affects Multiplier" is set to "ON (Simple)")
        Adjustment Per Point Of Luck
        (If "Settings (Adjustment Options) > Luck Affects Multiplier" is set to "ON (Detailed)")
        Components: Common
            Adjustment Per Point Of Luck
        Components: Uncommon
            Adjustment Per Point Of Luck
        Components: Rare
            Adjustment Per Point Of Luck
        Components: Special
            Adjustment Per Point Of Luck
    (If "Settings (Adjustment Options) > Add Randomness To Multiplier" is not set to "OFF")
    Randomness


Scrap Categories
----------------
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


Crafting Materials Required
---------------------------
Aluminum x3
Circuitry x3
Adhesive x3
Gears x6
Nuclear Material x3
Plastic x3
Springs x1
Steel x12
Screws x12
Fusion Core (any charge level) x1


Recycler Form ID
----------------
FExxx840


FormIDs
-------
FExxx80- Quest
FExxx81- FormID List
FExxx82- Magic Effect
FExxx83- Container
FExxx84- Ingestible
FExxx85- Transform
FExxx86- Constructable Object
FExxx87- Note
FExxxA-- Message
FExxxB-- Terminal
FExxxC-- Global


Credits
-------
SavrenX - For the textures from their "SavrenX HD Settlement and Clutters" mod (https://www.nexusmods.com/fallout4/mods/40485)
pra - For some feature ideas based on their "Scrapping Machine" mod (https://www.nexusmods.com/fallout4/mods/35793)
Kentington - For the OG "Portable Junk Recycler" mod (https://www.nexusmods.com/fallout4/mods/14110)
Grospolina - For the code to convert an integer ID into a hex ID (https://forums.nexusmods.com/index.php?/topic/8441118-convert-decimal-formid-to-hexadecimal/page-2#entry78086848)
Lively - For allowing me to post the beta of this mod on his Discord server to get some play testing done
kinggath - For the Canary save file monitoring mod