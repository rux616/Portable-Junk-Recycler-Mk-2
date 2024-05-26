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

{
  local base = {
    type: {
      action: {
        call_function: 'CallFunction',
        call_global_function: 'CallGlobalFunction',
        run_console_command: 'RunConsoleCommand',
        send_event: 'SendEvent',
      },

      control: {
        button: 'button',
        dropdown: 'dropdown',
        dropdown_files: 'dropdownFiles',
        hidden_switcher: 'hiddenSwitcher',
        hotkey: 'hotkey',
        image: 'image',
        keyinput: 'keyinput',
        positioner: 'positioner',
        section: 'section',
        slider: 'slider',
        spacer: 'spacer',
        stepper: 'stepper',
        switcher: 'switcher',
        text: 'text',
        text_input: 'textInput',
        text_input_float: 'textInputFloat',
        text_input_int: 'textInputInt',
      },

      source: {
        global_value: 'GlobalValue',
        mod_setting_bool: 'ModSettingBool',
        mod_setting_float: 'ModSettingFloat',
        mod_setting_int: 'ModSettingInt',
        mod_setting_string: 'ModSettingString',
        property_value_bool: 'PropertyValueBool',
        property_value_float: 'PropertyValueFloat',
        property_value_int: 'PropertyValueInt',
        property_value_string: 'PropertyValueString',
      },
    },

    condition_operator: {
      and: 'AND',
      only: 'ONLY',
      or: 'OR',
    },

    field: {
      action: 'action',
      allow_modifier_keys: 'allowModifierKeys',
      class_name: 'class_name',
      command: 'command',
      content: 'content',
      desc: 'desc',
      display_name: 'displayName',
      form: 'form',
      func: 'function',
      group_condition: 'groupCondition',
      group_control: 'groupControl',
      height: 'height',
      help: 'help',
      hide_if_missing_reqs: 'hideIfMissingReqs',
      html: 'html',
      id: 'id',
      keybinds: 'keybinds',
      lib_name: 'libName',
      lines: 'lines',
      max: 'max',
      min: 'min',
      min_mcm_version: 'minMcmVersion',
      mod_name: 'modName',
      options: 'options',
      page_display_name: 'pageDisplayName',
      pages: 'pages',
      params: 'params',
      plugin_requirements: 'pluginRequirements',
      property_name: 'propertyName',
      script: 'script',
      script_name: 'scriptName',
      source_form: 'sourceForm',
      source_type: 'sourceType',
      step: 'step',
      text: 'text',
      type: 'type',
      value_options: 'valueOptions',
    },
  },

  control: {
    local control_base(type, group=null, text=null, help=null) = {
      [base.field.type]: type,
      [if text != null then base.field.text else null]: text,
      [if help != null then base.field.help else null]: help,
    } + if group != null then group else {},

    button(text, action, group=null, help=null): control_base(
      type=base.type.control.button, group=group, text=text, help=help,
    ) + action,

    dropdown(text, options, source, group=null, help=null): control_base(
      type=base.type.control.dropdown, group=group, text=text, help=help,
    ) + source + {
      [base.field.value_options]+: {
        [base.field.options]: options,
      },
    },

    hidden_switcher(source, group): control_base(
      type=base.type.control.hidden_switcher, group=group
    ) + source,

    hotkey(text, id, allow_modifier_keys=null, group=null, help=null): control_base(
      type=base.type.control.hotkey, group=group, text=text, help=help
    ) + {
      [base.field.id]: id,
      [if allow_modifier_keys != null && (allow_modifier_keys == true || allow_modifier_keys == false) then base.field.value_options]: {
        [base.field.allow_modifier_keys]: allow_modifier_keys,
      },
    },

    image(lib_name, class_name, width=null, height=null, group=null, help=null): control_base(
      type=base.type.control.image, group=group, help=help
    ) + {
      [base.field.lib_name]: lib_name,
      [base.field.class_name]: class_name,
      [if width != null then base.field.width else null]: width,
      [if height != null then base.field.height else null]: height,
    },

    section(text, group=null, help=null):: control_base(
      type=base.type.control.section, group=group, text=text, help=help
    ),

    slider(text, min, max, step, source, group=null, help=null): control_base(
      type=base.type.control.slider, text=text, group=group, help=help
    ) + source + {
      [base.field.value_options]+: {
        [base.field.min]: min,
        [base.field.max]: max,
        [base.field.step]: step,
      },
    },

    spacer(lines=null, height=null, group=null, help=null): control_base(
      type=base.type.control.spacer, group=group, help=help
    ) + {
      [if lines != null then base.field.lines else null]: lines,
      [if height != null then base.field.height else null]: height,
    },

    stepper(text, options, source=null, group=null, help=null): control_base(
      type=base.type.control.stepper, text=text, group=group, help=help
    ) + if source != null then source else {} + {
      [base.field.value_options]+: {
        [base.field.options]: options,
      },
    },

    switcher(text, source=null, group=null, help=null): control_base(
      type=base.type.control.switcher, text=text, group=group, help=help
    ) + if source != null then source else {},

    text(text, html=false, group=null, help=null): control_base(
      type=base.type.control.text, text=text, group=group, help=help
    ) + {
      [if html then base.field.html else null]: html,
    },
  },

  field: {
    content: base.field.content,
    display_name: base.field.display_name,
    hide_if_missing_reqs: base.field.hide_if_missing_reqs,
    id: base.field.id,
    keybinds: base.field.keybinds,
    min_mcm_version: base.field.min_mcm_version,
    mod_name: base.field.mod_name,
    page_display_name: base.field.page_display_name,
    pages: base.field.pages,
    plugin_requirements: base.field.plugin_requirements,
  },

  helper: {
    action: {
      local action_base(type) = {
        [base.field.action]: {
          [base.field.type]: type,
        },
      },
      local function_base(type, function_name, params) = action_base(type) + {
        [base.field.action]+: {
          [base.field.func]: function_name,
          [if params != null then base.field.params else null]: params,
        },
      },
      // script_name isn't yet supported by the CallFunction type
      call_function(form, function_name, params=null, script_name=null): function_base(base.type.action.call_function, function_name, params) + {
        [base.field.action]+: {
          [base.field.form]: form,
          [if script_name != null then base.field.script_name else null]: script_name,
        },
      },
      call_global_function(script, function_name, params=null): function_base(base.type.action.call_global_function, function_name, params) + {
        [base.field.action]+: {
          [base.field.script]: script,
        },
      },
      run_console_command(command): action_base(base.type.action.run_console_command) + {
        [base.field.action]+: {
          [base.field.command]: command,
        },
      },
      send_event(form): action_base(base.type.action.send_event) + {
        [base.field.action]+: {
          [base.field.form]: form,
        },
      },
    },

    group: {
      control(group_id): {
        [base.field.group_control]: group_id,
      },
      condition: {
        local condition_base(group_ids, operator) = {
          [base.field.group_condition]: {
            [operator]: if std.isArray(group_ids) then group_ids else [group_ids],
          },
        },
        and(group_ids): condition_base(group_ids, base.condition_operator.and),
        only(group_ids): condition_base(group_ids, base.condition_operator.only),
        or(group_ids): condition_base(group_ids, base.condition_operator.or),
      },
    },

    source: {
      local source_type_base(source_type) = {
        [base.field.value_options]: {
          [base.field.source_type]: source_type,
        },
      },
      local source_type_form_base(source_type, source_form) = source_type_base(source_type) + {
        [base.field.value_options]+: {
          [base.field.source_form]: source_form,
        },
      },
      global_value(source_form): source_type_form_base(base.type.source.global_value, source_form),
      mod_setting: {
        local source_type_mod_setting_base(source_type, id) = source_type_base(source_type) + {
          [base.field.id]: id,
        },
        bool(id): source_type_mod_setting_base(base.type.source.mod_setting_bool, id),
        float(id): source_type_mod_setting_base(base.type.source.mod_setting_float, id),
        int(id): source_type_mod_setting_base(base.type.source.mod_setting_int, id),
        string(id): source_type_mod_setting_base(base.type.source.mod_setting_string, id),
      },
      property_value: {
        local source_type_property_value_base(source_type, source_form, property_name, script_name) = source_type_form_base(source_type, source_form) + {
          [base.field.value_options]+: {
            [base.field.property_name]: property_name,
            [if script_name != null then base.field.script_name else null]: script_name,
          },
        },
        bool(source_form, property_name, script_name=null): source_type_property_value_base(base.type.source.property_value_bool, source_form, property_name, script_name),
        float(source_form, property_name, script_name=null): source_type_property_value_base(base.type.source.property_value_float, source_form, property_name, script_name),
        int(source_form, property_name, script_name=null): source_type_property_value_base(base.type.source.property_value_int, source_form, property_name, script_name),
        string(source_form, property_name, script_name=null): source_type_property_value_base(base.type.source.property_value_string, source_form, property_name, script_name),
      },
    },
  },

  keybind(id, desc, action): {
    [base.field.id]: id,
    [base.field.desc]: desc,
  } + action,
}
