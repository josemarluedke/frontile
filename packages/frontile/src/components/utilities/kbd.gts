import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import { parseKeys } from '../../utils/keys';
import type { KbdKey, KbdPlatform } from '../../utils/keys';
import type { KbdSlots, SlotsToClasses } from '@frontile/theme';

interface RenderedKey {
  key: KbdKey;
  /** Set on every key but the first, so it renders *between* caps. */
  separator?: string;
}

export interface KbdSignature {
  Args: {
    /**
     * The shortcut to render, as `+`-separated keys: `"mod+shift+p"`.
     *
     * Named keys resolve to glyphs (`mod`, `shift`, `enter`, `esc`, `up`, …);
     * anything else renders verbatim, with a single letter capitalised. Use
     * `plus` for a literal `+`. A string with no `+` is one key, rendered as
     * given.
     *
     * Ignored when a block is passed.
     */
    keys?: string;

    /**
     * `split` gives each key its own cap; `merged` puts every glyph in one.
     *
     * @defaultValue 'split'
     */
    display?: 'split' | 'merged';

    /**
     * Rendered between caps, e.g. `"+"`. Only applies when `@display` is
     * `split`.
     */
    separator?: string;

    /**
     * @defaultValue 'md'
     */
    size?: 'sm' | 'md' | 'lg';

    /**
     * @defaultValue 'default'
     */
    intent?:
      | 'default'
      | 'primary'
      | 'secondary'
      | 'tertiary'
      | 'success'
      | 'warning'
      | 'danger';

    /**
     * `inherit` follows the colour it sits on, for keycaps on a filled row.
     * `plain` drops the box entirely, for quiet trailing shortcuts.
     *
     * @defaultValue 'default'
     */
    appearance?: 'default' | 'outlined' | 'faded' | 'inherit' | 'plain';

    /**
     * Overrides the platform for this keycap only. Prefer `setKbdPlatform` to
     * set it once for the whole app.
     */
    platform?: KbdPlatform;

    /**
     * Custom class name, it will override the default ones using Tailwind Merge
     * library.
     */
    class?: string;

    classes?: SlotsToClasses<KbdSlots>;
  };
  Element: HTMLElement;
  Blocks: {
    /** Replaces `@keys` with arbitrary content, rendered as a single cap. */
    default: [];
  };
}

/**
 * Renders keyboard keys and shortcuts.
 *
 * A wrapper `<kbd>` holds one child `<kbd>` per key, which is the HTML
 * specification's own idiom for a key combination.
 */
class Kbd extends Component<KbdSignature> {
  get isMerged(): boolean {
    return this.args.display === 'merged';
  }

  get keys(): KbdKey[] {
    return parseKeys(this.args.keys, this.args.platform);
  }

  get renderedKeys(): RenderedKey[] {
    const { separator } = this.args;

    return this.keys.map((key, index) => ({
      key,
      separator: index > 0 ? separator : undefined
    }));
  }

  /** In merged mode every glyph shares one cap, so they concatenate. */
  get mergedGlyph(): string {
    return this.keys.map((key) => key.glyph).join('');
  }

  /**
   * The merged cap is read out as its key names, since a run of glyphs like
   * `⌘⇧P` is unintelligible to a screen reader.
   */
  get mergedLabel(): string {
    return this.keys.map((key) => key.name ?? key.glyph).join(' ');
  }

  get classNames() {
    const { kbd } = useStyles();
    const { classes } = this.args;

    const { base, key, separator } = kbd({
      size: this.args.size,
      intent: this.args.intent,
      appearance: this.args.appearance,
      isMerged: this.isMerged
    });

    return {
      base: base({ class: [classes?.base, this.args.class] }),
      key: key({ class: classes?.key }),
      separator: separator({ class: classes?.separator })
    };
  }

  <template>
    <kbd
      class={{this.classNames.base}}
      data-test-id="kbd"
      data-component="kbd"
      ...attributes
    >
      {{#if (has-block)}}
        <kbd
          class={{this.classNames.key}}
          data-test-id="kbd-key"
        >{{yield}}</kbd>
      {{else if this.isMerged}}
        <kbd class={{this.classNames.key}} data-test-id="kbd-key">
          <span aria-hidden="true">{{this.mergedGlyph}}</span>
          <span class="sr-only">{{this.mergedLabel}}</span>
        </kbd>
      {{else}}
        {{#each this.renderedKeys as |rendered|}}
          {{#if rendered.separator}}
            <span
              class={{this.classNames.separator}}
              aria-hidden="true"
              data-test-id="kbd-separator"
            >{{rendered.separator}}</span>
          {{/if}}

          <kbd
            class={{this.classNames.key}}
            data-test-id="kbd-key"
            title={{rendered.key.name}}
          >
            {{! A symbol is meaningless read aloud, so it is hidden and its
                  name spoken instead. A glyph like Esc already reads
                  correctly, and labelling it would say "Escape Escape". }}
            {{#if rendered.key.needsSpokenLabel}}
              <span aria-hidden="true">{{rendered.key.glyph}}</span>
              <span class="sr-only">{{rendered.key.name}}</span>
            {{else}}
              {{rendered.key.glyph}}
            {{/if}}
          </kbd>
        {{/each}}
      {{/if}}
    </kbd>
  </template>
}

export { Kbd };
export default Kbd;
