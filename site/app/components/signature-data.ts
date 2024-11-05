import type { ComponentDoc } from 'glimmer-docgen-typescript';
const data: ComponentDoc[] = [
  {
    package: 'buttons',
    module: 'button-group',
    name: 'ButtonGroup',
    fileName: 'packages/buttons/declarations/components/button-group.d.ts',
    Args: [
      {
        identifier: 'appearance',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'outlined\'</span> | <span class="hljs-string">\'minimal\'</span> | <span class="hljs-string">\'custom\'</span>',
          items: ["'default'", "'outlined'", "'minimal'", "'custom'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The button appearance',
        tags: { defaultValue: { name: 'defaultValue', value: "'default'" } },
        defaultValue: '<span class="hljs-string">\'default\'</span>'
      },
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Custom class name, it will override the default ones using Tailwind Merge library.',
        tags: {}
      },
      {
        identifier: 'intent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>',
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
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span>',
          items: ["'xs'", "'sm'", "'lg'", "'xl'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size of the button',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[{ <span class="hljs-attr">Button</span>: <span class="hljs-built_in">never</span>; ToggleButton: <span class="hljs-built_in">never</span>; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: '<span class="hljs-built_in">Object</span>',
                items: [
                  {
                    identifier: 'Button',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'ToggleButton',
                    type: { type: '<span class="hljs-built_in">never</span>' },
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
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'outlined\'</span> | <span class="hljs-string">\'minimal\'</span> | <span class="hljs-string">\'custom\'</span>',
          items: ["'default'", "'outlined'", "'minimal'", "'custom'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The button appearance',
        tags: { defaultValue: { name: 'defaultValue', value: "'default'" } },
        defaultValue: '<span class="hljs-string">\'default\'</span>'
      },
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Custom class name, it will override the default ones using Tailwind Merge library.',
        tags: {}
      },
      {
        identifier: 'intent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>',
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
        tags: {}
      },
      {
        identifier: 'isInGroup',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'If button is part of a group. Most of the time, this is automatically set\nwhen using the ButtonGroup component.',
        tags: {}
      },
      {
        identifier: 'isRenderless',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Disable rendering the button element. It yields an object with classNames instead.',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span>',
          items: ["'xs'", "'sm'", "'lg'", "'xl'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size of the button',
        tags: {}
      },
      {
        identifier: 'type',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'button\'</span> | <span class="hljs-string">\'submit\'</span> | <span class="hljs-string">\'reset\'</span>',
          items: ["'button'", "'submit'", "'reset'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The HTML type of the button',
        tags: { defaultValue: { name: 'defaultValue', value: "'button'" } },
        defaultValue: '<span class="hljs-string">\'button\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[{ <span class="hljs-attr">classNames</span>: <span class="hljs-built_in">string</span>; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: '<span class="hljs-built_in">Object</span>',
                items: [
                  {
                    identifier: 'classNames',
                    type: { type: '<span class="hljs-built_in">string</span>' },
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
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'outlined\'</span> | <span class="hljs-string">\'faded\'</span>',
          items: ["'default'", "'outlined'", "'faded'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The chip appearance',
        tags: { defaultValue: { name: 'defaultValue', value: "'default'" } },
        defaultValue: '<span class="hljs-string">\'default\'</span>'
      },
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Custom class name, it will override the default ones using Tailwind Merge library.',
        tags: {}
      },
      {
        identifier: 'intent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>',
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
        tags: {}
      },
      {
        identifier: 'isDisabled',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Disables the clip and disables the close button if any.',
        tags: {}
      },
      {
        identifier: 'onClose',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '() => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description:
          'Function to be called when clicking on the close button.\nIf you pass this argument, the close button will be visible.',
        tags: {}
      },
      {
        identifier: 'radius',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'full\'</span>',
          items: ["'sm'", "'lg'", "'none'", "'full'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The radius the chip',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size of the chip',
        tags: {}
      },
      {
        identifier: 'withDot',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Option to add dot to the chip',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
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
    module: 'close-button',
    name: 'CloseButton',
    fileName: 'packages/buttons/declarations/components/close-button.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Additional class for close button element',
        tags: {}
      },
      {
        identifier: 'onClick',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(event: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'The function to call when button is clicked',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'xs'", "'sm'", "'lg'", "'xl'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The icon size',
        tags: { defaultValue: { name: 'defaultValue', value: "'lg'" } },
        defaultValue: '<span class="hljs-string">\'lg\'</span>'
      },
      {
        identifier: 'title',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The title of the close button',
        tags: { defaultValue: { name: 'defaultValue', value: "'Close'" } },
        defaultValue: '<span class="hljs-string">\'Close\'</span>'
      },
      {
        identifier: 'variant',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'transparent\'</span> | <span class="hljs-string">\'subtle\'</span>',
          items: ["'transparent'", "'subtle'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {
          defaultValue: { name: 'defaultValue', value: "'transparent'" }
        },
        defaultValue: '<span class="hljs-string">\'transparent\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[<span class="hljs-built_in">string</span>]',
          items: [
            {
              identifier: '0',
              type: { type: '<span class="hljs-built_in">string</span>' },
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
    module: 'toggle-button',
    name: 'ToggleButton',
    fileName: 'packages/buttons/declarations/components/toggle-button.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Custom class name, it will override the default ones using Tailwind Merge library.',
        tags: {}
      },
      {
        identifier: 'intent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>',
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
        tags: {}
      },
      {
        identifier: 'isInGroup',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'If button is part of a group. Most of the time, this is automatically set\nwhen using the ButtonGroup component.',
        tags: {}
      },
      {
        identifier: 'isSelected',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'If the button is currently selected',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(isSelected: <span class="hljs-built_in">boolean</span>) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when the buttle is toggled',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span>',
          items: ["'xs'", "'sm'", "'lg'", "'xl'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size of the button',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
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
    package: 'collections',
    module: 'dropdown',
    name: 'Dropdown',
    fileName: 'packages/collections/declarations/components/dropdown.d.ts',
    Args: [
      {
        identifier: 'closeOnItemSelect',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether the dropdown should close upon selecting an item.',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'didClose',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '() => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'flipOptions',
        type: {
          type: '{ mainAxis?: <span class="hljs-built_in">boolean</span>; crossAxis?: <span class="hljs-built_in">boolean</span>; fallbackPlacements?: Placement[]; fallbackStrategy?: <span class="hljs-string">\'bestFit\'</span> | <span class="hljs-string">\'initialPlacement\'</span>; fallbackAxisSideDirection?: <span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'start\'</span> | <span class="hljs-string">\'end\'</span>; ... <span class="hljs-number">5</span> more ...; boundary?: Boundary; }'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'middleware',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '{ <span class="hljs-attr">name</span>: <span class="hljs-built_in">string</span>; options?: <span class="hljs-built_in">any</span>; fn: <span class="hljs-function">(<span class="hljs-params">state: { placement: Placement; strategy: Strategy; x: <span class="hljs-built_in">number</span>; y: <span class="hljs-built_in">number</span>; initialPlacement: Placement; middlewareData: MiddlewareData; rects: ElementRects; platform: Platform; elements: Elements; }</span>) =></span> Promisable&#x3C;...>; }[]'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'offsetOptions',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: 'OffsetOptions',
          items: [
            'number',
            '{ mainAxis?: number; crossAxis?: number; alignmentAxis?: number; }',
            'Derivable<OffsetValue>'
          ]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: '5' } },
        defaultValue: '<span class="hljs-number">5</span>'
      },
      {
        identifier: 'placement',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'top\'</span> | <span class="hljs-string">\'top-start\'</span> | <span class="hljs-string">\'top-end\'</span> | <span class="hljs-string">\'right\'</span> | <span class="hljs-string">\'right-start\'</span> | <span class="hljs-string">\'right-end\'</span> | <span class="hljs-string">\'bottom\'</span> | <span class="hljs-string">\'bottom-start\'</span> | <span class="hljs-string">\'bottom-end\'</span> | <span class="hljs-string">\'left\'</span> | <span class="hljs-string">\'left-start\'</span> | <span class="hljs-string">\'left-end\'</span>',
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
        defaultValue: '<span class="hljs-string">\'bottom-start\'</span>'
      },
      {
        identifier: 'shiftOptions',
        type: {
          type: '{ mainAxis?: <span class="hljs-built_in">boolean</span>; crossAxis?: <span class="hljs-built_in">boolean</span>; rootBoundary?: RootBoundary; elementContext?: ElementContext; altBoundary?: <span class="hljs-built_in">boolean</span>; padding?: Padding; limiter?: { ...; }; boundary?: Boundary; }'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'strategy',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: 'Strategy',
          items: ["'absolute'", "'fixed'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: "'absolute'" } },
        defaultValue: '<span class="hljs-string">\'absolute\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[{ <span class="hljs-attr">Trigger</span>: <span class="hljs-built_in">never</span>; Menu: <span class="hljs-built_in">never</span>; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: '<span class="hljs-built_in">Object</span>',
                items: [
                  {
                    identifier: 'Trigger',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Menu',
                    type: { type: '<span class="hljs-built_in">never</span>' },
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
        type: {
          type: 'ModifierLike&#x3C;{ <span class="hljs-attr">Element</span>: HTMLElement; }>'
        },
        isRequired: true,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } }
      },
      {
        identifier: 'toggle',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '() => <span class="hljs-built_in">void</span>'
        },
        isRequired: true,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } }
      },
      {
        identifier: 'trigger',
        type: {
          type: 'ModifierLike&#x3C;{ <span class="hljs-attr">Element</span>: HTMLElement; }>'
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'appearance',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'outlined\'</span> | <span class="hljs-string">\'minimal\'</span> | <span class="hljs-string">\'custom\'</span>',
          items: ["'default'", "'outlined'", "'minimal'", "'custom'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The button appearance',
        tags: { defaultValue: { name: 'defaultValue', value: "'default'" } },
        defaultValue: '<span class="hljs-string">\'default\'</span>'
      },
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Custom class name, it will override the default ones using Tailwind Merge library.',
        tags: {}
      },
      {
        identifier: 'intent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>',
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
        tags: {}
      },
      {
        identifier: 'isInGroup',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'If button is part of a group. Most of the time, this is automatically set\nwhen using the ButtonGroup component.',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span>',
          items: ["'xs'", "'sm'", "'lg'", "'xl'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size of the button',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
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
    package: 'collections',
    module: 'dropdown',
    name: 'Menu',
    fileName: 'packages/collections/declarations/components/dropdown.d.ts',
    Args: [
      {
        identifier: 'Content',
        type: { type: '<span class="hljs-built_in">never</span>' },
        isRequired: true,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } }
      },
      {
        identifier: 'toggle',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '() => <span class="hljs-built_in">void</span>'
        },
        isRequired: true,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } }
      },
      {
        identifier: 'allowEmpty',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'appearance',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'outlined\'</span> | <span class="hljs-string">\'faded\'</span>',
          items: ["'default'", "'outlined'", "'faded'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The appearance of each item',
        tags: { defaultValue: { name: 'defaultValue', value: "'default'" } },
        defaultValue: '<span class="hljs-string">\'default\'</span>'
      },
      {
        identifier: 'backdrop',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'faded\'</span> | <span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'transparent\'</span> | <span class="hljs-string">\'blur\'</span>',
          items: ["'faded'", "'none'", "'transparent'", "'blur'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'backdropTransition',
        type: {
          type: '<span class="hljs-built_in">Object</span>',
          items: [
            {
              identifier: 'didTransitionIn',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'didTransitionOut',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'isEnabled',
              type: { type: '<span class="hljs-built_in">boolean</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'name',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'parentSelector',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'blockScroll',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'closeOnEscapeKey',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Whether to close when the escape key is pressed',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'closeOnItemSelect',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } }
      },
      {
        identifier: 'closeOnOutsideClick',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to close when the area outside (the backdrop) is clicked',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'disabledKeys',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '<span class="hljs-built_in">string</span>[]'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'disableFocusTrap',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'disableTransitions',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Disable css transitions',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
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
            value: '{ clickOutsideDeactivates: true, allowOutsideClick: true }'
          }
        },
        defaultValue:
          '{ <span class="hljs-attr">clickOutsideDeactivates</span>: <span class="hljs-literal">true</span>, <span class="hljs-attr">allowOutsideClick</span>: <span class="hljs-literal">true</span> }'
      },
      {
        identifier: 'intent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>',
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
        tags: {}
      },
      {
        identifier: 'onAction',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(key: <span class="hljs-built_in">string</span>) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onSelectionChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(key: <span class="hljs-built_in">string</span>[]) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'renderInPlace',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to render in place or in the specified/default destination',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'selectedKeys',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '<span class="hljs-built_in">string</span>[]'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'selectionMode',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: 'SelectionMode',
          items: ["'none'", "'single'", "'multiple'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'target',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | Element',
          items: ['string', 'Element']
        },
        isRequired: false,
        isInternal: false,
        description:
          'The target where to render the portal.\nThere are 3 options: 1) `Element` object, 2) element id, 3) portal target name.\n\nFor element id, string must be prefixed with `#`.\nIf no value is passee in, we will render to the closest unnamed portal target,\nparent portal or `document.body`.',
        tags: {}
      },
      {
        identifier: 'transition',
        type: {
          type: '<span class="hljs-built_in">Object</span>',
          items: [
            {
              identifier: 'didTransitionIn',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'didTransitionOut',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'isEnabled',
              type: { type: '<span class="hljs-built_in">boolean</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'name',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'parentSelector',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
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
        defaultValue:
          '{<span class="hljs-attr">name</span>: <span class="hljs-string">\'overlay-transition--scale\'</span>}'
      },
      {
        identifier: 'transitionDuration',
        type: { type: '<span class="hljs-built_in">number</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Duration of the animation',
        tags: { defaultValue: { name: 'defaultValue', value: '200' } },
        defaultValue: '<span class="hljs-number">200</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[item: <span class="hljs-built_in">never</span>]',
          items: [
            {
              identifier: '0',
              type: { type: '<span class="hljs-built_in">never</span>' },
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
    module: 'checkbox-group',
    name: 'CheckboxGroup',
    fileName: 'packages/forms/declarations/components/checkbox-group.d.ts',
    Args: [
      {
        identifier: 'classes',
        type: {
          type: 'SlotsToClasses&#x3C;<span class="hljs-string">\'base\'</span> | <span class="hljs-string">\'optionsContainer\'</span> | <span class="hljs-string">\'label\'</span>>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'description',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'isInvalid',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'isRequired',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'name',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">boolean</span>, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'orientation',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'horizontal\'</span> | <span class="hljs-string">\'vertical\'</span>',
          items: ["'horizontal'", "'vertical'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[Checkbox: <span class="hljs-built_in">never</span>]',
          items: [
            {
              identifier: '0',
              type: { type: '<span class="hljs-built_in">never</span>' },
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
    module: 'checkbox',
    name: 'Checkbox',
    fileName: 'packages/forms/declarations/components/checkbox.d.ts',
    Args: [
      {
        identifier: 'checked',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'classes',
        type: {
          type: 'SlotsToClasses&#x3C;<span class="hljs-string">\'base\'</span> | <span class="hljs-string">\'label\'</span> | <span class="hljs-string">\'input\'</span> | <span class="hljs-string">\'labelContainer\'</span>>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'description',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'isInvalid',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'isRequired',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'name',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">boolean</span>, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
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
    package: 'forms',
    module: 'form-control',
    name: 'FormControl',
    fileName: 'packages/forms/declarations/components/form-control.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'description',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'id',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'isInvalid',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'isRequired',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'preventErrorFeedback',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[{ <span class="hljs-attr">id</span>: <span class="hljs-built_in">string</span>; isInvalid: <span class="hljs-built_in">boolean</span>; describedBy: <span class="hljs-function">(<span class="hljs-params">hasDescription?: <span class="hljs-built_in">string</span> | <span class="hljs-built_in">boolean</span>, hasFeedback?: <span class="hljs-built_in">string</span> | <span class="hljs-built_in">boolean</span></span>) =></span> <span class="hljs-built_in">string</span>; Label: <span class="hljs-built_in">never</span>; Description: <span class="hljs-built_in">never</span>; Feedback: <span class="hljs-built_in">never</span>; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: '<span class="hljs-built_in">Object</span>',
                items: [
                  {
                    identifier: 'id',
                    type: { type: '<span class="hljs-built_in">string</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'isInvalid',
                    type: {
                      type: '<span class="hljs-built_in">boolean</span>'
                    },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'describedBy',
                    type: {
                      type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                      raw: '(hasDescription?: <span class="hljs-built_in">string</span> | <span class="hljs-built_in">boolean</span>, hasFeedback?: <span class="hljs-built_in">string</span> | <span class="hljs-built_in">boolean</span>) => <span class="hljs-built_in">string</span>'
                    },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Label',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Description',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Feedback',
                    type: { type: '<span class="hljs-built_in">never</span>' },
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
        identifier: 'label',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'description',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
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
    module: 'form-description',
    name: 'FormDescription',
    fileName: 'packages/forms/declarations/components/form-description.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'id',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
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
    module: 'form-feedback',
    name: 'FormFeedback',
    fileName: 'packages/forms/declarations/components/form-feedback.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'id',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'intent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>',
          items: ["'primary'", "'success'", "'warning'", "'danger'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'messages',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
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
    module: 'form',
    name: 'Form',
    fileName: 'packages/forms/declarations/components/form.d.ts',
    Args: [
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(data: FormResultData, <span class="hljs-attr">eventType</span>: <span class="hljs-string">\'submit\'</span> | <span class="hljs-string">\'input\'</span>, <span class="hljs-attr">event</span>: Event | SubmitEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: {
        type: '<span class="hljs-built_in">Array</span>',
        raw: 'HTMLFormElement'
      },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/Array'
    },
    description: '',
    tags: {}
  },
  {
    package: 'forms',
    module: 'icons',
    name: 'IconChevronUpDown',
    fileName: 'packages/forms/declarations/components/icons.d.ts',
    Args: [],
    Blocks: [],
    Element: {
      identifier: 'Element',
      type: { type: 'SVGElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/SVGElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'forms',
    module: 'input',
    name: 'Input',
    fileName: 'packages/forms/declarations/components/input.d.ts',
    Args: [
      {
        identifier: 'classes',
        type: {
          type: 'SlotsToClasses&#x3C;<span class="hljs-string">\'base\'</span> | <span class="hljs-string">\'input\'</span> | <span class="hljs-string">\'innerContainer\'</span> | <span class="hljs-string">\'startContent\'</span> | <span class="hljs-string">\'endContent\'</span>>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'description',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'endContentPointerEvents',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'auto\'</span>',
          items: ["'none'", "'auto'"]
        },
        isRequired: false,
        isInternal: false,
        description:
          'Controls pointer-events property of endContent.\nIf you want to pass the click event to the input, set it to `none`.',
        tags: { defaultValue: { name: 'defaultValue', value: "'auto'" } },
        defaultValue: '<span class="hljs-string">\'auto\'</span>'
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'isClearable',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Whether to include a clear button',
        tags: {}
      },
      {
        identifier: 'isInvalid',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'isRequired',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'name',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">string</span>, event?: InputEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onchange is triggered',
        tags: {}
      },
      {
        identifier: 'onInput',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">string</span>, event?: InputEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when oninput is triggered',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'startContentPointerEvents',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'auto\'</span>',
          items: ["'none'", "'auto'"]
        },
        isRequired: false,
        isInternal: false,
        description:
          'Controls pointer-events property of startContent.\nIf you want to pass the click event to the input, set it to `none`.',
        tags: { defaultValue: { name: 'defaultValue', value: "'auto'" } },
        defaultValue: '<span class="hljs-string">\'auto\'</span>'
      },
      {
        identifier: 'type',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'value',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'startContent',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'endContent',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
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
    module: 'label',
    name: 'Label',
    fileName: 'packages/forms/declarations/components/label.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The class name to be passed to the label base slot.',
        tags: {}
      },
      {
        identifier: 'classes',
        type: {
          type: 'SlotsToClasses&#x3C;<span class="hljs-string">\'base\'</span> | <span class="hljs-string">\'asterisk\'</span>>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'for',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: "The 'for' attribute of a <label>.",
        tags: {}
      },
      {
        identifier: 'isRequired',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
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
    package: 'forms',
    module: 'native-select',
    name: 'NativeSelect',
    fileName: 'packages/forms/declarations/components/native-select.d.ts',
    Args: [
      {
        identifier: 'allowEmpty',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'classes',
        type: {
          type: 'SlotsToClasses&#x3C;<span class="hljs-string">\'base\'</span> | <span class="hljs-string">\'input\'</span> | <span class="hljs-string">\'innerContainer\'</span> | <span class="hljs-string">\'startContent\'</span> | <span class="hljs-string">\'endContent\'</span> | <span class="hljs-string">\'icon\'</span>>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'description',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'disabledKeys',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '<span class="hljs-built_in">string</span>[]'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'endContentPointerEvents',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'auto\'</span>',
          items: ["'none'", "'auto'"]
        },
        isRequired: false,
        isInternal: false,
        description:
          'Controls pointer-events property of endContent.\nDefauled to `none` to pass the click event to the input. If your content\nneeds to capture events, consider adding `pointer-events-auto` class to that\nelement only.',
        tags: { defaultValue: { name: 'defaultValue', value: "'none'" } },
        defaultValue: '<span class="hljs-string">\'none\'</span>'
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'id',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'isInvalid',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'isRequired',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'items',
        type: { type: '<span class="hljs-built_in">Array</span>', raw: 'T[]' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'name',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onAction',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(key: <span class="hljs-built_in">string</span>) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onItemsChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(items: ListItem[], <span class="hljs-attr">action</span>: <span class="hljs-string">\'add\'</span> | <span class="hljs-string">\'remove\'</span>) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } }
      },
      {
        identifier: 'onSelectionChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(key: <span class="hljs-built_in">string</span>[]) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'placeholder',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Placeholder text used when `allowEmpty` is set to `true`.',
        tags: {}
      },
      {
        identifier: 'selectedKeys',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '<span class="hljs-built_in">string</span>[]'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'selectionMode',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'single\'</span> | <span class="hljs-string">\'multiple\'</span>',
          items: ["'single'", "'multiple'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'startContentPointerEvents',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'auto\'</span>',
          items: ["'none'", "'auto'"]
        },
        isRequired: false,
        isInternal: false,
        description:
          'Controls pointer-events property of startContent.\nIf you want to pass the click event to the input, set it to `none`.',
        tags: { defaultValue: { name: 'defaultValue', value: "'auto'" } },
        defaultValue: '<span class="hljs-string">\'auto\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'item',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[{ <span class="hljs-attr">item</span>: T; key: <span class="hljs-built_in">string</span>; label: <span class="hljs-built_in">string</span>; Item: <span class="hljs-built_in">never</span>; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: '<span class="hljs-built_in">Object</span>',
                items: [
                  {
                    identifier: 'item',
                    type: { type: 'T' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'key',
                    type: { type: '<span class="hljs-built_in">string</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'label',
                    type: { type: '<span class="hljs-built_in">string</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Item',
                    type: { type: '<span class="hljs-built_in">never</span>' },
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
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[{ <span class="hljs-attr">Item</span>: <span class="hljs-built_in">never</span>; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: '<span class="hljs-built_in">Object</span>',
                items: [
                  {
                    identifier: 'Item',
                    type: { type: '<span class="hljs-built_in">never</span>' },
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
        identifier: 'startContent',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'endContent',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: {
        type: '<span class="hljs-built_in">Array</span>',
        raw: 'HTMLSelectElement'
      },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/Array'
    },
    description: '',
    tags: {}
  },
  {
    package: 'forms',
    module: 'native-select',
    name: 'NativeSelectItem',
    fileName: 'packages/forms/declarations/components/native-select.d.ts',
    Args: [
      {
        identifier: 'key',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'manager',
        type: { type: 'ListManager' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'textValue',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'selectedIcon',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'start',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'end',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLOptionElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLOptionElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'forms',
    module: 'radio-group',
    name: 'RadioGroup',
    fileName: 'packages/forms/declarations/components/radio-group.d.ts',
    Args: [
      {
        identifier: 'classes',
        type: {
          type: 'SlotsToClasses&#x3C;<span class="hljs-string">\'base\'</span> | <span class="hljs-string">\'optionsContainer\'</span> | <span class="hljs-string">\'label\'</span>>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'description',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'isInvalid',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'isRequired',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'name',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: T, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'orientation',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'horizontal\'</span> | <span class="hljs-string">\'vertical\'</span>',
          items: ["'horizontal'", "'vertical'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'value',
        type: { type: 'T' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[Radio: <span class="hljs-built_in">never</span>]',
          items: [
            {
              identifier: '0',
              type: { type: '<span class="hljs-built_in">never</span>' },
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
    module: 'radio',
    name: 'Radio',
    fileName: 'packages/forms/declarations/components/radio.d.ts',
    Args: [
      {
        identifier: 'value',
        type: { type: 'T' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'checkedValue',
        type: { type: 'T' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'classes',
        type: {
          type: 'SlotsToClasses&#x3C;<span class="hljs-string">\'base\'</span> | <span class="hljs-string">\'label\'</span> | <span class="hljs-string">\'input\'</span> | <span class="hljs-string">\'labelContainer\'</span>>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'description',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'isInvalid',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'isRequired',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'name',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: T, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
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
    package: 'forms',
    module: 'select',
    name: 'Select',
    fileName: 'packages/forms/declarations/components/select.d.ts',
    Args: [
      {
        identifier: 'allowEmpty',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'appearance',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'outlined\'</span> | <span class="hljs-string">\'faded\'</span>',
          items: ["'default'", "'outlined'", "'faded'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The appearance of each item',
        tags: { defaultValue: { name: 'defaultValue', value: "'default'" } },
        defaultValue: '<span class="hljs-string">\'default\'</span>'
      },
      {
        identifier: 'backdrop',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'faded\'</span> | <span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'transparent\'</span> | <span class="hljs-string">\'blur\'</span>',
          items: ["'faded'", "'none'", "'transparent'", "'blur'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'backdropTransition',
        type: {
          type: '<span class="hljs-built_in">Object</span>',
          items: [
            {
              identifier: 'didTransitionIn',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'didTransitionOut',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'isEnabled',
              type: { type: '<span class="hljs-built_in">boolean</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'name',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'parentSelector',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'blockScroll',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'classes',
        type: {
          type: 'SlotsToClasses&#x3C;<span class="hljs-string">\'base\'</span> | <span class="hljs-string">\'input\'</span> | <span class="hljs-string">\'innerContainer\'</span> | <span class="hljs-string">\'startContent\'</span> | <span class="hljs-string">\'endContent\'</span> | <span class="hljs-string">\'icon\'</span> | <span class="hljs-string">\'placeholder\'</span> | <span class="hljs-string">\'listbox\'</span> | <span class="hljs-string">\'clearButton\'</span>>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'closeOnEscapeKey',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Whether to close when the escape key is pressed',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'closeOnItemSelect',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Whether the select should close upon selecting an item.',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'closeOnOutsideClick',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to close when the area outside (the backdrop) is clicked',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'description',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'didClose',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '() => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'disabledKeys',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '<span class="hljs-built_in">string</span>[]'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'disableFocusTrap',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'disableTransitions',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Disable css transitions',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'endContentPointerEvents',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'auto\'</span>',
          items: ["'none'", "'auto'"]
        },
        isRequired: false,
        isInternal: false,
        description:
          'Controls pointer-events property of endContent.\nDefauled to `none` to pass the click event to the input. If your content\nneeds to capture events, consider adding `pointer-events-auto` class to that\nelement only.',
        tags: { defaultValue: { name: 'defaultValue', value: "'none'" } },
        defaultValue: '<span class="hljs-string">\'none\'</span>'
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'flipOptions',
        type: {
          type: '{ mainAxis?: <span class="hljs-built_in">boolean</span>; crossAxis?: <span class="hljs-built_in">boolean</span>; fallbackPlacements?: Placement[]; fallbackStrategy?: <span class="hljs-string">\'bestFit\'</span> | <span class="hljs-string">\'initialPlacement\'</span>; fallbackAxisSideDirection?: <span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'start\'</span> | <span class="hljs-string">\'end\'</span>; ... <span class="hljs-number">5</span> more ...; boundary?: Boundary; }'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
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
            value: '{ clickOutsideDeactivates: true, allowOutsideClick: true }'
          }
        },
        defaultValue:
          '{ <span class="hljs-attr">clickOutsideDeactivates</span>: <span class="hljs-literal">true</span>, <span class="hljs-attr">allowOutsideClick</span>: <span class="hljs-literal">true</span> }'
      },
      {
        identifier: 'id',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'inputSize',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'intent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>',
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
        tags: {}
      },
      {
        identifier: 'isClearable',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to include a clear button.\nIt ignores the option allowEmpty.',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'isDisabled',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'isInvalid',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'isRequired',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'items',
        type: { type: '<span class="hljs-built_in">Array</span>', raw: 'T[]' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'middleware',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '{ <span class="hljs-attr">name</span>: <span class="hljs-built_in">string</span>; options?: <span class="hljs-built_in">any</span>; fn: <span class="hljs-function">(<span class="hljs-params">state: { placement: Placement; strategy: Strategy; x: <span class="hljs-built_in">number</span>; y: <span class="hljs-built_in">number</span>; initialPlacement: Placement; middlewareData: MiddlewareData; rects: ElementRects; platform: Platform; elements: Elements; }</span>) =></span> Promisable&#x3C;...>; }[]'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'name',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'offsetOptions',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: 'OffsetOptions',
          items: [
            'number',
            '{ mainAxis?: number; crossAxis?: number; alignmentAxis?: number; }',
            'Derivable<OffsetValue>'
          ]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: '5' } },
        defaultValue: '<span class="hljs-number">5</span>'
      },
      {
        identifier: 'onAction',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(key: <span class="hljs-built_in">string</span>) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onSelectionChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(key: <span class="hljs-built_in">string</span>[]) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'placeholder',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'placement',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'top\'</span> | <span class="hljs-string">\'top-start\'</span> | <span class="hljs-string">\'top-end\'</span> | <span class="hljs-string">\'right\'</span> | <span class="hljs-string">\'right-start\'</span> | <span class="hljs-string">\'right-end\'</span> | <span class="hljs-string">\'bottom\'</span> | <span class="hljs-string">\'bottom-start\'</span> | <span class="hljs-string">\'bottom-end\'</span> | <span class="hljs-string">\'left\'</span> | <span class="hljs-string">\'left-start\'</span> | <span class="hljs-string">\'left-end\'</span>',
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
        defaultValue: '<span class="hljs-string">\'bottom-start\'</span>'
      },
      {
        identifier: 'popoverSize',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'renderInPlace',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to render in place or in the specified/default destination',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'selectedKeys',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '<span class="hljs-built_in">string</span>[]'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'selectionMode',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'single\'</span> | <span class="hljs-string">\'multiple\'</span>',
          items: ["'single'", "'multiple'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'shiftOptions',
        type: {
          type: '{ mainAxis?: <span class="hljs-built_in">boolean</span>; crossAxis?: <span class="hljs-built_in">boolean</span>; rootBoundary?: RootBoundary; elementContext?: ElementContext; altBoundary?: <span class="hljs-built_in">boolean</span>; padding?: Padding; limiter?: { ...; }; boundary?: Boundary; }'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'startContentPointerEvents',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'auto\'</span>',
          items: ["'none'", "'auto'"]
        },
        isRequired: false,
        isInternal: false,
        description:
          'Controls pointer-events property of startContent.\nIf you want to pass the click event to the input, set it to `none`.',
        tags: { defaultValue: { name: 'defaultValue', value: "'auto'" } },
        defaultValue: '<span class="hljs-string">\'auto\'</span>'
      },
      {
        identifier: 'strategy',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: 'Strategy',
          items: ["'absolute'", "'fixed'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: "'absolute'" } },
        defaultValue: '<span class="hljs-string">\'absolute\'</span>'
      },
      {
        identifier: 'target',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | Element',
          items: ['string', 'Element']
        },
        isRequired: false,
        isInternal: false,
        description:
          'The target where to render the portal.\nThere are 3 options: 1) `Element` object, 2) element id, 3) portal target name.\n\nFor element id, string must be prefixed with `#`.\nIf no value is passee in, we will render to the closest unnamed portal target,\nparent portal or `document.body`.',
        tags: {}
      },
      {
        identifier: 'transition',
        type: {
          type: '<span class="hljs-built_in">Object</span>',
          items: [
            {
              identifier: 'didTransitionIn',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'didTransitionOut',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'isEnabled',
              type: { type: '<span class="hljs-built_in">boolean</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'name',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'parentSelector',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
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
        defaultValue:
          '{<span class="hljs-attr">name</span>: <span class="hljs-string">\'overlay-transition--scale\'</span>}'
      },
      {
        identifier: 'transitionDuration',
        type: { type: '<span class="hljs-built_in">number</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Duration of the animation',
        tags: { defaultValue: { name: 'defaultValue', value: '200' } },
        defaultValue: '<span class="hljs-number">200</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'item',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[{ <span class="hljs-attr">item</span>: T; key: <span class="hljs-built_in">string</span>; label: <span class="hljs-built_in">string</span>; Item: <span class="hljs-built_in">never</span>; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: '<span class="hljs-built_in">Object</span>',
                items: [
                  {
                    identifier: 'item',
                    type: { type: 'T' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'key',
                    type: { type: '<span class="hljs-built_in">string</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'label',
                    type: { type: '<span class="hljs-built_in">string</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Item',
                    type: { type: '<span class="hljs-built_in">never</span>' },
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
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[{ <span class="hljs-attr">Item</span>: <span class="hljs-built_in">never</span>; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: '<span class="hljs-built_in">Object</span>',
                items: [
                  {
                    identifier: 'Item',
                    type: { type: '<span class="hljs-built_in">never</span>' },
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
        identifier: 'startContent',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'endContent',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
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
    module: 'textarea',
    name: 'Textarea',
    fileName: 'packages/forms/declarations/components/textarea.d.ts',
    Args: [
      {
        identifier: 'classes',
        type: {
          type: 'SlotsToClasses&#x3C;<span class="hljs-string">\'base\'</span> | <span class="hljs-string">\'input\'</span> | <span class="hljs-string">\'innerContainer\'</span> | <span class="hljs-string">\'startContent\'</span> | <span class="hljs-string">\'endContent\'</span>>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'description',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'id',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'isInvalid',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'isRequired',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'name',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onInput',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'value',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">number</span> | <span class="hljs-built_in">boolean</span>',
          items: ['string', 'number', 'false', 'true']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
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
    package: 'forms-legacy',
    module: 'form-checkbox-group',
    name: 'FormCheckboxGroup',
    fileName:
      'packages/forms-legacy/declarations/components/form-checkbox-group.d.ts',
    Args: [
      {
        identifier: 'containerClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {}
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: 'A list of errors or a single text describing the error',
        tags: {}
      },
      {
        identifier: 'hasError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'If has errors',
        tags: {}
      },
      {
        identifier: 'hasSubmitted',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'If the form has been submitted, used to force displaying errors',
        tags: {}
      },
      {
        identifier: 'hint',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {}
      },
      {
        identifier: 'isInline',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'If the Checkbox should be in one line',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The group label',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description:
          'Default callback added to the yielded FormCheckbox component, called when onchange is triggered',
        tags: {}
      },
      {
        identifier: 'showError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Force displaying errors',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[checkbox: <span class="hljs-built_in">never</span>, <span class="hljs-attr">api</span>: { <span class="hljs-attr">onChange</span>: <span class="hljs-function">(<span class="hljs-params">value: unknown, event: Event</span>) =></span> <span class="hljs-built_in">void</span>; }]',
          items: [
            {
              identifier: '0',
              type: { type: '<span class="hljs-built_in">never</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: '1',
              type: {
                type: '<span class="hljs-built_in">Object</span>',
                items: [
                  {
                    identifier: 'onChange',
                    type: {
                      type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                      raw: '(value: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
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
    package: 'forms-legacy',
    module: 'form-checkbox',
    name: 'FormCheckbox',
    fileName:
      'packages/forms-legacy/declarations/components/form-checkbox.d.ts',
    Args: [
      {
        identifier: 'checked',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: true,
        isInternal: false,
        description:
          'If the checkbox is checked.\nYou must also pass `onChange` to update its value.',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">boolean</span>, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: true,
        isInternal: false,
        description: 'Callback when onchange is triggered',
        tags: {}
      },
      {
        identifier: 'containerClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {}
      },
      {
        identifier: 'hint',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The input field label',
        tags: {}
      },
      {
        identifier: 'name',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The name of the checkbox',
        tags: {}
      },
      {
        identifier: 'privateContainerClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: { ignore: { name: 'ignore', value: '' } }
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {}
      },
      {
        identifier: '_parentOnChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">boolean</span>, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Internal function for InputCheckboxGroup',
        tags: { ignore: { name: 'ignore', value: '' } }
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
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
    package: 'forms-legacy',
    module: 'form-field',
    name: 'FormField',
    fileName: 'packages/forms-legacy/declarations/components/form-field.d.ts',
    Args: [
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[{ <span class="hljs-attr">id</span>: <span class="hljs-built_in">string</span>; hintId: <span class="hljs-built_in">string</span>; feedbackId: <span class="hljs-built_in">string</span>; Label: <span class="hljs-built_in">never</span>; Hint: <span class="hljs-built_in">never</span>; Feedback: <span class="hljs-built_in">never</span>; Input: <span class="hljs-built_in">never</span>; Textarea: <span class="hljs-built_in">never</span>; Checkbox: <span class="hljs-built_in">never</span>; Radio: <span class="hljs-built_in">never</span>; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: '<span class="hljs-built_in">Object</span>',
                items: [
                  {
                    identifier: 'id',
                    type: { type: '<span class="hljs-built_in">string</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'hintId',
                    type: { type: '<span class="hljs-built_in">string</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'feedbackId',
                    type: { type: '<span class="hljs-built_in">string</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Label',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Hint',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Feedback',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Input',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Textarea',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Checkbox',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Radio',
                    type: { type: '<span class="hljs-built_in">never</span>' },
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
    package: 'forms-legacy',
    module: 'form-input',
    name: 'FormInputBase',
    fileName: 'packages/forms-legacy/declarations/components/form-input.d.ts',
    Args: [
      {
        identifier: 'value',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: true,
        isInternal: false,
        description:
          'The value to be used in the input.\nYou must also pass `onChange` or `onInput` to update its value.',
        tags: {}
      },
      {
        identifier: 'containerClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {}
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: 'A list of errors or a single text describing the error',
        tags: {}
      },
      {
        identifier: 'hasError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'If has errors',
        tags: {}
      },
      {
        identifier: 'hasSubmitted',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'If the form has been submitted, used to force displaying errors',
        tags: {}
      },
      {
        identifier: 'hint',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {}
      },
      {
        identifier: 'inputClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the input element',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The group label',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onchange is triggered',
        tags: {}
      },
      {
        identifier: 'onFocusIn',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(event: FocusEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onfocus is triggered',
        tags: {}
      },
      {
        identifier: 'onFocusOut',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(event: FocusEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onblur is triggered',
        tags: {}
      },
      {
        identifier: 'onInput',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when oninput is triggered',
        tags: {}
      },
      {
        identifier: 'showError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Force displaying errors',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {}
      },
      {
        identifier: 'type',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The input type',
        tags: { defaultValue: { name: 'defaultValue', value: "'text'" } },
        defaultValue: '<span class="hljs-string">\'text\'</span>'
      }
    ],
    Blocks: [],
    description: '',
    tags: {}
  },
  {
    package: 'forms-legacy',
    module: 'form-input',
    name: 'FormInput',
    fileName: 'packages/forms-legacy/declarations/components/form-input.d.ts',
    Args: [
      {
        identifier: 'value',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: true,
        isInternal: false,
        description:
          'The value to be used in the input.\nYou must also pass `onChange` or `onInput` to update its value.',
        tags: {}
      },
      {
        identifier: 'containerClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {}
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: 'A list of errors or a single text describing the error',
        tags: {}
      },
      {
        identifier: 'hasError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'If has errors',
        tags: {}
      },
      {
        identifier: 'hasSubmitted',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'If the form has been submitted, used to force displaying errors',
        tags: {}
      },
      {
        identifier: 'hint',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {}
      },
      {
        identifier: 'inputClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the input element',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The group label',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onchange is triggered',
        tags: {}
      },
      {
        identifier: 'onFocusIn',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(event: FocusEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onfocus is triggered',
        tags: {}
      },
      {
        identifier: 'onFocusOut',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(event: FocusEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onblur is triggered',
        tags: {}
      },
      {
        identifier: 'onInput',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when oninput is triggered',
        tags: {}
      },
      {
        identifier: 'showError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Force displaying errors',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {}
      },
      {
        identifier: 'type',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The input type',
        tags: { defaultValue: { name: 'defaultValue', value: "'text'" } },
        defaultValue: '<span class="hljs-string">\'text\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
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
    package: 'forms-legacy',
    module: 'form-radio-group',
    name: 'FormRadioGroup',
    fileName:
      'packages/forms-legacy/declarations/components/form-radio-group.d.ts',
    Args: [
      {
        identifier: 'value',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">number</span> | <span class="hljs-built_in">boolean</span>',
          items: ['string', 'number', 'false', 'true']
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'containerClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {}
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: 'A list of errors or a single text describing the error',
        tags: {}
      },
      {
        identifier: 'hasError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'If has errors',
        tags: {}
      },
      {
        identifier: 'hasSubmitted',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'If the form has been submitted, used to force displaying errors',
        tags: {}
      },
      {
        identifier: 'hint',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {}
      },
      {
        identifier: 'isInline',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'If the Checkbox should be in one line',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The group label',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description:
          'Default callback added to the yielded FormRadio component, called when onchange is triggered',
        tags: {}
      },
      {
        identifier: 'showError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Force displaying errors',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[radio: <span class="hljs-built_in">never</span>]',
          items: [
            {
              identifier: '0',
              type: { type: '<span class="hljs-built_in">never</span>' },
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
    package: 'forms-legacy',
    module: 'form-radio',
    name: 'FormRadio',
    fileName: 'packages/forms-legacy/declarations/components/form-radio.d.ts',
    Args: [
      {
        identifier: 'checked',
        type: { type: 'unknown' },
        isRequired: true,
        isInternal: false,
        description:
          'The current checked value.\nThis will be used to compare against the `value` argument,\nif equal, the radio will me marked as checked.',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: true,
        isInternal: false,
        description: 'Callback when onchange is triggered',
        tags: {}
      },
      {
        identifier: 'value',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">number</span> | <span class="hljs-built_in">boolean</span>',
          items: ['string', 'number', 'false', 'true']
        },
        isRequired: true,
        isInternal: false,
        description:
          'The value to be used in the radio button.\nYou must also pass `onChange` to update its value.',
        tags: {}
      },
      {
        identifier: 'containerClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {}
      },
      {
        identifier: 'hint',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The input field label',
        tags: {}
      },
      {
        identifier: 'name',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The name of the checkbox',
        tags: {}
      },
      {
        identifier: 'privateContainerClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'CSS classes to be added in the container element, in be used in for group',
        tags: { ignore: { name: 'ignore', value: '' } }
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {}
      },
      {
        identifier: '_parentOnChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Internal function for InputRadioGroup',
        tags: { ignore: { name: 'ignore', value: '' } }
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
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
    package: 'forms-legacy',
    module: 'form-select',
    name: 'FormSelect',
    fileName: 'packages/forms-legacy/declarations/components/form-select.d.ts',
    Args: [
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(selection: <span class="hljs-built_in">any</span>, <span class="hljs-attr">select</span>: Select, event?: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'afterOptionsComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'allowClear',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'animationEnabled',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'ariaDescribedBy',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'ariaInvalid',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'ariaLabel',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'ariaLabelledBy',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'beforeOptionsComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'buildSelection',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(selected: <span class="hljs-built_in">any</span>, <span class="hljs-attr">select</span>: Select) => <span class="hljs-built_in">any</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'calculatePosition',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: 'CalculatePosition'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'closeOnSelect',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'containerClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {}
      },
      {
        identifier: 'defaultHighlighted',
        type: { type: '<span class="hljs-built_in">any</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'destination',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'disabled',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'dropdownClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'ebdContentComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'ebdTriggerComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: 'A list of errors or a single text describing the error',
        tags: {}
      },
      {
        identifier: 'eventType',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'extra',
        type: { type: '<span class="hljs-built_in">any</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'groupComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'hasError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'If has errors',
        tags: {}
      },
      {
        identifier: 'hasSubmitted',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'If the form has been submitted, used to force displaying errors',
        tags: {}
      },
      {
        identifier: 'highlightOnHover',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'hint',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {}
      },
      {
        identifier: 'horizontalPosition',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'initiallyOpened',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'isMultiple',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'If is multiple select instead of single',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The input field label',
        tags: {}
      },
      {
        identifier: 'labelClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'labelClickAction',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: 'TLabelClickAction',
          items: ["'focus'", "'open'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'labelComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'labelText',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'loadingMessage',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'matcher',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: 'MatcherFn'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'matchTriggerWidth',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'noMatchesMessage',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'noMatchesMessageComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onBlur',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(select: Select, <span class="hljs-attr">event</span>: FocusEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onClose',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(select: Select, <span class="hljs-attr">e</span>: Event) => <span class="hljs-built_in">boolean</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onFocus',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(select: Select, <span class="hljs-attr">event</span>: FocusEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onFocusIn',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(select: Select, <span class="hljs-attr">event</span>: FocusEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onFocusOut',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(select: Select, <span class="hljs-attr">event</span>: FocusEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onInput',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(term: <span class="hljs-built_in">string</span>, <span class="hljs-attr">select</span>: Select, <span class="hljs-attr">e</span>: Event) => <span class="hljs-built_in">string</span> | <span class="hljs-literal">false</span> | <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onKeydown',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(select: Select, <span class="hljs-attr">e</span>: KeyboardEvent) => <span class="hljs-built_in">boolean</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onOpen',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(select: Select, <span class="hljs-attr">e</span>: Event) => <span class="hljs-built_in">boolean</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'options',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-keyword">readonly</span> <span class="hljs-built_in">any</span>[] | <span class="hljs-built_in">Promise</span>&#x3C;<span class="hljs-keyword">readonly</span> <span class="hljs-built_in">any</span>[]>',
          items: ['readonly any[]', 'Promise<readonly any[]>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'optionsComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'placeholder',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'placeholderComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'preventScroll',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'registerAPI',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(select: Select) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'renderInPlace',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'required',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'resultCountMessage',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(resultCount: <span class="hljs-built_in">number</span>) => <span class="hljs-built_in">string</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'rootEventType',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: 'TRootEventType',
          items: ["'click'", "'mousedown'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'scrollTo',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(option: <span class="hljs-built_in">any</span>, <span class="hljs-attr">select</span>: Select) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'search',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(term: <span class="hljs-built_in">string</span>, <span class="hljs-attr">select</span>: Select) => <span class="hljs-keyword">readonly</span> <span class="hljs-built_in">any</span>[] | <span class="hljs-built_in">Promise</span>&#x3C;<span class="hljs-keyword">readonly</span> <span class="hljs-built_in">any</span>[]>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'searchEnabled',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'searchField',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'searchMessage',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'searchMessageComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'searchPlaceholder',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'selected',
        type: { type: '<span class="hljs-built_in">any</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'selectedItemComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'showError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Force displaying errors',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {}
      },
      {
        identifier: 'tabindex',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">number</span>',
          items: ['string', 'number']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'title',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'triggerClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'triggerComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'triggerId',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'triggerRole',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'typeAheadOptionMatcher',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: 'MatcherFn'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'verticalPosition',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
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
                type: '<span class="hljs-built_in">Object</span>',
                items: [
                  {
                    identifier: 'selected',
                    type: { type: '<span class="hljs-built_in">any</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'highlighted',
                    type: { type: '<span class="hljs-built_in">any</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'options',
                    type: {
                      type: '<span class="hljs-built_in">Array</span>',
                      raw: '<span class="hljs-keyword">readonly</span> <span class="hljs-built_in">any</span>[]'
                    },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'results',
                    type: {
                      type: '<span class="hljs-built_in">Array</span>',
                      raw: '<span class="hljs-keyword">readonly</span> <span class="hljs-built_in">any</span>[]'
                    },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'resultsCount',
                    type: { type: '<span class="hljs-built_in">number</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'loading',
                    type: {
                      type: '<span class="hljs-built_in">boolean</span>'
                    },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'isActive',
                    type: {
                      type: '<span class="hljs-built_in">boolean</span>'
                    },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'searchText',
                    type: { type: '<span class="hljs-built_in">string</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'lastSearchedText',
                    type: { type: '<span class="hljs-built_in">string</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'actions',
                    type: {
                      type: '<span class="hljs-built_in">Object</span>',
                      items: [
                        {
                          identifier: 'search',
                          type: {
                            type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                            raw: '(term: <span class="hljs-built_in">string</span>) => <span class="hljs-built_in">void</span>'
                          },
                          isRequired: true,
                          isInternal: false,
                          description: '',
                          tags: {}
                        },
                        {
                          identifier: 'highlight',
                          type: {
                            type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                            raw: '(option: <span class="hljs-built_in">any</span>) => <span class="hljs-built_in">void</span>'
                          },
                          isRequired: true,
                          isInternal: false,
                          description: '',
                          tags: {}
                        },
                        {
                          identifier: 'select',
                          type: {
                            type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                            raw: '(selected: <span class="hljs-built_in">any</span>, e?: Event) => <span class="hljs-built_in">void</span>'
                          },
                          isRequired: true,
                          isInternal: false,
                          description: '',
                          tags: {}
                        },
                        {
                          identifier: 'choose',
                          type: {
                            type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                            raw: '(selected: <span class="hljs-built_in">any</span>, e?: Event) => <span class="hljs-built_in">void</span>'
                          },
                          isRequired: true,
                          isInternal: false,
                          description: '',
                          tags: {}
                        },
                        {
                          identifier: 'scrollTo',
                          type: {
                            type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                            raw: '(option: <span class="hljs-built_in">any</span>) => <span class="hljs-built_in">void</span>'
                          },
                          isRequired: true,
                          isInternal: false,
                          description: '',
                          tags: {}
                        },
                        {
                          identifier: 'labelClick',
                          type: {
                            type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                            raw: '(e: MouseEvent) => <span class="hljs-built_in">void</span>'
                          },
                          isRequired: true,
                          isInternal: false,
                          description: '',
                          tags: {}
                        },
                        {
                          identifier: 'toggle',
                          type: {
                            type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                            raw: '(e?: Event) => <span class="hljs-built_in">void</span>'
                          },
                          isRequired: true,
                          isInternal: false,
                          description: '',
                          tags: {}
                        },
                        {
                          identifier: 'close',
                          type: {
                            type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                            raw: '(e?: Event, skipFocus?: <span class="hljs-built_in">boolean</span>) => <span class="hljs-built_in">void</span>'
                          },
                          isRequired: true,
                          isInternal: false,
                          description: '',
                          tags: {}
                        },
                        {
                          identifier: 'open',
                          type: {
                            type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                            raw: '(e?: Event) => <span class="hljs-built_in">void</span>'
                          },
                          isRequired: true,
                          isInternal: false,
                          description: '',
                          tags: {}
                        },
                        {
                          identifier: 'reposition',
                          type: {
                            type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                            raw: '(...args: <span class="hljs-built_in">any</span>[]) => RepositionChanges'
                          },
                          isRequired: true,
                          isInternal: false,
                          description: '',
                          tags: {}
                        },
                        {
                          identifier: 'registerTriggerElement',
                          type: {
                            type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                            raw: '(e: HTMLElement) => <span class="hljs-built_in">void</span>'
                          },
                          isRequired: true,
                          isInternal: false,
                          description: '',
                          tags: {}
                        },
                        {
                          identifier: 'registerDropdownElement',
                          type: {
                            type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                            raw: '(e: HTMLElement) => <span class="hljs-built_in">void</span>'
                          },
                          isRequired: true,
                          isInternal: false,
                          description: '',
                          tags: {}
                        },
                        {
                          identifier: 'getTriggerElement',
                          type: {
                            type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                            raw: '() => HTMLElement'
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
                    identifier: 'uniqueId',
                    type: { type: '<span class="hljs-built_in">string</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'disabled',
                    type: {
                      type: '<span class="hljs-built_in">boolean</span>'
                    },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'isOpen',
                    type: {
                      type: '<span class="hljs-built_in">boolean</span>'
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
    package: 'forms-legacy',
    module: 'form-textarea',
    name: 'FormTextarea',
    fileName:
      'packages/forms-legacy/declarations/components/form-textarea.d.ts',
    Args: [
      {
        identifier: 'value',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: true,
        isInternal: false,
        description:
          'The value to be used in the input.\nYou must also pass `onChange` or `onInput` to update its value.',
        tags: {}
      },
      {
        identifier: 'containerClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {}
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: 'A list of errors or a single text describing the error',
        tags: {}
      },
      {
        identifier: 'hasError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'If has errors',
        tags: {}
      },
      {
        identifier: 'hasSubmitted',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'If the form has been submitted, used to force displaying errors',
        tags: {}
      },
      {
        identifier: 'hint',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {}
      },
      {
        identifier: 'inputClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the input element',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The group label',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onchange is triggered',
        tags: {}
      },
      {
        identifier: 'onFocusIn',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(event: FocusEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onfocus is triggered',
        tags: {}
      },
      {
        identifier: 'onFocusOut',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(event: FocusEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onblur is triggered',
        tags: {}
      },
      {
        identifier: 'onInput',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when oninput is triggered',
        tags: {}
      },
      {
        identifier: 'showError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Force displaying errors',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {}
      },
      {
        identifier: 'type',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The input type',
        tags: { defaultValue: { name: 'defaultValue', value: "'text'" } },
        defaultValue: '<span class="hljs-string">\'text\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
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
        tags: {}
      },
      {
        identifier: 'placement',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
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
        tags: {}
      },
      {
        identifier: 'spacing',
        type: { type: '<span class="hljs-built_in">number</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Spacing for each notification, in px.',
        tags: { defaultValue: { name: 'defaultValue', value: '16' } },
        defaultValue: '<span class="hljs-number">16</span>'
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
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Custom class name, it will override the default ones using Tailwind Merge library.',
        tags: {}
      },
      {
        identifier: 'placement',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
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
        defaultValue: '<span class="hljs-string">\'bottom-right\'</span>'
      },
      {
        identifier: 'spacing',
        type: { type: '<span class="hljs-built_in">number</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Spacing for each notification, in px.',
        tags: { defaultValue: { name: 'defaultValue', value: '16' } },
        defaultValue: '<span class="hljs-number">16</span>'
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
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'inPlace',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'transition',
        type: {
          type: '<span class="hljs-built_in">Object</span>',
          items: [
            {
              identifier: 'didTransitionIn',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'didTransitionOut',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'isEnabled',
              type: { type: '<span class="hljs-built_in">boolean</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'name',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'parentSelector',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'type',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'faded\'</span> | <span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'transparent\'</span> | <span class="hljs-string">\'blur\'</span>',
          items: ["'faded'", "'none'", "'transparent'", "'blur'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: "'faded'" } },
        defaultValue: '<span class="hljs-string">\'faded\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
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
    module: 'drawer',
    name: 'Drawer',
    fileName: 'packages/overlays/declarations/components/drawer.d.ts',
    Args: [
      {
        identifier: 'isOpen',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: true,
        isInternal: false,
        description: 'Whether it is open or not',
        tags: {}
      },
      {
        identifier: 'allowCloseButton',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'If set to false, the close button will not be displayed.',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'allowClosing',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'If set to false, the close button will not be displayed,\ncloseOnOutsideClick will be set to false, and closeOnEscapeKey will also be set\nto false.',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'backdrop',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'faded\'</span> | <span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'transparent\'</span> | <span class="hljs-string">\'blur\'</span>',
          items: ["'faded'", "'none'", "'transparent'", "'blur'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'backdropTransition',
        type: {
          type: '<span class="hljs-built_in">Object</span>',
          items: [
            {
              identifier: 'didTransitionIn',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'didTransitionOut',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'isEnabled',
              type: { type: '<span class="hljs-built_in">boolean</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'name',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'parentSelector',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'closeButtonSize',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'xs'", "'sm'", "'lg'", "'xl'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The Close Button size.',
        tags: {}
      },
      {
        identifier: 'closeOnEscapeKey',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Whether to close when the escape key is pressed',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'closeOnOutsideClick',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to close when the area outside (the backdrop) is clicked',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'didClose',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '() => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description:
          'A function that will be called when closing is finished executing, this\nincludes waiting for animations/transitions to finish.',
        tags: {}
      },
      {
        identifier: 'disableFocusTrap',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Whether the focus trap is disabled or not',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'disableTransitions',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Disable css transitions',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
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
            value: '{ clickOutsideDeactivates: true, allowOutsideClick: true }'
          }
        },
        defaultValue:
          '{ <span class="hljs-attr">clickOutsideDeactivates</span>: <span class="hljs-literal">true</span>, <span class="hljs-attr">allowOutsideClick</span>: <span class="hljs-literal">true</span> }'
      },
      {
        identifier: 'onClose',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '() => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'A function that will be called when closed',
        tags: {}
      },
      {
        identifier: 'onOpen',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '() => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'A function that will be called when opened',
        tags: {}
      },
      {
        identifier: 'placement',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'top\'</span> | <span class="hljs-string">\'right\'</span> | <span class="hljs-string">\'bottom\'</span> | <span class="hljs-string">\'left\'</span>',
          items: ["'top'", "'right'", "'bottom'", "'left'"]
        },
        isRequired: false,
        isInternal: false,
        description:
          "The Drawer can appear from any side of the screen. The 'placement'\noption allows to choose where it appears from.",
        tags: { defaultValue: { name: 'defaultValue', value: "'right'" } },
        defaultValue: '<span class="hljs-string">\'right\'</span>'
      },
      {
        identifier: 'renderInPlace',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to render in place or in the specified/default destination',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span> | <span class="hljs-string">\'md\'</span> | <span class="hljs-string">\'full\'</span>',
          items: ["'xs'", "'sm'", "'lg'", "'xl'", "'md'", "'full'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The Drawer size.',
        tags: { defaultValue: { name: 'defaultValue', value: "'md'" } },
        defaultValue: '<span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: 'target',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | Element',
          items: ['string', 'Element']
        },
        isRequired: false,
        isInternal: false,
        description:
          'The target where to render the portal.\nThere are 3 options: 1) `Element` object, 2) element id, 3) portal target name.\n\nFor element id, string must be prefixed with `#`.\nIf no value is passee in, we will render to the closest unnamed portal target,\nparent portal or `document.body`.',
        tags: {}
      },
      {
        identifier: 'transition',
        type: {
          type: '<span class="hljs-built_in">Object</span>',
          items: [
            {
              identifier: 'didTransitionIn',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'didTransitionOut',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'isEnabled',
              type: { type: '<span class="hljs-built_in">boolean</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'name',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'parentSelector',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
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
        defaultValue:
          '{<span class="hljs-attr">name</span>: <span class="hljs-string">\'overlay-transition--slide-from-[placement]\'</span>}'
      },
      {
        identifier: 'transitionDuration',
        type: { type: '<span class="hljs-built_in">number</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Duration of the animation',
        tags: { defaultValue: { name: 'defaultValue', value: '200' } },
        defaultValue: '<span class="hljs-number">200</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[{ <span class="hljs-attr">CloseButton</span>: <span class="hljs-built_in">never</span>; Header: <span class="hljs-built_in">never</span>; Body: <span class="hljs-built_in">never</span>; Footer: <span class="hljs-built_in">never</span>; headerId: <span class="hljs-built_in">string</span>; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: '<span class="hljs-built_in">Object</span>',
                items: [
                  {
                    identifier: 'CloseButton',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Header',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Body',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Footer',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'headerId',
                    type: { type: '<span class="hljs-built_in">string</span>' },
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
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: true,
        isInternal: false,
        description: 'Whether it is open or not',
        tags: {}
      },
      {
        identifier: 'allowCloseButton',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'If set to false, the close button will not be displayed.',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'allowClosing',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'If set to false, the close button will not be displayed,\ncloseOnOutsideClick will be set to false, and closeOnEscapeKey will also be set\nto false.',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'backdrop',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'faded\'</span> | <span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'transparent\'</span> | <span class="hljs-string">\'blur\'</span>',
          items: ["'faded'", "'none'", "'transparent'", "'blur'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'backdropTransition',
        type: {
          type: '<span class="hljs-built_in">Object</span>',
          items: [
            {
              identifier: 'didTransitionIn',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'didTransitionOut',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'isEnabled',
              type: { type: '<span class="hljs-built_in">boolean</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'name',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'parentSelector',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'closeButtonSize',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'xs'", "'sm'", "'lg'", "'xl'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The Close Button size.',
        tags: {}
      },
      {
        identifier: 'closeOnEscapeKey',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Whether to close when the escape key is pressed',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'closeOnOutsideClick',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to close when the area outside (the backdrop) is clicked',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'didClose',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '() => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description:
          'A function that will be called when closing is finished executing, this\nincludes waiting for animations/transitions to finish.',
        tags: {}
      },
      {
        identifier: 'disableFocusTrap',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Whether the focus trap is disabled or not',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'disableTransitions',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Disable css transitions',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
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
            value: '{ clickOutsideDeactivates: true, allowOutsideClick: true }'
          }
        },
        defaultValue:
          '{ <span class="hljs-attr">clickOutsideDeactivates</span>: <span class="hljs-literal">true</span>, <span class="hljs-attr">allowOutsideClick</span>: <span class="hljs-literal">true</span> }'
      },
      {
        identifier: 'isCentered',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'If set to true, the modal will be vertically centered',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'onClose',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '() => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'A function that will be called when closed',
        tags: {}
      },
      {
        identifier: 'onOpen',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '() => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'A function that will be called when opened',
        tags: {}
      },
      {
        identifier: 'renderInPlace',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to render in place or in the specified/default destination',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span> | <span class="hljs-string">\'md\'</span> | <span class="hljs-string">\'full\'</span>',
          items: ["'xs'", "'sm'", "'lg'", "'xl'", "'md'", "'full'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The Modal size.',
        tags: { defaultValue: { name: 'defaultValue', value: "'lg'" } },
        defaultValue: '<span class="hljs-string">\'lg\'</span>'
      },
      {
        identifier: 'target',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | Element',
          items: ['string', 'Element']
        },
        isRequired: false,
        isInternal: false,
        description:
          'The target where to render the portal.\nThere are 3 options: 1) `Element` object, 2) element id, 3) portal target name.\n\nFor element id, string must be prefixed with `#`.\nIf no value is passee in, we will render to the closest unnamed portal target,\nparent portal or `document.body`.',
        tags: {}
      },
      {
        identifier: 'transition',
        type: {
          type: '<span class="hljs-built_in">Object</span>',
          items: [
            {
              identifier: 'didTransitionIn',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'didTransitionOut',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'isEnabled',
              type: { type: '<span class="hljs-built_in">boolean</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'name',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'parentSelector',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
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
        defaultValue:
          '{<span class="hljs-attr">name</span>: <span class="hljs-string">\'overlay-transition--zoom\'</span>}'
      },
      {
        identifier: 'transitionDuration',
        type: { type: '<span class="hljs-built_in">number</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Duration of the animation',
        tags: { defaultValue: { name: 'defaultValue', value: '200' } },
        defaultValue: '<span class="hljs-number">200</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[{ <span class="hljs-attr">CloseButton</span>: <span class="hljs-built_in">never</span>; Header: <span class="hljs-built_in">never</span>; Body: <span class="hljs-built_in">never</span>; Footer: <span class="hljs-built_in">never</span>; headerId: <span class="hljs-built_in">string</span>; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: '<span class="hljs-built_in">Object</span>',
                items: [
                  {
                    identifier: 'CloseButton',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Header',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Body',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Footer',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'headerId',
                    type: { type: '<span class="hljs-built_in">string</span>' },
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
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: true,
        isInternal: false,
        description: 'Whether it is open or not',
        tags: {}
      },
      {
        identifier: 'backdrop',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'faded\'</span> | <span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'transparent\'</span> | <span class="hljs-string">\'blur\'</span>',
          items: ["'faded'", "'none'", "'transparent'", "'blur'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'backdropTransition',
        type: {
          type: '<span class="hljs-built_in">Object</span>',
          items: [
            {
              identifier: 'didTransitionIn',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'didTransitionOut',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'isEnabled',
              type: { type: '<span class="hljs-built_in">boolean</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'name',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'parentSelector',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'blockScroll',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'closeOnEscapeKey',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Whether to close when the escape key is pressed',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'closeOnOutsideClick',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to close when the area outside (the backdrop) is clicked',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'closeOnOverlayElementClick',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to close when the overlay element is clicked, used for modal and drawer components.',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'customContentModifier',
        type: {
          type: 'ModifierLike&#x3C;{ <span class="hljs-attr">Element</span>: HTMLElement; }>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'didClose',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '() => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description:
          'A function that will be called when closing is finished executing, this\nincludes waiting for animations/transitions to finish.',
        tags: {}
      },
      {
        identifier: 'disableFlexContent',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'disableFocusTrap',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Whether the focus trap is disabled or not',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'disableTransitions',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Disable css transitions',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
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
            value: '{ clickOutsideDeactivates: true, allowOutsideClick: true }'
          }
        },
        defaultValue:
          '{ <span class="hljs-attr">clickOutsideDeactivates</span>: <span class="hljs-literal">true</span>, <span class="hljs-attr">allowOutsideClick</span>: <span class="hljs-literal">true</span> }'
      },
      {
        identifier: 'onClose',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '() => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'A function that will be called when closed',
        tags: {}
      },
      {
        identifier: 'onOpen',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '() => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'A function that will be called when opened',
        tags: {}
      },
      {
        identifier: 'preventFocusRestore',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'renderInPlace',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to render in place or in the specified/default destination',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'target',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | Element',
          items: ['string', 'Element']
        },
        isRequired: false,
        isInternal: false,
        description:
          'The target where to render the portal.\nThere are 3 options: 1) `Element` object, 2) element id, 3) portal target name.\n\nFor element id, string must be prefixed with `#`.\nIf no value is passee in, we will render to the closest unnamed portal target,\nparent portal or `document.body`.',
        tags: {}
      },
      {
        identifier: 'transition',
        type: {
          type: '<span class="hljs-built_in">Object</span>',
          items: [
            {
              identifier: 'didTransitionIn',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'didTransitionOut',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'isEnabled',
              type: { type: '<span class="hljs-built_in">boolean</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'name',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'parentSelector',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
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
        defaultValue:
          '{<span class="hljs-attr">name</span>:<span class="hljs-string">\'overlay-transition--fade\'</span>}'
      },
      {
        identifier: 'transitionDuration',
        type: { type: '<span class="hljs-built_in">number</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Duration of the animation',
        tags: { defaultValue: { name: 'defaultValue', value: '200' } },
        defaultValue: '<span class="hljs-number">200</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
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
    module: 'popover',
    name: 'Popover',
    fileName: 'packages/overlays/declarations/components/popover.d.ts',
    Args: [
      {
        identifier: 'didClose',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '() => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'flipOptions',
        type: {
          type: '{ mainAxis?: <span class="hljs-built_in">boolean</span>; crossAxis?: <span class="hljs-built_in">boolean</span>; fallbackPlacements?: Placement[]; fallbackStrategy?: <span class="hljs-string">\'bestFit\'</span> | <span class="hljs-string">\'initialPlacement\'</span>; fallbackAxisSideDirection?: <span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'start\'</span> | <span class="hljs-string">\'end\'</span>; ... <span class="hljs-number">5</span> more ...; boundary?: Boundary; }'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'isOpen',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'middleware',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '{ <span class="hljs-attr">name</span>: <span class="hljs-built_in">string</span>; options?: <span class="hljs-built_in">any</span>; fn: <span class="hljs-function">(<span class="hljs-params">state: { placement: Placement; strategy: Strategy; x: <span class="hljs-built_in">number</span>; y: <span class="hljs-built_in">number</span>; initialPlacement: Placement; middlewareData: MiddlewareData; rects: ElementRects; platform: Platform; elements: Elements; }</span>) =></span> Promisable&#x3C;...>; }[]'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'offsetOptions',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: 'OffsetOptions',
          items: [
            'number',
            '{ mainAxis?: number; crossAxis?: number; alignmentAxis?: number; }',
            'Derivable<OffsetValue>'
          ]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: '5' } },
        defaultValue: '<span class="hljs-number">5</span>'
      },
      {
        identifier: 'onOpenChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(isOpen: <span class="hljs-built_in">boolean</span>) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'placement',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'top\'</span> | <span class="hljs-string">\'top-start\'</span> | <span class="hljs-string">\'top-end\'</span> | <span class="hljs-string">\'right\'</span> | <span class="hljs-string">\'right-start\'</span> | <span class="hljs-string">\'right-end\'</span> | <span class="hljs-string">\'bottom\'</span> | <span class="hljs-string">\'bottom-start\'</span> | <span class="hljs-string">\'bottom-end\'</span> | <span class="hljs-string">\'left\'</span> | <span class="hljs-string">\'left-start\'</span> | <span class="hljs-string">\'left-end\'</span>',
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
        defaultValue: '<span class="hljs-string">\'bottom-start\'</span>'
      },
      {
        identifier: 'shiftOptions',
        type: {
          type: '{ mainAxis?: <span class="hljs-built_in">boolean</span>; crossAxis?: <span class="hljs-built_in">boolean</span>; rootBoundary?: RootBoundary; elementContext?: ElementContext; altBoundary?: <span class="hljs-built_in">boolean</span>; padding?: Padding; limiter?: { ...; }; boundary?: Boundary; }'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'strategy',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: 'Strategy',
          items: ["'absolute'", "'fixed'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: "'absolute'" } },
        defaultValue: '<span class="hljs-string">\'absolute\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[{ <span class="hljs-attr">anchor</span>: ModifierLike&#x3C;{ <span class="hljs-attr">Element</span>: HTMLElement; }>; isOpen: <span class="hljs-built_in">boolean</span>; toggle: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; open: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; close: <span class="hljs-function">() =></span> <span class="hljs-built_in">void</span>; trigger: ModifierLike&#x3C;{ <span class="hljs-attr">Element</span>: HTMLElement; Args: { ...; }; }>; Content: <span class="hljs-built_in">never</span>; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: '<span class="hljs-built_in">Object</span>',
                items: [
                  {
                    identifier: 'anchor',
                    type: {
                      type: 'ModifierLike&#x3C;{ <span class="hljs-attr">Element</span>: HTMLElement; }>'
                    },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'isOpen',
                    type: {
                      type: '<span class="hljs-built_in">boolean</span>'
                    },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'toggle',
                    type: {
                      type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                      raw: '() => <span class="hljs-built_in">void</span>'
                    },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'open',
                    type: {
                      type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                      raw: '() => <span class="hljs-built_in">void</span>'
                    },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'close',
                    type: {
                      type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                      raw: '() => <span class="hljs-built_in">void</span>'
                    },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'trigger',
                    type: {
                      type: 'ModifierLike&#x3C;{ <span class="hljs-attr">Element</span>: HTMLElement; Args: { <span class="hljs-attr">Positional</span>: [eventType?: <span class="hljs-string">\'click\'</span> | <span class="hljs-string">\'hover\'</span>]; }; }>'
                    },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Content',
                    type: { type: '<span class="hljs-built_in">never</span>' },
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
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: true,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } }
      },
      {
        identifier: 'internalDidClose',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '() => <span class="hljs-built_in">void</span>'
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: { ignore: { name: 'ignore', value: '' } }
      },
      {
        identifier: 'isOpen',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: true,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } }
      },
      {
        identifier: 'loop',
        type: {
          type: 'ModifierLike&#x3C;{ <span class="hljs-attr">Element</span>: HTMLElement; }>'
        },
        isRequired: true,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } }
      },
      {
        identifier: 'toggle',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '() => <span class="hljs-built_in">void</span>'
        },
        isRequired: true,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } }
      },
      {
        identifier: 'backdrop',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'faded\'</span> | <span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'transparent\'</span> | <span class="hljs-string">\'blur\'</span>',
          items: ["'faded'", "'none'", "'transparent'", "'blur'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'backdropTransition',
        type: {
          type: '<span class="hljs-built_in">Object</span>',
          items: [
            {
              identifier: 'didTransitionIn',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'didTransitionOut',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'isEnabled',
              type: { type: '<span class="hljs-built_in">boolean</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'name',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'parentSelector',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'blockScroll',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'closeOnEscapeKey',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Whether to close when the escape key is pressed',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'closeOnOutsideClick',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to close when the area outside (the backdrop) is clicked',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'didClose',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '() => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description:
          'A function that will be called when closing is finished executing, this\nincludes waiting for animations/transitions to finish.',
        tags: {}
      },
      {
        identifier: 'disableFocusTrap',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'disableTransitions',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Disable css transitions',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
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
            value: '{ clickOutsideDeactivates: true, allowOutsideClick: true }'
          }
        },
        defaultValue:
          '{ <span class="hljs-attr">clickOutsideDeactivates</span>: <span class="hljs-literal">true</span>, <span class="hljs-attr">allowOutsideClick</span>: <span class="hljs-literal">true</span> }'
      },
      {
        identifier: 'onOpen',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '() => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'A function that will be called when opened',
        tags: {}
      },
      {
        identifier: 'preventFocusRestore',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: true,
        description: '',
        tags: { internal: { name: 'internal', value: '' } }
      },
      {
        identifier: 'renderInPlace',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to render in place or in the specified/default destination',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'xl'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size of the content.',
        tags: { defaultValue: { name: 'defaultValue', value: "'md'" } },
        defaultValue: '<span class="hljs-string">\'md\'</span>'
      },
      {
        identifier: 'target',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | Element',
          items: ['string', 'Element']
        },
        isRequired: false,
        isInternal: false,
        description:
          'The target where to render the portal.\nThere are 3 options: 1) `Element` object, 2) element id, 3) portal target name.\n\nFor element id, string must be prefixed with `#`.\nIf no value is passee in, we will render to the closest unnamed portal target,\nparent portal or `document.body`.',
        tags: {}
      },
      {
        identifier: 'transition',
        type: {
          type: '<span class="hljs-built_in">Object</span>',
          items: [
            {
              identifier: 'didTransitionIn',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'didTransitionOut',
              type: {
                type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
                raw: '() => <span class="hljs-built_in">void</span>'
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'enterToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'isEnabled',
              type: { type: '<span class="hljs-built_in">boolean</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveActiveClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'leaveToClass',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'name',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'parentSelector',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
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
        defaultValue:
          '{<span class="hljs-attr">name</span>: <span class="hljs-string">\'overlay-transition--scale\'</span>}'
      },
      {
        identifier: 'transitionDuration',
        type: { type: '<span class="hljs-built_in">number</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Duration of the animation',
        tags: { defaultValue: { name: 'defaultValue', value: '200' } },
        defaultValue: '<span class="hljs-number">200</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
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
    description: 'Component yielded from Popover',
    tags: {}
  },
  {
    package: 'overlays',
    module: 'portal-target',
    name: 'PortalTarget',
    fileName: 'packages/overlays/declarations/components/portal-target.d.ts',
    Args: [
      {
        identifier: 'for',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Target name',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Element: {
      identifier: 'Element',
      type: { type: 'HTMLElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement'
    },
    description: '',
    tags: {}
  },
  {
    package: 'overlays',
    module: 'portal',
    name: 'Portal',
    fileName: 'packages/overlays/declarations/components/portal.d.ts',
    Args: [
      {
        identifier: 'appendToParentPortal',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: 'true' } },
        defaultValue: '<span class="hljs-literal">true</span>'
      },
      {
        identifier: 'renderInPlace',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Whether to render in place or in the specified/default destination',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'target',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | Element',
          items: ['string', 'Element']
        },
        isRequired: false,
        isInternal: false,
        description:
          'The target where to render the portal.\nThere are 3 options: 1) `Element` object, 2) element id, 3) portal target name.\n\nFor element id, string must be prefixed with `#`.\nIf no value is passee in, we will render to the closest unnamed portal target,\nparent portal or `document.body`.',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
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
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'Custom class name, it will override the default ones using Tailwind Merge library.',
        tags: {}
      },
      {
        identifier: 'formatOptions',
        type: {
          type: '<span class="hljs-built_in">Object</span>',
          items: [
            {
              identifier: 'localeMatcher',
              type: {
                type: '<span class="hljs-built_in">enum</span>',
                raw: '<span class="hljs-string">\'lookup\'</span> | <span class="hljs-string">\'best fit\'</span>',
                items: ["'lookup'", "'best fit'"]
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'style',
              type: {
                type: '<span class="hljs-built_in">enum</span>',
                raw: 'keyof NumberFormatOptionsStyleRegistry',
                items: ["'decimal'", "'percent'", "'currency'"]
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'currency',
              type: { type: '<span class="hljs-built_in">string</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'currencyDisplay',
              type: {
                type: '<span class="hljs-built_in">enum</span>',
                raw: 'keyof NumberFormatOptionsCurrencyDisplayRegistry',
                items: ["'symbol'", "'name'", "'code'"]
              },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'useGrouping',
              type: { type: '<span class="hljs-built_in">boolean</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'minimumIntegerDigits',
              type: { type: '<span class="hljs-built_in">number</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'minimumFractionDigits',
              type: { type: '<span class="hljs-built_in">number</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'maximumFractionDigits',
              type: { type: '<span class="hljs-built_in">number</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'minimumSignificantDigits',
              type: { type: '<span class="hljs-built_in">number</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            },
            {
              identifier: 'maximumSignificantDigits',
              type: { type: '<span class="hljs-built_in">number</span>' },
              isRequired: false,
              isInternal: false,
              description: '',
              tags: {}
            }
          ]
        },
        isRequired: false,
        isInternal: false,
        description:
          'The display format of the value.\nValues are formatted as a percentage by default.',
        tags: {}
      },
      {
        identifier: 'hint',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The content to display as the hint.',
        tags: {}
      },
      {
        identifier: 'intent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>',
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
        tags: {}
      },
      {
        identifier: 'isIndeterminate',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          "Whether presentation is indeterminate when progress isn't known.",
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The content to display as the label.',
        tags: {}
      },
      {
        identifier: 'maxValue',
        type: { type: '<span class="hljs-built_in">number</span>' },
        isRequired: false,
        isInternal: false,
        description: '\nThe largest value allowed for the input',
        tags: { defaultValue: { name: 'defaultValue', value: '100' } },
        defaultValue: '<span class="hljs-number">100</span>'
      },
      {
        identifier: 'minValue',
        type: { type: '<span class="hljs-built_in">number</span>' },
        isRequired: false,
        isInternal: false,
        description: '\nThe smallest value allowed for the input',
        tags: { defaultValue: { name: 'defaultValue', value: '0' } },
        defaultValue: '<span class="hljs-number">0</span>'
      },
      {
        identifier: 'progress',
        type: { type: '<span class="hljs-built_in">number</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The current progress value',
        tags: {}
      },
      {
        identifier: 'radius',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'none\'</span> | <span class="hljs-string">\'full\'</span>',
          items: ["'sm'", "'lg'", "'none'", "'full'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The radius the progress bar',
        tags: {}
      },
      {
        identifier: 'showValueLabel',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          "Whether the value's label is displayed.\nTrue by default if there's a label, false by default if not.",
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'xs'", "'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size of the progress bar',
        tags: {}
      },
      {
        identifier: 'valueLabel',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description:
          "The content to display as the value's label (e.g. 1 of 4).",
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
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
    fileName: 'packages/utilities/declarations/components/collapsible.d.ts',
    Args: [
      {
        identifier: 'isOpen',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: true,
        isInternal: false,
        description: 'If true, the content will be visible',
        tags: {}
      },
      {
        identifier: 'initialHeight',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description:
          "The height for the content in it's collapsed state.\nThe unit of the value should be included, eg. '10px'.",
        tags: { defaultValue: { name: 'defaultValue', value: '0' } },
        defaultValue: '<span class="hljs-number">0</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
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
    module: 'divider',
    name: 'Divider',
    fileName: 'packages/utilities/declarations/components/divider.d.ts',
    Args: [
      {
        identifier: 'as',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'orientation',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'horizontal\'</span> | <span class="hljs-string">\'vertical\'</span>',
          items: ["'horizontal'", "'vertical'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [],
    Element: {
      identifier: 'Element',
      type: { type: 'Element' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/Element'
    },
    description: '',
    tags: {}
  },
  {
    package: 'utilities',
    module: 'spinner',
    name: 'Spinner',
    fileName: 'packages/utilities/declarations/components/spinner.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'intent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>',
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
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: "'default'" } },
        defaultValue: '<span class="hljs-string">\'default\'</span>'
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'xs\'</span> | <span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'xl\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'xs'", "'sm'", "'lg'", "'xl'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { defaultValue: { name: 'defaultValue', value: "'md'" } },
        defaultValue: '<span class="hljs-string">\'md\'</span>'
      }
    ],
    Blocks: [],
    Element: {
      identifier: 'Element',
      type: { type: 'SVGElement' },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/SVGElement'
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
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
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
        tags: {}
      },
      {
        identifier: 'alwaysShowErrors',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Always show errors if there are any',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'onReset',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(data: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback executed when from `onreset` event is triggered',
        tags: {}
      },
      {
        identifier: 'onSubmit',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(data: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description:
          'Callback executed when from `onsubmit` event is triggered',
        tags: {}
      },
      {
        identifier: 'runExecuteInsteadOfSave',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Run Changeset execute method instead of save',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      },
      {
        identifier: 'validateOnInit',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Validate the changeset on initialization',
        tags: { defaultValue: { name: 'defaultValue', value: 'false' } },
        defaultValue: '<span class="hljs-literal">false</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[{ <span class="hljs-attr">Input</span>: <span class="hljs-built_in">never</span>; Textarea: <span class="hljs-built_in">never</span>; Select: <span class="hljs-built_in">never</span>; Checkbox: <span class="hljs-built_in">never</span>; CheckboxGroup: <span class="hljs-built_in">never</span>; Radio: <span class="hljs-built_in">never</span>; RadioGroup: <span class="hljs-built_in">never</span>; state: { <span class="hljs-attr">hasSubmitted</span>: <span class="hljs-built_in">boolean</span>; }; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: '<span class="hljs-built_in">Object</span>',
                items: [
                  {
                    identifier: 'Input',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Textarea',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Select',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Checkbox',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'CheckboxGroup',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Radio',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'RadioGroup',
                    type: { type: '<span class="hljs-built_in">never</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'state',
                    type: {
                      type: '<span class="hljs-built_in">Object</span>',
                      items: [
                        {
                          identifier: 'hasSubmitted',
                          type: {
                            type: '<span class="hljs-built_in">boolean</span>'
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
      type: {
        type: '<span class="hljs-built_in">Array</span>',
        raw: 'HTMLFormElement'
      },
      description: '',
      url: 'https://developer.mozilla.org/en-US/docs/Web/API/Array'
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
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'manager',
        type: { type: 'ListManager' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'appearance',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'outlined\'</span> | <span class="hljs-string">\'faded\'</span>',
          items: ["'default'", "'outlined'", "'faded'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The appearance of each item',
        tags: { defaultValue: { name: 'defaultValue', value: "'default'" } },
        defaultValue: '<span class="hljs-string">\'default\'</span>'
      },
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'description',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'intent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>',
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
        tags: {}
      },
      {
        identifier: 'onClick',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '() => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'shortcut',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'textValue',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'type',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'listbox\'</span> | <span class="hljs-string">\'menu\'</span>',
          items: ["'listbox'", "'menu'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'withDivider',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'selectedIcon',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'start',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'end',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
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
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'appearance',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'outlined\'</span> | <span class="hljs-string">\'faded\'</span>',
          items: ["'default'", "'outlined'", "'faded'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The appearance of each item',
        tags: { defaultValue: { name: 'defaultValue', value: "'default'" } },
        defaultValue: '<span class="hljs-string">\'default\'</span>'
      },
      {
        identifier: 'autoActivateFirstItem',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { edefaultValue: { name: 'edefaultValue', value: 'true' } }
      },
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'disabledKeys',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '<span class="hljs-built_in">string</span>[]'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'elementToAddKeyboardEvents',
        type: { type: 'HTMLElement' },
        isRequired: false,
        isInternal: false,
        description:
          'The element to add keyboard events to.\n\nThis does not respect the option `iskeyboardEventsEnabled`.',
        tags: { defaultValue: { name: 'defaultValue', value: 'null' } },
        defaultValue: '<span class="hljs-literal">null</span>'
      },
      {
        identifier: 'intent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'primary\'</span> | <span class="hljs-string">\'success\'</span> | <span class="hljs-string">\'warning\'</span> | <span class="hljs-string">\'danger\'</span>',
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
        tags: {}
      },
      {
        identifier: 'isKeyboardEventsEnabled',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'items',
        type: { type: '<span class="hljs-built_in">Array</span>', raw: 'T[]' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onAction',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(key: <span class="hljs-built_in">string</span>) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onActiveItemChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(key?: <span class="hljs-built_in">string</span>) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onSelectionChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(key: <span class="hljs-built_in">string</span>[]) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'selectedKeys',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '<span class="hljs-built_in">string</span>[]'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'selectionMode',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: 'SelectionMode',
          items: ["'none'", "'single'", "'multiple'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'type',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'listbox\'</span> | <span class="hljs-string">\'menu\'</span>',
          items: ["'listbox'", "'menu'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: { default: { name: 'default', value: "'listbox'" } }
      }
    ],
    Blocks: [
      {
        identifier: 'item',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[{ <span class="hljs-attr">item</span>: T; key: <span class="hljs-built_in">string</span>; label: <span class="hljs-built_in">string</span>; Item: <span class="hljs-built_in">never</span>; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: '<span class="hljs-built_in">Object</span>',
                items: [
                  {
                    identifier: 'item',
                    type: { type: 'T' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'key',
                    type: { type: '<span class="hljs-built_in">string</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'label',
                    type: { type: '<span class="hljs-built_in">string</span>' },
                    isRequired: true,
                    isInternal: false,
                    description: '',
                    tags: {}
                  },
                  {
                    identifier: 'Item',
                    type: { type: '<span class="hljs-built_in">never</span>' },
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
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[{ <span class="hljs-attr">Item</span>: <span class="hljs-built_in">never</span>; }]',
          items: [
            {
              identifier: '0',
              type: {
                type: '<span class="hljs-built_in">Object</span>',
                items: [
                  {
                    identifier: 'Item',
                    type: { type: '<span class="hljs-built_in">never</span>' },
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
    fileName:
      'packages/forms-legacy/declarations/components/form-field/checkbox.d.ts',
    Args: [
      {
        identifier: 'checked',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'id',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'name',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">boolean</span>, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
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
    fileName:
      'packages/forms-legacy/declarations/components/form-field/feedback.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'id',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'isError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
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
    module: 'hint',
    name: 'FormFieldHint',
    fileName:
      'packages/forms-legacy/declarations/components/form-field/hint.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'id',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
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
    module: 'input',
    name: 'FormFieldInput',
    fileName:
      'packages/forms-legacy/declarations/components/form-field/input.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'id',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onInput',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'type',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'value',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
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
    fileName:
      'packages/forms-legacy/declarations/components/form-field/label.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'for',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
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
    fileName:
      'packages/forms-legacy/declarations/components/form-field/radio.d.ts',
    Args: [
      {
        identifier: 'checked',
        type: { type: 'unknown' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'id',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'name',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'value',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">number</span> | <span class="hljs-built_in">boolean</span>',
          items: ['string', 'number', 'false', 'true']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
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
    fileName:
      'packages/forms-legacy/declarations/components/form-field/textarea.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'id',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onInput',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'value',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">number</span> | <span class="hljs-built_in">boolean</span>',
          items: ['string', 'number', 'false', 'true']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
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
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
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
    module: 'footer',
    name: 'DrawerFooter',
    fileName: 'packages/overlays/declarations/components/drawer/footer.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
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
    module: 'header',
    name: 'DrawerHeader',
    fileName: 'packages/overlays/declarations/components/drawer/header.d.ts',
    Args: [
      {
        identifier: 'labelledById',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: true,
        isInternal: false,
        description:
          'The id used to reference labelledById in Drawer component',
        tags: {}
      },
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
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
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
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
    module: 'footer',
    name: 'ModalFooter',
    fileName: 'packages/overlays/declarations/components/modal/footer.d.ts',
    Args: [
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
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
    module: 'header',
    name: 'ModalHeader',
    fileName: 'packages/overlays/declarations/components/modal/header.d.ts',
    Args: [
      {
        identifier: 'labelledById',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: true,
        isInternal: false,
        description: 'The id used to reference labelledById in Modal component',
        tags: {}
      },
      {
        identifier: 'class',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
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
        tags: {}
      },
      {
        identifier: 'fieldName',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
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
        tags: {}
      },
      {
        identifier: 'fieldName',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'containerClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {}
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '<span class="hljs-built_in">string</span>[]'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'groupName',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'hasError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'If has errors',
        tags: {}
      },
      {
        identifier: 'hasSubmitted',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'If the form has been submitted, used to force displaying errors',
        tags: {}
      },
      {
        identifier: 'hint',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {}
      },
      {
        identifier: 'isInline',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'If the Checkbox should be in one line',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The group label',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description:
          'Default callback added to the yielded FormCheckbox component, called when onchange is triggered',
        tags: {}
      },
      {
        identifier: 'showError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Force displaying errors',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[checkbox: <span class="hljs-built_in">never</span>]',
          items: [
            {
              identifier: '0',
              type: { type: '<span class="hljs-built_in">never</span>' },
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
        tags: {}
      },
      {
        identifier: 'checked',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: true,
        isInternal: false,
        description:
          'If the checkbox is checked.\nYou must also pass `onChange` to update its value.',
        tags: {}
      },
      {
        identifier: 'fieldName',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">boolean</span>, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: true,
        isInternal: false,
        description: 'Callback when onchange is triggered',
        tags: {}
      },
      {
        identifier: 'containerClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {}
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'hint',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The input field label',
        tags: {}
      },
      {
        identifier: 'name',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The name of the checkbox',
        tags: {}
      },
      {
        identifier: 'privateContainerClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: { ignore: { name: 'ignore', value: '' } }
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {}
      },
      {
        identifier: '_groupName',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: '_parentOnChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Internal function for InputCheckboxGroup',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
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
        tags: {}
      },
      {
        identifier: 'fieldName',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'value',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: true,
        isInternal: false,
        description:
          'The value to be used in the input.\nYou must also pass `onChange` or `onInput` to update its value.',
        tags: {}
      },
      {
        identifier: 'containerClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {}
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'hasError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'If has errors',
        tags: {}
      },
      {
        identifier: 'hasSubmitted',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'If the form has been submitted, used to force displaying errors',
        tags: {}
      },
      {
        identifier: 'hint',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {}
      },
      {
        identifier: 'inputClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the input element',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The group label',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onchange is triggered',
        tags: {}
      },
      {
        identifier: 'onFocusIn',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(event: FocusEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onfocus is triggered',
        tags: {}
      },
      {
        identifier: 'onFocusOut',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(event: FocusEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onblur is triggered',
        tags: {}
      },
      {
        identifier: 'onInput',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when oninput is triggered',
        tags: {}
      },
      {
        identifier: 'showError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Force displaying errors',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {}
      },
      {
        identifier: 'type',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The input type',
        tags: { defaultValue: { name: 'defaultValue', value: "'text'" } },
        defaultValue: '<span class="hljs-string">\'text\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
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
        tags: {}
      },
      {
        identifier: 'fieldName',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'value',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">number</span> | <span class="hljs-built_in">boolean</span>',
          items: ['string', 'number', 'false', 'true']
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'containerClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {}
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'hasError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'If has errors',
        tags: {}
      },
      {
        identifier: 'hasSubmitted',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'If the form has been submitted, used to force displaying errors',
        tags: {}
      },
      {
        identifier: 'hint',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {}
      },
      {
        identifier: 'isInline',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'If the Checkbox should be in one line',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The group label',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description:
          'Default callback added to the yielded FormRadio component, called when onchange is triggered',
        tags: {}
      },
      {
        identifier: 'showError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Force displaying errors',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[radio: ComponentLike&#x3C;FormRadioSignature>]',
          items: [
            {
              identifier: '0',
              type: { type: 'ComponentLike&#x3C;FormRadioSignature>' },
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
        tags: {}
      },
      {
        identifier: 'checked',
        type: { type: 'unknown' },
        isRequired: true,
        isInternal: false,
        description:
          'The current checked value.\nThis will be used to compare against the `value` argument,\nif equal, the radio will me marked as checked.',
        tags: {}
      },
      {
        identifier: 'fieldName',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: true,
        isInternal: false,
        description: 'Callback when onchange is triggered',
        tags: {}
      },
      {
        identifier: 'value',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">number</span> | <span class="hljs-built_in">boolean</span>',
          items: ['string', 'number', 'false', 'true']
        },
        isRequired: true,
        isInternal: false,
        description:
          'The value to be used in the radio button.\nYou must also pass `onChange` to update its value.',
        tags: {}
      },
      {
        identifier: 'containerClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {}
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'hint',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The input field label',
        tags: {}
      },
      {
        identifier: 'name',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The name of the checkbox',
        tags: {}
      },
      {
        identifier: 'privateContainerClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'CSS classes to be added in the container element, in be used in for group',
        tags: { ignore: { name: 'ignore', value: '' } }
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {}
      },
      {
        identifier: '_parentOnChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: unknown, <span class="hljs-attr">event</span>: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Internal function for InputRadioGroup',
        tags: { ignore: { name: 'ignore', value: '' } }
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
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
        tags: {}
      },
      {
        identifier: 'fieldName',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(selection: unknown, <span class="hljs-attr">select</span>: unknown, event?: Event) => <span class="hljs-built_in">void</span>'
        },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'afterOptionsComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'allowClear',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'animationEnabled',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'ariaDescribedBy',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'ariaInvalid',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'ariaLabel',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'ariaLabelledBy',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'beforeOptionsComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'buildSelection',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(selected: <span class="hljs-built_in">any</span>, <span class="hljs-attr">select</span>: Select) => <span class="hljs-built_in">any</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'calculatePosition',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: 'CalculatePosition'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'closeOnSelect',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'containerClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {}
      },
      {
        identifier: 'defaultHighlighted',
        type: { type: '<span class="hljs-built_in">any</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'destination',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'disabled',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'dropdownClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'ebdContentComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'ebdTriggerComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'eventType',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'extra',
        type: { type: '<span class="hljs-built_in">any</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'groupComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'hasError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'If has errors',
        tags: {}
      },
      {
        identifier: 'hasSubmitted',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'If the form has been submitted, used to force displaying errors',
        tags: {}
      },
      {
        identifier: 'highlightOnHover',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'hint',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {}
      },
      {
        identifier: 'horizontalPosition',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'initiallyOpened',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'isMultiple',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'If is multiple select instead of single',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The input field label',
        tags: {}
      },
      {
        identifier: 'labelClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'labelClickAction',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: 'TLabelClickAction',
          items: ["'focus'", "'open'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'labelComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'labelText',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'loadingMessage',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'matcher',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: 'MatcherFn'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'matchTriggerWidth',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'noMatchesMessage',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'noMatchesMessageComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onBlur',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(select: Select, <span class="hljs-attr">event</span>: FocusEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onClose',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(select: unknown, <span class="hljs-attr">e</span>: Event) => <span class="hljs-built_in">boolean</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onFocus',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(select: Select, <span class="hljs-attr">event</span>: FocusEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onFocusIn',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(select: Select, <span class="hljs-attr">event</span>: FocusEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onFocusOut',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(select: unknown, <span class="hljs-attr">event</span>: FocusEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onInput',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(term: <span class="hljs-built_in">string</span>, <span class="hljs-attr">select</span>: Select, <span class="hljs-attr">e</span>: Event) => <span class="hljs-built_in">string</span> | <span class="hljs-literal">false</span> | <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onKeydown',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(select: Select, <span class="hljs-attr">e</span>: KeyboardEvent) => <span class="hljs-built_in">boolean</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'onOpen',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(select: Select, <span class="hljs-attr">e</span>: Event) => <span class="hljs-built_in">boolean</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'options',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-keyword">readonly</span> <span class="hljs-built_in">any</span>[] | <span class="hljs-built_in">Promise</span>&#x3C;<span class="hljs-keyword">readonly</span> <span class="hljs-built_in">any</span>[]>',
          items: ['readonly any[]', 'Promise<readonly any[]>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'optionsComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'placeholder',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'placeholderComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'preventScroll',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'registerAPI',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(select: Select) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'renderInPlace',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'required',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'resultCountMessage',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(resultCount: <span class="hljs-built_in">number</span>) => <span class="hljs-built_in">string</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'rootEventType',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: 'TRootEventType',
          items: ["'click'", "'mousedown'"]
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'scrollTo',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(option: <span class="hljs-built_in">any</span>, <span class="hljs-attr">select</span>: Select) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'search',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(term: <span class="hljs-built_in">string</span>, <span class="hljs-attr">select</span>: Select) => <span class="hljs-keyword">readonly</span> <span class="hljs-built_in">any</span>[] | <span class="hljs-built_in">Promise</span>&#x3C;<span class="hljs-keyword">readonly</span> <span class="hljs-built_in">any</span>[]>'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'searchEnabled',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'searchField',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'searchMessage',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'searchMessageComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'searchPlaceholder',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'selected',
        type: { type: '<span class="hljs-built_in">any</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'selectedItemComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'showError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Force displaying errors',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {}
      },
      {
        identifier: 'tabindex',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">number</span>',
          items: ['string', 'number']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'title',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'triggerClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'triggerComponent',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | ComponentLike&#x3C;<span class="hljs-built_in">any</span>>',
          items: ['string', 'ComponentLike<any>']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'triggerId',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'triggerRole',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'typeAheadOptionMatcher',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: 'MatcherFn'
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'verticalPosition',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[option: unknown, <span class="hljs-attr">select</span>: unknown]',
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
              type: { type: 'unknown' },
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
        tags: {}
      },
      {
        identifier: 'fieldName',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: true,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'value',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: true,
        isInternal: false,
        description:
          'The value to be used in the input.\nYou must also pass `onChange` or `onInput` to update its value.',
        tags: {}
      },
      {
        identifier: 'containerClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the container element',
        tags: {}
      },
      {
        identifier: 'errors',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-built_in">string</span> | <span class="hljs-built_in">string</span>[]',
          items: ['string', 'string[]']
        },
        isRequired: false,
        isInternal: false,
        description: '',
        tags: {}
      },
      {
        identifier: 'hasError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'If has errors',
        tags: {}
      },
      {
        identifier: 'hasSubmitted',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description:
          'If the form has been submitted, used to force displaying errors',
        tags: {}
      },
      {
        identifier: 'hint',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'A help text to be displayed',
        tags: {}
      },
      {
        identifier: 'inputClass',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'CSS classes to be added in the input element',
        tags: {}
      },
      {
        identifier: 'label',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The group label',
        tags: {}
      },
      {
        identifier: 'onChange',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onchange is triggered',
        tags: {}
      },
      {
        identifier: 'onFocusIn',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(event: FocusEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onfocus is triggered',
        tags: {}
      },
      {
        identifier: 'onFocusOut',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(event: FocusEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when onblur is triggered',
        tags: {}
      },
      {
        identifier: 'onInput',
        type: {
          type: '<span class="hljs-function"><span class="hljs-keyword">function</span></span>',
          raw: '(value: <span class="hljs-built_in">string</span>, <span class="hljs-attr">event</span>: InputEvent) => <span class="hljs-built_in">void</span>'
        },
        isRequired: false,
        isInternal: false,
        description: 'Callback when oninput is triggered',
        tags: {}
      },
      {
        identifier: 'showError',
        type: { type: '<span class="hljs-built_in">boolean</span>' },
        isRequired: false,
        isInternal: false,
        description: 'Force displaying errors',
        tags: {}
      },
      {
        identifier: 'size',
        type: {
          type: '<span class="hljs-built_in">enum</span>',
          raw: '<span class="hljs-string">\'sm\'</span> | <span class="hljs-string">\'lg\'</span> | <span class="hljs-string">\'md\'</span>',
          items: ["'sm'", "'lg'", "'md'"]
        },
        isRequired: false,
        isInternal: false,
        description: 'The size',
        tags: {}
      },
      {
        identifier: 'type',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The input type',
        tags: { defaultValue: { name: 'defaultValue', value: "'text'" } },
        defaultValue: '<span class="hljs-string">\'text\'</span>'
      }
    ],
    Blocks: [
      {
        identifier: 'default',
        type: {
          type: '<span class="hljs-built_in">Array</span>',
          raw: '[]',
          items: []
        },
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
export type { ComponentDoc };
export default data;
