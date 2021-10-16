local mcm = import 'lib/mcm.libsonnet';

local mod_name = 'Portable Junk Recycler Mk 2';
local mod_version = '0.3.1 beta';
local plugin_name = mod_name + '.esp';
local quest_form = plugin_name + '|800';
local min_mcm_version = 2;

local grp_general_mult_adjust_simple = 1;
local grp_general_mult_adjust_detailed = 2;
local grp_int_affects_mult_simple = 3;
local grp_int_affects_mult_detailed = 4;
local grp_lck_affects_mult_simple = 5;
local grp_lck_affects_mult_detailed = 6;
local grp_rng_affects_mult_simple = 7;
local grp_rng_affects_mult_detailed = 8;
local grp_scrapper_affects_mult_simple = 9;
local grp_scrapper_affects_mult_detailed = 10;
local grp_scrapper_3_available = 11;
local grp_scrapper_4_available = 12;
local grp_scrapper_5_available = 13;

local str_comp = 'Components: ';
local str_comp_c = str_comp + 'Common';
local str_comp_u = str_comp + 'Uncommon';
local str_comp_r = str_comp + 'Rare';
local str_comp_s = str_comp + 'Special';
local str_settlement = 'In Player-Owned Settlements';
local str_not_settlement = 'Everywhere Else';
local str_indent = '    ';
local str_per_point = 'Adjustment Per Point Of ';
local str_int = 'Intelligence';
local str_lck = 'Luck';
local str_per_point_int = str_per_point + str_int;
local str_per_point_lck = str_per_point + str_lck;
local str_min = 'Minimum';
local str_max = 'Maximum';

local adjust_min = -1.0;
local adjust_max = 1.0;
local adjust_step = 0.01;
local stat_adjust_min = 0.0;
local stat_adjust_max = 1.0;
local stat_adjust_step = 0.005;

{
  [mcm.field.mod_name]: mod_name,
  [mcm.field.display_name]: mod_name,
  [mcm.field.min_mcm_version]: min_mcm_version,
  [mcm.field.plugin_requirements]: [plugin_name],
  [mcm.field.content]: [
    mcm.control.text('<p align="center"><font size="24">' + mod_name + '</font></p>', html=true),
    mcm.control.text('<p align="center">by rux616</p>', html=true),
    mcm.control.text('<p align="center">v' + mod_version + '</p>', html=true),
    mcm.control.spacer(lines=1),

    mcm.control.section('About'),
    mcm.control.text(''),
    mcm.control.spacer(lines=1),

    mcm.control.section('Multipliers'),
    mcm.control.button(
      text='View Current Multipliers',
      action=mcm.helper.action.call_function(quest_form, 'MCM_ShowCurrentMultipliers'),
      help='When the Pause Menu is closed, a message box will open displaying the current multipliers.'
    ),
    mcm.control.spacer(lines=1),

    mcm.control.section('Uses'),
    mcm.control.button(
      text='View Number Of Uses Remaining',
      action=mcm.helper.action.call_function(quest_form, 'MCM_ShowNumberOfUsesLeft'),
      help='When the Pause Menu is closed, a message box will open displaying the number of uses left.'
    ),
  ],
  [mcm.field.pages]: [
    {
      [mcm.field.page_display_name]: 'Settings',
      [mcm.field.content]: [
        // settings - general options
        mcm.control.section('General Options'),
        mcm.control.slider(
          text='Base Multiplier',
          min=0.0,
          max=2.0,
          step=0.01,
          source=mcm.helper.source.mod_setting.float('fMultBase:General'),
          help=''
        ),
        mcm.control.switcher(
          text='Always Return At Least One Component',
          source=mcm.helper.source.mod_setting.bool('bReturnAtLeastOneComponent:General'),
          help=''
        ),
        mcm.control.dropdown(
          text='Fractional Component Handling',
          options=['Round Up', 'Round Normally', 'Round Down'],
          source=mcm.helper.source.mod_setting.int('iFractionalComponentHandling:General'),
          help=''
        ),
        mcm.control.switcher(
          text='Has Limited Uses',
          source=mcm.helper.source.mod_setting.bool('bHasLimitedUses:General'),
          help=''
        ),
        mcm.control.slider(
          text=str_indent + 'Number Of Uses',
          min=1,
          max=200,
          step=1,
          source=mcm.helper.source.mod_setting.int('iNumberOfUses:General'),
          help=''
        ),
        mcm.control.switcher(
          text='Return Items Silently',
          source=mcm.helper.source.mod_setting.bool('bReturnItemsSilently:General'),
          help=''
        ),
        mcm.control.spacer(lines=1),

        // settings - adjustment options
        mcm.control.section('Adjustment Options'),
        mcm.control.dropdown('General Adjustments', ['Simple', 'Detailed'], mcm.helper.source.mod_setting.int('iGeneralMultAdjust:General')),
        mcm.control.dropdown('Intelligence Affects Multiplier', ['OFF', 'ON (Simple)', 'ON (Detailed)'], mcm.helper.source.mod_setting.int('iIntAffectsMult:General')),
        mcm.control.dropdown('Luck Affects Multiplier', ['OFF', 'ON (Simple)', 'ON (Detailed)'], mcm.helper.source.mod_setting.int('iLckAffectsMult:General')),
        mcm.control.dropdown('Add Randomness To Multiplier', ['OFF', 'ON (Simple)', 'ON (Detailed)'], mcm.helper.source.mod_setting.int('iRngAffectsMult:General')),
        mcm.control.dropdown('Scrapper Perk Affects Multiplier', ['OFF', 'ON (Simple)', 'ON (Detailed)'], mcm.helper.source.mod_setting.int('iScrapperAffectsMult:General')),
      ],
    },
    {
      [mcm.field.page_display_name]: 'Multiplier Adjustments',
      [mcm.field.content]: [
        // multiplier adjustments - general
        mcm.control.hidden_switcher(mcm.helper.source.property_value.bool(quest_form, 'MCM_GeneralMultAdjustSimple'), mcm.helper.group.control(grp_general_mult_adjust_simple)),
        mcm.control.hidden_switcher(mcm.helper.source.property_value.bool(quest_form, 'MCM_GeneralMultAdjustDetailed'), mcm.helper.group.control(grp_general_mult_adjust_detailed)),

        mcm.control.section('General', mcm.helper.group.condition.or([grp_general_mult_adjust_simple, grp_general_mult_adjust_detailed])),

        mcm.control.slider(str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustGeneralSettlement:Adjustments'), mcm.helper.group.condition.or(grp_general_mult_adjust_simple)),
        mcm.control.slider(str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustGeneralNotSettlement:Adjustments'), mcm.helper.group.condition.or(grp_general_mult_adjust_simple)),

        mcm.control.section(str_indent + str_comp_c, mcm.helper.group.condition.or(grp_general_mult_adjust_detailed)),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustGeneralSettlementC:Adjustments'), mcm.helper.group.condition.or(grp_general_mult_adjust_detailed)),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustGeneralNotSettlementC:Adjustments'), mcm.helper.group.condition.or(grp_general_mult_adjust_detailed)),
        mcm.control.section(str_indent + str_comp_u, mcm.helper.group.condition.or(grp_general_mult_adjust_detailed)),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustGeneralSettlementU:Adjustments'), mcm.helper.group.condition.or(grp_general_mult_adjust_detailed)),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustGeneralNotSettlementU:Adjustments'), mcm.helper.group.condition.or(grp_general_mult_adjust_detailed)),
        mcm.control.section(str_indent + str_comp_r, mcm.helper.group.condition.or(grp_general_mult_adjust_detailed)),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustGeneralSettlementR:Adjustments'), mcm.helper.group.condition.or(grp_general_mult_adjust_detailed)),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustGeneralNotSettlementR:Adjustments'), mcm.helper.group.condition.or(grp_general_mult_adjust_detailed)),
        mcm.control.section(str_indent + str_comp_s, mcm.helper.group.condition.or(grp_general_mult_adjust_detailed)),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustGeneralSettlementS:Adjustments'), mcm.helper.group.condition.or(grp_general_mult_adjust_detailed)),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustGeneralNotSettlementS:Adjustments'), mcm.helper.group.condition.or(grp_general_mult_adjust_detailed)),

        mcm.control.spacer(lines=1, group=mcm.helper.group.condition.or([grp_general_mult_adjust_simple, grp_general_mult_adjust_detailed])),

        // multiplier adjustments - intelligence
        mcm.control.hidden_switcher(mcm.helper.source.property_value.bool(quest_form, 'MCM_IntAffectsMultSimple'), mcm.helper.group.control(grp_int_affects_mult_simple)),
        mcm.control.hidden_switcher(mcm.helper.source.property_value.bool(quest_form, 'MCM_IntAffectsMultDetailed'), mcm.helper.group.control(grp_int_affects_mult_detailed)),

        mcm.control.section(str_int, mcm.helper.group.condition.or([grp_int_affects_mult_simple, grp_int_affects_mult_detailed])),

        mcm.control.slider(str_per_point_int, stat_adjust_min, stat_adjust_max, stat_adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustInt:Adjustments'), mcm.helper.group.condition.or(grp_int_affects_mult_simple)),

        mcm.control.section(str_indent + str_comp_c, mcm.helper.group.condition.or(grp_int_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_per_point_int, stat_adjust_min, stat_adjust_max, stat_adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustIntC:Adjustments'), mcm.helper.group.condition.or(grp_int_affects_mult_detailed)),
        mcm.control.section(str_indent + str_comp_u, mcm.helper.group.condition.or(grp_int_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_per_point_int, stat_adjust_min, stat_adjust_max, stat_adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustIntU:Adjustments'), mcm.helper.group.condition.or(grp_int_affects_mult_detailed)),
        mcm.control.section(str_indent + str_comp_r, mcm.helper.group.condition.or(grp_int_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_per_point_int, stat_adjust_min, stat_adjust_max, stat_adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustIntR:Adjustments'), mcm.helper.group.condition.or(grp_int_affects_mult_detailed)),
        mcm.control.section(str_indent + str_comp_s, mcm.helper.group.condition.or(grp_int_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_per_point_int, stat_adjust_min, stat_adjust_max, stat_adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustIntS:Adjustments'), mcm.helper.group.condition.or(grp_int_affects_mult_detailed)),

        mcm.control.spacer(lines=1, group=mcm.helper.group.condition.or([grp_int_affects_mult_simple, grp_int_affects_mult_detailed])),

        // multiplier adjustments - luck
        mcm.control.hidden_switcher(mcm.helper.source.property_value.bool(quest_form, 'MCM_LckAffectsMultSimple'), mcm.helper.group.control(grp_lck_affects_mult_simple)),
        mcm.control.hidden_switcher(mcm.helper.source.property_value.bool(quest_form, 'MCM_LckAffectsMultDetailed'), mcm.helper.group.control(grp_lck_affects_mult_detailed)),

        mcm.control.section(str_lck, mcm.helper.group.condition.or([grp_lck_affects_mult_simple, grp_lck_affects_mult_detailed])),

        mcm.control.slider(str_per_point + str_lck, stat_adjust_min, stat_adjust_max, stat_adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustLck:Adjustments'), mcm.helper.group.condition.or(grp_lck_affects_mult_simple)),

        mcm.control.section(str_indent + str_comp_c, mcm.helper.group.condition.or(grp_lck_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_per_point_lck, stat_adjust_min, stat_adjust_max, stat_adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustLckC:Adjustments'), mcm.helper.group.condition.or(grp_lck_affects_mult_detailed)),
        mcm.control.section(str_indent + str_comp_u, mcm.helper.group.condition.or(grp_lck_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_per_point_lck, stat_adjust_min, stat_adjust_max, stat_adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustLckU:Adjustments'), mcm.helper.group.condition.or(grp_lck_affects_mult_detailed)),
        mcm.control.section(str_indent + str_comp_r, mcm.helper.group.condition.or(grp_lck_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_per_point_lck, stat_adjust_min, stat_adjust_max, stat_adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustLckR:Adjustments'), mcm.helper.group.condition.or(grp_lck_affects_mult_detailed)),
        mcm.control.section(str_indent + str_comp_s, mcm.helper.group.condition.or(grp_lck_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_per_point_lck, stat_adjust_min, stat_adjust_max, stat_adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustLckS:Adjustments'), mcm.helper.group.condition.or(grp_lck_affects_mult_detailed)),

        mcm.control.spacer(lines=1, group=mcm.helper.group.condition.or([grp_lck_affects_mult_simple, grp_lck_affects_mult_detailed])),

        // multiplier adjustments - randomness
        mcm.control.hidden_switcher(mcm.helper.source.property_value.bool(quest_form, 'MCM_RngAffectsMultSimple'), mcm.helper.group.control(grp_rng_affects_mult_simple)),
        mcm.control.hidden_switcher(mcm.helper.source.property_value.bool(quest_form, 'MCM_RngAffectsMultDetailed'), mcm.helper.group.control(grp_rng_affects_mult_detailed)),

        mcm.control.section('Randomness', mcm.helper.group.condition.or([grp_rng_affects_mult_simple, grp_rng_affects_mult_detailed])),

        mcm.control.slider(str_min, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustRandomMin:Adjustments'), mcm.helper.group.condition.or(grp_rng_affects_mult_simple)),
        mcm.control.slider(str_max, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustRandomMax:Adjustments'), mcm.helper.group.condition.or(grp_rng_affects_mult_simple)),

        mcm.control.section(str_indent + str_comp_c, mcm.helper.group.condition.or(grp_rng_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_min, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustRandomMinC:Adjustments'), mcm.helper.group.condition.or(grp_rng_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_max, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustRandomMaxC:Adjustments'), mcm.helper.group.condition.or(grp_rng_affects_mult_detailed)),
        mcm.control.section(str_indent + str_comp_u, mcm.helper.group.condition.or(grp_rng_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_min, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustRandomMinU:Adjustments'), mcm.helper.group.condition.or(grp_rng_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_max, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustRandomMaxU:Adjustments'), mcm.helper.group.condition.or(grp_rng_affects_mult_detailed)),
        mcm.control.section(str_indent + str_comp_r, mcm.helper.group.condition.or(grp_rng_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_min, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustRandomMinR:Adjustments'), mcm.helper.group.condition.or(grp_rng_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_max, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustRandomMaxR:Adjustments'), mcm.helper.group.condition.or(grp_rng_affects_mult_detailed)),
        mcm.control.section(str_indent + str_comp_s, mcm.helper.group.condition.or(grp_rng_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_min, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustRandomMinS:Adjustments'), mcm.helper.group.condition.or(grp_rng_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_max, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustRandomMaxS:Adjustments'), mcm.helper.group.condition.or(grp_rng_affects_mult_detailed)),

        mcm.control.spacer(lines=1, group=mcm.helper.group.condition.or([grp_rng_affects_mult_simple, grp_rng_affects_mult_detailed])),

        // multiplier adjustments - scrapper 1
        mcm.control.hidden_switcher(mcm.helper.source.property_value.bool(quest_form, 'MCM_ScrapperAffectsMultSimple'), mcm.helper.group.control(grp_scrapper_affects_mult_simple)),
        mcm.control.hidden_switcher(mcm.helper.source.property_value.bool(quest_form, 'MCM_ScrapperAffectsMultDetailed'), mcm.helper.group.control(grp_scrapper_affects_mult_detailed)),

        mcm.control.section('Scrapper: Rank 1', mcm.helper.group.condition.or([grp_scrapper_affects_mult_simple, grp_scrapper_affects_mult_detailed])),

        mcm.control.slider(str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlement1:Adjustments'), mcm.helper.group.condition.or(grp_scrapper_affects_mult_simple)),
        mcm.control.slider(str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlement1:Adjustments'), mcm.helper.group.condition.or(grp_scrapper_affects_mult_simple)),

        mcm.control.section(str_indent + str_comp_c, mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlementC1:Adjustments'), mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlementC1:Adjustments'), mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),
        mcm.control.section(str_indent + str_comp_u, mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlementU1:Adjustments'), mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlementU1:Adjustments'), mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),
        mcm.control.section(str_indent + str_comp_r, mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlementR1:Adjustments'), mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlementR1:Adjustments'), mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),
        mcm.control.section(str_indent + str_comp_s, mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlementS1:Adjustments'), mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlementS1:Adjustments'), mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),

        mcm.control.spacer(lines=1, group=mcm.helper.group.condition.or([grp_scrapper_affects_mult_simple, grp_scrapper_affects_mult_detailed])),

        // multiplier adjustments - scrapper 2
        mcm.control.section('Scrapper: Rank 2', mcm.helper.group.condition.or([grp_scrapper_affects_mult_simple, grp_scrapper_affects_mult_detailed])),

        mcm.control.slider(str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlement2:Adjustments'), mcm.helper.group.condition.or(grp_scrapper_affects_mult_simple)),
        mcm.control.slider(str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlement2:Adjustments'), mcm.helper.group.condition.or(grp_scrapper_affects_mult_simple)),

        mcm.control.section(str_indent + str_comp_c, mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlementC2:Adjustments'), mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlementC2:Adjustments'), mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),
        mcm.control.section(str_indent + str_comp_u, mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlementU2:Adjustments'), mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlementU2:Adjustments'), mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),
        mcm.control.section(str_indent + str_comp_r, mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlementR2:Adjustments'), mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlementR2:Adjustments'), mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),
        mcm.control.section(str_indent + str_comp_s, mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlementS2:Adjustments'), mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlementS2:Adjustments'), mcm.helper.group.condition.or(grp_scrapper_affects_mult_detailed)),

        mcm.control.spacer(lines=1, group=mcm.helper.group.condition.or([grp_scrapper_affects_mult_simple, grp_scrapper_affects_mult_detailed])),

        // multiplier adjustments - scrapper 3
        mcm.control.hidden_switcher(mcm.helper.group.control(grp_scrapper_3_available), mcm.helper.source.property_value.bool(quest_form, 'MCM_Scrapper3Available')),

        mcm.control.section('Scrapper: Rank 3', mcm.helper.group.condition.and([grp_scrapper_affects_mult_simple, grp_scrapper_3_available])),
        mcm.control.slider(str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlement3:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_simple, grp_scrapper_3_available])),
        mcm.control.slider(str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlement3:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_simple, grp_scrapper_3_available])),
        mcm.control.spacer(lines=1, group=mcm.helper.group.condition.and([grp_scrapper_affects_mult_simple, grp_scrapper_3_available])),

        mcm.control.section('Scrapper: Rank 3', mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_3_available])),
        mcm.control.section(str_indent + str_comp_c, mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_3_available])),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlementC3:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_3_available])),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlementC3:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_3_available])),
        mcm.control.section(str_indent + str_comp_u, mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_3_available])),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlementU3:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_3_available])),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlementU3:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_3_available])),
        mcm.control.section(str_indent + str_comp_r, mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_3_available])),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlementR3:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_3_available])),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlementR3:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_3_available])),
        mcm.control.section(str_indent + str_comp_s, mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_3_available])),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlementS3:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_3_available])),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlementS3:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_3_available])),
        mcm.control.spacer(lines=1, group=mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_3_available])),

        // multiplier adjustments - scrapper 4
        mcm.control.hidden_switcher(mcm.helper.group.control(grp_scrapper_4_available), mcm.helper.source.property_value.bool(quest_form, 'MCM_Scrapper4Available')),

        mcm.control.section('Scrapper: Rank 4', mcm.helper.group.condition.and([grp_scrapper_affects_mult_simple, grp_scrapper_4_available])),
        mcm.control.slider(str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlement4:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_simple, grp_scrapper_4_available])),
        mcm.control.slider(str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlement4:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_simple, grp_scrapper_4_available])),
        mcm.control.spacer(lines=1, group=mcm.helper.group.condition.and([grp_scrapper_affects_mult_simple, grp_scrapper_4_available])),

        mcm.control.section('Scrapper: Rank 4', mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_4_available])),
        mcm.control.section(str_indent + str_comp_c, mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_4_available])),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlementC4:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_4_available])),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlementC4:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_4_available])),
        mcm.control.section(str_indent + str_comp_u, mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_4_available])),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlementU4:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_4_available])),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlementU4:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_4_available])),
        mcm.control.section(str_indent + str_comp_r, mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_4_available])),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlementR4:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_4_available])),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlementR4:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_4_available])),
        mcm.control.section(str_indent + str_comp_s, mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_4_available])),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlementS4:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_4_available])),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlementS4:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_4_available])),
        mcm.control.spacer(lines=1, group=mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_4_available])),

        // multiplier adjustments - scrapper 5
        mcm.control.hidden_switcher(mcm.helper.group.control(grp_scrapper_5_available), mcm.helper.source.property_value.bool(quest_form, 'MCM_Scrapper5Available')),

        mcm.control.section('Scrapper: Rank 5', mcm.helper.group.condition.and([grp_scrapper_affects_mult_simple, grp_scrapper_5_available])),
        mcm.control.slider(str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlement5:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_simple, grp_scrapper_5_available])),
        mcm.control.slider(str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlement5:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_simple, grp_scrapper_5_available])),
        mcm.control.spacer(lines=1, group=mcm.helper.group.condition.and([grp_scrapper_affects_mult_simple, grp_scrapper_5_available])),

        mcm.control.section('Scrapper: Rank 5', mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_5_available])),
        mcm.control.section(str_indent + str_comp_c, mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_5_available])),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlementC5:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_5_available])),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlementC5:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_5_available])),
        mcm.control.section(str_indent + str_comp_u, mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_5_available])),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlementU5:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_5_available])),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlementU5:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_5_available])),
        mcm.control.section(str_indent + str_comp_r, mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_5_available])),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlementR5:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_5_available])),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlementR5:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_5_available])),
        mcm.control.section(str_indent + str_comp_s, mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_5_available])),
        mcm.control.slider(str_indent + str_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperSettlementS5:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_5_available])),
        mcm.control.slider(str_indent + str_not_settlement, adjust_min, adjust_max, adjust_step, mcm.helper.source.mod_setting.float('fMultAdjustScrapperNotSettlementS5:Adjustments'), mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_5_available])),
        mcm.control.spacer(lines=1, group=mcm.helper.group.condition.and([grp_scrapper_affects_mult_detailed, grp_scrapper_5_available])),
      ],
    },
    {
      [mcm.field.page_display_name]: 'Advanced',
      [mcm.field.content]: [
        // advanced - reset settings to default
        mcm.control.section('Settings'),
        mcm.control.button('Reset Settings to Defaults', mcm.helper.action.call_function(quest_form, 'MCM_ResetToDefaults')),
        mcm.control.spacer(lines=1),

        // advanced - reset mutexes
        mcm.control.section('Locks'),
        mcm.control.button('Reset Locks', mcm.helper.action.call_function(quest_form, 'MCM_ResetMutexes')),
      ],
    },
  ],
}
