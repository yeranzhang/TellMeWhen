if not TMW then return end

TMW.CHANGELOG = {

[==[===v7.1.0===]==],
[==[]==],
[==[* Buff/Debuff equivalencies have been updated (with the exception of diminishing returns). Please open a ticket if you notice anything missing or mis-categorized.]==],
[==[]==],
[==[* New conditions]==],
[==[** Instance Size]==],
[==[** Zone PvP Type]==],
[==[]==],
[==[* New icon type: All-Unit Buffs/Debuffs. This icon type is mainly useful for tracking your multidotting on targets which might not have a unitID that they can be tracked by in a normal Buff/Debuff icon.]==],
[==[* New icon display method: Vertical Bars.]==],
[==[* You can now set a rotation amount for a icon's text displays.]==],
[==[* The suggestion list now defers its sorting so that input is more responsive.]==],
[==[* The "Highlight timer edge" setting is back.]==],
[==[* You can now export all your global groups at once.]==],
[==[]==],
[==[]==],
[==[====Bug Fixes====]==],
[==[* Fixed yet another issue with ElvUI's timer texts (they weren't going away when they should have been).]==],
[==[* A whole lot of other minor bugs have been fixed - too many to list here.]==],
[==[]==],
[==[]==],
[==[===v7.0.3===]==],
[==[* Re-worked the Instance Type condition to make it more extensible in the future, and also added a few missing instance types to it.]==],
[==[* Added a Unit Specialization condition that can check the specs of enemies in arenas, and all units in battlegrounds.]==],
[==[]==],
[==[====Bug Fixes====]==],
[==[* Fixed an error that would be thrown if the whisper target ended up evaluating to nil.]==],
[==[* TellMeWhen now duplicates Blizzard's code for the spell activation overlay (and has some additional code to get this to play nicely with Masque) so that it should hopefully no longer get blamed for tainting your action bars.]==],
[==[* TellMeWhen also now duplicates Blizzard's code for dropdown menus, and improves upon it slightly. This should also help with taint issues.]==],
[==[]==],
[==[===v7.0.2===]==],
[==[====Bug Fixes====]==],
[==[* Fixed the missing slider value text for the Unit Level condition.]==],
[==[* The Haste conditions no longer have a hard cap of 100%.]==],
[==[* Fixed a false error that would display during configuring while using the [Range] DogTag.]==],
[==[* Fixed an error relating to refreshing the tooltip for non-button widgets.]==],
[==[]==],
[==[===v7.0.1===]==],
[==[* Numbered units entered with a space in the middle (e.g. "arena 1") will once again be corrected by TellMeWhen. It is still bad practice to enter units like that, though.]==],
[==[]==],
[==[====Bug Fixes====]==],
[==[* Fixed a typo that was preventing Loss of Control icons from reporting their spell.]==],
[==[* Fixed an error that would happen when upgrading a text layout that was previously unnamed: IconModule_TextsTexts.lua:150 attempt to concatenate field 'Name' (a nil value)]==],
[==[]==],
[==[===v7.0.0===]==],
[==[]==],
[==[====Core Systems====]==],
[==[* You can now create global groups that exist for all characters on your account. These groups can be enabled and disabled on a per-profile basis.]==],
[==[* Text Layouts are now defined on an account-wide basis instead of being defined for individual profiles.]==],
[==[]==],
[==[* Many icon types, when set on the first icon in a group, are now able to control that entire group with the data that they harvest.]==],
[==[]==],
[==[* All references from one icon or group to another in TellMeWhen are now tracked by a unique ID. This ID will persist no matter where it is moved or exported to.]==],
[==[** This includes:]==],
[==[*** DogTags]==],
[==[*** Meta icons]==],
[==[*** Icon Shown conditions (and the other conditions that track icons)]==],
[==[*** Group anchoring to other groups]==],
[==[** The consequence of this is that you can now, for example, import/export a meta icon separately from the icons it is checking and they will automatically find eachother once they are all imported (as long as these export strings were created with TMW v7.0.0+)]==],
[==[** IMPORTANT: Existing DogTags that reference other icons/groups by ID cannot be updated automatically - you will need to change these yourself.]==],
[==[]==],
[==[====Events/Notifications====]==],
[==[* Events have been re-branded to Notifications, and you can now add notifications that will trigger continually while a set of conditions evaluate to true.]==],
[==[* New Notification: Counter. Configure a counter that can be checked in conditions and displayed with DogTags.]==],
[==[* The On Other Icon Show/Hide events have been removed. Their functionality can be obtained using an On Condition Set Passing trigger.]==],
[==[* You can now adjust the target opacity of the Alpha Flash animation]==],
[==[]==],
[==[====Icon Types====]==],
[==[* Global Cooldowns are now only filtered for icon types that can track things on the global cooldown.]==],
[==[* Combat Event: the unit exclusion "Miscellaneous: Unknown Unit" will now also cause events that were fired without a unit to be excluded.]==],
[==[* Meta Icon: The "Inherit failed condition opacity" setting has been removed. Meta icons will now always inherit the exact opacity of the icons they are showing, though this can be overridden by the meta icon's opacity settings.]==],
[==[* Meta Icon: Complex chains of meta icon inheritance should now be handled much better, especially when some of the icons have animations on them.]==],
[==[* Diminishing Returns: The duration of Diminishing Returns is now customizable in TMW's main options.]==],
[==[* Buff/Debuff: Ice Block and Divine Shield are now treated as being as non-stealable (Blizzard flags them incorrectly)]==],
[==[* Buff/Debuff: Added an [AuraSource] DogTag to obtain the unit that applied a buff/debuff, if available.]==],
[==[* Buff/Debuff Check: Removed the "Hide if no units" option since it didn't make much sense for this icon type.]==],
[==[]==],
[==[====Conditions====]==],
[==[* New Conditions added that offer integration with Big Wigs and Deadly Boss Mods.]==],
[==[* New Condition: Specialization Role]==],
[==[* New Condition: Unit Range (uses LibRangeCheck-2.0 to check the unit's approximate range)]==],
[==[* The Buff/Debuff - "Number of" conditions now accept semicolon-delimited lists of multiple auras that should be counted.]==],
[==[]==],
[==[====Group Modules====]==],
[==[* You can now anchor groups to the cursor.]==],
[==[* You can now right-click-and-drag the group resize handle to easily change the number of rows and columns of a group, and doing so with this method will preserve the relative positions of icons within a group.]==],
[==[* Added group settings that allow you to specify when a group should be shown based on the role that your current specialization fulfills.]==],
[==[]==],
[==[====Icon Modules====]==],
[==[* You can now enter "none" or "blank" as a custom texture for an icon to force it to display no texture.]==],
[==[* You can now enter a spell prefixed by a dash to omit that spell from any equivalencies entered, E.g. "Slowed; -Dazed" would check all slowed effects except daze.]==],
[==[]==],
[==[* New text layout settings: Width, Height, & JustifyV.]==],
[==[]==],
[==[====Miscellaneous====]==],
[==[* The group settings tab in the Icon Editor now only displays the group options for the currently loaded icon's group by default. This can be changed back to the old behavior with a checkbox in the top-left corner of the tab in the Icon Editor.]==],
[==[]==],
[==[* Exporting a meta icon will also export the string(s) of its component icons.]==],
[==[* Exporting groups and icons will also export the string(s) of their text layouts.]==],
[==[]==],
[==[* Various updates to many buff/debuff equivalencies.]==],
[==[* New buff equivalency: SpeedBoosts]==],
[==[]==],
[==[* Code snippets can now be disabled from autorunning at login.]==],
[==[* Dramatically decreased memory usage for icons that have no icon type assigned.]==],
[==[* You can now use "thisobj" in Lua conditions as a reference to the icon or group that is checking the conditions.]==],
[==[]==],
[==[* TellMeWhen now warns you when importing executable Lua code so that you can't be tricked into importing scripts you don't know about.]==],
[==[]==],
[==[* TellMeWhen_Options now maintains a backup of TellMeWhen's SavedVariables that will be restored if TellMeWhen's SVs become corrupted.]==],
[==[]==],
[==[* TellMeWhen no longer includes the massively incomplete localizations for itIT, ptBR, frFR, deDE, koKR, and esMX (esMX now uses esES). If you would like to contribute to localization, go to http://wow.curseforge.com/addons/tellmewhen/localization/]==],
[==[]==],
[==[====Bug Fixes====]==],
[==[* Units tracked by name with spaces in them (E.g. Kor'kron Warbringer as a CLEU unit filter) will now be interpreted properly as input.]==],
[==[** IMPORTANT: A consequence of this fix is that if you are enter a unit like "boss 1", this will no longer work. You need to enter "boss1", which has always been the proper unitID.]==],
[==[* Importing/Exporting icons from/to strings with hyperlinks in some part of the icon's data will now preserve the hyperlink.]==],
[==[* Icons should now always have the correct size after their view changes or the size or ID of a group changes.]==],
[==[* Fixed an issue where strings imported from older version of TellMeWhen (roughly pre-v6.0.0) could have their StackMin/Max and DurationMin/Max settings as strings instead of numbers.]==],
[==[* The "Equipment set equipped" condition should properly update when saving the equipment set that is currently equipped.]==],
[==[* Fixed an issue when upgrading text layouts that could also cause them to not be upgraded at all: /Components/IconModules/IconModule_Texts/Texts.lua line 205: attempt to index field 'Anchors' (a nil value)]==],
[==[* Currency conditions should once again be listed in the condition type selection menu.]==],
[==[* The NPC ID condition should now work correctly with npcIDs that are greater than 65535 (0xFFFF).]==],
[==[* Meta icons should reflect changes in the icons that they are checking that are caused by using slash commands to enable/disable icons while TMW is locked.]==],
[==[* TellMeWhen no longer registers PLAYER_TALENT_UPDATE - there is a Blizzard big causing this to fire at random for warlocks, and possibly other classes as well, which triggers a TMW:Update() which can cause a sudden framerate drop. PLAYER_SPECIALIZATION_CHANGED still fires for everything that we cared about.]==],
[==[]==],
[==[===v6.2.6===]==],
[==[====Bug Fixes====]==],
[==[* Added a hack to ElvUI's timer texts so that they will once again obey the setting in TellMeWhen. Previously, they would be enabled for all icons because of a change made by ElvUI's developers.]==],
[==[* Spell Cooldown icons that are tracking by spellID instead of by name should once again reflect spell charges properly (this functionality was disrupted by a bug introduced by Blizzard in patch 5.4).]==],
[==[]==],
[==[===v6.2.5===]==],
[==[* ElvUI's timer texts are once again supported by TellMeWhen.]==],
[==[]==],
[==[===v6.2.4===]==],
[==[* Added DogTags for string.gsub and string.find.]==],
[==[* Added Yu'lon's Barrier to the DamageShield equivalency.]==],
[==[]==],
[==[====Bug Fixes====]==],
[==[* IconModule_Alpha/Alpha.lua:84: attempt to index local "IconModule_Alpha" (a nil value)]==],
[==[* Rune icons will now behave properly when no runes are found that match the types configured for the icon.]==],
[==[* The Banish loss of control type was accidentally linked to the Fear loss of control type - this has been fixed.]==],
[==[* Unit cooldown icons should now attempt to show the first usable spell even if no units being checked have casted any spells yet.]==],
[==[]==],
[==[===v6.2.3===]==],
[==[* IMPORTANT: The color settings for all timer bars (including bar group and timer overlay bars) have changed a bit:]==],
[==[** The labels for these settings now correctly correspond to the state that they will be used for.]==],
[==[** The colors will automatically switch when you enable the "Fill bar up" setting for a bar.]==],
[==[** These changes will probably require you to reconfigure some of your settings.]==],
[==[]==],
[==[* Icons in groups that use the Bar display method can now have their colors configured on a per-icon basis.]==],
[==[** You can copy colors between icons by right-click dragging one icon to another.]==],
[==[]==],
[==[* TellMeWhen now uses a coroutine-based update engine to help prevent the occasional "script ran too long" error.]==],
[==[** This version also includes an updated LibDogTag-3.0 and LibDogTag-Unit-3.0 that should no longer throw "script ran too long" errors.]==],
[==[]==],
[==[====Bug Fixes====]==],
[==[* Removed the "Snared" Loss of Control category from the configuration since it is most certainly not used by Blizzard.]==],
[==[* Item-tracking icons and condition should now always get the correct data once it becomes available.]==],
[==[]==],
[==[===v6.2.2===]==],
[==[* Buff/Debuff icons can now sort by stacks.]==],
[==[* The group sorting option to sort by duration now treats spells that are on the GCD as having no cooldown.]==],
[==[]==],
[==[* Added a few more popup notifications when invalid settings/actions are entered/performed.]==],
[==[* Icons will now be automatically enabled when you select an icon type.]==],
[==[* Incorporated LibDogTag-Stats-3.0 into TellMeWhen's various implementations of LibDogTag-3.0.]==],
[==[* The Mastery condition now uses GetMasteryEffect() instead of GetMastery(). The condition will now be comparable to the total percentage increase granted by mastery instead of the value that has to be multiplied by your spec's mastery coefficient (which is no longer shown in Blizzard's character sheet.)]==],
[==[* TMWOptDB now uses AceDB-3.0. One benefit of this is that the suggestion list will now always be locale-appropriate.]==],
[==[* The suggestion list for units is now much more useful.]==],
[==[* The suggestion list now has a warning in the tooltip when inserting spells that interfere with the names of equivalencies.]==],
[==[* The suggestion list now pops up a help message the first time it is shown.]==],
[==[* You can now copy an icon's events and conditions by right-click-dragging the icon to another icon.]==],
[==[** You can also copy group conditions between groups this way.]==],
[==[* When right-click-dragging an icon to an icon that has multiple icons in the same place, you can now choose which one you would like the destination to be.]==],
[==[]==],
[==[====Bug Fixes====]==],
[==[* Buff/Debuff icons that are set to sort by low duration should now properly display unlimited duration auras when there is nothing else to display.]==],
[==[* The Ranged Attack Power condition should now always use the proper RAP value.]==],
[==[* Fixed some "You are not in a raid group" errors.]==],
[==[* All features in TellMeWhen that track items (including Item Cooldown icons and any item conditions) are universally able to accept slotIDs as input, and all features will now correctly distinguished equipped items from items in your bag when tracking by slotID. This is the result of a new, robust system for managing items.]==],
[==[]==],
}
