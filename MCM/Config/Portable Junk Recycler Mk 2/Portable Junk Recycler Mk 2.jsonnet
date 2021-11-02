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
          mcm.control.slider(text='$MultBaseText', min=0.0, max=2.0, step=0.01, source=mcm.helper.source.mod_setting.float(id='fMultBase:General'), help='$MultBaseHelp'),
          mcm.control.switcher(text='$ReturnAtLeastOneComponentText', source=mcm.helper.source.mod_setting.bool(id='bReturnAtLeastOneComponent:General'), help='$ReturnAtLeastOneComponentHelp'),
          mcm.control.dropdown(text='$FractionalComponentHandlingText', options=['$RoundUp', '$RoundNormally', '$RoundDown'], source=mcm.helper.source.mod_setting.int(id='iFractionalComponentHandling:General'), help='$FractionalComponentHandlingHelp'),
          mcm.control.switcher(text='$HasLimitedUsesText', source=mcm.helper.source.mod_setting.bool(id='bHasLimitedUses:General'), help='$HasLimitedUsesHelp'),
          mcm.control.slider(text='$IndentNumberOfUsesText', min=1, max=200, step=1, source=mcm.helper.source.mod_setting.int(id='iNumberOfUses:General'), help='$NumberOfUsesHelp'),
          mcm.control.spacer(lines=1),

          // settings - adjustment options
          mcm.control.section(text='$AdjustmentOptions'),
          mcm.control.dropdown(text='$GeneralAdjustmentsText', options=['$Simple', '$Detailed'], source=mcm.helper.source.mod_setting.int(id='iGeneralMultAdjust:General'), help='$GeneralAdjustmentsHelp'),
          mcm.control.dropdown(text='$IntelligenceAffectsMultiplierText', options=['$OFF', '$ONSimple', '$ONDetailed'], source=mcm.helper.source.mod_setting.int(id='iIntAffectsMult:General'), help='$IntelligenceAffectsMultiplierHelp'),
          mcm.control.dropdown(text='$LuckAffectsMultiplierText', options=['$OFF', '$ONSimple', '$ONDetailed'], source=mcm.helper.source.mod_setting.int(id='iLckAffectsMult:General'), help='$LuckAffectsMultiplierHelp'),
          mcm.control.dropdown(text='$AddRandomnessToMultiplierText', options=['$OFF', '$ONSimple', '$ONDetailed'], source=mcm.helper.source.mod_setting.int(id='iRngAffectsMult:General'), help='$AddRandomnessToMultiplierHelp'),
          mcm.control.dropdown(text='$ScrapperPerkAffectsMultiplierText', options=['$OFF', '$ONSimple', '$ONDetailed'], source=mcm.helper.source.mod_setting.int(id='iScrapperAffectsMult:General'), help='$ScrapperPerkAffectsMultiplierHelp'),
          mcm.control.spacer(lines=1),
        ],
      },
      {
        [mcm.field.page_display_name]: '$RecyclerInterface',
        [mcm.field.content]: [
          // recycler interface - behavior
          mcm.control.section(text='$Behavior'),
          mcm.control.switcher(text='$AutoRecyclingModeText', source=mcm.helper.source.mod_setting.bool(id='bAutoRecyclingMode:General'), help='$AutoRecyclingModeHelp'),
          mcm.control.switcher(text='$AllowJunkOnlyText', source=mcm.helper.source.mod_setting.bool(id='bAllowJunkOnly:General'), help='$AllowJunkOnlyHelp'),
          mcm.control.switcher(text='$AutoTransferJunkText', source=mcm.helper.source.mod_setting.bool(id='bAutoTransferJunk:General'), help='$AutoTransferJunkHelp'),
          mcm.control.switcher(text='$AllowBehaviorOverridesText', source=mcm.helper.source.mod_setting.bool(id='bAllowBehaviorOverrides:General'), help='$AllowBehaviorOverridesHelp'),
          mcm.control.switcher(text='$ReturnItemsSilentlyText', source=mcm.helper.source.mod_setting.bool(id='bReturnItemsSilently:General'), help='$ReturnItemsSilentlyHelp'),
          mcm.control.spacer(lines=1),

          // recycler interface - hotkeys
          mcm.control.section(text='$Hotkeys'),
          mcm.control.stepper(text='$BehaviorOverrideForceTransferJunkText', options=['$HotkeyShift'], help='$BehaviorOverrideForceTransferJunkHelp'),
          mcm.control.stepper(text='$BehaviorOverrideForceRetainJunkText', options=['$HotkeyCtrl'], help='$BehaviorOverrideForceRetainJunkHelp'),
          mcm.control.stepper(text='$EditAlwaysAutoTransferText', options=['$HotkeyAltShift'], help='$EditAlwaysAutoTransferHelp'),
          mcm.control.stepper(text='$EditNeverAutoTransferText', options=['$HotkeyAltCtrl'], help='$EditNeverAutoTransferHelp'),
        ],
      },
      {
        [mcm.field.page_display_name]: '$MultiplierAdjustments',
        [mcm.field.content]: [
          // multiplier adjustments - general
          mcm.control.hidden_switcher(source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_GeneralMultAdjustSimple', script_name=mod.control_script), group=mcm.helper.group.control(mod.group_id.general_mult_adjust_simple)),
          mcm.control.hidden_switcher(source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_GeneralMultAdjustDetailed', script_name=mod.control_script), group=mcm.helper.group.control(mod.group_id.general_mult_adjust_detailed)),

          mcm.control.section(text='$General', group=mcm.helper.group.condition.or([mod.group_id.general_mult_adjust_simple, mod.group_id.general_mult_adjust_detailed])),

          mcm.control.slider(text=str_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustGeneralSettlement:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_simple), help=''),
          mcm.control.slider(text=str_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustGeneralNotSettlement:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_simple), help=''),

          mcm.control.section(text=str_indent_comp_c, group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed),),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustGeneralSettlementC:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed), help=''),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustGeneralNotSettlementC:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed), help=''),
          mcm.control.section(text=str_indent_comp_u, group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed)),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustGeneralSettlementU:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed), help=''),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustGeneralNotSettlementU:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed), help=''),
          mcm.control.section(text=str_indent_comp_r, group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed)),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustGeneralSettlementR:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed), help=''),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustGeneralNotSettlementR:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed), help=''),
          mcm.control.section(text=str_indent_comp_s, group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed)),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustGeneralSettlementS:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed), help=''),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustGeneralNotSettlementS:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.general_mult_adjust_detailed), help=''),

          mcm.control.spacer(lines=1, group=mcm.helper.group.condition.or([mod.group_id.general_mult_adjust_simple, mod.group_id.general_mult_adjust_detailed])),

          // multiplier adjustments - intelligence
          mcm.control.hidden_switcher(source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_IntAffectsMultSimple', script_name=mod.control_script), group=mcm.helper.group.control(mod.group_id.int_affects_mult_simple)),
          mcm.control.hidden_switcher(source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_IntAffectsMultDetailed', script_name=mod.control_script), group=mcm.helper.group.control(mod.group_id.int_affects_mult_detailed)),

          mcm.control.section(text=str_int, group=mcm.helper.group.condition.or([mod.group_id.int_affects_mult_simple, mod.group_id.int_affects_mult_detailed])),

          mcm.control.slider(str_per_point_int, stat_adjust_min, stat_adjust_max, stat_adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustInt:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.int_affects_mult_simple)),

          mcm.control.section(text=str_indent_comp_c, group=mcm.helper.group.condition.or(mod.group_id.int_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_per_point_int, min=stat_adjust_min, max=stat_adjust_max, step=stat_adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustIntC:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.int_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_u, group=mcm.helper.group.condition.or(mod.group_id.int_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_per_point_int, min=stat_adjust_min, max=stat_adjust_max, step=stat_adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustIntU:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.int_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_r, group=mcm.helper.group.condition.or(mod.group_id.int_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_per_point_int, min=stat_adjust_min, max=stat_adjust_max, step=stat_adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustIntR:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.int_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_s, group=mcm.helper.group.condition.or(mod.group_id.int_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_per_point_int, min=stat_adjust_min, max=stat_adjust_max, step=stat_adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustIntS:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.int_affects_mult_detailed)),

          mcm.control.spacer(lines=1, group=mcm.helper.group.condition.or([mod.group_id.int_affects_mult_simple, mod.group_id.int_affects_mult_detailed])),

          // multiplier adjustments - luck
          mcm.control.hidden_switcher(source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_LckAffectsMultSimple', script_name=mod.control_script), group=mcm.helper.group.control(mod.group_id.lck_affects_mult_simple)),
          mcm.control.hidden_switcher(source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_LckAffectsMultDetailed', script_name=mod.control_script), group=mcm.helper.group.control(mod.group_id.lck_affects_mult_detailed)),

          mcm.control.section(text=str_lck, group=mcm.helper.group.condition.or([mod.group_id.lck_affects_mult_simple, mod.group_id.lck_affects_mult_detailed])),

          mcm.control.slider(text=str_per_point_lck, min=stat_adjust_min, max=stat_adjust_max, step=stat_adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustLck:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.lck_affects_mult_simple)),

          mcm.control.section(text=str_indent_comp_c, group=mcm.helper.group.condition.or(mod.group_id.lck_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_per_point_lck, min=stat_adjust_min, max=stat_adjust_max, step=stat_adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustLckC:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.lck_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_u, group=mcm.helper.group.condition.or(mod.group_id.lck_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_per_point_lck, min=stat_adjust_min, max=stat_adjust_max, step=stat_adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustLckU:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.lck_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_r, group=mcm.helper.group.condition.or(mod.group_id.lck_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_per_point_lck, min=stat_adjust_min, max=stat_adjust_max, step=stat_adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustLckR:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.lck_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_s, group=mcm.helper.group.condition.or(mod.group_id.lck_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_per_point_lck, min=stat_adjust_min, max=stat_adjust_max, step=stat_adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustLckS:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.lck_affects_mult_detailed)),

          mcm.control.spacer(lines=1, group=mcm.helper.group.condition.or([mod.group_id.lck_affects_mult_simple, mod.group_id.lck_affects_mult_detailed])),

          // multiplier adjustments - randomness
          mcm.control.hidden_switcher(source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_RngAffectsMultSimple', script_name=mod.control_script), group=mcm.helper.group.control(mod.group_id.rng_affects_mult_simple)),
          mcm.control.hidden_switcher(source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_RngAffectsMultDetailed', script_name=mod.control_script), group=mcm.helper.group.control(mod.group_id.rng_affects_mult_detailed)),

          mcm.control.section(text='Randomness', group=mcm.helper.group.condition.or([mod.group_id.rng_affects_mult_simple, mod.group_id.rng_affects_mult_detailed])),

          mcm.control.slider(text=str_min, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustRandomMin:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_simple)),
          mcm.control.slider(text=str_max, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustRandomMax:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_simple)),

          mcm.control.section(text=str_indent_comp_c, group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_min, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustRandomMinC:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_max, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustRandomMaxC:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_u, group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_min, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustRandomMinU:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_max, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustRandomMaxU:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_r, group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_min, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustRandomMinR:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_max, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustRandomMaxR:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_s, group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_min, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustRandomMinS:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_max, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustRandomMaxS:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.rng_affects_mult_detailed)),

          mcm.control.spacer(lines=1, group=mcm.helper.group.condition.or([mod.group_id.rng_affects_mult_simple, mod.group_id.rng_affects_mult_detailed])),

          // multiplier adjustments - scrapper 1
          mcm.control.hidden_switcher(source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_ScrapperAffectsMultSimple', script_name=mod.control_script), group=mcm.helper.group.control(mod.group_id.scrapper_affects_mult_simple)),
          mcm.control.hidden_switcher(source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_ScrapperAffectsMultDetailed', script_name=mod.control_script), group=mcm.helper.group.control(mod.group_id.scrapper_affects_mult_detailed)),

          mcm.control.section(text='Scrapper: Rank 1', group=mcm.helper.group.condition.or([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_affects_mult_detailed])),

          mcm.control.slider(text=str_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlement1:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_simple)),
          mcm.control.slider(text=str_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlement1:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_simple)),

          mcm.control.section(text=str_indent_comp_c, group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementC1:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementC1:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_u, group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementU1:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementU1:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_r, group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementR1:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementR1:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_s, group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementS1:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementS1:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),

          mcm.control.spacer(lines=1, group=mcm.helper.group.condition.or([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_affects_mult_detailed])),

          // multiplier adjustments - scrapper 2
          mcm.control.section(text='Scrapper: Rank 2', group=mcm.helper.group.condition.or([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_affects_mult_detailed])),

          mcm.control.slider(text=str_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlement2:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_simple)),
          mcm.control.slider(text=str_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlement2:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_simple)),

          mcm.control.section(text=str_indent_comp_c, group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementC2:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementC2:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_u, group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementU2:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementU2:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_r, group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementR2:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementR2:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.section(text=str_indent_comp_s, group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementS2:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementS2:Adjustments'), group=mcm.helper.group.condition.or(mod.group_id.scrapper_affects_mult_detailed)),

          mcm.control.spacer(lines=1, group=mcm.helper.group.condition.or([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_affects_mult_detailed])),

          // multiplier adjustments - scrapper 3
          mcm.control.hidden_switcher(group=mcm.helper.group.control(mod.group_id.scrapper_3_available), source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_Scrapper3Available', script_name=mod.control_script)),

          mcm.control.section(text='Scrapper: Rank 3', group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_3_available])),
          mcm.control.slider(text=str_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlement3:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_3_available])),
          mcm.control.slider(text=str_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlement3:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_3_available])),
          mcm.control.spacer(lines=1, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_3_available, mod.group_id.scrapper_4_available])),

          mcm.control.section(text='Scrapper: Rank 3', group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.section(text=str_indent_comp_c, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementC3:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementC3:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.section(text=str_indent_comp_u, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementU3:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementU3:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.section(text=str_indent_comp_r, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementR3:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementR3:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.section(text=str_indent_comp_s, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementS3:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementS3:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available])),
          mcm.control.spacer(lines=1, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_3_available, mod.group_id.scrapper_4_available])),

          // multiplier adjustments - scrapper 4
          mcm.control.hidden_switcher(group=mcm.helper.group.control(mod.group_id.scrapper_4_available), source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_Scrapper4Available', script_name=mod.control_script)),

          mcm.control.section(text='Scrapper: Rank 4', group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_4_available])),
          mcm.control.slider(text=str_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlement4:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_4_available])),
          mcm.control.slider(text=str_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlement4:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_4_available])),
          mcm.control.spacer(lines=1, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_4_available, mod.group_id.scrapper_5_available])),

          mcm.control.section(text='Scrapper: Rank 4', group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.section(text=str_indent_comp_c, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementC4:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementC4:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.section(text=str_indent_comp_u, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementU4:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementU4:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.section(text=str_indent_comp_r, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementR4:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementR4:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.section(text=str_indent_comp_s, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementS4:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementS4:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available])),
          mcm.control.spacer(lines=1, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_4_available, mod.group_id.scrapper_5_available])),

          // multiplier adjustments - scrapper 5
          mcm.control.hidden_switcher(group=mcm.helper.group.control(mod.group_id.scrapper_5_available), source=mcm.helper.source.property_value.bool(source_form=mod.quest_form, property_name='MCM_Scrapper5Available', script_name=mod.control_script)),

          mcm.control.section(text='Scrapper: Rank 5', group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_5_available])),
          mcm.control.slider(text=str_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlement5:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_5_available])),
          mcm.control.slider(text=str_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlement5:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_5_available])),
          //mcm.control.spacer(lines=1, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_simple, mod.group_id.scrapper_5_available])),

          mcm.control.section(text='Scrapper: Rank 5', group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.section(text=str_indent_comp_c, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementC5:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementC5:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.section(text=str_indent_comp_u, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementU5:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementU5:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.section(text=str_indent_comp_r, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementR5:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementR5:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.section(text=str_indent_comp_s, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.slider(text=str_indent_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperSettlementS5:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          mcm.control.slider(text=str_indent_not_settlement, min=adjust_min, max=adjust_max, step=adjust_step, source=mcm.helper.source.mod_setting.float(id='fMultAdjustScrapperNotSettlementS5:Adjustments'), group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
          //mcm.control.spacer(lines=1, group=mcm.helper.group.condition.and([mod.group_id.scrapper_affects_mult_detailed, mod.group_id.scrapper_5_available])),
        ],
      },
      {
        [mcm.field.page_display_name]: '$Advanced',
        [mcm.field.content]: [
          // advanced - reset settings to default
          mcm.control.section(text='$Settings'),
          mcm.control.button(text='$ResetSettingsToDefaultsText', action=mcm.helper.action.call_function(mod.quest_form, 'ResetToDefaults', script_name=mod.control_script), help='$ResetSettingsToDefaultsHelp'),
          mcm.control.spacer(lines=1),

          // advanced - reset mutexes
          mcm.control.section(text='$Locks'),
          mcm.control.button(text='$ResetLocksText', action=mcm.helper.action.call_function(mod.quest_form, 'ResetMutexes', script_name=mod.control_script), help='$ResetLocksHelp'),
          mcm.control.spacer(lines=1),

          // advanced - clear junk items list
          mcm.control.section(text='$RecyclableItemList'),
          mcm.control.button(text='$ResetRecyclableItemListText', action=mcm.helper.action.call_function(mod.quest_form, 'ResetRecyclableItemList', script_name=mod.control_script), help='$ResetRecyclableItemListHelp'),
          mcm.control.spacer(lines=1),

          // advanced - reset behavior override flags
          mcm.control.section(text='$BehaviorOverrides'),
          mcm.control.button(text='$ResetBehaviorOverridesText', action=mcm.helper.action.call_function(mod.quest_form, 'ResetBehaviorOverrides', script_name=mod.control_script), help='$ResetBehaviorOverridesHelp'),
          mcm.control.spacer(lines=1),

          // advanced - uninstall
          mcm.control.section(text='$Uninstall'),
          mcm.control.switcher(text='$ShowUninstallModButtonText', group=mcm.helper.group.control(mod.group_id.uninstall_safeguard), help='$ShowUninstallModButtonHelp'),
          mcm.control.button(text='$UninstallModText', action=mcm.helper.action.call_function(mod.quest_form, 'Uninstall', script_name=mod.control_script), help='$UninstallModHelp', group=mcm.helper.group.condition.or(mod.group_id.uninstall_safeguard)),
        ],
      },
    ],
  },
}
