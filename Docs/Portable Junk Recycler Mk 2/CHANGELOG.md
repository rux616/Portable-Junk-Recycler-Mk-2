Portable Junk Recycler Mk 2
===========================

Table Of Contents
-----------------
- [Portable Junk Recycler Mk 2](#portable-junk-recycler-mk-2)
    - [Table Of Contents](#table-of-contents)
- [Changelogs](#changelogs)
    - [v1.0.0](#v100)
    - [v0.7.0-beta](#v070-beta)
    - [v0.6.0-beta](#v060-beta)
    - [v0.5.0-beta](#v050-beta)
    - [v0.4.0 beta](#v040-beta)
    - [v0.3.1 beta](#v031-beta)
    - [v0.3.0 beta](#v030-beta)
    - [v0.2.3 beta](#v023-beta)
    - [v0.2.2 beta](#v022-beta)
    - [v0.2.1 beta](#v021-beta)
    - [v0.2.0 beta](#v020-beta)


Changelogs
==========

v1.0.0
------
- Initial release

v0.7.0-beta
-----------
- Added MCM setting: 'Enable Script Logging' ('Advanced' page) - choose whether to enable script logging (only possible when "bEnableLogging=1" and "bEnableTracing=1" are also set in the "[Papyrus]" section of fallout4custom.ini, and the debug scripts are installed)
- Added MCM setting: 'Enable Script Profiling' ('Advanced' page) - choose whether to enable script profiling (only possible when "bEnableProfiling=1" is also set in the "[Papyrus]" section of fallout4custom.ini, and the debug scripts are installed)
- Added "Troubleshooting Info" section to readme
- Performed some minor cleanup on documentation and text files
- Major internal code refactor to pull out the settings from the control script

([TOC](#table-of-contents))

v0.6.0-beta
-----------
- Added MCM setting: 'Only Transfer Low Component Weight Ratio Items' ('Recycler Interface' page) - choose when to only transfer items whose component parts weigh less than the item
- Added MCM setting: 'Max Number Of Threads To Use' ('Advanced' page) - set the maximum number of threads that will be used in multithreaded operations
- Added MCM setting: 'Use "Direct Move" Method To Update Recyclable Item List' ('Advanced' page) - when updating the list of recyclable items, a special 'direct move' version of the method will be used, potentially increasing speed by a little bit, but potentially causing lag of its own by moving the contents of the player inventory directly
- Added MCM setting: 'Enable Automatic Transfer List Editing' ('Recycler Interface' page) - enables the ability to edit the auto transfer lists; off by default to prevent accidental activation
- Added message shown when editing an auto transfer list is finished
- Filter out items with UnscrappableObject keyword when building recyclable items list
- Changed Override Behavior setting to off by default to prevent accidental activation
- Changed options with "Allow" in name to "Enable"
- Fixed filtering of items into the Mk 2 inventory
- Sped up updating of recyclable items list by adding async processing while the script is waiting to open the container
- Slightly altered the main mod menu page to consolidate informational buttons

([TOC](#table-of-contents))

v0.5.0-beta
-----------
- Added some optional light plugins to change the crafting category of the recycler device: "Devices", "Other", and "Tools" from AWKCR; "Devices", and "Utility" from Lively's Keyword Resources (LKR)
- Added a "Never Automatically Transfer" list so that certain items never get transferred to the recycler inventory automatically
- Added an "Always Automatically Transfer" list so that certain items always get transferred to the recycler inventory automatically
- Added MCM setting: 'Use "Never Automatically Transfer" List' ('Recycler Interface' page) - uses the list
- Added MCM setting: 'Use "Always Automatically Transfer" List' ('Recycler Interface' page) - uses the list
- Added MCM setting: 'Crafting Station' ('Recycler Interface' page) - choose where the recycler device is crafted, can dynamically choose from the Utility Workbench from Standalone Workbenches, the Utility Workbench from AWKCR, or the Chemistry Station from Vanilla, or manually specify one of them, falling back to Chemistry Station from Vanilla if the choice isn't detected
- Added MCM button: 'Reset List: Always Automatically Transfer' ('Advanced' page) - resets the FormList associated with determining what junk items are always automatically moved to the recycler inventory
- Added MCM button: 'Reset List: Never Automatically Transfer' ('Advanced' page) - resets the FormList associated with determining what junk items are never automatically moved to the recycler inventory
- Added a safeguard in MCM so you don't accidentally click the uninstall button ('Advanced' page)
- Added help entries for all settings and buttons in the MCM
- Improved some of the descriptions of MCM settings and buttons
- Changed MCM button: 'Reset Recyclable Item List' ('Advanced' page) -> 'Reset List: Recyclable Items' ('Advanced' page)
- Changed settings.ini categories of settings to broadly match the names of their locations in the menus
- Changed MCM button: 'Uninstall' ('Advanced' page) - cannot be triggered when there is a recycling process running or the control script is busy
- Removed MCM button: 'Reset Behavior Overrides' ('Advanced' page) - no longer needed
- Adopted the GPL 3.0 license (with the "or later" option) for the source code of the mod

([TOC](#table-of-contents))

v0.4.0 beta
-----------
- Major refactor to allow the use of multithreading to alleviate several performance bottlenecks
- Added new setting: Allow Junk Only (applies a filter to the recycler so that it only accepts junk items)
- Added new setting: Automatically Move Junk (automatically moves junk items in the player inventory to the recycler inventory)
- Added new setting: Behavior Overrides (if LShift is held when activating the recycler item, junk items are moved into the recycler inventory, just like how the 'Automatically Move Junk' option works; if LCtrl is held when activating the recycler item, junk items will be forced to NOT move)
- Added new setting: Automatic Recycling Mode (doesn't pop open the recycler inventory, just recycles all the junk in your inventory)
- Added new button ('Advanced' page in the MCM): Reset Recyclable Item List (resets the FormList associated with the 'Automatically Move Junk' functionality, in case it ever starts putting weird stuff into the recycler inventory)
- Added new button ('Advanced' page in the MCM): Reset Behavior Overrides (resets the behavior overrides if they get stuck)
- Added new button ('Advanced' page in the MCM): Uninstall Mod (prepares the mod for uninstallation by deleting variables and unregistering from events)
- Refined fix for loading auto-saves in v0.3.1 by returning to using properties, but no 'const' ones: The problem is that 'const' properties aren't saved into the papyrus VM, so if a save is made while a script is running and then said save is reloaded, if the already-running script tries to access a const property the game doesn't know what the script is attempting to access, so it just returns NONE, and things can get into a bad state or potentially even outright break.
- Increase timeout for runtime init mutex release
- Started localizing MCM config and adding help strings
- Changed crafting materials required:
    - Enhanced Targeting Card x1
    - Fusion Core x1
    - High-powered Magnet x1
    - Power Relay Coil x2
    - Screws x12
    - Sensor Module x1
    - Steel x20

([TOC](#table-of-contents))

v0.3.1 beta
-----------
- Added warning message if MCM not detected
- Fixed things breaking if the player loaded an auto-save that was created after activating the recycler device in the inventory. It seems that when the papyrus VM would unfreeze after loading the save, it had forgotten about the properties of the script. To work around it, the forms are loaded into local variables manually.
- Altered crafting recipe a bit

([TOC](#table-of-contents))

v0.3.0 beta
-----------
- Made MCM required
- Removed settings holotape and associated forms
- Cleaned up newly-dead code related to having F4SE and MCM be optional
- Cleaned up newly-dead code related to settings holotape
- Added new setting: Return Items Silently (determines if the player gets notification messages about items being returned from the recycler)
- Added warning message if F4SE not detected

([TOC](#table-of-contents))

v0.2.3 beta
-----------
- Added more logging to scripts
- Fixed freeze when aiming at things that could be activated when recycling process was ready to return items to player (F4SE is now required)

([TOC](#table-of-contents))

v0.2.2 beta
-----------
- fixed multipliers not applying to all components in a multi-component item

([TOC](#table-of-contents))

v0.2.1 beta
-----------
- fixed unintentional resource loop

([TOC](#table-of-contents))

v0.2.0 beta
-----------
- initial beta release

([TOC](#table-of-contents))
