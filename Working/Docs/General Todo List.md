# General TODO List

* [X] create a way for conflicts between MCM and global vars to be resolved
* [X] decide whether to implement some code-based min-max values for the globals
* [X] add a test object that returns 100 of each kind of component (or at least 100 of a component from each _class_ of components)
* [X] determine whether to reset the IsRunning property in QuestScript on game load - alternatively could be an option in the terminal/MCM
    * outcome: no - add buttons to reset 'busy' and 'running' into settings menu
* [X] add a reset to defaults function
    * [X] polish up naming in config.jsonnet
* [X] organize the int ID to hex ID code
* [X] figure out what the right approach is for tracing. the mod should have it, but it should probably be an option that gets turned on (how? last time i thought about that, i came up with some weird chicken/egg scenarios regarding resets and such) maybe it should be a bool property instead of a SettingMapBool property?
    * outcome: trace all the things. if user is running with debug off, it won't record anything.
* [X] put Messages into the mod - don't rely on debug.notification
* [X] add F4SE version and F4SE script version into debug output in QuestEffect
* [X] investigate having a recycler with only a limited amount of uses. (keywords? actor values? change to MiscObject and use OnActivate event?)
    * outcome: have `HasLimitedUses`, `NumberOfUses`, and `NumberOfUsesLeft` properties on quest script
* [X] finish implementing 'limited use' support in effect script
* [X] handle the case of 'number of times used = 0' when altering the number of uses setting (irrelevant due to how it's kept track of now)
* [X] add [canary save file monitor](https://www.nexusmods.com/fallout4/mods/44949) support
* [-] decide whether to add F4SE-based support for non-vanilla components
    * outcome: do it
    * update: cancelled; can't do it without adding hard dependency on F4SE scripts
* [X] decide whether to add adjustments for INT and LCK
    * outcome: do it
* [X] decide whether to add random element (influenced by LCK?)
    * outcome: do it
* [X] add menu option to reset 'busy' and 'running' mutexes
* [-] add GetName() support to RecycleComponents function (EffectScript)
* [-] add function to set an internal variable to true if papyrus debugging is on (use DebugOnly descriptor)
* [X] decide on whether add 'number of components' mode as a limited use counter?
    * outcome: no
* [X] decide on whether to add an upgrade path to the mod by having the QuestScript.InitSettings function check whether a variable exists before creating a new instance of it (would depend on a function argument "abForce" which would be used in the case of first time init and reset to defaults)
    * outcome: no need, as the recommended upgrade path is going to be a clean save (disable mod, load game, save game, install and enable new mod)
* [X] add adjustments for INT and LCK to:
    * [X] QuestScript
    * [X] config.json
    * [X] settings.ini
* [X] investigate smarter way to send MCM status (and McmModName?) to ChangeSettingXXX functions rather than embedding it in the structs
    * [X] outcome: pass it into change/load functions in Base
* [X] adjust recycling process so it uses an intermediate container (components are removed from primary container, adjusted and added to intermediate container, then eventually moved back to the player)
* [-] add function to dump all variables to debug log (cancelled - look through save with ReSaver/FallRim Tools)
* [-] make another ppj file for compiling 'release' (that is, debug statements commented out) quality scripts (cancelled)
* [-] fix build process to centralize version numbers (cancelled, too much of a pain in the ass for too little gain)
* [X] group adjustment flags in general settings in config.json (scrap perk, intelligence, luck, ...)
* [-] add F4SE-based support for non-vanilla components
    * [-] QuestScript
    * [-] EffectScript
    * [-] config.json
    * [-] settings.ini
    * ---> can't do this without adding a direct dependency on F4SE scripts <---
* [X] add simple random element (not influenced by luck directly)
    * [X?] QuestScript
    * [X?] EffectScript
    * [X] config.json
    * [X] settings.ini
    * [X] handle case of minimum random adjustment setting > maximum random adjustment setting
        * doesn't actually matter - Utility.RandomFloat() auto-corrects
* [X] reorganize to put things like the INT settings, LCK settings, and RND settings in consistent order
    * [X] mcm layout.txt
    * [X] config.json
    * [X] EffectScript
    * [X] QuestScript
    * [X] settings.ini
* [X] go over groupControl/groupCondition keys and make sure that there are no duplicates (add '2' to old values)
    * 1 (old) = X
    * 7 (old) = Y
    * 2 (old) = Z
    * 3 (old) = A
    * 4 (old) = B
    * 5 (old) = C
    * 6 (old) = D
    * 8 (old) = E
    * 9 (old) = F
* [X] there's a bug that is preventing randomness section in multiplier adjustments page in MCM from showing up when starting new and having player settings ini
* [X] add feedback to use via popup when resetting settings to default and when resetting mutexes
* [X] add menu option to check how many uses are left
* [-] add control settings holotape/terminal
    * [-] control settings terminal with single script instead of fragments?
* [X] (maybe) see if FallUI/DEF_IU can support modifying the container interface to add "TRANSFER ALL JUNK" button
    * result: they can (as can vanilla), but it still fails because there's some bethesda code objects called that thinks you're trying to equip the item
* [X] reorder records in plugin file
* [X] see if there's a way to trigger back in terminals without adding a layer to tab stack
    * outcome: doesn't seem to be - remove "BACK" entry on terminal entries
* [X] figure out how to set property MCM settings to read from a specific script
    * "scriptName" key in "valueOptions" array
* [X] add setting to filter junk from container -> might have to make a second container if an empty form list
    * [X] add sub-setting to control whether to auto move junk items to temp container
* [-] add setting to specify the number of threads?
* [-] should I create a thread manager that hands out work as needed instead of dividing up work once?
    * result: simply multithread all possible things
* [-] add button (in 'advanced' MCM page) to regenerate component maps
* [X] add button (in 'advanced' MCM page) to clear found junk item FormList
* [X] add button (in 'advanced' MCM page) to clear stuck override markers
* [X] add button (in 'advanced' MCM page) to uninstall
* [X] change FormList properties to FormListWrapper structs
* [X] add 'shift' key override to add junk items to container if held when recycler is activated
    * [X] add ability to change key?
* [X] add 'ctrl' key override to _not_ add junk items to container if held when recycler is activated
    * [X] add ability to change key?
* [X] add fully automatic mode to recycler
    * [-] disable player controls during?
* [X] break threading out to its own quest
* [X] add never auto transfer list (stuff in there doesn't get automatically moved or recycled)
    * [X] open it up with Alt+Ctrl activation
    * [X] add (in 'advanced' MCM page) button to clear list
    * (functionality)
        * spawn filtered container
        * once spawned, add one of every item in the current exemption list into the container
        * when opened, show a message stating that this is the exemption editing mode
        * when closed, revert FormList and add every form inside to FormList. every item beyond 1 would get put back into player's inventory
* [X] add always auto transfer list (stuff in there always gets automatically moved or recycled)
    * [X] open it up with Alt+Shift activation
    * [X] add (in 'advanced' MCM page) button to clear list
* [-] convert to using states?
* [X] see if I can break out *Coordinator functions into their own base script that can be imported (a la Base)
    * result: separate quest and script
* [X] determine what open source license to use
    * result: GPL-3.0-or-later
    * [X] implement chosen open source license
* [X] auto-detect Standalone Workbenches (use Utility bench)
* [X] auto-detect AWKCR
* [-] auto-detect lively's keyword resource
    * result: can't change category keywords on a COBJ through papyrus
* [X] make ESP patches for different COBJ keywords
    * [X] AWKCR: 0x001766 (AEC_cm_Devices) DEVICES
    * [X] AWKCR: 0x001768 (AEC_cm_Tools) TOOLS
    * [X] AWKCR: 0x000860 (AEC_cm_Other_Recipe) OTHER
    * [X] LKR: 0x834 (lkr_elec_devices) DEVICES
    * [X] LKR: 0x8AF (lkr_util_utility) UTILITY
* [-] add blank 'Portable Junk Recycler Mk 2.ini' file to MCM/Config directory and build process
    * result: won't do it as it will potentially overwrite user's already-existing one
* [X] localize jsonnet file
* [X] write "help" strings for jsonnet
* [X] add metadata to all the plugin files
* [X] write readme
    * [X] explain how multipliers work
    * [X] mention canary support
* [X] add setting to change max number of threads used
    * [X] see if that reduces stuttering when activating
    * (result): it does not
* [-] localize MCM strings file (Cn/De/En/Es/Esmx/Fr/It/Ja/Pl/Ptbr/Ru)
* [-] localize plugin file (Cn/De/En/Es/Esmx/Fr/It/Ja/Pl/Ptbr/Ru)
* [X] finish adding Enable{Logging,Profiling} to ControlScript
    * [X] check logic around how OpenUserLog works
* [X] think about potential race conditions with how setting callbacks now work
* [X] remove base art assets from repo
* [X] add text to README ('Copyright and Licensing' section) saying same thing that nexus mods 'mod permissions' page says
* [X] add troubleshooting section to README, include things like the mod log, how to turn on papyrus logging, etc.
* version locations:
    * .version file
