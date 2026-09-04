import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { modifier } from 'ember-modifier';
import { useStyles } from '@frontile/theme';
import { VisuallyHidden } from '../../utilities/visually-hidden';
import { guidFor } from '@ember/object/internals';
import type { TOC } from '@ember/component/template-only';
import type { CommandSlots, SlotsToClasses } from '@frontile/theme';

export interface CommandInputSignature {
  Args: {
    /** @internal bound by Command */
    value?: string;
    /** @internal bound by Command */
    onInput?: (value: string) => void;
    /** @internal bound by Command */
    controlsId?: string;
    /** @internal bound by Command */
    hasResults?: boolean;
    /** @internal bound by Command */
    activeDescendant?: string;
    /** @internal bound by Command */
    setup?: (element: HTMLInputElement) => void;

    /**
     * Accessible name for the input.
     *
     * @defaultValue 'Search'
     */
    label?: string;

    placeholder?: string;
    classes?: SlotsToClasses<CommandSlots>;
  };
  Element: HTMLInputElement;
  Blocks: {
    /** Replaces the leading search icon. */
    icon: [];
  };
}

/**
 * The palette's search field.
 *
 * Carries the combobox semantics itself — `role`, `aria-expanded`,
 * `aria-controls` and `aria-activedescendant` all belong on the input, not on a
 * wrapper, so a screen reader announces the active option while focus never
 * leaves the field.
 */
class CommandInput extends Component<CommandInputSignature> {
  inputId = `${guidFor(this)}-input`;

  registerInput = modifier((element: HTMLInputElement) => {
    this.args.setup?.(element);
  });

  handleInput = (event: Event) => {
    this.args.onInput?.((event.target as HTMLInputElement).value);
  };

  get classNames() {
    const { command } = useStyles();
    return command();
  }

  <template>
    <div
      class={{this.classNames.inputWrapper class=@classes.inputWrapper}}
      data-test-id="command-input-wrapper"
    >
      {{#if (has-block "icon")}}
        {{yield to="icon"}}
      {{else}}
        <SearchIcon
          class={{this.classNames.inputIcon class=@classes.inputIcon}}
        />
      {{/if}}

      <VisuallyHidden>
        <label for={{this.inputId}}>{{if @label @label "Search"}}</label>
      </VisuallyHidden>

      {{! role=combobox is not implicit on a text input }}
      {{! template-lint-disable no-redundant-role require-mandatory-role-attributes }}
      <input
        id={{this.inputId}}
        type="text"
        role="combobox"
        aria-autocomplete="list"
        aria-expanded={{if @hasResults "true" "false"}}
        {{! Only while the listbox exists -- otherwise this points at nothing. }}
        aria-controls={{if @hasResults @controlsId}}
        aria-activedescendant={{@activeDescendant}}
        autocomplete="off"
        autocapitalize="off"
        autocorrect="off"
        spellcheck="false"
        value={{@value}}
        placeholder={{@placeholder}}
        data-test-id="command-input"
        data-component="command-input"
        class={{this.classNames.input class=@classes.input}}
        {{this.registerInput}}
        {{on "input" this.handleInput}}
        ...attributes
      />
      {{! template-lint-enable no-redundant-role require-mandatory-role-attributes }}
    </div>
  </template>
}

const SearchIcon: TOC<{ Element: SVGElement }> = <template>
  <svg
    xmlns="http://www.w3.org/2000/svg"
    fill="none"
    viewBox="0 0 24 24"
    stroke-width="1.5"
    stroke="currentColor"
    aria-hidden="true"
    ...attributes
  >
    <path
      stroke-linecap="round"
      stroke-linejoin="round"
      d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z"
    />
  </svg>
</template>;

export { CommandInput };
export default CommandInput;
