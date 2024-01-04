import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { tv } from 'tailwind-variants';

const button = tv({
  base: 'leading-tight inline-block	font-semibold border border-transparent rounded disabled:cursor-not-allowed	disabled:opacity-40',
  variants: {
    appearance: {
      default: '',
      outlined: '',
      minimal: '',
      custom: ''
    },
    intent: {
      default: '',
      primary: '',
      success: '',
      warning: '',
      danger: ''
    },
    size: {
      xs: 'text-sm py-1 px-2',
      sm: 'text-base px-3 py-2',
      md: 'text-base px-4 py-3',
      lg: 'text-base px-4 py-4',
      xl: 'text-xl px-6 py-5'
    }
  },
  compoundVariants: [
    // APPEARANCE: default
    {
      appearance: 'default',
      intent: 'default',
      class: 'text-white bg-gray-700 hover:bg-gray-800 active:bg-gray-900'
    },
    {
      appearance: 'default',
      intent: 'primary',
      class: 'text-white bg-blue-700 hover:bg-blue-800 active:bg-blue-900'
    },
    {
      appearance: 'default',
      intent: 'success',
      class: 'text-white bg-green-600 hover:bg-green-700 active:bg-green-800'
    },
    {
      appearance: 'default',
      intent: 'warning',
      class: 'text-white bg-yellow-600 hover:bg-yellow-700 active:bg-yellow-800'
    },
    {
      appearance: 'default',
      intent: 'danger',
      class: 'text-white bg-red-600 hover:bg-red-700 active:bg-red-800'
    },

    // APPEARANCE: minimal
    {
      appearance: 'minimal',
      intent: 'default',
      class:
        'text-gray-700 hover:text-white hover:bg-gray-800 active:bg-gray-900'
    },
    {
      appearance: 'minimal',
      intent: 'primary',
      class:
        'text-blue-700 hover:text-white hover:bg-blue-800 active:bg-blue-900'
    },
    {
      appearance: 'minimal',
      intent: 'success',
      class:
        'text-green-600 hover:text-white hover:bg-green-700 active:bg-green-800'
    },
    {
      appearance: 'minimal',
      intent: 'warning',
      class:
        'text-yellow-600 hover:text-white hover:bg-yellow-700 active:bg-yellow-800'
    },
    {
      appearance: 'minimal',
      intent: 'danger',
      class: 'text-red-600 hover:text-white hover:bg-red-700 active:bg-red-800'
    },

    // APPEARANCE: outlined
    {
      appearance: 'outlined',
      intent: 'default',
      class:
        'text-gray-700 border-gray-700 hover:text-white hover:bg-gray-700 active:bg-gray-800'
    },
    {
      appearance: 'outlined',
      intent: 'primary',
      class:
        'text-blue-700 border-blue-700 hover:text-white hover:bg-blue-700 active:bg-blue-800'
    },
    {
      appearance: 'outlined',
      intent: 'success',
      class:
        'text-green-600 border-green-600 hover:text-white hover:bg-green-600 active:bg-green-700'
    },
    {
      appearance: 'outlined',
      intent: 'warning',
      class:
        'text-yellow-600 border-yellow-600 hover:text-white hover:bg-yellow-600 active:bg-yellow-700'
    },
    {
      appearance: 'outlined',
      intent: 'danger',
      class:
        'text-red-600 border-red-600 hover:text-white hover:bg-red-600 active:bg-red-700'
    },

    // APPEARANCE: custom
    {
      appearance: 'custom',
      intent: 'default',
      class: 'text-gray-700'
    },
    {
      appearance: 'custom',
      intent: 'primary',
      class: 'text-blue-700'
    },
    {
      appearance: 'custom',
      intent: 'success',
      class: 'text-green-600'
    },
    {
      appearance: 'custom',
      intent: 'warning',
      class: 'text-yellow-600'
    },
    {
      appearance: 'custom',
      intent: 'danger',
      class: 'text-red-600'
    }
  ],
  defaultVariants: {
    size: 'md',
    intent: 'primary'
  }
});

export interface ButtonArgs {
  /**
   * The HTML type of the button
   *
   * @defaultValue 'button'
   */
  type?: 'button' | 'submit' | 'reset';

  /**
   * The button appearance
   *
   * @defaultValue 'default'
   */
  appearance?: 'default' | 'outlined' | 'minimal' | 'custom';

  /**
   * The intent of the button
   */
  intent?: 'default' | 'primary' | 'success' | 'warning' | 'danger';

  /**
   * The size of the button
   */
  size?: 'xs' | 'sm' | 'lg' | 'xl';

  /**
   * Disable rendering the button element. It yields an object with classNames instead.
   */
  isRenderless?: boolean;
}

export interface ButtonSignature {
  Args: ButtonArgs;
  Blocks: {
    default: [{ classNames: string }];
  };
  Element: HTMLButtonElement;
}

export default class Button extends Component<ButtonSignature> {
  get type(): string {
    if (this.args.type) {
      return this.args.type;
    }
    return 'button';
  }

  get classNames(): string {
    return button({
      intent: this.args.intent || 'default',
      size: this.args.size,
      appearance: this.args.appearance || 'default'
    });
    // const names = [];

    // if (this.args.appearance === 'outlined') {
    //   names.push('btn-outlined');
    // } else if (this.args.appearance === 'minimal') {
    //   names.push('btn-minimal');
    // } else if (this.args.appearance === 'custom') {
    //   names.push('btn-custom');
    // } else {
    //   names.push('btn');
    // }

    // if (this.args.size) {
    //   names.push(`${names[0]}--${this.args.size}`);
    // }

    // if (this.args.intent) {
    //   names.push(`${names[0]}--${this.args.intent}`);
    // }

    // return names.join(' ');
  }

  <template>
    {{#if @isRenderless}}
      {{yield (hash classNames=this.classNames)}}
    {{else}}
      <button type={{this.type}} class={{this.classNames}} ...attributes>
        {{yield (hash classNames=this.classNames)}}
      </button>
    {{/if}}
  </template>
}
