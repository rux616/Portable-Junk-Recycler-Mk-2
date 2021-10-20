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
      class_name: 'class_name',
      command: 'command',
      desc: 'desc',
      form: 'form',
      func: 'function',
      group_condition: 'groupCondition',
      group_control: 'groupControl',
      height: 'height',
      help: 'help',
      html: 'html',
      id: 'id',
      lib_name: 'libName',
      lines: 'lines',
      max: 'max',
      min: 'min',
      options: 'options',
      params: 'params',
      property_name: 'propertyName',
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

    hotkey(id, desc, action, group=null, help=null): control_base(
      type=base.type.control.hotkey, group=group, help=help
    ) + {
      [base.field.id]: id,
      [base.field.desc]: desc,
    } + action,

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

    stepper(text, options, source, group=null, help=null): control_base(
      type=base.type.control.stepper, text=text, group=group, help=help
    ) + source + {
      [base.field.value_options]+: {
        [base.field.options]: options,
      },
    },

    switcher(text, source, group=null, help=null): control_base(
      type=base.type.control.switcher, text=text, group=group, help=help
    ) + source,

    text(text, html=false, group=null, help=null): control_base(
      type=base.type.control.text, text=text, group=group, help=help
    ) + {
      [if html then base.field.html else null]: html,
    },
  },

  field: {
    content: 'content',
    display_name: 'displayName',
    min_mcm_version: 'minMcmVersion',
    mod_name: 'modName',
    page_display_name: 'pageDisplayName',
    pages: 'pages',
    plugin_requirements: 'pluginRequirements',
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
      call_function(form, function_name, params=null, script_name=null): function_base(base.type.action.call_function, function_name, params) + {
        [base.field.action]+: {
          [base.field.form]: form,
          [if script_name != null then base.field.script_name else null]: script_name,
        },
      },
      call_global_function(script, function_name, params=null): function_base(base.type.action.call_function, function_name, params) + {
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
        bool(source_form, property_name, script_name = null): source_type_property_value_base(base.type.source.property_value_bool, source_form, property_name, script_name),
        float(source_form, property_name, script_name = null): source_type_property_value_base(base.type.source.property_value_float, source_form, property_name, script_name),
        int(source_form, property_name, script_name = null): source_type_property_value_base(base.type.source.property_value_int, source_form, property_name, script_name),
        string(source_form, property_name, script_name = null): source_type_property_value_base(base.type.source.property_value_string, source_form, property_name, script_name),
      },
    },
  },
}
