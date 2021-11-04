// Copyright 2021 Dan Cassidy

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// SPDX-License-Identifier: GPL-3.0-or-later

local mcm = import 'lib/mcm.libsonnet';

local str_indent_comp_c = '$IndentComponentsCommon';
local str_indent_comp_u = '$IndentComponentsUncommon';
local str_indent_comp_r = '$IndentComponentsRare';
local str_indent_comp_s = '$IndentComponentsSpecial';
local str_settlement = '$InSettlements';
local str_not_settlement = '$EverywhereElse';
local str_indent_settlement = '$IndentInSettlements';
local str_indent_not_settlement = '$IndentEverywhereElse';
local str_int = '$Intelligence';
local str_lck = '$Luck';
local str_per_point_int = '$AdjustmentInt';
local str_per_point_lck = '$AdjustmentLck';
local str_indent_per_point_int = '$IndentAdjustmentInt';
local str_indent_per_point_lck = '$IndentAdjustmentLck';
local str_min = '$Minimum';
local str_max = '$Maximum';
local str_indent_min = '$IndentMinimum';
local str_indent_max = '$IndentMaximum';

local adjust_min = -1.0;
local adjust_max = 1.0;
local adjust_step = 0.01;
local stat_adjust_min = 0.0;
local stat_adjust_max = 1.0;
local stat_adjust_step = 0.005;

{
  local mod = {
    name: 'Portable Junk Recycler Mk 2',
    localized_name: '$PortableJunkRecyclerMk2',
    version: '0.5.0 beta',
    plugin_name: mod.name + '.esp',
    quest_form: mod.plugin_name + '|800',
    control_script: 'PortableJunkRecyclerMk2:ControlScript',
    min_mcm_version: 2,

    group_id: {
      general_mult_adjust_simple: 1,
      general_mult_adjust_detailed: 2,
      int_affects_mult_simple: 3,
      int_affects_mult_detailed: 4,
      lck_affects_mult_simple: 5,
      lck_affects_mult_detailed: 6,
      rng_affects_mult_simple: 7,
      rng_affects_mult_detailed: 8,
      scrapper_affects_mult_simple: 9,
      scrapper_affects_mult_detailed: 10,
      scrapper_3_available: 11,
      scrapper_4_available: 12,
      scrapper_5_available: 13,
      uninstall_safeguard: 14,
    },
  },

  'config.json': {
    [mcm.field.mod_name]: mod.name,
    [mcm.field.display_name]: mod.localized_name,
    [mcm.field.min_mcm_version]: mod.min_mcm_version,
    [mcm.field.plugin_requirements]: [mod.plugin_name],
    [mcm.field.content]: [
      mcm.control.text(text='<p align="center"><font size="24">' + mod.localized_name + '</font></p>', html=true),
      mcm.control.text(text='<p align="center">by rux616</p>', html=true),
      mcm.control.text(text='<p align="center">v' + mod.version + '</p>', html=true),
      mcm.control.spacer(lines=1),

      mcm.control.section(text='$About'),
      mcm.control.text(text='$AboutText'),
      mcm.control.spacer(lines=1),

      mcm.control.section(text='$Multipliers'),
      mcm.control.button(text='$ViewCurrentMultipliersText', action=mcm.helper.action.call_function(mod.quest_form, 'ShowCurrentMultipliers', script_name=mod.control_script), help='$ViewCurrentMultipliersHelp'),
      mcm.control.spacer(lines=1),

      mcm.control.section(text='$Uses'),
      mcm.control.button(text='$ViewNumberOfUsesRemainingText', action=mcm.helper.action.call_function(mod.quest_form, 'ShowNumberOfUsesLeft', script_name=mod.control_script), help='$ViewNumberOfUsesRemainingHelp'),
    ],
    [mcm.field.pages]: [
      {
        [mcm.field.page_display_name]: '$Settings',
        [mcm.field.content]: [
          // settings - general options
          mcm.control.section(text='$GeneralOptions'),
          mcm.control.slider(text='$MultBaseText', min=0.0, max=2.0, step=0.01, source=mcm.helper.source.mod_setting.float(id='fMultBase:GeneralOptions'), help='$MultBaseHelp'),
          mcm.control.switcher(text='$ReturnAtLeastOneComponentText', source=mcm.helper.source.mod_setting.bool(id='bReturnAtLeastOneComponent:GeneralOptions'), help='$ReturnAtLeastOneComponentHelp'),
          mcm.control.dropdown(text='$FractionalComponentHandlingText', options=['$RoundUp', '$RoundNormally', '$RoundDown'], source=mcm.helper.source.mod_setting.int(id='iFractionalComponentHandling:GeneralOptions'), help='$FractionalComponentHandlingHelp'),
          mcm.control.switcher(text='$HasLimitedUsesText', source=mcm.helper.source.mod_setting.bool(id='bHasLimitedUses:GeneralOptions'), help='$HasLimitedUsesHelp'),
          mcm.control.slider(text='$IndentNumberOfUsesText', min=1, max=200, step=1, source=mcm.helper.source.mod_setting.int(id='iNumberOfUses:GeneralOptions'), help='$NumberOfUsesHelp'),
          mcm.control.spacer(lines=1),

          // settings - adjustment options
          mcm.control.section(text='$AdjustmentOptions'),
          mcm.control.dropdown(text='$GeneralAdjustmentsText', options=['$Simple', '$Detailed'], source=mcm.helper.source.mod_setting.int(id='iGeneralMultAdjust:AdjustmentOptions'), help='$GeneralAdjustmentsHelp'),
          mcm.control.dropdown(text='$IntelligenceAffectsMultiplierText', options=['$OFF', '$ONSimple', '$ONDetailed'], source=mcm.helper.source.mod_setting.int(id='iIntAffectsMult:AdjustmentOptions'), help='$IntelligenceAffectsMultiplierHelp'),
          mcm.control.dropdown(text='$LuckAffectsMultiplierText', options=['$OFF', '$ONSimple', '$ONDetailed'], source=mcm.helper.source.mod_setting.int(id='iLckAffectsMult:AdjustmentOptions'), help='$LuckAffectsMultiplierHelp'),
          mcm.control.dropdown(text='$AddRandomnessToMultiplierText', options=['$OFF', '$ONSimple', '$ONDetailed'], source=mcm.helper.source.mod_setting.int(id='iRngAffectsMult:AdjustmentOptions'), help='$AddRandomnessToMultiplierHelp'),
          mcm.control.dropdown(text='$ScrapperPerkAffectsMultiplierText', options=['$OFF', '$ONSimple', '$ONDetailed'], source=mcm.helper.source.mod_setting.int(id='iScrapperAffectsMult:AdjustmentOptions'), help='$ScrapperPerkAffectsMultiplierHelp'),
          mcm.control.spacer(lines=1),
        ],
      },
      {
        [mcm.field.page_display_name]: '$RecyclerInterface',
        [mcm.field.content]: [
          // recycler interface - behavior
          mcm.control.section(text='$Behavior'),
          mcm.control.switcher(text='$AutoRecyclingModeText', source=mcm.helper.source.mod_setting.bool(id='bAutoRecyclingMode:Behavior'), help='$AutoRecyclingModeHelp'),
          mcm.control.switcher(text='$AllowJunkOnlyText', source=mcm.helper.source.mod_setting.bool(id='bAllowJunkOnly:Behavior'), help='$AllowJunkOnlyHelp'),
          mcm.control.switcher(text='$AutoTransferJunkText', source=mcm.helper.source.mod_setting.bool(id='bAutoTransferJunk:Behavior'), help='$AutoTransferJunkHelp'),
          mcm.control.switcher(text='$UseAlwaysAutoTransferListText', source=mcm.helper.source.mod_setting.bool(id='bUseAlwaysAutoTransferList:Behavior'), help='$UseAlwaysAutoTransferListHelp'),
          mcm.control.switcher(text='$UseNeverAutoTransferListText', source=mcm.helper.source.mod_setting.bool(id='bUseNeverAutoTransferList:Behavior'), help='$UseNeverAutoTransferListHelp'),
          mcm.control.switcher(text='$AllowBehaviorOverridesText', source=mcm.helper.source.mod_setting.bool(id='bAllowBehaviorOverrides:Behavior'), help='$AllowBehaviorOverridesHelp'),
          mcm.control.switcher(text='$ReturnItemsSilentlyText', source=mcm.helper.source.mod_setting.bool(id='bReturnItemsSilently:Behavior'), help='$ReturnItemsSilentlyHelp'),
          mcm.control.spacer(lines=1),

          // recycler interface - crafting
          mcm.control.section(text='$Crafting'),
          mcm.control.dropdown(text='$CraftingStationText', options=['$Dynamic', '$UtilityWorkbenchSW', '$UtilityWorkbenchAWKCR', '$ChemistryStationVanilla'], source=mcm.helper.source.mod_setting.int(id='iCraftingStation:Crafting'), help='$CraftingStationHelp'),
          mcm.control.spacer(lines=1),

          // recycler interface - hotkeys
          mcm.control.section(text='$Hotkeys'),
          mcm.control.stepper(text='$BehaviorOverrideForceAutoRecyclingModeText', options=['$HotkeyCtrlShift'], help='$BehaviorOverrideForceAutoRecyclingModeHelp'),
          mcm.control.stepper(text='$BehaviorOverrideForceTransferJunkText', options=['$HotkeyShift'], help='$BehaviorOverrideForceTransferJunkHelp'),
          mcm.control.stepper(text='$BehaviorOverrideForceRetainJunkText', options=['$HotkeyCtrl'], help='$BehaviorOverrideForceRetainJunkHelp'),
          mcm.control.stepper(text='$EditAlwaysAutoTransferListText', options=['$HotkeyAltShift'], help='$EditAlwaysAutoTransferListHelp'),
          mcm.control.stepper(text='$EditNeverAutoTransferListText', options=['$HotkeyAltCtrl'], help='$EditNeverAutoTransferListHelp'),
        ],
      },
      {
        [mcm.field.page_display_name]: '$MultiplierAdjustments',
        [mcm.field.content]: [
          // multiplier adjustments - general
          mcm.control.hidden_switcher(source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_GeneralMultAdjustSimple', script_name=mod.control_script), group=mcm.helper.group.control(mod.group_id.general_mult_adjust_simple)),
          mcm.control.hidden_switcher(source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_GeneralMultAdjustDetailed', script_name=mod.control_script), group=mcm.helper.group.control(mod.group_id.general_mult_adjust_detailed)),

          mcm.control.section(text='$General', group=mcm.helper.group.condition.or([mod.group_id.general_mult_adjust_simple, mod.group_id.general_mult_adjust_detailed])),

          mcm.control.slider(text=str_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustGeneralSettlement:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_simple), help=''),
          mcm.control.slider(text=str_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustGeneralNotSettlement:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_simple), help=''),

          mcm.control.section(text=str_indent_comp_c, group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed),),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustGeneralSettlementC:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed), help=''),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustGeneralNotSettlementC:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed), help=''),
          mcm.control.section(text=str_indent_comp_u, group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed)),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustGeneralSettlementU:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed), help=''),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustGeneralNotSettlementU:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed), help=''),
          mcm.control.section(text=str_indent_comp_r, group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed)),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustGeneralSettlementR:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed), help=''),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustGeneralNotSettlementR:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed), help=''),
          mcm.control.section(text=str_indent_comp_s, group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed)),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustGeneralSettlementS:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed), help=''),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustGeneralNotSettlementS:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed), help=''),

          mcm.control.spacer(lines=1, group=mcm.helper.group.condition.or([mod.group_id.general_mult_adjust_simple, mod.group_id.general_mult_adjust_detailed])),

          // multiplier adjustments - intelligence
          mcm.control.hidden_switcher(source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_IntAffectsMultSimple', script_name=mod.control_script), group=mcm.helper.group.control(mod.group_id.int_affects_mult_simple)),
          mcm.control.hidden_switcher(source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_IntAffectsMultDetailed', script_name=mod.control_script), group=mcm.helper.group.control(mod.group_id.int_affects_mult_detailed)),

          mcm.control.section(text=str_int, group=mcm.helper.group.condition.or([mod.group_id.int_affects_mult_simple, mod.group_id.int_affects_mult_detailed])),

          mcm.control.slider(str_per_point_int, stat_adjust_min, stat_adjust_max, stat_adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustInt:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.int_affects_mult_simple)),

          mcm.control.section(text=str_indent_comp_c, group=mcm.helper.group.condition.or(mod.group_id.int_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_per_point_int, min=stat_adjust_min, max=stat_adjust_max, step=stat_adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustIntC:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.int_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_u, group=mcm.helper.group.condition.or(mod.group_id.int_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_per_point_int, min=stat_adjust_min, max=stat_adjust_max, step=stat_adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustIntU:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.int_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_r, group=mcm.helper.group.condition.or(mod.group_id.int_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_per_point_int, min=stat_adjust_min, max=stat_adjust_max, step=stat_adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustIntR:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.int_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_s, group=mcm.helper.group.condition.or(mod.group_id.int_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_per_point_int, min=stat_adjust_min, max=stat_adjust_max, step=stat_adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustIntS:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.int_affects_mult_detailed)),

          mcm.control.spacer(lines=1, group=mcm.helper.group.condition.or([mod.group_id.int_affects_mult_simple, mod.group_id.int_affects_mult_detailed])),

          // multiplier adjustments - luck
          mcm.control.hidden_switcher(source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_LckAffectsMultSimple', script_name=mod.control_script), group=mcm.helper.group.control(mod.group_id.lck_affects_mult_simple)),
          mcm.control.hidden_switcher(source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_LckAffectsMultDetailed', script_name=mod.control_script), group=mcm.helper.group.control(mod.group_id.lck_affects_mult_detailed)),

          mcm.control.section(text=str_lck, group=mcm.helper.group.condition.or([mod.group_id.lck_affects_mult_simple, mod.group_id.lck_affects_mult_detailed])),

          mcm.control.slider(text=str_per_point_lck, min=stat_adjust_min, max=stat_adjust_max, step=stat_adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustLck:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.lck_affects_mult_simple)),

          mcm.control.section(text=str_indent_comp_c, group=mcm.helper.group.condition.or(mod.group_id.lck_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_per_point_lck, min=stat_adjust_min, max=stat_adjust_max, step=stat_adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustLckC:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.lck_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_u, group=mcm.helper.group.condition.or(mod.group_id.lck_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_per_point_lck, min=stat_adjust_min, max=stat_adjust_max, step=stat_adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustLckU:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.lck_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_r, group=mcm.helper.group.condition.or(mod.group_id.lck_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_per_point_lck, min=stat_adjust_min, max=stat_adjust_max, step=stat_adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustLckR:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.lck_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_s, group=mcm.helper.group.condition.or(mod.group_id.lck_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_per_point_lck, min=stat_adjust_min, max=stat_adjust_max, step=stat_adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustLckS:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.lck_affects_mult_detailed)),

          mcm.control.spacer(lines=1, group=mcm.helper.group.condition.or([mod.group_id.lck_affects_mult_simple, mod.group_id.lck_affects_mult_detailed])),

          // multiplier adjustments - randomness
          mcm.control.hidden_switcher(source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_RngAffectsMultSimple', script_name=mod.control_script), group=mcm.helper.group.control(mod.group_id.rng_affects_mult_simple)),
          mcm.control.hidden_switcher(source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_RngAffectsMultDetailed', script_name=mod.control_script), group=mcm.helper.group.control(mod.group_id.rng_affects_mult_detailed)),

          mcm.control.section(text='Randomness', group=mcm.helper.group.condition.or([mod.group_id.rng_affects_mult_simple, mod.group_id.rng_affects_mult_detailed])),

          mcm.control.slider(text=str_min, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustRandomMin:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_simple)),
          mcm.control.slider(text=str_max, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustRandomMax:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_simple)),

          mcm.control.section(text=str_indent_comp_c, group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_min, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustRandomMinC:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_max, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustRandomMaxC:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_u, group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_min, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustRandomMinU:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_max, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustRandomMaxU:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_r, group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_min, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustRandomMinR:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_max, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustRandomMaxR:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_s, group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_min, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustRandomMinS:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_max, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustRandomMaxS:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),

          mcm.control.spacer(lines=1, group=mcm.helper.group.condition.or([mod.group_id.rng_affects_mult_simple, mod.group_id.rng_affects_mult_detailed])),

          // multiplier adjustments - scrapper 1
          mcm.control.hidden_switcher(source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_ScrapperAffectsMultSimple', script_name=mod.control_script), group=mcm.helper.group.control(mod.group_id.scrapper_affects_mult_simple)),
          mcm.control.hidden_switcher(source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_ScrapperAffectsMultDetailed', script_name=mod.control_script), group=mcm.helper.group.control(mod.group_id.scrapper_affects_mult_detailed)),

          mcm.control.section(text='Scrapper: Rank 1', group=mcm.helper.group.condition.or([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_affects_mult_detailed])),

          mcm.control.slider(text=str_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlement1:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_simple)),
          mcm.control.slider(text=str_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlement1:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_simple)),

          mcm.control.section(text=str_indent_comp_c, group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementC1:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementC1:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_u, group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementU1:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementU1:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_r, group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementR1:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementR1:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_s, group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementS1:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementS1:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),

          mcm.control.spacer(lines=1, group=mcm.helper.group.condition.or([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_affects_mult_detailed])),

          // multiplier adjustments - scrapper 2
          mcm.control.section(text='Scrapper: Rank 2', group=mcm.helper.group.condition.or([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_affects_mult_detailed])),

          mcm.control.slider(text=str_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlement2:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_simple)),
          mcm.control.slider(text=str_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlement2:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_simple)),

          mcm.control.section(text=str_indent_comp_c, group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementC2:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementC2:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_u, group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementU2:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementU2:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_r, group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementR2:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementR2:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_s, group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementS2:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementS2:MultiplierAdjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),

          mcm.control.spacer(lines=1, group=mcm.helper.group.condition.or([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_affects_mult_detailed])),

          // multiplier adjustments - scrapper 3
          mcm.control.hidden_switcher(group=mcm.helper.group.control(mod.group_id.scrapper_3_available), source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_Scrapper3Available', script_name=mod.control_script)),

          mcm.control.section(text='Scrapper: Rank 3', group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_3_available])),
          mcm.control.slider(text=str_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlement3:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_3_available])),
          mcm.control.slider(text=str_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlement3:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_3_available])),
          mcm.control.spacer(lines=1, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_3_available, mod.group_id.scrapper_4_available])),

          mcm.control.section(text='Scrapper: Rank 3', group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.section(text=str_indent_comp_c, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementC3:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementC3:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.section(text=str_indent_comp_u, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementU3:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementU3:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.section(text=str_indent_comp_r, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementR3:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementR3:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.section(text=str_indent_comp_s, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementS3:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementS3:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.spacer(lines=1, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available, mod.group_id.scrapper_4_available])),

          // multiplier adjustments - scrapper 4
          mcm.control.hidden_switcher(group=mcm.helper.group.control(mod.group_id.scrapper_4_available), source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_Scrapper4Available', script_name=mod.control_script)),

          mcm.control.section(text='Scrapper: Rank 4', group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_4_available])),
          mcm.control.slider(text=str_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlement4:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_4_available])),
          mcm.control.slider(text=str_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlement4:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_4_available])),
          mcm.control.spacer(lines=1, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_4_available, mod.group_id.scrapper_5_available])),

          mcm.control.section(text='Scrapper: Rank 4', group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.section(text=str_indent_comp_c, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementC4:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementC4:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.section(text=str_indent_comp_u, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementU4:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementU4:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.section(text=str_indent_comp_r, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementR4:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementR4:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.section(text=str_indent_comp_s, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementS4:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementS4:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.spacer(lines=1, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available, mod.group_id.scrapper_5_available])),

          // multiplier adjustments - scrapper 5
          mcm.control.hidden_switcher(group=mcm.helper.group.control(mod.group_id.scrapper_5_available), source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_Scrapper5Available', script_name=mod.control_script)),

          mcm.control.section(text='Scrapper: Rank 5', group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_5_available])),
          mcm.control.slider(text=str_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlement5:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_5_available])),
          mcm.control.slider(text=str_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlement5:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_5_available])),
          //mcm.control.spacer(lines=1, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_5_available])),

          mcm.control.section(text='Scrapper: Rank 5', group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.section(text=str_indent_comp_c, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementC5:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementC5:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.section(text=str_indent_comp_u, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementU5:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementU5:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.section(text=str_indent_comp_r, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementR5:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementR5:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.section(text=str_indent_comp_s, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementS5:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementS5:MultiplierAdjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          //mcm.control.spacer(lines=1, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
        ],
      },
      {
        [mcm.field.page_display_name]: '$Advanced',
        [mcm.field.content]: [
          // advanced - reset settings to default
          mcm.control.section(text='$Settings'),
          mcm.control.button(text='$ResetSettingsToDefaultsText', action=mcm.helper.action.call_function(form=mod.quest_form, function_name='ResetToDefaults', script_name=mod.control_script), help='$ResetSettingsToDefaultsHelp'),
          mcm.control.spacer(lines=1),

          // advanced - reset mutexes
          mcm.control.section(text='$Locks'),
          mcm.control.button(text='$ResetLocksText', action=mcm.helper.action.call_function(form=mod.quest_form, function_name='ResetMutexes', script_name=mod.control_script), help='$ResetLocksHelp'),
          mcm.control.spacer(lines=1),

          // advanced - reset item lists
          mcm.control.section(text='$ItemLists'),
          mcm.control.button(text='$ResetRecyclableItemListText', action=mcm.helper.action.call_function(form=mod.quest_form, function_name='ResetRecyclableItemList', script_name=mod.control_script), help='$ResetRecyclableItemListHelp'),
          mcm.control.button(text='$ResetAlwaysAutoTransferListText', action=mcm.helper.action.call_function(form=mod.quest_form, function_name='ResetAlwaysAutoTransferList', script_name=mod.control_script), help='$ResetAlwaysAutoTransferListHelp'),
          mcm.control.button(text='$ResetNeverAutoTransferListText', action=mcm.helper.action.call_function(form=mod.quest_form, function_name='ResetNeverAutoTransferList', script_name=mod.control_script), help='$ResetNeverAutoTransferListHelp'),
          mcm.control.spacer(lines=1),

          // advanced - uninstall
          mcm.control.section(text='$Uninstall'),
          mcm.control.switcher(text='$ShowUninstallModButtonText', group=mcm.helper.group.control(mod.group_id.uninstall_safeguard), help='$ShowUninstallModButtonHelp'),
          mcm.control.button(text='$UninstallModText', action=mcm.helper.action.call_function(form=mod.quest_form, function_name='Uninstall', script_name=mod.control_script), help='$UninstallModHelp', group=mcm.helper.group.condition.or(mod.group_id.uninstall_safeguard)),
        ],
      },
    ],
  },
}
