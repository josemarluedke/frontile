export default [
  {
    package: 'addon-blueprint',
    module: 'my-component',
    name: 'MyComponent',
    fileName:
      'packages/addon-blueprint/declarations/components/my-component.d.ts',
    Args: [
      {
        identifier: 'MyArg',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[string]',
          items: [
            {
              identifier: '0',
              type: { type: 'string' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'buttons',
    module: 'button-group',
    name: 'ButtonGroup',
    fileName: 'packages/buttons/declarations/components/button-group.d.ts',
    Args: [
      {
        identifier: 'appearance',
        type: {
          type: 'enum',
          raw: '"default" | "outlined" | "minimal" | "custom"',
          items: ["'default'", "'outlined'", "'minimal'", "'custom'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The button appearance',
        tags: { defaultValue: { name: 'defaultValue', value: "'default'" } },
        defaultValue: "'default'",
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'outlined\'</span> | <span class="hljs-string">\'minimal\'</span> | <span class="hljs-string">\'custom\'</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'default\'</span>'
      },
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description:
          'Custom class name, it will override the default ones using Tailwind Merge library.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'intent',
        type: {
          type: 'enum',
          raw: '"default" | "primary" | "success" | "warning" | "danger"',
          items: [
            "'default'",
            "'primary'",
            "'success'",
            "'warning'",
            "'danger'"
          ]
        },
        isRequired: false,
        isInternal: false,
        description: 'The intent of the button',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"xs" | "sm" | "lg" | "xl"',
          items: ["'xs'", "'sm'", "'lg'", "'xl'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size of the button',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[{ Button: never; ToggleButton: never; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: 'Object',
                items: [
                  {
                    identifier: 'Button',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'ToggleButton',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  }
                ]
              },
              isRequired: true,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'buttons',
    module: 'button',
    name: 'Button',
    fileName: 'packages/buttons/declarations/components/button.d.ts',
    Args: [
      {
        identifier: 'appearance',
        type: {
          type: 'enum',
          raw: '"default" | "outlined" | "minimal" | "custom"',
          items: ["'default'", "'outlined'", "'minimal'", "'custom'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The button appearance',
        tags: { defaultValue: { name: 'defaultValue', value: "'default'" } },
        defaultValue: "'default'",
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'outlined\'</span> | <span class="hljs-string">\'minimal\'</span> | <span class="hljs-string">\'custom\'</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'default\'</span>'
      },
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description:
          'Custom class name, it will override the default ones using Tailwind Merge library.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'intent',
        type: {
          type: 'enum',
          raw: '"default" | "primary" | "success" | "warning" | "danger"',
          items: [
            "'default'",
            "'primary'",
            "'success'",
            "'warning'",
            "'danger'"
          ]
        },
        isRequired: false,
        isInternal: false,
        description: 'The intent of the button',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>'
      },
      {
        identifier: 'isInGroup',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'If button is part of a group. Most of the time, this is automatically set\nwhen using the ButtonGroup component.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'isRenderless',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'Disable rendering the button element. It yields an object with classNames instead.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"xs" | "sm" | "lg" | "xl"',
          items: ["'xs'", "'sm'", "'lg'", "'xl'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size of the button',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span>'
      },
      {
        identifier: 'type',
        type: {
          type: 'enum',
          raw: '"button" | "submit" | "reset"',
          items: ["'button'", "'submit'", "'reset'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The HTML type of the button',
        tags: { defaultValue: { name: 'defaultValue', value: "'button'" } },
        defaultValue: "'button'",
        highlightedType:
          '<span class="hljs-string">\'button\'</span> | <span class="hljs-string">\'submit\'</span> | <span class="hljs-string">\'reset\'</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'button\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[{ classNames: string; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: 'Object',
                items: [
                  {
                    identifier: 'classNames',
                    type: { type: 'string' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  }
                ]
              },
              isRequired: true,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLButtonElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLButtonElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'buttons',
    module: 'chip',
    name: 'Chip',
    fileName: 'packages/buttons/declarations/components/chip.d.ts',
    Args: [
      {
        identifier: 'appearance',
        type: {
          type: 'enum',
          raw: '"default" | "outlined" | "faded"',
          items: ["'default'", "'outlined'", "'faded'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The chip appearance',
        tags: { defaultValue: { name: 'defaultValue', value: "'default'" } },
        defaultValue: "'default'",
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'outlined\'</span> | <span class="hljs-string">\'faded\'</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'default\'</span>'
      },
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description:
          'Custom class name, it will override the default ones using Tailwind Merge library.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'intent',
        type: {
          type: 'enum',
          raw: '"default" | "primary" | "success" | "warning" | "danger"',
          items: [
            "'default'",
            "'primary'",
            "'success'",
            "'warning'",
            "'danger'"
          ]
        },
        isRequired: false,
        isInternal: false,
        description: 'The intent of the chip',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>'
      },
      {
        identifier: 'isDisabled',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Disables the clip and disables the close button if any.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'onClose',
        type: { type: '() => void' },
        isRequired: false,
        isInternal: false,
        description:
          'Function to be called when clicking on the close button.\nIf you pass this argument, the close button will be visible.',
        tags: {},
        highlightedType: '() => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'radius',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "none" | "full"',
          items: ["'sm'", "'lg'", "'none'", "'full'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The radius the chip',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'full\'</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size of the chip',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: 'withDot',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Option to add dot to the chip',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'buttons',
    module: 'close-button',
    name: 'CloseButton',
    fileName: 'packages/buttons/declarations/components/close-button.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'Additional class for close button element',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'onClick',
        type: { type: '(event: Event) => void' },
        isRequired: false,
        isInternal: false,
        description: 'The function to call when button is clicked',
        tags: {},
        highlightedType:
          '(event: Event) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"xs" | "sm" | "lg" | "xl" | "md"',
          items: ["'xs'", "'sm'", "'lg'", "'xl'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The icon size',
        tags: { defaultValue: { name: 'defaultValue', value: "'lg'" } },
        defaultValue: "'lg'",
        highlightedType:
          '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span> | <span class="hljs-string">\'md\'</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'lg\'</span>'
      },
      {
        identifier: 'title',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The title of the close button',
        tags: { defaultValue: { name: 'defaultValue', value: "'Close'" } },
        defaultValue: "'Close'",
        highlightedType: '<span class="hljs-built_in">string</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'Close\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[string]',
          items: [
            {
              identifier: '0',
              type: { type: 'string' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLButtonElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLButtonElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'buttons',
    module: 'progress-bar',
    name: 'ProgressBar',
    fileName: 'packages/buttons/declarations/components/progress-bar.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description:
          'Custom class name, it will override the default ones using Tailwind Merge library.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'formatOptions',
        type: { type: 'NumberFormatOptions' },
        isRequired: false,
        isInternal: false,
        description:
          'The display format of the value.\nValues are formatted as a percentage by default.',
        tags: {},
        highlightedType: 'NumberFormatOptions'
      },
      {
        identifier: 'hint',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The content to display as the hint.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'intent',
        type: {
          type: 'enum',
          raw: '"default" | "primary" | "success" | "warning" | "danger"',
          items: [
            "'default'",
            "'primary'",
            "'success'",
            "'warning'",
            "'danger'"
          ]
        },
        isRequired: false,
        isInternal: false,
        description: 'The intent of the progress bar',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>'
      },
      {
        identifier: 'isIndeterminate',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          "Whether presentation is indeterminate when progress isn't known.",
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'label',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The content to display as the label.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'maxValue',
        type: { type: 'number' },
        isRequired: false,
        isInternal: false,
        description: '\nThe largest value allowed for the input',
        tags: { defaultValue: { name: 'defaultValue', value: '100' } },
        defaultValue: '100',
        highlightedType: '<span class="hljs-built_in">number</span>',
        highlightedDefaultValue: '<span class="hljs-number">100</span>'
      },
      {
        identifier: 'minValue',
        type: { type: 'number' },
        isRequired: false,
        isInternal: false,
        description: '\nThe smallest value allowed for the input',
        tags: { defaultValue: { name: 'defaultValue', value: '0' } },
        defaultValue: '0',
        highlightedType: '<span class="hljs-built_in">number</span>',
        highlightedDefaultValue: '<span class="hljs-number">0</span>'
      },
      {
        identifier: 'progress',
        type: { type: 'number' },
        isRequired: false,
        isInternal: false,
        description: 'The current progress value',
        tags: {},
        highlightedType: '<span class="hljs-built_in">number</span>'
      },
      {
        identifier: 'radius',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "none" | "full"',
          items: ["'sm'", "'lg'", "'none'", "'full'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The radius the progress bar',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'full\'</span>'
      },
      {
        identifier: 'showValueLabel',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          "Whether the value's label is displayed.\nTrue by default if there's a label, false by default if not.",
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"xs" | "sm" | "lg" | "md"',
          items: ["'xs'", "'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size of the progress bar',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: 'valueLabel',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description:
          "The content to display as the value's label (e.g. 1 of 4).",
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'buttons',
    module: 'toggle-button',
    name: 'ToggleButton',
    fileName: 'packages/buttons/declarations/components/toggle-button.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description:
          'Custom class name, it will override the default ones using Tailwind Merge library.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'intent',
        type: {
          type: 'enum',
          raw: '"default" | "primary" | "success" | "warning" | "danger"',
          items: [
            "'default'",
            "'primary'",
            "'success'",
            "'warning'",
            "'danger'"
          ]
        },
        isRequired: false,
        isInternal: false,
        description: 'The intent of the button',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>'
      },
      {
        identifier: 'isInGroup',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'If button is part of a group. Most of the time, this is automatically set\nwhen using the ButtonGroup component.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'isSelected',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If the button is currently selected',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'onChange',
        type: { type: '(isSelected: boolean) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Callback when the buttle is toggled',
        tags: {},
        highlightedType:
          '(isSelected: <span class="hljs-built_in">boolean</span>) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"xs" | "sm" | "lg" | "xl"',
          items: ["'xs'", "'sm'", "'lg'", "'xl'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size of the button',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLButtonElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLButtonElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'collections',
    module: 'dropdown-new',
    name: 'Dropdown',
    fileName: 'packages/collections/declarations/components/dropdown-new.d.ts',
    Args: [
      {
        identifier: 'closeOnItemSelect',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether the dropdown should close upon selecting an item.',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'flipOptions',
        type: { type: 'any' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">any</span>'
      },
      {
        identifier: 'middleware',
        type: {
          type: '{ name: string; options?: any; fn: (state: { placement: Placement; strategy: Strategy; x: number; y: number; initialPlacement: Placement; middlewareData: MiddlewareData; rects: ElementRects; platform: Platform; elements: Elements; }) => Promisable<...>; }[]'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '{ <span class="hljs-attr">name</span>: <span class="hljs-built_in">string</span>; options?: <span class="hljs-built_in">any</span>; fn: <span class="hljs-function">(<span class="hljs-params">state: { placement: Placement; strategy: Strategy; x: <span class="hljs-built_in">number</span>; y: <span class="hljs-built_in">number</span>; initialPlacement: Placement; middlewareData: MiddlewareData; rects: ElementRects; platform: Platform; elements: Elements; }</span>) =></span> Promisable&#x3C;...>; }[]'
      },
      {
        identifier: 'offsetOptions',
        type: { type: 'any' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: '5' } },
        defaultValue: '5',
        highlightedType: '<span class="hljs-built_in">any</span>',
        highlightedDefaultValue: '<span class="hljs-number">5</span>'
      },
      {
        identifier: 'onClose',
        type: { type: '() => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '() => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'placement',
        type: {
          type: 'enum',
          raw: '"top" | "top-start" | "top-end" | "right" | "right-start" | "right-end" | "bottom" | "bottom-start" | "bottom-end" | "left" | "left-start" | "left-end"',
          items: [
            "'top'",
            "'top-start'",
            "'top-end'",
            "'right'",
            "'right-start'",
            "'right-end'",
            "'bottom'",
            "'bottom-start'",
            "'bottom-end'",
            "'left'",
            "'left-start'",
            "'left-end'"
          ]
        },
        isRequired: false,
        isInternal: false,
        description: 'Placement of the menu when open',
        tags: {
          defaultValue: { name: 'defaultValue', value: "'bottom-start'" }
        },
        defaultValue: "'bottom-start'",
        highlightedType:
          '<span class="hljs-string">\'top\'</span> | <span class="hljs-string">\'top-start\'</span> | <span class="hljs-string">\'top-end\'</span> | <span class="hljs-string">\'right\'</span> | <span class="hljs-string">\'right-start\'</span> | <span class="hljs-string">\'right-end\'</span> | <span class="hljs-string">\'bottom\'</span> | <span class="hljs-string">\'bottom-start\'</span> | <span class="hljs-string">\'bottom-end\'</span> | <span class="hljs-string">\'left\'</span> | <span class="hljs-string">\'left-start\'</span> | <span class="hljs-string">\'left-end\'</span>',
        highlightedDefaultValue:
          '<span class="hljs-string">\'bottom-start\'</span>'
      },
      {
        identifier: 'shiftOptions',
        type: { type: 'any' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">any</span>'
      },
      {
        identifier: 'strategy',
        type: {
          type: 'enum',
          raw: 'Strategy',
          items: ["'absolute'", "'fixed'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: "'absolute'" } },
        defaultValue: "'absolute'",
        highlightedType: 'Strategy',
        highlightedDefaultValue: '<span class="hljs-string">\'absolute\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[{ Trigger: never; Menu: never; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: 'Object',
                items: [
                  {
                    identifier: 'Trigger',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Menu',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  }
                ]
              },
              isRequired: true,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLUListElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLUListElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'collections',
    module: 'dropdown-new',
    name: 'Trigger',
    fileName: 'packages/collections/declarations/components/dropdown-new.d.ts',
    Args: [
      {
        identifier: 'anchor',
        type: { type: 'ModifierLike<{ Element: HTMLElement; }>' },
        isRequired: true,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } },
        highlightedType:
          'ModifierLike&#x3C;{ <span class="hljs-attr">Element</span>: HTMLElement; }>'
      },
      {
        identifier: 'toggle',
        type: { type: '() => void' },
        isRequired: true,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } },
        highlightedType: '() => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'trigger',
        type: { type: 'ModifierLike<{ Element: HTMLElement; }>' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          'ModifierLike&#x3C;{ <span class="hljs-attr">Element</span>: HTMLElement; }>'
      },
      {
        identifier: 'appearance',
        type: {
          type: 'enum',
          raw: '"default" | "outlined" | "minimal" | "custom"',
          items: ["'default'", "'outlined'", "'minimal'", "'custom'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The button appearance',
        tags: { defaultValue: { name: 'defaultValue', value: "'default'" } },
        defaultValue: "'default'",
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'outlined\'</span> | <span class="hljs-string">\'minimal\'</span> | <span class="hljs-string">\'custom\'</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'default\'</span>'
      },
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description:
          'Custom class name, it will override the default ones using Tailwind Merge library.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'intent',
        type: {
          type: 'enum',
          raw: '"default" | "primary" | "success" | "warning" | "danger"',
          items: [
            "'default'",
            "'primary'",
            "'success'",
            "'warning'",
            "'danger'"
          ]
        },
        isRequired: false,
        isInternal: false,
        description: 'The intent of the button',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>'
      },
      {
        identifier: 'isInGroup',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'If button is part of a group. Most of the time, this is automatically set\nwhen using the ButtonGroup component.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"xs" | "sm" | "lg" | "xl"',
          items: ["'xs'", "'sm'", "'lg'", "'xl'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size of the button',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLButtonElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLButtonElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'collections',
    module: 'dropdown-new',
    name: 'Menu',
    fileName: 'packages/collections/declarations/components/dropdown-new.d.ts',
    Args: [
      {
        identifier: 'Content',
        type: { type: 'never' },
        isRequired: true,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } },
        highlightedType: '<span class="hljs-built_in">never</span>'
      },
      {
        identifier: 'toggle',
        type: { type: '() => void' },
        isRequired: true,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } },
        highlightedType: '() => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'allowEmpty',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'appearance',
        type: {
          type: 'enum',
          raw: '"default" | "outlined" | "faded"',
          items: ["'default'", "'outlined'", "'faded'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The appearance of each item',
        tags: { defaultValue: { name: 'defaultValue', value: "'default'" } },
        defaultValue: "'default'",
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'outlined\'</span> | <span class="hljs-string">\'faded\'</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'default\'</span>'
      },
      {
        identifier: 'backdrop',
        type: {
          type: 'enum',
          raw: '"faded" | "none" | "transparent" | "blur"',
          items: ["'faded'", "'none'", "'transparent'", "'blur'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'faded\'</span> | <span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'transparent\'</span> | <span class="hljs-string">\'blur\'</span>'
      },
      {
        identifier: 'backdropTransition',
        type: {
          type: '{ didTransitionIn?: () => void; didTransitionOut?: () => void; enterClass?: string; enterActiveClass?: string; enterToClass?: string; isEnabled?: boolean; leaveClass?: string; leaveActiveClass?: string; leaveToClass?: string; name?: string; parentSelector?: string; }'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '{ didTransitionIn?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; didTransitionOut?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; enterClass?: <span class="hljs-built_in">string</span>; enterActiveClass?: <span class="hljs-built_in">string</span>; enterToClass?: <span class="hljs-built_in">string</span>; isEnabled?: <span class="hljs-built_in">boolean</span>; leaveClass?: <span class="hljs-built_in">string</span>; leaveActiveClass?: <span class="hljs-built_in">string</span>; leaveToClass?: <span class="hljs-built_in">string</span>; name?: <span class="hljs-built_in">string</span>; parentSelector?: <span class="hljs-built_in">string</span>; }'
      },
      {
        identifier: 'blockScroll',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'closeOnEscapeKey',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Whether to close when the escape key is pressed',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'closeOnItemSelect',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } },
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'closeOnOutsideClick',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to close when the area outside (the backdrop) is clicked',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'destinationElementId',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description:
          'The destination where the overlay will be inserted, defaults to\n`document.body`',
        tags: { defaultValue: { name: 'defaultValue', value: 'undefined' } },
        defaultValue: 'undefined',
        highlightedType: '<span class="hljs-built_in">string</span>',
        highlightedDefaultValue: '<span class="hljs-literal">undefined</span>'
      },
      {
        identifier: 'disabledKeys',
        type: { type: 'string[]' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>[]'
      },
      {
        identifier: 'disableFocusTrap',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'disableTransitions',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Disable css transitions',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'focusTrapOptions',
        type: { type: 'unknown' },
        isRequired: false,
        isInternal: false,
        description: 'Focus trap options',
        tags: {
          defaultValue: {
            name: 'defaultValue',
            value: '{ allowOutsideClick: true }'
          }
        },
        defaultValue: '{ allowOutsideClick: true }',
        highlightedType: 'unknown',
        highlightedDefaultValue:
          '{ <span class="hljs-attr">allowOutsideClick</span>: <span class="hljs-literal">true</span> }'
      },
      {
        identifier: 'intent',
        type: {
          type: 'enum',
          raw: '"default" | "primary" | "success" | "warning" | "danger"',
          items: [
            "'default'",
            "'primary'",
            "'success'",
            "'warning'",
            "'danger'"
          ]
        },
        isRequired: false,
        isInternal: false,
        description: 'The intent of each item',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>'
      },
      {
        identifier: 'onAction',
        type: { type: '(key: string) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(key: <span class="hljs-built_in">string</span>) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onSelectionChange',
        type: { type: '(key: string[]) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(key: <span class="hljs-built_in">string</span>[]) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'renderInPlace',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to render in place or in the specified/default destination',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'selectedKeys',
        type: { type: 'string[]' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>[]'
      },
      {
        identifier: 'selectionMode',
        type: {
          type: 'enum',
          raw: 'SelectionMode',
          items: ["'none'", "'single'", "'multiple'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'SelectionMode'
      },
      {
        identifier: 'transition',
        type: {
          type: '{ didTransitionIn?: () => void; didTransitionOut?: () => void; enterClass?: string; enterActiveClass?: string; enterToClass?: string; isEnabled?: boolean; leaveClass?: string; leaveActiveClass?: string; leaveToClass?: string; name?: string; parentSelector?: string; }'
        },
        isRequired: false,
        isInternal: false,
        description: 'The transition to be used in the Modal.',
        tags: {
          defaultValue: {
            name: 'defaultValue',
            value: "{name: 'overlay-transition--scale'}"
          }
        },
        defaultValue: "{name: 'overlay-transition--scale'}",
        highlightedType:
          '{ didTransitionIn?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; didTransitionOut?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; enterClass?: <span class="hljs-built_in">string</span>; enterActiveClass?: <span class="hljs-built_in">string</span>; enterToClass?: <span class="hljs-built_in">string</span>; isEnabled?: <span class="hljs-built_in">boolean</span>; leaveClass?: <span class="hljs-built_in">string</span>; leaveActiveClass?: <span class="hljs-built_in">string</span>; leaveToClass?: <span class="hljs-built_in">string</span>; name?: <span class="hljs-built_in">string</span>; parentSelector?: <span class="hljs-built_in">string</span>; }',
        highlightedDefaultValue:
          '{<span class="hljs-attr">name</span>: <span class="hljs-string">\'overlay-transition--scale\'</span>}'
      },
      {
        identifier: 'transitionDuration',
        type: { type: 'number' },
        isRequired: false,
        isInternal: false,
        description: 'Duration of the animation',
        tags: { defaultValue: { name: 'defaultValue', value: '200' } },
        defaultValue: '200',
        highlightedType: '<span class="hljs-built_in">number</span>',
        highlightedDefaultValue: '<span class="hljs-number">200</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[item: never]',
          items: [
            {
              identifier: '0',
              type: { type: 'never' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLUListElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLUListElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'collections',
    module: 'dropdown',
    name: 'Dropdown',
    fileName: 'packages/collections/declarations/components/dropdown.d.ts',
    Args: [
      {
        identifier: 'closeOnItemSelect',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether the dropdown should close upon selecting an item.',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'flipOptions',
        type: { type: 'any' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">any</span>'
      },
      {
        identifier: 'middleware',
        type: {
          type: '{ name: string; options?: any; fn: (state: { placement: Placement; strategy: Strategy; x: number; y: number; initialPlacement: Placement; middlewareData: MiddlewareData; rects: ElementRects; platform: Platform; elements: Elements; }) => Promisable<...>; }[]'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '{ <span class="hljs-attr">name</span>: <span class="hljs-built_in">string</span>; options?: <span class="hljs-built_in">any</span>; fn: <span class="hljs-function">(<span class="hljs-params">state: { placement: Placement; strategy: Strategy; x: <span class="hljs-built_in">number</span>; y: <span class="hljs-built_in">number</span>; initialPlacement: Placement; middlewareData: MiddlewareData; rects: ElementRects; platform: Platform; elements: Elements; }</span>) =></span> Promisable&#x3C;...>; }[]'
      },
      {
        identifier: 'offsetOptions',
        type: { type: 'any' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: '5' } },
        defaultValue: '5',
        highlightedType: '<span class="hljs-built_in">any</span>',
        highlightedDefaultValue: '<span class="hljs-number">5</span>'
      },
      {
        identifier: 'onClose',
        type: { type: '() => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '() => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'placement',
        type: {
          type: 'enum',
          raw: '"top" | "top-start" | "top-end" | "right" | "right-start" | "right-end" | "bottom" | "bottom-start" | "bottom-end" | "left" | "left-start" | "left-end"',
          items: [
            "'top'",
            "'top-start'",
            "'top-end'",
            "'right'",
            "'right-start'",
            "'right-end'",
            "'bottom'",
            "'bottom-start'",
            "'bottom-end'",
            "'left'",
            "'left-start'",
            "'left-end'"
          ]
        },
        isRequired: false,
        isInternal: false,
        description: 'Placement of the menu when open',
        tags: {
          defaultValue: { name: 'defaultValue', value: "'bottom-start'" }
        },
        defaultValue: "'bottom-start'",
        highlightedType:
          '<span class="hljs-string">\'top\'</span> | <span class="hljs-string">\'top-start\'</span> | <span class="hljs-string">\'top-end\'</span> | <span class="hljs-string">\'right\'</span> | <span class="hljs-string">\'right-start\'</span> | <span class="hljs-string">\'right-end\'</span> | <span class="hljs-string">\'bottom\'</span> | <span class="hljs-string">\'bottom-start\'</span> | <span class="hljs-string">\'bottom-end\'</span> | <span class="hljs-string">\'left\'</span> | <span class="hljs-string">\'left-start\'</span> | <span class="hljs-string">\'left-end\'</span>',
        highlightedDefaultValue:
          '<span class="hljs-string">\'bottom-start\'</span>'
      },
      {
        identifier: 'shiftOptions',
        type: { type: 'any' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">any</span>'
      },
      {
        identifier: 'strategy',
        type: {
          type: 'enum',
          raw: 'Strategy',
          items: ["'absolute'", "'fixed'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: "'absolute'" } },
        defaultValue: "'absolute'",
        highlightedType: 'Strategy',
        highlightedDefaultValue: '<span class="hljs-string">\'absolute\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[{ Trigger: never; Menu: never; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: 'Object',
                items: [
                  {
                    identifier: 'Trigger',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Menu',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  }
                ]
              },
              isRequired: true,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLUListElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLUListElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'collections',
    module: 'dropdown',
    name: 'Trigger',
    fileName: 'packages/collections/declarations/components/dropdown.d.ts',
    Args: [
      {
        identifier: 'anchor',
        type: { type: 'ModifierLike<{ Element: HTMLElement; }>' },
        isRequired: true,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } },
        highlightedType:
          'ModifierLike&#x3C;{ <span class="hljs-attr">Element</span>: HTMLElement; }>'
      },
      {
        identifier: 'toggle',
        type: { type: '() => void' },
        isRequired: true,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } },
        highlightedType: '() => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'trigger',
        type: { type: 'ModifierLike<{ Element: HTMLElement; }>' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          'ModifierLike&#x3C;{ <span class="hljs-attr">Element</span>: HTMLElement; }>'
      },
      {
        identifier: 'appearance',
        type: {
          type: 'enum',
          raw: '"default" | "outlined" | "minimal" | "custom"',
          items: ["'default'", "'outlined'", "'minimal'", "'custom'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The button appearance',
        tags: { defaultValue: { name: 'defaultValue', value: "'default'" } },
        defaultValue: "'default'",
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'outlined\'</span> | <span class="hljs-string">\'minimal\'</span> | <span class="hljs-string">\'custom\'</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'default\'</span>'
      },
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description:
          'Custom class name, it will override the default ones using Tailwind Merge library.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'intent',
        type: {
          type: 'enum',
          raw: '"default" | "primary" | "success" | "warning" | "danger"',
          items: [
            "'default'",
            "'primary'",
            "'success'",
            "'warning'",
            "'danger'"
          ]
        },
        isRequired: false,
        isInternal: false,
        description: 'The intent of the button',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>'
      },
      {
        identifier: 'isInGroup',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'If button is part of a group. Most of the time, this is automatically set\nwhen using the ButtonGroup component.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"xs" | "sm" | "lg" | "xl"',
          items: ["'xs'", "'sm'", "'lg'", "'xl'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size of the button',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLButtonElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLButtonElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'collections',
    module: 'dropdown',
    name: 'Menu',
    fileName: 'packages/collections/declarations/components/dropdown.d.ts',
    Args: [
      {
        identifier: 'Content',
        type: { type: 'never' },
        isRequired: true,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } },
        highlightedType: '<span class="hljs-built_in">never</span>'
      },
      {
        identifier: 'toggle',
        type: { type: '() => void' },
        isRequired: true,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } },
        highlightedType: '() => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'allowEmpty',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'appearance',
        type: {
          type: 'enum',
          raw: '"default" | "outlined" | "faded"',
          items: ["'default'", "'outlined'", "'faded'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The appearance of each item',
        tags: { defaultValue: { name: 'defaultValue', value: "'default'" } },
        defaultValue: "'default'",
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'outlined\'</span> | <span class="hljs-string">\'faded\'</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'default\'</span>'
      },
      {
        identifier: 'backdrop',
        type: {
          type: 'enum',
          raw: '"faded" | "none" | "transparent" | "blur"',
          items: ["'faded'", "'none'", "'transparent'", "'blur'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'faded\'</span> | <span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'transparent\'</span> | <span class="hljs-string">\'blur\'</span>'
      },
      {
        identifier: 'backdropTransition',
        type: {
          type: '{ didTransitionIn?: () => void; didTransitionOut?: () => void; enterClass?: string; enterActiveClass?: string; enterToClass?: string; isEnabled?: boolean; leaveClass?: string; leaveActiveClass?: string; leaveToClass?: string; name?: string; parentSelector?: string; }'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '{ didTransitionIn?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; didTransitionOut?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; enterClass?: <span class="hljs-built_in">string</span>; enterActiveClass?: <span class="hljs-built_in">string</span>; enterToClass?: <span class="hljs-built_in">string</span>; isEnabled?: <span class="hljs-built_in">boolean</span>; leaveClass?: <span class="hljs-built_in">string</span>; leaveActiveClass?: <span class="hljs-built_in">string</span>; leaveToClass?: <span class="hljs-built_in">string</span>; name?: <span class="hljs-built_in">string</span>; parentSelector?: <span class="hljs-built_in">string</span>; }'
      },
      {
        identifier: 'blockScroll',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'closeOnEscapeKey',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Whether to close when the escape key is pressed',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'closeOnItemSelect',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } },
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'closeOnOutsideClick',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to close when the area outside (the backdrop) is clicked',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'destinationElementId',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description:
          'The destination where the overlay will be inserted, defaults to\n`document.body`',
        tags: { defaultValue: { name: 'defaultValue', value: 'undefined' } },
        defaultValue: 'undefined',
        highlightedType: '<span class="hljs-built_in">string</span>',
        highlightedDefaultValue: '<span class="hljs-literal">undefined</span>'
      },
      {
        identifier: 'disabledKeys',
        type: { type: 'string[]' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>[]'
      },
      {
        identifier: 'disableFocusTrap',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'disableTransitions',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Disable css transitions',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'focusTrapOptions',
        type: { type: 'unknown' },
        isRequired: false,
        isInternal: false,
        description: 'Focus trap options',
        tags: {
          defaultValue: {
            name: 'defaultValue',
            value: '{ allowOutsideClick: true }'
          }
        },
        defaultValue: '{ allowOutsideClick: true }',
        highlightedType: 'unknown',
        highlightedDefaultValue:
          '{ <span class="hljs-attr">allowOutsideClick</span>: <span class="hljs-literal">true</span> }'
      },
      {
        identifier: 'intent',
        type: {
          type: 'enum',
          raw: '"default" | "primary" | "success" | "warning" | "danger"',
          items: [
            "'default'",
            "'primary'",
            "'success'",
            "'warning'",
            "'danger'"
          ]
        },
        isRequired: false,
        isInternal: false,
        description: 'The intent of each item',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>'
      },
      {
        identifier: 'onAction',
        type: { type: '(key: string) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(key: <span class="hljs-built_in">string</span>) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onSelectionChange',
        type: { type: '(key: string[]) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(key: <span class="hljs-built_in">string</span>[]) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'renderInPlace',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to render in place or in the specified/default destination',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'selectedKeys',
        type: { type: 'string[]' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>[]'
      },
      {
        identifier: 'selectionMode',
        type: {
          type: 'enum',
          raw: 'SelectionMode',
          items: ["'none'", "'single'", "'multiple'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'SelectionMode'
      },
      {
        identifier: 'transition',
        type: {
          type: '{ didTransitionIn?: () => void; didTransitionOut?: () => void; enterClass?: string; enterActiveClass?: string; enterToClass?: string; isEnabled?: boolean; leaveClass?: string; leaveActiveClass?: string; leaveToClass?: string; name?: string; parentSelector?: string; }'
        },
        isRequired: false,
        isInternal: false,
        description: 'The transition to be used in the Modal.',
        tags: {
          defaultValue: {
            name: 'defaultValue',
            value: "{name: 'overlay-transition--scale'}"
          }
        },
        defaultValue: "{name: 'overlay-transition--scale'}",
        highlightedType:
          '{ didTransitionIn?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; didTransitionOut?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; enterClass?: <span class="hljs-built_in">string</span>; enterActiveClass?: <span class="hljs-built_in">string</span>; enterToClass?: <span class="hljs-built_in">string</span>; isEnabled?: <span class="hljs-built_in">boolean</span>; leaveClass?: <span class="hljs-built_in">string</span>; leaveActiveClass?: <span class="hljs-built_in">string</span>; leaveToClass?: <span class="hljs-built_in">string</span>; name?: <span class="hljs-built_in">string</span>; parentSelector?: <span class="hljs-built_in">string</span>; }',
        highlightedDefaultValue:
          '{<span class="hljs-attr">name</span>: <span class="hljs-string">\'overlay-transition--scale\'</span>}'
      },
      {
        identifier: 'transitionDuration',
        type: { type: 'number' },
        isRequired: false,
        isInternal: false,
        description: 'Duration of the animation',
        tags: { defaultValue: { name: 'defaultValue', value: '200' } },
        defaultValue: '200',
        highlightedType: '<span class="hljs-built_in">number</span>',
        highlightedDefaultValue: '<span class="hljs-number">200</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[item: never]',
          items: [
            {
              identifier: '0',
              type: { type: 'never' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLUListElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLUListElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'forms',
    module: 'form-checkbox-group',
    name: 'FormCheckboxGroup',
    fileName: 'packages/forms/declarations/components/form-checkbox-group.d.ts',
    Args: [
      {
        identifier: 'containerClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'errors',
        type: {
          type: 'enum',
          raw: 'string | string[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: 'A list of errors or a single text describing the error',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]'
      },
      {
        identifier: 'hasError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If has errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'hasSubmitted',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'If the form has been submitted, used to force displaying errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'hint',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'isInline',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If the Checkbox should be in one line',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'label',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The group label',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'onChange',
        type: { type: '(value: unknown, event: Event) => void' },
        isRequired: false,
        isInternal: false,
        description:
          'Default callback added to the yielded FormCheckbox component, called when onchange is triggered',
        tags: {},
        highlightedType:
          '(value: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'showError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Force displaying errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[checkbox: never, api: { onChange: (value: unknown, event: Event) => void; }]',
          items: [
            {
              identifier: '0',
              type: { type: 'never' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: '1',
              type: {
                type: 'Object',
                items: [
                  {
                    identifier: 'onChange',
                    type: { type: '(value: unknown, event: Event) => void' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  }
                ]
              },
              isRequired: true,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'forms',
    module: 'form-checkbox',
    name: 'FormCheckbox',
    fileName: 'packages/forms/declarations/components/form-checkbox.d.ts',
    Args: [
      {
        identifier: 'checked',
        type: { type: 'boolean' },
        isRequired: true,
        isInternal: false,
        description:
          'If the checkbox is checked.\nYou must also pass `onChange` to update its value.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'onChange',
        type: { type: '(value: boolean, event: Event) => void' },
        isRequired: true,
        isInternal: false,
        description: 'Callback when onchange is triggered',
        tags: {},
        highlightedType:
          '(value: <span class="hljs-built_in">boolean</span>, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'containerClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'hint',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'label',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The input field label',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'name',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The name of the checkbox',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'privateContainerClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: { ignore: { name: 'ignore', value: '' } },
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: '_parentOnChange',
        type: { type: '(value: boolean, event: Event) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Internal function for InputCheckboxGroup',
        tags: { ignore: { name: 'ignore', value: '' } },
        highlightedType:
          '(value: <span class="hljs-built_in">boolean</span>, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLInputElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLInputElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'forms',
    module: 'form-field',
    name: 'FormField',
    fileName: 'packages/forms/declarations/components/form-field.d.ts',
    Args: [
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[{ id: string; hintId: string; feedbackId: string; Label: never; Hint: never; Feedback: never; Input: never; Textarea: never; Checkbox: never; Radio: never; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: 'Object',
                items: [
                  {
                    identifier: 'id',
                    type: { type: 'string' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'hintId',
                    type: { type: 'string' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'feedbackId',
                    type: { type: 'string' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Label',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Hint',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Feedback',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Input',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Textarea',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Checkbox',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Radio',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  }
                ]
              },
              isRequired: true,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'forms',
    module: 'form-input',
    name: 'FormInputBase',
    fileName: 'packages/forms/declarations/components/form-input.d.ts',
    Args: [
      {
        identifier: 'value',
        type: { type: 'string' },
        isRequired: true,
        isInternal: false,
        description:
          'The value to be used in the input.\nYou must also pass `onChange` or `onInput` to update its value.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'containerClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'errors',
        type: {
          type: 'enum',
          raw: 'string | string[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: 'A list of errors or a single text describing the error',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]'
      },
      {
        identifier: 'hasError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If has errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'hasSubmitted',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'If the form has been submitted, used to force displaying errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'hint',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'inputClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the input element',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'label',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The group label',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'onChange',
        type: { type: '(value: string, event: InputEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onchange is triggered',
        tags: {},
        highlightedType:
          '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onFocusIn',
        type: { type: '(event: FocusEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onfocus is triggered',
        tags: {},
        highlightedType:
          '(event: FocusEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onFocusOut',
        type: { type: '(event: FocusEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onblur is triggered',
        tags: {},
        highlightedType:
          '(event: FocusEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onInput',
        type: { type: '(value: string, event: InputEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Callback when oninput is triggered',
        tags: {},
        highlightedType:
          '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'showError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Force displaying errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: 'type',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The input type',
        tags: { defaultValue: { name: 'defaultValue', value: "'text'" } },
        defaultValue: "'text'",
        highlightedType: '<span class="hljs-built_in">string</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'text\'</span>'
      }
    ],
    Blocks: [],
    description: '',
    tags: {}
  },
  {
    package: 'forms',
    module: 'form-input',
    name: 'FormInput',
    fileName: 'packages/forms/declarations/components/form-input.d.ts',
    Args: [
      {
        identifier: 'value',
        type: { type: 'string' },
        isRequired: true,
        isInternal: false,
        description:
          'The value to be used in the input.\nYou must also pass `onChange` or `onInput` to update its value.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'containerClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'errors',
        type: {
          type: 'enum',
          raw: 'string | string[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: 'A list of errors or a single text describing the error',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]'
      },
      {
        identifier: 'hasError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If has errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'hasSubmitted',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'If the form has been submitted, used to force displaying errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'hint',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'inputClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the input element',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'label',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The group label',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'onChange',
        type: { type: '(value: string, event: InputEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onchange is triggered',
        tags: {},
        highlightedType:
          '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onFocusIn',
        type: { type: '(event: FocusEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onfocus is triggered',
        tags: {},
        highlightedType:
          '(event: FocusEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onFocusOut',
        type: { type: '(event: FocusEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onblur is triggered',
        tags: {},
        highlightedType:
          '(event: FocusEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onInput',
        type: { type: '(value: string, event: InputEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Callback when oninput is triggered',
        tags: {},
        highlightedType:
          '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'showError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Force displaying errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: 'type',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The input type',
        tags: { defaultValue: { name: 'defaultValue', value: "'text'" } },
        defaultValue: "'text'",
        highlightedType: '<span class="hljs-built_in">string</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'text\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLInputElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLInputElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'forms',
    module: 'form-radio-group',
    name: 'FormRadioGroup',
    fileName: 'packages/forms/declarations/components/form-radio-group.d.ts',
    Args: [
      {
        identifier: 'value',
        type: {
          type: 'enum',
          raw: 'string | number | boolean',
          items: ['string', 'number', 'false', 'true']
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">number</span> | <span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'containerClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'errors',
        type: {
          type: 'enum',
          raw: 'string | string[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: 'A list of errors or a single text describing the error',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]'
      },
      {
        identifier: 'hasError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If has errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'hasSubmitted',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'If the form has been submitted, used to force displaying errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'hint',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'isInline',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If the Checkbox should be in one line',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'label',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The group label',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'onChange',
        type: { type: '(value: unknown, event: Event) => void' },
        isRequired: false,
        isInternal: false,
        description:
          'Default callback added to the yielded FormRadio component, called when onchange is triggered',
        tags: {},
        highlightedType:
          '(value: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'showError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Force displaying errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[radio: never]',
          items: [
            {
              identifier: '0',
              type: { type: 'never' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'forms',
    module: 'form-radio',
    name: 'FormRadio',
    fileName: 'packages/forms/declarations/components/form-radio.d.ts',
    Args: [
      {
        identifier: 'checked',
        type: { type: 'unknown' },
        isRequired: true,
        isInternal: false,
        description:
          'The current checked value.\nThis will be used to compare against the `value` argument,\nif equal, the radio will me marked as checked.',
        tags: {},
        highlightedType: 'unknown'
      },
      {
        identifier: 'onChange',
        type: { type: '(value: unknown, event: Event) => void' },
        isRequired: true,
        isInternal: false,
        description: 'Callback when onchange is triggered',
        tags: {},
        highlightedType:
          '(value: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'value',
        type: {
          type: 'enum',
          raw: 'string | number | boolean',
          items: ['string', 'number', 'false', 'true']
        },
        isRequired: true,
        isInternal: false,
        description:
          'The value to be used in the radio button.\nYou must also pass `onChange` to update its value.',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">number</span> | <span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'containerClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'hint',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'label',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The input field label',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'name',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The name of the checkbox',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'privateContainerClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description:
          'CSS classes to be added in the container element, in be used in for group',
        tags: { ignore: { name: 'ignore', value: '' } },
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: '_parentOnChange',
        type: { type: '(value: unknown, event: Event) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Internal function for InputRadioGroup',
        tags: { ignore: { name: 'ignore', value: '' } },
        highlightedType:
          '(value: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLInputElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLInputElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'forms',
    module: 'form-select',
    name: 'FormSelect',
    fileName: 'packages/forms/declarations/components/form-select.d.ts',
    Args: [
      {
        identifier: 'onChange',
        type: {
          type: '(selection: any, select: Select, event?: Event) => void'
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(selection: <span class="hljs-built_in">any</span>, <span class="hljs-attr">select</span>: Select, event?: Event) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'options',
        type: {
          type: 'enum',
          raw: 'any[] | PromiseProxy<any[]>',
          items: ['any[]', 'PromiseProxy<any[]>']
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">any</span>[] | PromiseProxy&#x3C;<span class="hljs-built_in">any</span>[]>'
      },
      {
        identifier: 'selected',
        type: { type: 'any' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">any</span>'
      },
      {
        identifier: 'beforeOptionsComponent',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'buildSelection',
        type: { type: '(selected: any, select: Select) => any' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(selected: <span class="hljs-built_in">any</span>, <span class="hljs-attr">select</span>: Select) => <span class="hljs-built_in">any</span>'
      },
      {
        identifier: 'closeOnSelect',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'containerClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'defaultHighlighted',
        type: { type: 'any' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">any</span>'
      },
      {
        identifier: 'errors',
        type: {
          type: 'enum',
          raw: 'string | string[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: 'A list of errors or a single text describing the error',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]'
      },
      {
        identifier: 'groupComponent',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'hasError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If has errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'hasSubmitted',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'If the form has been submitted, used to force displaying errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'highlightOnHover',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'hint',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'initiallyOpened',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'isMultiple',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If is multiple select instead of single',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'label',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The input field label',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'matcher',
        type: { type: 'MatcherFn' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'MatcherFn'
      },
      {
        identifier: 'matchTriggerWidth',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'noMatchesMessage',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'noMatchesMessageComponent',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'onBlur',
        type: { type: '(select: Select, event: FocusEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(select: Select, <span class="hljs-attr">event</span>: FocusEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onClose',
        type: { type: '(select: Select, e: Event) => boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(select: Select, <span class="hljs-attr">e</span>: Event) => <span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'onFocus',
        type: { type: '(select: Select, event: FocusEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(select: Select, <span class="hljs-attr">event</span>: FocusEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onFocusIn',
        type: { type: '(select: Select, event: FocusEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(select: Select, <span class="hljs-attr">event</span>: FocusEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onFocusOut',
        type: { type: '(select: Select, event: FocusEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(select: Select, <span class="hljs-attr">event</span>: FocusEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onInput',
        type: {
          type: '(term: string, select: Select, e: Event) => string | false | void'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(term: <span class="hljs-built_in">string</span>, <span class="hljs-attr">select</span>: Select, <span class="hljs-attr">e</span>: Event) => <span class="hljs-built_in">string</span> | <span class="hljs-literal">false</span> | <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onKeydown',
        type: { type: '(select: Select, e: KeyboardEvent) => boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(select: Select, <span class="hljs-attr">e</span>: KeyboardEvent) => <span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'onOpen',
        type: { type: '(select: Select, e: Event) => boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(select: Select, <span class="hljs-attr">e</span>: Event) => <span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'optionsComponent',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'placeholderComponent',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'registerAPI',
        type: { type: '(select: Select) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(select: Select) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'scrollTo',
        type: { type: '(option: any, select: Select) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(option: <span class="hljs-built_in">any</span>, <span class="hljs-attr">select</span>: Select) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'search',
        type: {
          type: '(term: string, select: Select) => any[] | PromiseProxy<any[]>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(term: <span class="hljs-built_in">string</span>, <span class="hljs-attr">select</span>: Select) => <span class="hljs-built_in">any</span>[] | PromiseProxy&#x3C;<span class="hljs-built_in">any</span>[]>'
      },
      {
        identifier: 'searchEnabled',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'searchField',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'searchMessage',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'searchMessageComponent',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'showError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Force displaying errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: 'tabindex',
        type: {
          type: 'enum',
          raw: 'string | number',
          items: ['string', 'number']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">number</span>'
      },
      {
        identifier: 'triggerComponent',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'typeAheadOptionMatcher',
        type: { type: 'MatcherFn' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'MatcherFn'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[unknown, Select]',
          items: [
            {
              identifier: '0',
              type: { type: 'unknown' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: '1',
              type: {
                type: 'Object',
                items: [
                  {
                    identifier: 'selected',
                    type: { type: 'any' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'highlighted',
                    type: { type: 'any' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'options',
                    type: { type: 'any[]' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'results',
                    type: { type: 'any[]' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'resultsCount',
                    type: { type: 'number' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'loading',
                    type: { type: 'boolean' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'isActive',
                    type: { type: 'boolean' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'searchText',
                    type: { type: 'string' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'lastSearchedText',
                    type: { type: 'string' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'actions',
                    type: { type: 'SelectActions' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'uniqueId',
                    type: { type: 'string' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'disabled',
                    type: { type: 'boolean' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'isOpen',
                    type: { type: 'boolean' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  }
                ]
              },
              isRequired: true,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'forms',
    module: 'form-textarea',
    name: 'FormTextarea',
    fileName: 'packages/forms/declarations/components/form-textarea.d.ts',
    Args: [
      {
        identifier: 'value',
        type: { type: 'string' },
        isRequired: true,
        isInternal: false,
        description:
          'The value to be used in the input.\nYou must also pass `onChange` or `onInput` to update its value.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'containerClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'errors',
        type: {
          type: 'enum',
          raw: 'string | string[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: 'A list of errors or a single text describing the error',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]'
      },
      {
        identifier: 'hasError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If has errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'hasSubmitted',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'If the form has been submitted, used to force displaying errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'hint',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'inputClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the input element',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'label',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The group label',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'onChange',
        type: { type: '(value: string, event: InputEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onchange is triggered',
        tags: {},
        highlightedType:
          '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onFocusIn',
        type: { type: '(event: FocusEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onfocus is triggered',
        tags: {},
        highlightedType:
          '(event: FocusEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onFocusOut',
        type: { type: '(event: FocusEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onblur is triggered',
        tags: {},
        highlightedType:
          '(event: FocusEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onInput',
        type: { type: '(value: string, event: InputEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Callback when oninput is triggered',
        tags: {},
        highlightedType:
          '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'showError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Force displaying errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: 'type',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The input type',
        tags: { defaultValue: { name: 'defaultValue', value: "'text'" } },
        defaultValue: "'text'",
        highlightedType: '<span class="hljs-built_in">string</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'text\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLTextAreaElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLTextAreaElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'notifications',
    module: 'notification-card',
    name: 'NotificationCard',
    fileName:
      'packages/notifications/declarations/components/notification-card.d.ts',
    Args: [
      {
        identifier: 'notification',
        type: { type: 'Notification' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'Notification'
      },
      {
        identifier: 'placement',
        type: {
          type: 'enum',
          raw: 'containerPlacement',
          items: [
            "'top-left'",
            "'top-center'",
            "'top-right'",
            "'bottom-left'",
            "'bottom-center'",
            "'bottom-right'"
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'containerPlacement'
      },
      {
        identifier: 'spacing',
        type: { type: 'number' },
        isRequired: false,
        isInternal: false,
        description: 'Spacing for each notification, in px.',
        tags: { defaultValue: { name: 'defaultValue', value: '16' } },
        defaultValue: '16',
        highlightedType: '<span class="hljs-built_in">number</span>',
        highlightedDefaultValue: '<span class="hljs-number">16</span>'
      }
    ],
    Blocks: [],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'notifications',
    module: 'notifications-container',
    name: 'NotificationsContainer',
    fileName:
      'packages/notifications/declarations/components/notifications-container.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description:
          'Custom class name, it will override the default ones using Tailwind Merge library.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'placement',
        type: {
          type: 'enum',
          raw: 'containerPlacement',
          items: [
            "'top-left'",
            "'top-center'",
            "'top-right'",
            "'bottom-left'",
            "'bottom-center'",
            "'bottom-right'"
          ]
        },
        isRequired: false,
        isInternal: false,
        description: 'The placement of the notifications',
        tags: {
          defaultValue: { name: 'defaultValue', value: "'bottom-right'" }
        },
        defaultValue: "'bottom-right'",
        highlightedType: 'containerPlacement',
        highlightedDefaultValue:
          '<span class="hljs-string">\'bottom-right\'</span>'
      },
      {
        identifier: 'spacing',
        type: { type: 'number' },
        isRequired: false,
        isInternal: false,
        description: 'Spacing for each notification, in px.',
        tags: { defaultValue: { name: 'defaultValue', value: '16' } },
        defaultValue: '16',
        highlightedType: '<span class="hljs-built_in">number</span>',
        highlightedDefaultValue: '<span class="hljs-number">16</span>'
      }
    ],
    Blocks: [],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'overlays',
    module: 'backdrop',
    name: 'Backdrop',
    fileName: 'packages/overlays/declarations/components/backdrop.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'inPlace',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'transition',
        type: {
          type: '{ didTransitionIn?: () => void; didTransitionOut?: () => void; enterClass?: string; enterActiveClass?: string; enterToClass?: string; isEnabled?: boolean; leaveClass?: string; leaveActiveClass?: string; leaveToClass?: string; name?: string; parentSelector?: string; }'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '{ didTransitionIn?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; didTransitionOut?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; enterClass?: <span class="hljs-built_in">string</span>; enterActiveClass?: <span class="hljs-built_in">string</span>; enterToClass?: <span class="hljs-built_in">string</span>; isEnabled?: <span class="hljs-built_in">boolean</span>; leaveClass?: <span class="hljs-built_in">string</span>; leaveActiveClass?: <span class="hljs-built_in">string</span>; leaveToClass?: <span class="hljs-built_in">string</span>; name?: <span class="hljs-built_in">string</span>; parentSelector?: <span class="hljs-built_in">string</span>; }'
      },
      {
        identifier: 'type',
        type: {
          type: 'enum',
          raw: '"faded" | "none" | "transparent" | "blur"',
          items: ["'faded'", "'none'", "'transparent'", "'blur'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: "'faded'" } },
        defaultValue: "'faded'",
        highlightedType:
          '<span class="hljs-string">\'faded\'</span> | <span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'transparent\'</span> | <span class="hljs-string">\'blur\'</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'faded\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'overlays',
    module: 'drawer',
    name: 'Drawer',
    fileName: 'packages/overlays/declarations/components/drawer.d.ts',
    Args: [
      {
        identifier: 'isOpen',
        type: { type: 'boolean' },
        isRequired: true,
        isInternal: false,
        description: 'Whether it is open or not',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'allowCloseButton',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If set to false, the close button will not be displayed.',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'allowClosing',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'If set to false, the close button will not be displayed,\ncloseOnOutsideClick will be set to false, and closeOnEscapeKey will also be set\nto false.',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'backdrop',
        type: {
          type: 'enum',
          raw: '"faded" | "none" | "transparent" | "blur"',
          items: ["'faded'", "'none'", "'transparent'", "'blur'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'faded\'</span> | <span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'transparent\'</span> | <span class="hljs-string">\'blur\'</span>'
      },
      {
        identifier: 'backdropTransition',
        type: {
          type: '{ didTransitionIn?: () => void; didTransitionOut?: () => void; enterClass?: string; enterActiveClass?: string; enterToClass?: string; isEnabled?: boolean; leaveClass?: string; leaveActiveClass?: string; leaveToClass?: string; name?: string; parentSelector?: string; }'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '{ didTransitionIn?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; didTransitionOut?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; enterClass?: <span class="hljs-built_in">string</span>; enterActiveClass?: <span class="hljs-built_in">string</span>; enterToClass?: <span class="hljs-built_in">string</span>; isEnabled?: <span class="hljs-built_in">boolean</span>; leaveClass?: <span class="hljs-built_in">string</span>; leaveActiveClass?: <span class="hljs-built_in">string</span>; leaveToClass?: <span class="hljs-built_in">string</span>; name?: <span class="hljs-built_in">string</span>; parentSelector?: <span class="hljs-built_in">string</span>; }'
      },
      {
        identifier: 'closeButtonSize',
        type: {
          type: 'enum',
          raw: '"xs" | "sm" | "lg" | "xl" | "md"',
          items: ["'xs'", "'sm'", "'lg'", "'xl'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The Close Button size.',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span> | <span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: 'closeOnEscapeKey',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Whether to close when the escape key is pressed',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'closeOnOutsideClick',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to close when the area outside (the backdrop) is clicked',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'destinationElementId',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description:
          'The destination where the overlay will be inserted, defaults to\n`document.body`',
        tags: { defaultValue: { name: 'defaultValue', value: 'undefined' } },
        defaultValue: 'undefined',
        highlightedType: '<span class="hljs-built_in">string</span>',
        highlightedDefaultValue: '<span class="hljs-literal">undefined</span>'
      },
      {
        identifier: 'didClose',
        type: { type: '() => void' },
        isRequired: false,
        isInternal: false,
        description:
          'A function that will be called when closing is finished executing, this\nincludes waiting for animations/transitions to finish.',
        tags: {},
        highlightedType: '() => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'disableFocusTrap',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Whether the focus trap is disabled or not',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'disableTransitions',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Disable css transitions',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'focusTrapOptions',
        type: { type: 'unknown' },
        isRequired: false,
        isInternal: false,
        description: 'Focus trap options',
        tags: {
          defaultValue: {
            name: 'defaultValue',
            value: '{ allowOutsideClick: true }'
          }
        },
        defaultValue: '{ allowOutsideClick: true }',
        highlightedType: 'unknown',
        highlightedDefaultValue:
          '{ <span class="hljs-attr">allowOutsideClick</span>: <span class="hljs-literal">true</span> }'
      },
      {
        identifier: 'onClose',
        type: { type: '() => void' },
        isRequired: false,
        isInternal: false,
        description: 'A function that will be called when closed',
        tags: {},
        highlightedType: '() => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onOpen',
        type: { type: '() => void' },
        isRequired: false,
        isInternal: false,
        description: 'A function that will be called when opened',
        tags: {},
        highlightedType: '() => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'placement',
        type: {
          type: 'enum',
          raw: '"top" | "right" | "bottom" | "left"',
          items: ["'top'", "'right'", "'bottom'", "'left'"]
        },
        isRequired: false,
        isInternal: false,
        description:
          "The Drawer can appear from any side of the screen. The 'placement'\noption allows to choose where it appears from.",
        tags: { defaultValue: { name: 'defaultValue', value: "'right'" } },
        defaultValue: "'right'",
        highlightedType:
          '<span class="hljs-string">\'top\'</span> | <span class="hljs-string">\'right\'</span> | <span class="hljs-string">\'bottom\'</span> | <span class="hljs-string">\'left\'</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'right\'</span>'
      },
      {
        identifier: 'renderInPlace',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to render in place or in the specified/default destination',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"xs" | "sm" | "lg" | "xl" | "md" | "full"',
          items: ["'xs'", "'sm'", "'lg'", "'xl'", "'md'", "'full'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The Drawer size.',
        tags: { defaultValue: { name: 'defaultValue', value: "'md'" } },
        defaultValue: "'md'",
        highlightedType:
          '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span> | <span class="hljs-string">\'md\'</span> | <span class="hljs-string">\'full\'</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: 'transition',
        type: {
          type: '{ didTransitionIn?: () => void; didTransitionOut?: () => void; enterClass?: string; enterActiveClass?: string; enterToClass?: string; isEnabled?: boolean; leaveClass?: string; leaveActiveClass?: string; leaveToClass?: string; name?: string; parentSelector?: string; }'
        },
        isRequired: false,
        isInternal: false,
        description: 'The transition to be used in the Drawer.',
        tags: {
          defaultValue: {
            name: 'defaultValue',
            value: "{name: 'overlay-transition--slide-from-[placement]'}"
          }
        },
        defaultValue: "{name: 'overlay-transition--slide-from-[placement]'}",
        highlightedType:
          '{ didTransitionIn?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; didTransitionOut?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; enterClass?: <span class="hljs-built_in">string</span>; enterActiveClass?: <span class="hljs-built_in">string</span>; enterToClass?: <span class="hljs-built_in">string</span>; isEnabled?: <span class="hljs-built_in">boolean</span>; leaveClass?: <span class="hljs-built_in">string</span>; leaveActiveClass?: <span class="hljs-built_in">string</span>; leaveToClass?: <span class="hljs-built_in">string</span>; name?: <span class="hljs-built_in">string</span>; parentSelector?: <span class="hljs-built_in">string</span>; }',
        highlightedDefaultValue:
          '{<span class="hljs-attr">name</span>: <span class="hljs-string">\'overlay-transition--slide-from-[placement]\'</span>}'
      },
      {
        identifier: 'transitionDuration',
        type: { type: 'number' },
        isRequired: false,
        isInternal: false,
        description: 'Duration of the animation',
        tags: { defaultValue: { name: 'defaultValue', value: '200' } },
        defaultValue: '200',
        highlightedType: '<span class="hljs-built_in">number</span>',
        highlightedDefaultValue: '<span class="hljs-number">200</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[{ CloseButton: never; Header: never; Body: never; Footer: never; headerId: string; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: 'Object',
                items: [
                  {
                    identifier: 'CloseButton',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Header',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Body',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Footer',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'headerId',
                    type: { type: 'string' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  }
                ]
              },
              isRequired: true,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'overlays',
    module: 'modal',
    name: 'Modal',
    fileName: 'packages/overlays/declarations/components/modal.d.ts',
    Args: [
      {
        identifier: 'isOpen',
        type: { type: 'boolean' },
        isRequired: true,
        isInternal: false,
        description: 'Whether it is open or not',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'allowCloseButton',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If set to false, the close button will not be displayed.',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'allowClosing',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'If set to false, the close button will not be displayed,\ncloseOnOutsideClick will be set to false, and closeOnEscapeKey will also be set\nto false.',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'backdrop',
        type: {
          type: 'enum',
          raw: '"faded" | "none" | "transparent" | "blur"',
          items: ["'faded'", "'none'", "'transparent'", "'blur'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'faded\'</span> | <span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'transparent\'</span> | <span class="hljs-string">\'blur\'</span>'
      },
      {
        identifier: 'backdropTransition',
        type: {
          type: '{ didTransitionIn?: () => void; didTransitionOut?: () => void; enterClass?: string; enterActiveClass?: string; enterToClass?: string; isEnabled?: boolean; leaveClass?: string; leaveActiveClass?: string; leaveToClass?: string; name?: string; parentSelector?: string; }'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '{ didTransitionIn?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; didTransitionOut?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; enterClass?: <span class="hljs-built_in">string</span>; enterActiveClass?: <span class="hljs-built_in">string</span>; enterToClass?: <span class="hljs-built_in">string</span>; isEnabled?: <span class="hljs-built_in">boolean</span>; leaveClass?: <span class="hljs-built_in">string</span>; leaveActiveClass?: <span class="hljs-built_in">string</span>; leaveToClass?: <span class="hljs-built_in">string</span>; name?: <span class="hljs-built_in">string</span>; parentSelector?: <span class="hljs-built_in">string</span>; }'
      },
      {
        identifier: 'closeButtonSize',
        type: {
          type: 'enum',
          raw: '"xs" | "sm" | "lg" | "xl" | "md"',
          items: ["'xs'", "'sm'", "'lg'", "'xl'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The Close Button size.',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span> | <span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: 'closeOnEscapeKey',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Whether to close when the escape key is pressed',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'closeOnOutsideClick',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to close when the area outside (the backdrop) is clicked',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'destinationElementId',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description:
          'The destination where the overlay will be inserted, defaults to\n`document.body`',
        tags: { defaultValue: { name: 'defaultValue', value: 'undefined' } },
        defaultValue: 'undefined',
        highlightedType: '<span class="hljs-built_in">string</span>',
        highlightedDefaultValue: '<span class="hljs-literal">undefined</span>'
      },
      {
        identifier: 'didClose',
        type: { type: '() => void' },
        isRequired: false,
        isInternal: false,
        description:
          'A function that will be called when closing is finished executing, this\nincludes waiting for animations/transitions to finish.',
        tags: {},
        highlightedType: '() => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'disableFocusTrap',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Whether the focus trap is disabled or not',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'disableTransitions',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Disable css transitions',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'focusTrapOptions',
        type: { type: 'unknown' },
        isRequired: false,
        isInternal: false,
        description: 'Focus trap options',
        tags: {
          defaultValue: {
            name: 'defaultValue',
            value: '{ allowOutsideClick: true }'
          }
        },
        defaultValue: '{ allowOutsideClick: true }',
        highlightedType: 'unknown',
        highlightedDefaultValue:
          '{ <span class="hljs-attr">allowOutsideClick</span>: <span class="hljs-literal">true</span> }'
      },
      {
        identifier: 'isCentered',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If set to true, the modal will be vertically centered',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'onClose',
        type: { type: '() => void' },
        isRequired: false,
        isInternal: false,
        description: 'A function that will be called when closed',
        tags: {},
        highlightedType: '() => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onOpen',
        type: { type: '() => void' },
        isRequired: false,
        isInternal: false,
        description: 'A function that will be called when opened',
        tags: {},
        highlightedType: '() => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'renderInPlace',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to render in place or in the specified/default destination',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"xs" | "sm" | "lg" | "xl" | "md" | "full"',
          items: ["'xs'", "'sm'", "'lg'", "'xl'", "'md'", "'full'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The Modal size.',
        tags: { defaultValue: { name: 'defaultValue', value: "'lg'" } },
        defaultValue: "'lg'",
        highlightedType:
          '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span> | <span class="hljs-string">\'md\'</span> | <span class="hljs-string">\'full\'</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'lg\'</span>'
      },
      {
        identifier: 'transition',
        type: {
          type: '{ didTransitionIn?: () => void; didTransitionOut?: () => void; enterClass?: string; enterActiveClass?: string; enterToClass?: string; isEnabled?: boolean; leaveClass?: string; leaveActiveClass?: string; leaveToClass?: string; name?: string; parentSelector?: string; }'
        },
        isRequired: false,
        isInternal: false,
        description: 'The transition to be used in the Modal.',
        tags: {
          defaultValue: {
            name: 'defaultValue',
            value: "{name: 'overlay-transition--zoom'}"
          }
        },
        defaultValue: "{name: 'overlay-transition--zoom'}",
        highlightedType:
          '{ didTransitionIn?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; didTransitionOut?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; enterClass?: <span class="hljs-built_in">string</span>; enterActiveClass?: <span class="hljs-built_in">string</span>; enterToClass?: <span class="hljs-built_in">string</span>; isEnabled?: <span class="hljs-built_in">boolean</span>; leaveClass?: <span class="hljs-built_in">string</span>; leaveActiveClass?: <span class="hljs-built_in">string</span>; leaveToClass?: <span class="hljs-built_in">string</span>; name?: <span class="hljs-built_in">string</span>; parentSelector?: <span class="hljs-built_in">string</span>; }',
        highlightedDefaultValue:
          '{<span class="hljs-attr">name</span>: <span class="hljs-string">\'overlay-transition--zoom\'</span>}'
      },
      {
        identifier: 'transitionDuration',
        type: { type: 'number' },
        isRequired: false,
        isInternal: false,
        description: 'Duration of the animation',
        tags: { defaultValue: { name: 'defaultValue', value: '200' } },
        defaultValue: '200',
        highlightedType: '<span class="hljs-built_in">number</span>',
        highlightedDefaultValue: '<span class="hljs-number">200</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[{ CloseButton: never; Header: never; Body: never; Footer: never; headerId: string; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: 'Object',
                items: [
                  {
                    identifier: 'CloseButton',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Header',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Body',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Footer',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'headerId',
                    type: { type: 'string' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  }
                ]
              },
              isRequired: true,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'overlays',
    module: 'overlay',
    name: 'Overlay',
    fileName: 'packages/overlays/declarations/components/overlay.d.ts',
    Args: [
      {
        identifier: 'isOpen',
        type: { type: 'boolean' },
        isRequired: true,
        isInternal: false,
        description: 'Whether it is open or not',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'backdrop',
        type: {
          type: 'enum',
          raw: '"faded" | "none" | "transparent" | "blur"',
          items: ["'faded'", "'none'", "'transparent'", "'blur'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'faded\'</span> | <span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'transparent\'</span> | <span class="hljs-string">\'blur\'</span>'
      },
      {
        identifier: 'backdropTransition',
        type: {
          type: '{ didTransitionIn?: () => void; didTransitionOut?: () => void; enterClass?: string; enterActiveClass?: string; enterToClass?: string; isEnabled?: boolean; leaveClass?: string; leaveActiveClass?: string; leaveToClass?: string; name?: string; parentSelector?: string; }'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '{ didTransitionIn?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; didTransitionOut?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; enterClass?: <span class="hljs-built_in">string</span>; enterActiveClass?: <span class="hljs-built_in">string</span>; enterToClass?: <span class="hljs-built_in">string</span>; isEnabled?: <span class="hljs-built_in">boolean</span>; leaveClass?: <span class="hljs-built_in">string</span>; leaveActiveClass?: <span class="hljs-built_in">string</span>; leaveToClass?: <span class="hljs-built_in">string</span>; name?: <span class="hljs-built_in">string</span>; parentSelector?: <span class="hljs-built_in">string</span>; }'
      },
      {
        identifier: 'blockScroll',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'closeOnEscapeKey',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Whether to close when the escape key is pressed',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'closeOnOutsideClick',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to close when the area outside (the backdrop) is clicked',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'closeOnOverlayElementClick',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to close when the overlay element is clicked, used for modal and drawer components.',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'customContentModifier',
        type: { type: 'ModifierLike<{ Element: HTMLElement; }>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          'ModifierLike&#x3C;{ <span class="hljs-attr">Element</span>: HTMLElement; }>'
      },
      {
        identifier: 'destinationElementId',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description:
          'The destination where the overlay will be inserted, defaults to\n`document.body`',
        tags: { defaultValue: { name: 'defaultValue', value: 'undefined' } },
        defaultValue: 'undefined',
        highlightedType: '<span class="hljs-built_in">string</span>',
        highlightedDefaultValue: '<span class="hljs-literal">undefined</span>'
      },
      {
        identifier: 'didClose',
        type: { type: '() => void' },
        isRequired: false,
        isInternal: false,
        description:
          'A function that will be called when closing is finished executing, this\nincludes waiting for animations/transitions to finish.',
        tags: {},
        highlightedType: '() => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'disableFlexContent',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'disableFocusTrap',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Whether the focus trap is disabled or not',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'disableTransitions',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Disable css transitions',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'focusTrapOptions',
        type: { type: 'unknown' },
        isRequired: false,
        isInternal: false,
        description: 'Focus trap options',
        tags: {
          defaultValue: {
            name: 'defaultValue',
            value: '{ allowOutsideClick: true }'
          }
        },
        defaultValue: '{ allowOutsideClick: true }',
        highlightedType: 'unknown',
        highlightedDefaultValue:
          '{ <span class="hljs-attr">allowOutsideClick</span>: <span class="hljs-literal">true</span> }'
      },
      {
        identifier: 'onClose',
        type: { type: '() => void' },
        isRequired: false,
        isInternal: false,
        description: 'A function that will be called when closed',
        tags: {},
        highlightedType: '() => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onOpen',
        type: { type: '() => void' },
        isRequired: false,
        isInternal: false,
        description: 'A function that will be called when opened',
        tags: {},
        highlightedType: '() => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'renderInPlace',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to render in place or in the specified/default destination',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'transition',
        type: {
          type: '{ didTransitionIn?: () => void; didTransitionOut?: () => void; enterClass?: string; enterActiveClass?: string; enterToClass?: string; isEnabled?: boolean; leaveClass?: string; leaveActiveClass?: string; leaveToClass?: string; name?: string; parentSelector?: string; }'
        },
        isRequired: false,
        isInternal: false,
        description: 'Transition options',
        tags: {
          defaultValue: {
            name: 'defaultValue',
            value: "{name:'overlay-transition--fade'}"
          }
        },
        defaultValue: "{name:'overlay-transition--fade'}",
        highlightedType:
          '{ didTransitionIn?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; didTransitionOut?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; enterClass?: <span class="hljs-built_in">string</span>; enterActiveClass?: <span class="hljs-built_in">string</span>; enterToClass?: <span class="hljs-built_in">string</span>; isEnabled?: <span class="hljs-built_in">boolean</span>; leaveClass?: <span class="hljs-built_in">string</span>; leaveActiveClass?: <span class="hljs-built_in">string</span>; leaveToClass?: <span class="hljs-built_in">string</span>; name?: <span class="hljs-built_in">string</span>; parentSelector?: <span class="hljs-built_in">string</span>; }',
        highlightedDefaultValue:
          '{<span class="hljs-attr">name</span>:<span class="hljs-string">\'overlay-transition--fade\'</span>}'
      },
      {
        identifier: 'transitionDuration',
        type: { type: 'number' },
        isRequired: false,
        isInternal: false,
        description: 'Duration of the animation',
        tags: { defaultValue: { name: 'defaultValue', value: '200' } },
        defaultValue: '200',
        highlightedType: '<span class="hljs-built_in">number</span>',
        highlightedDefaultValue: '<span class="hljs-number">200</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'overlays',
    module: 'popover',
    name: 'Popover',
    fileName: 'packages/overlays/declarations/components/popover.d.ts',
    Args: [
      {
        identifier: 'flipOptions',
        type: { type: 'any' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">any</span>'
      },
      {
        identifier: 'middleware',
        type: {
          type: '{ name: string; options?: any; fn: (state: { placement: Placement; strategy: Strategy; x: number; y: number; initialPlacement: Placement; middlewareData: MiddlewareData; rects: ElementRects; platform: Platform; elements: Elements; }) => Promisable<...>; }[]'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '{ <span class="hljs-attr">name</span>: <span class="hljs-built_in">string</span>; options?: <span class="hljs-built_in">any</span>; fn: <span class="hljs-function">(<span class="hljs-params">state: { placement: Placement; strategy: Strategy; x: <span class="hljs-built_in">number</span>; y: <span class="hljs-built_in">number</span>; initialPlacement: Placement; middlewareData: MiddlewareData; rects: ElementRects; platform: Platform; elements: Elements; }</span>) =></span> Promisable&#x3C;...>; }[]'
      },
      {
        identifier: 'offsetOptions',
        type: { type: 'any' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: '5' } },
        defaultValue: '5',
        highlightedType: '<span class="hljs-built_in">any</span>',
        highlightedDefaultValue: '<span class="hljs-number">5</span>'
      },
      {
        identifier: 'onClose',
        type: { type: '() => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '() => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'placement',
        type: {
          type: 'enum',
          raw: '"top" | "top-start" | "top-end" | "right" | "right-start" | "right-end" | "bottom" | "bottom-start" | "bottom-end" | "left" | "left-start" | "left-end"',
          items: [
            "'top'",
            "'top-start'",
            "'top-end'",
            "'right'",
            "'right-start'",
            "'right-end'",
            "'bottom'",
            "'bottom-start'",
            "'bottom-end'",
            "'left'",
            "'left-start'",
            "'left-end'"
          ]
        },
        isRequired: false,
        isInternal: false,
        description: 'Placement of the menu when open',
        tags: {
          defaultValue: { name: 'defaultValue', value: "'bottom-start'" }
        },
        defaultValue: "'bottom-start'",
        highlightedType:
          '<span class="hljs-string">\'top\'</span> | <span class="hljs-string">\'top-start\'</span> | <span class="hljs-string">\'top-end\'</span> | <span class="hljs-string">\'right\'</span> | <span class="hljs-string">\'right-start\'</span> | <span class="hljs-string">\'right-end\'</span> | <span class="hljs-string">\'bottom\'</span> | <span class="hljs-string">\'bottom-start\'</span> | <span class="hljs-string">\'bottom-end\'</span> | <span class="hljs-string">\'left\'</span> | <span class="hljs-string">\'left-start\'</span> | <span class="hljs-string">\'left-end\'</span>',
        highlightedDefaultValue:
          '<span class="hljs-string">\'bottom-start\'</span>'
      },
      {
        identifier: 'shiftOptions',
        type: { type: 'any' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">any</span>'
      },
      {
        identifier: 'strategy',
        type: {
          type: 'enum',
          raw: 'Strategy',
          items: ["'absolute'", "'fixed'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: "'absolute'" } },
        defaultValue: "'absolute'",
        highlightedType: 'Strategy',
        highlightedDefaultValue: '<span class="hljs-string">\'absolute\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[{ anchor: ModifierLike<{ Element: HTMLElement; }>; isOpen: boolean; toggle: () => void; open: () => void; close: () => void; trigger: ModifierLike<{ Element: HTMLElement; }>; Content: never; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: 'Object',
                items: [
                  {
                    identifier: 'anchor',
                    type: { type: 'ModifierLike<{ Element: HTMLElement; }>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'isOpen',
                    type: { type: 'boolean' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'toggle',
                    type: { type: '() => void' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'open',
                    type: { type: '() => void' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'close',
                    type: { type: '() => void' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'trigger',
                    type: { type: 'ModifierLike<{ Element: HTMLElement; }>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Content',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  }
                ]
              },
              isRequired: true,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLUListElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLUListElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'overlays',
    module: 'popover',
    name: 'Content',
    fileName: 'packages/overlays/declarations/components/popover.d.ts',
    Args: [
      {
        identifier: 'id',
        type: { type: 'string' },
        isRequired: true,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } },
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'isOpen',
        type: { type: 'boolean' },
        isRequired: true,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } },
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'loop',
        type: { type: 'ModifierLike<{ Element: HTMLElement; }>' },
        isRequired: true,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } },
        highlightedType:
          'ModifierLike&#x3C;{ <span class="hljs-attr">Element</span>: HTMLElement; }>'
      },
      {
        identifier: 'toggle',
        type: { type: '() => void' },
        isRequired: true,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } },
        highlightedType: '() => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'backdrop',
        type: {
          type: 'enum',
          raw: '"faded" | "none" | "transparent" | "blur"',
          items: ["'faded'", "'none'", "'transparent'", "'blur'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'faded\'</span> | <span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'transparent\'</span> | <span class="hljs-string">\'blur\'</span>'
      },
      {
        identifier: 'backdropTransition',
        type: {
          type: '{ didTransitionIn?: () => void; didTransitionOut?: () => void; enterClass?: string; enterActiveClass?: string; enterToClass?: string; isEnabled?: boolean; leaveClass?: string; leaveActiveClass?: string; leaveToClass?: string; name?: string; parentSelector?: string; }'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '{ didTransitionIn?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; didTransitionOut?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; enterClass?: <span class="hljs-built_in">string</span>; enterActiveClass?: <span class="hljs-built_in">string</span>; enterToClass?: <span class="hljs-built_in">string</span>; isEnabled?: <span class="hljs-built_in">boolean</span>; leaveClass?: <span class="hljs-built_in">string</span>; leaveActiveClass?: <span class="hljs-built_in">string</span>; leaveToClass?: <span class="hljs-built_in">string</span>; name?: <span class="hljs-built_in">string</span>; parentSelector?: <span class="hljs-built_in">string</span>; }'
      },
      {
        identifier: 'blockScroll',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'closeOnEscapeKey',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Whether to close when the escape key is pressed',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'closeOnOutsideClick',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to close when the area outside (the backdrop) is clicked',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'destinationElementId',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description:
          'The destination where the overlay will be inserted, defaults to\n`document.body`',
        tags: { defaultValue: { name: 'defaultValue', value: 'undefined' } },
        defaultValue: 'undefined',
        highlightedType: '<span class="hljs-built_in">string</span>',
        highlightedDefaultValue: '<span class="hljs-literal">undefined</span>'
      },
      {
        identifier: 'didClose',
        type: { type: '() => void' },
        isRequired: false,
        isInternal: false,
        description:
          'A function that will be called when closing is finished executing, this\nincludes waiting for animations/transitions to finish.',
        tags: {},
        highlightedType: '() => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'disableFocusTrap',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'disableTransitions',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Disable css transitions',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'focusTrapOptions',
        type: { type: 'unknown' },
        isRequired: false,
        isInternal: false,
        description: 'Focus trap options',
        tags: {
          defaultValue: {
            name: 'defaultValue',
            value: '{ allowOutsideClick: true }'
          }
        },
        defaultValue: '{ allowOutsideClick: true }',
        highlightedType: 'unknown',
        highlightedDefaultValue:
          '{ <span class="hljs-attr">allowOutsideClick</span>: <span class="hljs-literal">true</span> }'
      },
      {
        identifier: 'onOpen',
        type: { type: '() => void' },
        isRequired: false,
        isInternal: false,
        description: 'A function that will be called when opened',
        tags: {},
        highlightedType: '() => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'renderInPlace',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to render in place or in the specified/default destination',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "xl" | "md"',
          items: ["'sm'", "'lg'", "'xl'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size of the content.',
        tags: { defaultValue: { name: 'defaultValue', value: "'md'" } },
        defaultValue: "'md'",
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span> | <span class="hljs-string">\'md\'</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: 'transition',
        type: {
          type: '{ didTransitionIn?: () => void; didTransitionOut?: () => void; enterClass?: string; enterActiveClass?: string; enterToClass?: string; isEnabled?: boolean; leaveClass?: string; leaveActiveClass?: string; leaveToClass?: string; name?: string; parentSelector?: string; }'
        },
        isRequired: false,
        isInternal: false,
        description: 'The transition to be used in the Modal.',
        tags: {
          defaultValue: {
            name: 'defaultValue',
            value: "{name: 'overlay-transition--scale'}"
          }
        },
        defaultValue: "{name: 'overlay-transition--scale'}",
        highlightedType:
          '{ didTransitionIn?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; didTransitionOut?: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; enterClass?: <span class="hljs-built_in">string</span>; enterActiveClass?: <span class="hljs-built_in">string</span>; enterToClass?: <span class="hljs-built_in">string</span>; isEnabled?: <span class="hljs-built_in">boolean</span>; leaveClass?: <span class="hljs-built_in">string</span>; leaveActiveClass?: <span class="hljs-built_in">string</span>; leaveToClass?: <span class="hljs-built_in">string</span>; name?: <span class="hljs-built_in">string</span>; parentSelector?: <span class="hljs-built_in">string</span>; }',
        highlightedDefaultValue:
          '{<span class="hljs-attr">name</span>: <span class="hljs-string">\'overlay-transition--scale\'</span>}'
      },
      {
        identifier: 'transitionDuration',
        type: { type: 'number' },
        isRequired: false,
        isInternal: false,
        description: 'Duration of the animation',
        tags: { defaultValue: { name: 'defaultValue', value: '200' } },
        defaultValue: '200',
        highlightedType: '<span class="hljs-built_in">number</span>',
        highlightedDefaultValue: '<span class="hljs-number">200</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'status',
    module: 'my-component',
    name: 'MyComponent',
    fileName: 'packages/status/declarations/components/my-component.d.ts',
    Args: [
      {
        identifier: 'MyArg',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[string]',
          items: [
            {
              identifier: '0',
              type: { type: 'string' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'status',
    module: 'progress-bar',
    name: 'ProgressBar',
    fileName: 'packages/status/declarations/components/progress-bar.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description:
          'Custom class name, it will override the default ones using Tailwind Merge library.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'formatOptions',
        type: { type: 'NumberFormatOptions' },
        isRequired: false,
        isInternal: false,
        description:
          'The display format of the value.\nValues are formatted as a percentage by default.',
        tags: {},
        highlightedType: 'NumberFormatOptions'
      },
      {
        identifier: 'hint',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The content to display as the hint.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'intent',
        type: {
          type: 'enum',
          raw: '"default" | "primary" | "success" | "warning" | "danger"',
          items: [
            "'default'",
            "'primary'",
            "'success'",
            "'warning'",
            "'danger'"
          ]
        },
        isRequired: false,
        isInternal: false,
        description: 'The intent of the progress bar',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>'
      },
      {
        identifier: 'isIndeterminate',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          "Whether presentation is indeterminate when progress isn't known.",
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'label',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The content to display as the label.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'maxValue',
        type: { type: 'number' },
        isRequired: false,
        isInternal: false,
        description: '\nThe largest value allowed for the input',
        tags: { defaultValue: { name: 'defaultValue', value: '100' } },
        defaultValue: '100',
        highlightedType: '<span class="hljs-built_in">number</span>',
        highlightedDefaultValue: '<span class="hljs-number">100</span>'
      },
      {
        identifier: 'minValue',
        type: { type: 'number' },
        isRequired: false,
        isInternal: false,
        description: '\nThe smallest value allowed for the input',
        tags: { defaultValue: { name: 'defaultValue', value: '0' } },
        defaultValue: '0',
        highlightedType: '<span class="hljs-built_in">number</span>',
        highlightedDefaultValue: '<span class="hljs-number">0</span>'
      },
      {
        identifier: 'progress',
        type: { type: 'number' },
        isRequired: false,
        isInternal: false,
        description: 'The current progress value',
        tags: {},
        highlightedType: '<span class="hljs-built_in">number</span>'
      },
      {
        identifier: 'radius',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "none" | "full"',
          items: ["'sm'", "'lg'", "'none'", "'full'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The radius the progress bar',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'full\'</span>'
      },
      {
        identifier: 'showValueLabel',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          "Whether the value's label is displayed.\nTrue by default if there's a label, false by default if not.",
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"xs" | "sm" | "lg" | "md"',
          items: ["'xs'", "'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size of the progress bar',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: 'valueLabel',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description:
          "The content to display as the value's label (e.g. 1 of 4).",
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'utilities',
    module: 'close-button',
    name: 'CloseButton',
    fileName: 'packages/utilities/declarations/components/close-button.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'Additional class for close button element',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'onClick',
        type: { type: '(event: Event) => void' },
        isRequired: false,
        isInternal: false,
        description: 'The function to call when button is clicked',
        tags: {},
        highlightedType:
          '(event: Event) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"xs" | "sm" | "lg" | "xl" | "md"',
          items: ["'xs'", "'sm'", "'lg'", "'xl'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The icon size',
        tags: { defaultValue: { name: 'defaultValue', value: "'lg'" } },
        defaultValue: "'lg'",
        highlightedType:
          '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span> | <span class="hljs-string">\'md\'</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'lg\'</span>'
      },
      {
        identifier: 'title',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The title of the close button',
        tags: { defaultValue: { name: 'defaultValue', value: "'Close'" } },
        defaultValue: "'Close'",
        highlightedType: '<span class="hljs-built_in">string</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'Close\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[string]',
          items: [
            {
              identifier: '0',
              type: { type: 'string' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLButtonElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLButtonElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'utilities',
    module: 'visually-hidden',
    name: 'VisuallyHidden',
    fileName: 'packages/utilities/declarations/components/visually-hidden.d.ts',
    Args: [],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'item',
    name: 'ListboxItem',
    fileName: 'packages/buttons/declarations/components/listbox/item.d.ts',
    Args: [
      {
        identifier: 'key',
        type: { type: 'string' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'manager',
        type: { type: 'ListManager' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'ListManager'
      },
      {
        identifier: 'appearance',
        type: {
          type: 'enum',
          raw: '"default" | "outlined" | "faded"',
          items: ["'default'", "'outlined'", "'faded'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The appearance of each item',
        tags: { defaultValue: { name: 'defaultValue', value: "'default'" } },
        defaultValue: "'default'",
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'outlined\'</span> | <span class="hljs-string">\'faded\'</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'default\'</span>'
      },
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'description',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'intent',
        type: {
          type: 'enum',
          raw: '"default" | "primary" | "success" | "warning" | "danger"',
          items: [
            "'default'",
            "'primary'",
            "'success'",
            "'warning'",
            "'danger'"
          ]
        },
        isRequired: false,
        isInternal: false,
        description: 'The intent of each item',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>'
      },
      {
        identifier: 'onClick',
        type: { type: '() => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '() => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'shortcut',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'textValue',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'type',
        type: {
          type: 'enum',
          raw: '"menu" | "listbox"',
          items: ["'menu'", "'listbox'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'menu\'</span> | <span class="hljs-string">\'listbox\'</span>'
      },
      {
        identifier: 'withDivider',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'selectedIcon',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'start',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'end',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLLIElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLLIElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'listbox',
    name: 'Listbox',
    fileName: 'packages/buttons/declarations/components/listbox/listbox.d.ts',
    Args: [
      {
        identifier: 'allowEmpty',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'appearance',
        type: {
          type: 'enum',
          raw: '"default" | "outlined" | "faded"',
          items: ["'default'", "'outlined'", "'faded'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The appearance of each item',
        tags: { defaultValue: { name: 'defaultValue', value: "'default'" } },
        defaultValue: "'default'",
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'outlined\'</span> | <span class="hljs-string">\'faded\'</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'default\'</span>'
      },
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'disabledKeys',
        type: { type: 'string[]' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>[]'
      },
      {
        identifier: 'intent',
        type: {
          type: 'enum',
          raw: '"default" | "primary" | "success" | "warning" | "danger"',
          items: [
            "'default'",
            "'primary'",
            "'success'",
            "'warning'",
            "'danger'"
          ]
        },
        isRequired: false,
        isInternal: false,
        description: 'The intent of each item',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>'
      },
      {
        identifier: 'isKeyboardEventsEnabled',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'items',
        type: { type: 'unknown[]' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'unknown[]'
      },
      {
        identifier: 'onAction',
        type: { type: '(key: string) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(key: <span class="hljs-built_in">string</span>) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onSelectionChange',
        type: { type: '(key: string[]) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(key: <span class="hljs-built_in">string</span>[]) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'selectedKeys',
        type: { type: 'string[]' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>[]'
      },
      {
        identifier: 'selectionMode',
        type: {
          type: 'enum',
          raw: 'SelectionMode',
          items: ["'none'", "'single'", "'multiple'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'SelectionMode'
      },
      {
        identifier: 'type',
        type: {
          type: 'enum',
          raw: '"menu" | "listbox"',
          items: ["'menu'", "'listbox'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { default: { name: 'default', value: "'listbox'" } },
        highlightedType:
          '<span class="hljs-string">\'menu\'</span> | <span class="hljs-string">\'listbox\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'item',
        type: {
          type: 'Array',
          raw: '[{ item: unknown; Item: never; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: 'Object',
                items: [
                  {
                    identifier: 'item',
                    type: { type: 'unknown' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Item',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  }
                ]
              },
              isRequired: true,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[{ Item: never; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: 'Object',
                items: [
                  {
                    identifier: 'Item',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  }
                ]
              },
              isRequired: true,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLUListElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLUListElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'changeset-form',
    module: 'changeset-form',
    name: 'ChangesetForm',
    fileName:
      'packages/changeset-form/declarations/components/changeset-form/index.d.ts',
    Args: [
      {
        identifier: 'changeset',
        type: { type: 'BufferedChangeset' },
        isRequired: true,
        isInternal: false,
        description: 'Changeset Object',
        tags: {},
        highlightedType: 'BufferedChangeset'
      },
      {
        identifier: 'alwaysShowErrors',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Always show errors if there are any',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'onReset',
        type: { type: '(data: unknown, event: Event) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Callback executed when from `onreset` event is triggered',
        tags: {},
        highlightedType:
          '(data: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onSubmit',
        type: { type: '(data: unknown, event: Event) => void' },
        isRequired: false,
        isInternal: false,
        description:
          'Callback executed when from `onsubmit` event is triggered',
        tags: {},
        highlightedType:
          '(data: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'runExecuteInsteadOfSave',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Run Changeset execute method instead of save',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'validateOnInit',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Validate the changeset on initialization',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[{ Input: never; Textarea: never; Select: never; Checkbox: never; CheckboxGroup: never; Radio: never; RadioGroup: never; state: { hasSubmitted: boolean; }; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: 'Object',
                items: [
                  {
                    identifier: 'Input',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Textarea',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Select',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Checkbox',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'CheckboxGroup',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Radio',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'RadioGroup',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'state',
                    type: { type: '{ hasSubmitted: boolean; }' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  }
                ]
              },
              isRequired: true,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLFormElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLFormElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'item',
    name: 'ListboxItem',
    fileName: 'packages/collections/declarations/components/listbox/item.d.ts',
    Args: [
      {
        identifier: 'key',
        type: { type: 'string' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'manager',
        type: { type: 'ListManager' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'ListManager'
      },
      {
        identifier: 'appearance',
        type: {
          type: 'enum',
          raw: '"default" | "outlined" | "faded"',
          items: ["'default'", "'outlined'", "'faded'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The appearance of each item',
        tags: { defaultValue: { name: 'defaultValue', value: "'default'" } },
        defaultValue: "'default'",
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'outlined\'</span> | <span class="hljs-string">\'faded\'</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'default\'</span>'
      },
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'description',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'intent',
        type: {
          type: 'enum',
          raw: '"default" | "primary" | "success" | "warning" | "danger"',
          items: [
            "'default'",
            "'primary'",
            "'success'",
            "'warning'",
            "'danger'"
          ]
        },
        isRequired: false,
        isInternal: false,
        description: 'The intent of each item',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>'
      },
      {
        identifier: 'onClick',
        type: { type: '() => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '() => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'shortcut',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'textValue',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'type',
        type: {
          type: 'enum',
          raw: '"menu" | "listbox"',
          items: ["'menu'", "'listbox'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'menu\'</span> | <span class="hljs-string">\'listbox\'</span>'
      },
      {
        identifier: 'withDivider',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'selectedIcon',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'start',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'end',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLLIElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLLIElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'listbox',
    name: 'Listbox',
    fileName:
      'packages/collections/declarations/components/listbox/listbox.d.ts',
    Args: [
      {
        identifier: 'allowEmpty',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'appearance',
        type: {
          type: 'enum',
          raw: '"default" | "outlined" | "faded"',
          items: ["'default'", "'outlined'", "'faded'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The appearance of each item',
        tags: { defaultValue: { name: 'defaultValue', value: "'default'" } },
        defaultValue: "'default'",
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'outlined\'</span> | <span class="hljs-string">\'faded\'</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'default\'</span>'
      },
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'disabledKeys',
        type: { type: 'string[]' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>[]'
      },
      {
        identifier: 'intent',
        type: {
          type: 'enum',
          raw: '"default" | "primary" | "success" | "warning" | "danger"',
          items: [
            "'default'",
            "'primary'",
            "'success'",
            "'warning'",
            "'danger'"
          ]
        },
        isRequired: false,
        isInternal: false,
        description: 'The intent of each item',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>'
      },
      {
        identifier: 'isKeyboardEventsEnabled',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'items',
        type: { type: 'unknown[]' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'unknown[]'
      },
      {
        identifier: 'onAction',
        type: { type: '(key: string) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(key: <span class="hljs-built_in">string</span>) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onSelectionChange',
        type: { type: '(key: string[]) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(key: <span class="hljs-built_in">string</span>[]) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'selectedKeys',
        type: { type: 'string[]' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>[]'
      },
      {
        identifier: 'selectionMode',
        type: {
          type: 'enum',
          raw: 'SelectionMode',
          items: ["'none'", "'single'", "'multiple'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'SelectionMode'
      },
      {
        identifier: 'type',
        type: {
          type: 'enum',
          raw: '"menu" | "listbox"',
          items: ["'menu'", "'listbox'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { default: { name: 'default', value: "'listbox'" } },
        highlightedType:
          '<span class="hljs-string">\'menu\'</span> | <span class="hljs-string">\'listbox\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'item',
        type: {
          type: 'Array',
          raw: '[{ item: unknown; Item: never; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: 'Object',
                items: [
                  {
                    identifier: 'item',
                    type: { type: 'unknown' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Item',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  }
                ]
              },
              isRequired: true,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[{ Item: never; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: 'Object',
                items: [
                  {
                    identifier: 'Item',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  }
                ]
              },
              isRequired: true,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLUListElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLUListElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'checkbox',
    name: 'FormFieldCheckbox',
    fileName: 'packages/forms/declarations/components/form-field/checkbox.d.ts',
    Args: [
      {
        identifier: 'checked',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'id',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'name',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'onChange',
        type: { type: '(value: boolean, event: Event) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(value: <span class="hljs-built_in">boolean</span>, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      }
    ],
    Blocks: [],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLInputElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLInputElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'feedback',
    name: 'FormFieldFeedback',
    fileName: 'packages/forms/declarations/components/form-field/feedback.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'errors',
        type: {
          type: 'enum',
          raw: 'string | string[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]'
      },
      {
        identifier: 'id',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'isError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'hint',
    name: 'FormFieldHint',
    fileName: 'packages/forms/declarations/components/form-field/hint.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'id',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'input',
    name: 'FormFieldInput',
    fileName: 'packages/forms/declarations/components/form-field/input.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'id',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'onChange',
        type: { type: '(value: string, event: InputEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onInput',
        type: { type: '(value: string, event: InputEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: 'type',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'value',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      }
    ],
    Blocks: [],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLInputElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLInputElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'label',
    name: 'FormFieldLabel',
    fileName: 'packages/forms/declarations/components/form-field/label.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'for',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLLabelElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'radio',
    name: 'FormFieldRadio',
    fileName: 'packages/forms/declarations/components/form-field/radio.d.ts',
    Args: [
      {
        identifier: 'checked',
        type: { type: 'unknown' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'unknown'
      },
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'id',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'name',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'onChange',
        type: { type: '(value: unknown, event: Event) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(value: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: 'value',
        type: {
          type: 'enum',
          raw: 'string | number | boolean',
          items: ['string', 'number', 'false', 'true']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">number</span> | <span class="hljs-built_in">boolean</span>'
      }
    ],
    Blocks: [],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLInputElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLInputElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'textarea',
    name: 'FormFieldTextarea',
    fileName: 'packages/forms/declarations/components/form-field/textarea.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'id',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'onChange',
        type: { type: '(value: string, event: InputEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onInput',
        type: { type: '(value: string, event: InputEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: 'value',
        type: {
          type: 'enum',
          raw: 'string | number | boolean',
          items: ['string', 'number', 'false', 'true']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">number</span> | <span class="hljs-built_in">boolean</span>'
      }
    ],
    Blocks: [],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLTextAreaElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLTextAreaElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'body',
    name: 'DrawerBody',
    fileName: 'packages/overlays/declarations/components/drawer/body.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'footer',
    name: 'DrawerFooter',
    fileName: 'packages/overlays/declarations/components/drawer/footer.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'header',
    name: 'DrawerHeader',
    fileName: 'packages/overlays/declarations/components/drawer/header.d.ts',
    Args: [
      {
        identifier: 'labelledById',
        type: { type: 'string' },
        isRequired: true,
        isInternal: false,
        description:
          'The id used to reference labelledById in Drawer component',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'overlays',
    module: 'drawer',
    name: 'Drawer',
    fileName: 'packages/overlays/declarations/components/drawer/index.d.ts',
    Args: [
      {
        identifier: 'allowCloseButton',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If set to false, the close button will not be displayed.',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'allowClosing',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'If set to false, the close button will not be displayed,\ncloseOnOutsideClick will be set to false, and closeOnEscapeKey will also be set\nto false.',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'closeButtonSize',
        type: {
          type: 'enum',
          raw: '"xs" | "sm" | "lg" | "xl" | "md"',
          items: ["'xs'", "'sm'", "'lg'", "'xl'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The Close Button size.',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span> | <span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: 'placement',
        type: {
          type: 'enum',
          raw: '"top" | "right" | "bottom" | "left"',
          items: ["'top'", "'right'", "'bottom'", "'left'"]
        },
        isRequired: false,
        isInternal: false,
        description:
          "The Drawer can appear from any side of the screen. The 'placement'\noption allows to choose where it appears from.",
        tags: { defaultValue: { name: 'defaultValue', value: "'right'" } },
        defaultValue: "'right'",
        highlightedType:
          '<span class="hljs-string">\'top\'</span> | <span class="hljs-string">\'right\'</span> | <span class="hljs-string">\'bottom\'</span> | <span class="hljs-string">\'left\'</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'right\'</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"xs" | "sm" | "lg" | "xl" | "md" | "full"',
          items: ["'xs'", "'sm'", "'lg'", "'xl'", "'md'", "'full'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The Drawer size.',
        tags: { defaultValue: { name: 'defaultValue', value: "'md'" } },
        defaultValue: "'md'",
        highlightedType:
          '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span> | <span class="hljs-string">\'md\'</span> | <span class="hljs-string">\'full\'</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: 'transitionName',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The name of the transition to be used in the Drawer.',
        tags: {
          defaultValue: {
            name: 'defaultValue',
            value: "'overlay-transition--slide-from-[placement]'"
          }
        },
        defaultValue: "'overlay-transition--slide-from-[placement]'",
        highlightedType: '<span class="hljs-built_in">string</span>',
        highlightedDefaultValue:
          '<span class="hljs-string">\'overlay-transition--slide-from-[placement]\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[{ CloseButton: any; Header: never; Body: never; Footer: never; headerId: string; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: 'Object',
                items: [
                  {
                    identifier: 'CloseButton',
                    type: { type: 'any' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Header',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Body',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Footer',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'headerId',
                    type: { type: 'string' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  }
                ]
              },
              isRequired: true,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'body',
    name: 'ModalBody',
    fileName: 'packages/overlays/declarations/components/modal/body.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'footer',
    name: 'ModalFooter',
    fileName: 'packages/overlays/declarations/components/modal/footer.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'header',
    name: 'ModalHeader',
    fileName: 'packages/overlays/declarations/components/modal/header.d.ts',
    Args: [
      {
        identifier: 'labelledById',
        type: { type: 'string' },
        isRequired: true,
        isInternal: false,
        description: 'The id used to reference labelledById in Modal component',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'class',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'overlays',
    module: 'modal',
    name: 'Modal',
    fileName: 'packages/overlays/declarations/components/modal/index.d.ts',
    Args: [
      {
        identifier: 'allowCloseButton',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If set to false, the close button will not be displayed.',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'allowClosing',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'If set to false, the close button will not be displayed,\ncloseOnOutsideClick will be set to false, and closeOnEscapeKey will also be set\nto false.',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: 'true',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'closeButtonSize',
        type: {
          type: 'enum',
          raw: '"xs" | "sm" | "lg" | "xl" | "md"',
          items: ["'xs'", "'sm'", "'lg'", "'xl'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The Close Button size.',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span> | <span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: 'isCentered',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If set to true, the modal will be vertically centered',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: 'false',
        highlightedType: '<span class="hljs-built_in">boolean</span>',
        highlightedDefaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"xs" | "sm" | "lg" | "xl" | "md" | "full"',
          items: ["'xs'", "'sm'", "'lg'", "'xl'", "'md'", "'full'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The Modal size.',
        tags: { defaultValue: { name: 'defaultValue', value: "'lg'" } },
        defaultValue: "'lg'",
        highlightedType:
          '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span> | <span class="hljs-string">\'md\'</span> | <span class="hljs-string">\'full\'</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'lg\'</span>'
      },
      {
        identifier: 'transitionName',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The name of the transition to be used in the modal.',
        tags: {
          defaultValue: {
            name: 'defaultValue',
            value: "'overlay-transition--zoom'"
          }
        },
        defaultValue: "'overlay-transition--zoom'",
        highlightedType: '<span class="hljs-built_in">string</span>',
        highlightedDefaultValue:
          '<span class="hljs-string">\'overlay-transition--zoom\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[{ CloseButton: any; Header: never; Body: never; Footer: never; headerId: string; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: 'Object',
                items: [
                  {
                    identifier: 'CloseButton',
                    type: { type: 'any' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Header',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Body',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Footer',
                    type: { type: 'never' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'headerId',
                    type: { type: 'string' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  }
                ]
              },
              isRequired: true,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'utilities',
    module: 'collapsible',
    name: 'Collapsible',
    fileName:
      'packages/utilities/declarations/components/collapsible/index.d.ts',
    Args: [
      {
        identifier: 'isOpen',
        type: { type: 'boolean' },
        isRequired: true,
        isInternal: false,
        description: 'If true, the content will be visible',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'initialHeight',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description:
          "The height for the content in it's collapsed state.\nThe unit of the value should be included, eg. '10px'.",
        tags: { defaultValue: { name: 'defaultValue', value: '0' } },
        defaultValue: '0',
        highlightedType: '<span class="hljs-built_in">string</span>',
        highlightedDefaultValue: '<span class="hljs-number">0</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'base',
    name: 'ChangesetFormFieldsBase',
    fileName:
      'packages/changeset-form/declarations/components/changeset-form/fields/base.d.ts',
    Args: [
      {
        identifier: 'changeset',
        type: { type: 'BufferedChangeset' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'BufferedChangeset'
      },
      {
        identifier: 'fieldName',
        type: { type: 'string' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'errors',
        type: {
          type: 'enum',
          raw: 'string | string[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]'
      }
    ],
    Blocks: [],
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'checkbox-group',
    name: 'ChangesetFormFieldsCheckboxGroup',
    fileName:
      'packages/changeset-form/declarations/components/changeset-form/fields/checkbox-group.d.ts',
    Args: [
      {
        identifier: 'changeset',
        type: { type: 'BufferedChangeset' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'BufferedChangeset'
      },
      {
        identifier: 'fieldName',
        type: { type: 'string' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'containerClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'errors',
        type: { type: 'string[]' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>[]'
      },
      {
        identifier: 'groupName',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'hasError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If has errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'hasSubmitted',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'If the form has been submitted, used to force displaying errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'hint',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'isInline',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If the Checkbox should be in one line',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'label',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The group label',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'onChange',
        type: { type: '(value: unknown, event: Event) => void' },
        isRequired: false,
        isInternal: false,
        description:
          'Default callback added to the yielded FormCheckbox component, called when onchange is triggered',
        tags: {},
        highlightedType:
          '(value: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'showError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Force displaying errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[checkbox: never]',
          items: [
            {
              identifier: '0',
              type: { type: 'never' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'checkbox',
    name: 'ChangesetFormFieldsCheckbox',
    fileName:
      'packages/changeset-form/declarations/components/changeset-form/fields/checkbox.d.ts',
    Args: [
      {
        identifier: 'changeset',
        type: { type: 'BufferedChangeset' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'BufferedChangeset'
      },
      {
        identifier: 'checked',
        type: { type: 'boolean' },
        isRequired: true,
        isInternal: false,
        description:
          'If the checkbox is checked.\nYou must also pass `onChange` to update its value.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'fieldName',
        type: { type: 'string' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'onChange',
        type: { type: '(value: boolean, event: Event) => void' },
        isRequired: true,
        isInternal: false,
        description: 'Callback when onchange is triggered',
        tags: {},
        highlightedType:
          '(value: <span class="hljs-built_in">boolean</span>, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'containerClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'errors',
        type: {
          type: 'enum',
          raw: 'string | string[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]'
      },
      {
        identifier: 'hint',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'label',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The input field label',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'name',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The name of the checkbox',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'privateContainerClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: { ignore: { name: 'ignore', value: '' } },
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: '_groupName',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: '_parentOnChange',
        type: { type: '(value: unknown, event: Event) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Internal function for InputCheckboxGroup',
        tags: {},
        highlightedType:
          '(value: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLInputElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLInputElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'input',
    name: 'ChangesetFormFieldsInput',
    fileName:
      'packages/changeset-form/declarations/components/changeset-form/fields/input.d.ts',
    Args: [
      {
        identifier: 'changeset',
        type: { type: 'BufferedChangeset' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'BufferedChangeset'
      },
      {
        identifier: 'fieldName',
        type: { type: 'string' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'value',
        type: { type: 'string' },
        isRequired: true,
        isInternal: false,
        description:
          'The value to be used in the input.\nYou must also pass `onChange` or `onInput` to update its value.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'containerClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'errors',
        type: {
          type: 'enum',
          raw: 'string | string[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]'
      },
      {
        identifier: 'hasError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If has errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'hasSubmitted',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'If the form has been submitted, used to force displaying errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'hint',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'inputClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the input element',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'label',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The group label',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'onChange',
        type: { type: '(value: string, event: InputEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onchange is triggered',
        tags: {},
        highlightedType:
          '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onFocusIn',
        type: { type: '(event: FocusEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onfocus is triggered',
        tags: {},
        highlightedType:
          '(event: FocusEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onFocusOut',
        type: { type: '(event: FocusEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onblur is triggered',
        tags: {},
        highlightedType:
          '(event: FocusEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onInput',
        type: { type: '(value: string, event: InputEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Callback when oninput is triggered',
        tags: {},
        highlightedType:
          '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'showError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Force displaying errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: 'type',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The input type',
        tags: { defaultValue: { name: 'defaultValue', value: "'text'" } },
        defaultValue: "'text'",
        highlightedType: '<span class="hljs-built_in">string</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'text\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLInputElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLInputElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'radio-group',
    name: 'ChangesetFormFieldsRadioGroup',
    fileName:
      'packages/changeset-form/declarations/components/changeset-form/fields/radio-group.d.ts',
    Args: [
      {
        identifier: 'changeset',
        type: { type: 'BufferedChangeset' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'BufferedChangeset'
      },
      {
        identifier: 'fieldName',
        type: { type: 'string' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'value',
        type: {
          type: 'enum',
          raw: 'string | number | boolean',
          items: ['string', 'number', 'false', 'true']
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">number</span> | <span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'containerClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'errors',
        type: {
          type: 'enum',
          raw: 'string | string[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]'
      },
      {
        identifier: 'hasError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If has errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'hasSubmitted',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'If the form has been submitted, used to force displaying errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'hint',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'isInline',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If the Checkbox should be in one line',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'label',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The group label',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'onChange',
        type: { type: '(value: unknown, event: Event) => void' },
        isRequired: false,
        isInternal: false,
        description:
          'Default callback added to the yielded FormRadio component, called when onchange is triggered',
        tags: {},
        highlightedType:
          '(value: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'showError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Force displaying errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[radio: ComponentLike<FormRadioSignature>]',
          items: [
            {
              identifier: '0',
              type: { type: 'ComponentLike<FormRadioSignature>' },
              isRequired: true,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'radio',
    name: 'ChangesetFormFieldsRadio',
    fileName:
      'packages/changeset-form/declarations/components/changeset-form/fields/radio.d.ts',
    Args: [
      {
        identifier: 'changeset',
        type: { type: 'BufferedChangeset' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'BufferedChangeset'
      },
      {
        identifier: 'checked',
        type: { type: 'unknown' },
        isRequired: true,
        isInternal: false,
        description:
          'The current checked value.\nThis will be used to compare against the `value` argument,\nif equal, the radio will me marked as checked.',
        tags: {},
        highlightedType: 'unknown'
      },
      {
        identifier: 'fieldName',
        type: { type: 'string' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'onChange',
        type: { type: '(value: unknown, event: Event) => void' },
        isRequired: true,
        isInternal: false,
        description: 'Callback when onchange is triggered',
        tags: {},
        highlightedType:
          '(value: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'value',
        type: {
          type: 'enum',
          raw: 'string | number | boolean',
          items: ['string', 'number', 'false', 'true']
        },
        isRequired: true,
        isInternal: false,
        description:
          'The value to be used in the radio button.\nYou must also pass `onChange` to update its value.',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">number</span> | <span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'containerClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'errors',
        type: {
          type: 'enum',
          raw: 'string | string[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]'
      },
      {
        identifier: 'hint',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'label',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The input field label',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'name',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The name of the checkbox',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'privateContainerClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description:
          'CSS classes to be added in the container element, in be used in for group',
        tags: { ignore: { name: 'ignore', value: '' } },
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: '_parentOnChange',
        type: { type: '(value: unknown, event: Event) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Internal function for InputRadioGroup',
        tags: { ignore: { name: 'ignore', value: '' } },
        highlightedType:
          '(value: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLInputElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLInputElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'select',
    name: 'ChangesetFormFieldsSelect',
    fileName:
      'packages/changeset-form/declarations/components/changeset-form/fields/select.d.ts',
    Args: [
      {
        identifier: 'changeset',
        type: { type: 'BufferedChangeset' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'BufferedChangeset'
      },
      {
        identifier: 'fieldName',
        type: { type: 'string' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'onChange',
        type: {
          type: '(selection: unknown, select: Select, event?: Event) => void'
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(selection: unknown, <span class="hljs-attr">select</span>: Select, event?: Event) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'options',
        type: {
          type: 'enum',
          raw: 'any[] | PromiseProxy<any[]>',
          items: ['any[]', 'PromiseProxy<any[]>']
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">any</span>[] | PromiseProxy&#x3C;<span class="hljs-built_in">any</span>[]>'
      },
      {
        identifier: 'selected',
        type: { type: 'any' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">any</span>'
      },
      {
        identifier: 'beforeOptionsComponent',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'buildSelection',
        type: { type: '(selected: any, select: Select) => any' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(selected: <span class="hljs-built_in">any</span>, <span class="hljs-attr">select</span>: Select) => <span class="hljs-built_in">any</span>'
      },
      {
        identifier: 'closeOnSelect',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'containerClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'defaultHighlighted',
        type: { type: 'any' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">any</span>'
      },
      {
        identifier: 'errors',
        type: {
          type: 'enum',
          raw: 'string | string[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]'
      },
      {
        identifier: 'groupComponent',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'hasError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If has errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'hasSubmitted',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'If the form has been submitted, used to force displaying errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'highlightOnHover',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'hint',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'initiallyOpened',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'isMultiple',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If is multiple select instead of single',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'label',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The input field label',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'matcher',
        type: { type: 'MatcherFn' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'MatcherFn'
      },
      {
        identifier: 'matchTriggerWidth',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'noMatchesMessage',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'noMatchesMessageComponent',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'onBlur',
        type: { type: '(select: Select, event: FocusEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(select: Select, <span class="hljs-attr">event</span>: FocusEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onClose',
        type: { type: '(select: Select, e: Event) => boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(select: Select, <span class="hljs-attr">e</span>: Event) => <span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'onFocus',
        type: { type: '(select: Select, event: FocusEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(select: Select, <span class="hljs-attr">event</span>: FocusEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onFocusIn',
        type: { type: '(select: Select, event: FocusEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(select: Select, <span class="hljs-attr">event</span>: FocusEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onFocusOut',
        type: { type: '(select: Select, event: FocusEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(select: Select, <span class="hljs-attr">event</span>: FocusEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onInput',
        type: {
          type: '(term: string, select: Select, e: Event) => string | false | void'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(term: <span class="hljs-built_in">string</span>, <span class="hljs-attr">select</span>: Select, <span class="hljs-attr">e</span>: Event) => <span class="hljs-built_in">string</span> | <span class="hljs-literal">false</span> | <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onKeydown',
        type: { type: '(select: Select, e: KeyboardEvent) => boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(select: Select, <span class="hljs-attr">e</span>: KeyboardEvent) => <span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'onOpen',
        type: { type: '(select: Select, e: Event) => boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(select: Select, <span class="hljs-attr">e</span>: Event) => <span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'optionsComponent',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'placeholderComponent',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'registerAPI',
        type: { type: '(select: Select) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(select: Select) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'scrollTo',
        type: { type: '(option: any, select: Select) => void' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(option: <span class="hljs-built_in">any</span>, <span class="hljs-attr">select</span>: Select) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'search',
        type: {
          type: '(term: string, select: Select) => any[] | PromiseProxy<any[]>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '(term: <span class="hljs-built_in">string</span>, <span class="hljs-attr">select</span>: Select) => <span class="hljs-built_in">any</span>[] | PromiseProxy&#x3C;<span class="hljs-built_in">any</span>[]>'
      },
      {
        identifier: 'searchEnabled',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'searchField',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'searchMessage',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'searchMessageComponent',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'showError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Force displaying errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: 'tabindex',
        type: {
          type: 'enum',
          raw: 'string | number',
          items: ['string', 'number']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">number</span>'
      },
      {
        identifier: 'triggerComponent',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'typeAheadOptionMatcher',
        type: { type: 'MatcherFn' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'MatcherFn'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: 'Array',
          raw: '[option: unknown, select: Select]',
          items: [
            {
              identifier: '0',
              type: { type: 'unknown' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: '1',
              type: {
                type: 'Object',
                items: [
                  {
                    identifier: 'selected',
                    type: { type: 'any' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'highlighted',
                    type: { type: 'any' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'options',
                    type: { type: 'any[]' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'results',
                    type: { type: 'any[]' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'resultsCount',
                    type: { type: 'number' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'loading',
                    type: { type: 'boolean' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'isActive',
                    type: { type: 'boolean' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'searchText',
                    type: { type: 'string' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'lastSearchedText',
                    type: { type: 'string' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'actions',
                    type: { type: 'SelectActions' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'uniqueId',
                    type: { type: 'string' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'disabled',
                    type: { type: 'boolean' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'isOpen',
                    type: { type: 'boolean' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  }
                ]
              },
              isRequired: true,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLDivElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'unknown',
    module: 'textarea',
    name: 'ChangesetFormFieldsTextarea',
    fileName:
      'packages/changeset-form/declarations/components/changeset-form/fields/textarea.d.ts',
    Args: [
      {
        identifier: 'changeset',
        type: { type: 'BufferedChangeset' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: 'BufferedChangeset'
      },
      {
        identifier: 'fieldName',
        type: { type: 'string' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'value',
        type: { type: 'string' },
        isRequired: true,
        isInternal: false,
        description:
          'The value to be used in the input.\nYou must also pass `onChange` or `onInput` to update its value.',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'containerClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'errors',
        type: {
          type: 'enum',
          raw: 'string | string[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {},
        highlightedType:
          '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]'
      },
      {
        identifier: 'hasError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'If has errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'hasSubmitted',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description:
          'If the form has been submitted, used to force displaying errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'hint',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'inputClass',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the input element',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'label',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The group label',
        tags: {},
        highlightedType: '<span class="hljs-built_in">string</span>'
      },
      {
        identifier: 'onChange',
        type: { type: '(value: string, event: InputEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onchange is triggered',
        tags: {},
        highlightedType:
          '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onFocusIn',
        type: { type: '(event: FocusEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onfocus is triggered',
        tags: {},
        highlightedType:
          '(event: FocusEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onFocusOut',
        type: { type: '(event: FocusEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onblur is triggered',
        tags: {},
        highlightedType:
          '(event: FocusEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'onInput',
        type: { type: '(value: string, event: InputEvent) => void' },
        isRequired: false,
        isInternal: false,
        description: 'Callback when oninput is triggered',
        tags: {},
        highlightedType:
          '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
      },
      {
        identifier: 'showError',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: false,
        description: 'Force displaying errors',
        tags: {},
        highlightedType: '<span class="hljs-built_in">boolean</span>'
      },
      {
        identifier: 'size',
        type: {
          type: 'enum',
          raw: '"sm" | "lg" | "md"',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {},
        highlightedType:
          '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: 'type',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The input type',
        tags: { defaultValue: { name: 'defaultValue', value: "'text'" } },
        defaultValue: "'text'",
        highlightedType: '<span class="hljs-built_in">string</span>',
        highlightedDefaultValue: '<span class="hljs-string">\'text\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Array', raw: '[]', items: [] },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLTextAreaElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLTextAreaElement'
    },
    description: '',
    tags: {}
  }
];
