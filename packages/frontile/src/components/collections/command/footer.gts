import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { Kbd } from '../../utilities/kbd';
import type { TOC } from '@ember/component/template-only';
import type { CommandSlots, SlotsToClasses } from '@frontile/theme';
import type { WithBoundArgs } from '@glint/template';

export interface CommandKbdSignature {
  Args: {
    /** A shortcut to render, e.g. `"up"` or `"mod+k"`. See `Kbd`. */
    keys?: string;

    /** @internal bound by Command */
    classes?: SlotsToClasses<CommandSlots>;
  };
  Element: HTMLElement;
  Blocks: { default: [] };
}

/**
 * A keycap, for the footer's hints. A thin binding over `Kbd` so the palette
 * and the rest of the library render the same keycap.
 */
const CommandKbd: TOC<CommandKbdSignature> = <template>
  {{#if (has-block)}}
    <Kbd
      @size="sm"
      @appearance="outlined"
      @classes={{hash key=@classes.kbd}}
      data-test-id="command-kbd"
      ...attributes
    >{{yield}}</Kbd>
  {{else}}
    <Kbd
      @keys={{@keys}}
      @size="sm"
      @appearance="outlined"
      @classes={{hash key=@classes.kbd}}
      data-test-id="command-kbd"
      ...attributes
    />
  {{/if}}
</template>;

export interface CommandHintSignature {
  Args: {
    /** @internal bound by CommandFooter */
    classes?: SlotsToClasses<CommandSlots>;
  };
  Element: HTMLElement;
  Blocks: { default: [] };
}

/** One hint: a keycap or two and a label. */
const CommandHint: TOC<CommandHintSignature> = <template>
  <span class={{hintClass @classes}} data-test-id="command-hint" ...attributes>
    {{yield}}
  </span>
</template>;

function hintClass(classes?: SlotsToClasses<CommandSlots>): string {
  const { command } = useStyles();
  return command().footerHint({ class: classes?.footerHint });
}

export interface CommandFooterSignature {
  Args: {
    /** @internal bound by Command */
    classes?: SlotsToClasses<CommandSlots>;
  };
  Element: HTMLDivElement;
  Blocks: {
    /**
     * Replaces the default hints. Yields a `Kbd` keycap so custom hints match
     * the built-in ones.
     */
    default: [
      {
        Kbd: WithBoundArgs<typeof CommandKbd, 'classes'>;
        Hint: WithBoundArgs<typeof CommandHint, 'classes'>;
      }
    ];
  };
}

/**
 * The bar along the bottom of a palette that teaches its keyboard: how to move,
 * how to choose, how to leave. Renders sensible defaults when given no block.
 */
class CommandFooter extends Component<CommandFooterSignature> {
  get footerClass(): string {
    const { command } = useStyles();
    return command().footer({ class: this.args.classes?.footer });
  }

  <template>
    <div
      class={{this.footerClass}}
      data-test-id="command-footer"
      data-component="command-footer"
      ...attributes
    >
      {{#if (has-block)}}
        {{yield
          (hash
            Kbd=(component CommandKbd classes=@classes)
            Hint=(component CommandHint classes=@classes)
          )
        }}
      {{else}}
        <CommandHint @classes={{@classes}}>
          <CommandKbd @classes={{@classes}} aria-label="Arrow up">↑</CommandKbd>
          <CommandKbd
            @classes={{@classes}}
            aria-label="Arrow down"
          >↓</CommandKbd>
          Navigate
        </CommandHint>
        <CommandHint @classes={{@classes}}>
          <CommandKbd @classes={{@classes}} aria-label="Enter">↵</CommandKbd>
          Select
        </CommandHint>
        <CommandHint @classes={{@classes}}>
          <CommandKbd @classes={{@classes}}>Esc</CommandKbd>
          Close
        </CommandHint>
      {{/if}}
    </div>
  </template>
}

export { CommandFooter, CommandKbd, CommandHint };
export default CommandFooter;
