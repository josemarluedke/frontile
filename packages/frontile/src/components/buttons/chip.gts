import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { deprecate } from '@ember/debug';
import { on } from '@ember/modifier';
import { LinkTo } from '@ember/routing';
import type { TOC } from '@ember/component/template-only';
import { useStyles } from '@frontile/theme';
import { CloseButton } from './close-button';
import { press, type PressEvent } from '../../modifiers/press';
import { renamedArgValue } from '../../-private/deprecated-args';

interface ChipSignature {
  Args: {
    /**
     * The chip variant.
     *
     * @defaultValue 'solid'
     */
    variant?: 'solid' | 'outline' | 'soft';

    /**
     * @deprecated Use `variant`. `default` is now `solid`, `outlined` is
     * `outline`, and `faded` is `soft`.
     */
    appearance?: 'default' | 'outlined' | 'faded';

    /**
     * The color of the chip.
     */
    color?:
      | 'neutral'
      | 'primary'
      | 'secondary'
      | 'tertiary'
      | 'success'
      | 'warning'
      | 'danger';

    /**
     * @deprecated Use `color`. `default` is now `neutral`.
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
     * The size of the chip
     *
     * @defaultValue 'md'
     */
    size?: 'xs' | 'sm' | 'md' | 'lg';

    /**
     * @deprecated Ignored. Chip is always a pill; use `Badge` for a squared
     * label.
     */
    radius?: 'none' | 'sm' | 'lg' | 'full';

    /**
     * Adds a dot before the content, colored by `@color`. On the `solid`
     * variant the dot takes the chip's text color, since the chip's
     * background is already the chip's color.
     *
     * @defaultValue false
     */
    withDot?: boolean;

    /**
     * Renders the body as a `LinkTo` for this route. Takes precedence over
     * `@href` and `@onPress`.
     */
    route?: string;

    /** A single dynamic segment for `@route`. */
    model?: unknown;

    /** Dynamic segments for `@route`. Wins over `@model`. */
    models?: unknown[];

    /** Query params for `@route`. */
    query?: Record<string, unknown>;

    /**
     * Renders the body as a plain `<a href>`, for a router-free link. Ignored
     * when `@route` is given; takes precedence over `@onPress`.
     */
    href?: string;

    /**
     * Renders the body as a `<button type="button">` and calls this when it
     * is pressed (pointer, Enter or Space). Ignored when `@route` or `@href`
     * is given.
     */
    onPress?: (event: PressEvent) => void;

    /**
     * Marks the chip as selected (a toggled filter, say): it holds its
     * pressed fill and is announced as selected. A button body gets
     * `aria-pressed` (`"true"` or `"false"`); a link body gets
     * `aria-current="true"` while selected and no `aria-current` otherwise.
     * Leave it `undefined` for a chip that is not a toggle, so no
     * `aria-pressed` is rendered at all.
     */
    isSelected?: boolean;

    /**
     * Function to be called when clicking on the close button.
     * If you pass this argument, the close button will be visible.
     */
    onClose?: () => void;

    /**
     * The accessible name of the close button. Every close button would
     * otherwise be announced as just "Close", which does not say *what* is
     * being removed — worth setting when several chips sit together.
     *
     * @defaultValue 'Close'
     */
    closeButtonTitle?: string;

    /**
     * `tabindex` for the close button.
     *
     * Set to `-1` when chips sit inside another control (a multi-select field,
     * say) and the close button should stay a pointer affordance: every chip
     * would otherwise cost a Tab stop before the control itself is reached.
     * Whoever does this owes keyboard users another way to remove a chip.
     *
     * @defaultValue undefined (the close button is a normal tab stop)
     */
    closeButtonTabIndex?: number | string;

    /**
     * Dims the chip and disables its body and close button. A button body
     * gets `disabled`; a link body drops its `href` and gets
     * `aria-disabled="true"`, since an anchor cannot be natively disabled.
     *
     * @defaultValue false
     */
    isDisabled?: boolean;

    /**
     * Custom class name, it will override the default ones using Tailwind Merge library.
     */
    class?: string;
  };
  Blocks: {
    default: [];
  };
  Element: HTMLDivElement;
}

interface ChipBodyContentSignature {
  Args: { withDot?: boolean; dotClass: string; contentClass: string };
  Blocks: { default: [] };
}

const ChipBodyContent: TOC<ChipBodyContentSignature> = <template>
  {{#if @withDot}}
    <span class={{@dotClass}} data-part="dot"></span>
  {{/if}}
  <span class={{@contentClass}} data-part="content">
    {{yield}}
  </span>
</template>;

/**
 * An interactive, pill-shaped label: its body is a link or a button, and it
 * may also be removable. For a non-interactive label, use `Badge`.
 *
 * The body element follows the arguments, first match wins:
 *
 * - `@route` (with `@model`, `@models`, `@query`): a `LinkTo` anchor.
 * - `@href`: a plain `<a href>`.
 * - `@onPress`: a `<button type="button">`.
 * - none of those: a non-interactive `<span>`, only meaningful with
 *   `@onClose` (a removable chip, as in Select's selected items).
 *
 * The wrapper (`data-part="base"`, which receives `...attributes`) holds the
 * body (`data-part="body"`, containing the dot and the content) and, with
 * `@onClose`, the close button as the body's *sibling*: two separate controls,
 * each with its own tab stop and focus ring. Enter and Space activate a
 * button body; Enter activates a link body. With `@onClose`, Backspace or
 * Delete on the focused body or close button removes the chip (as MUI does).
 */
class Chip extends Component<ChipSignature> {
  @cached
  get models(): unknown[] {
    // `!= null` (not truthiness) so a falsy dynamic segment such as
    // `@model={{0}}` is not dropped.
    return (
      this.args.models ?? (this.args.model != null ? [this.args.model] : [])
    );
  }

  // `LinkTo` throws on an `undefined` `@query`.
  @cached
  get query(): Record<string, unknown> {
    return this.args.query ?? {};
  }

  get isDisabled(): boolean {
    return this.args.isDisabled ?? false;
  }

  /**
   * A disabled `@route` chip falls through to the plain anchor: `LinkTo`
   * always renders a real, navigable href, and dropping the href is what
   * actually disables a link (the same approach as `TabNav` items).
   */
  get rendersLinkTo(): boolean {
    return Boolean(this.args.route) && !this.isDisabled;
  }

  get rendersAnchor(): boolean {
    return (
      !this.rendersLinkTo &&
      (Boolean(this.args.route) || this.args.href !== undefined)
    );
  }

  get rendersButton(): boolean {
    return (
      !this.rendersLinkTo &&
      !this.rendersAnchor &&
      typeof this.args.onPress === 'function'
    );
  }

  get isPressable(): boolean {
    return (
      !this.isDisabled &&
      (this.rendersLinkTo || this.rendersAnchor || this.rendersButton)
    );
  }

  get ariaPressed(): 'true' | 'false' | undefined {
    if (this.args.isSelected === undefined) {
      return undefined;
    }
    return this.args.isSelected ? 'true' : 'false';
  }

  /**
   * `aria-current` for a link body: set only while selected. A link has no
   * "not selected" value the way `aria-pressed` has `false`.
   */
  get ariaCurrent(): 'true' | undefined {
    return this.args.isSelected === true ? 'true' : undefined;
  }

  /**
   * Backspace/Delete on a focused body or close button calls `@onClose`. It
   * prevents the default only when it actually closes, so a chip that is not
   * removable leaves those keys alone. A held-down key (`repeat`) or a key
   * pressed with a modifier is left alone too: holding Backspace must not
   * remove a row of chips, and modified keys belong to the browser or app.
   */
  handleRemoveKey = (event: KeyboardEvent): void => {
    if (event.key !== 'Backspace' && event.key !== 'Delete') {
      return;
    }
    if (
      event.repeat ||
      event.ctrlKey ||
      event.metaKey ||
      event.altKey ||
      event.shiftKey
    ) {
      return;
    }
    if (this.isDisabled || typeof this.args.onClose !== 'function') {
      return;
    }
    event.preventDefault();
    this.args.onClose();
  };

  handlePress = (event: PressEvent): void => {
    // The `press` modifier does not check `disabled` itself.
    if (this.isDisabled) {
      return;
    }
    this.args.onPress?.(event);
  };

  get classNames() {
    const { chip } = useStyles();

    if (this.args.radius !== undefined) {
      deprecate(
        'Chip: `@radius` is deprecated and ignored. Chip is always a pill; use `Badge` for a squared label.',
        false,
        {
          id: 'frontile.chip.radius',
          until: '0.19.0',
          for: 'frontile',
          since: { available: '0.18.0', enabled: '0.18.0' }
        }
      );
    }

    const { base, body, content, dot, closeButton } = chip({
      color:
        renamedArgValue(
          this.args.color,
          this.args.intent,
          { default: 'neutral' } as const,
          {
            component: 'Chip',
            from: 'intent',
            to: 'color',
            id: 'frontile.chip.intent'
          }
        ) || 'neutral',
      size: this.args.size,
      variant:
        renamedArgValue(
          this.args.variant,
          this.args.appearance,
          { default: 'solid', outlined: 'outline', faded: 'soft' } as const,
          {
            component: 'Chip',
            from: 'appearance',
            to: 'variant',
            id: 'frontile.chip.appearance'
          }
        ) || 'solid',
      isDisabled: this.args.isDisabled,
      isPressable: this.isPressable,
      isSelected: this.args.isSelected ?? false
    });

    return {
      base: base({ class: this.args.class }),
      body: body(),
      content: content(),
      dot: dot(),
      closeButton: closeButton()
    };
  }

  <template>
    <div
      class={{this.classNames.base}}
      data-component="chip"
      data-part="base"
      ...attributes
    >
      {{#if this.rendersLinkTo}}
        <LinkTo
          @route={{@route}}
          @models={{this.models}}
          @query={{this.query}}
          aria-current={{this.ariaCurrent}}
          class={{this.classNames.body}}
          data-part="body"
          {{on "keydown" this.handleRemoveKey}}
        >
          <ChipBodyContent
            @withDot={{@withDot}}
            @dotClass={{this.classNames.dot}}
            @contentClass={{this.classNames.content}}
          >{{yield}}</ChipBodyContent>
        </LinkTo>
      {{else if this.rendersAnchor}}
        <a
          {{! template-lint-disable no-unsupported-role-attributes }}
          href={{unless this.isDisabled @href}}
          aria-disabled={{if this.isDisabled "true"}}
          aria-current={{this.ariaCurrent}}
          class={{this.classNames.body}}
          data-part="body"
          {{on "keydown" this.handleRemoveKey}}
        >
          <ChipBodyContent
            @withDot={{@withDot}}
            @dotClass={{this.classNames.dot}}
            @contentClass={{this.classNames.content}}
          >{{yield}}</ChipBodyContent>
        </a>
      {{else if this.rendersButton}}
        <button
          type="button"
          disabled={{this.isDisabled}}
          aria-pressed={{this.ariaPressed}}
          class={{this.classNames.body}}
          data-part="body"
          {{press this.handlePress}}
          {{on "keydown" this.handleRemoveKey}}
        >
          <ChipBodyContent
            @withDot={{@withDot}}
            @dotClass={{this.classNames.dot}}
            @contentClass={{this.classNames.content}}
          >{{yield}}</ChipBodyContent>
        </button>
      {{else}}
        <span class={{this.classNames.body}} data-part="body">
          <ChipBodyContent
            @withDot={{@withDot}}
            @dotClass={{this.classNames.dot}}
            @contentClass={{this.classNames.content}}
          >{{yield}}</ChipBodyContent>
        </span>
      {{/if}}
      {{#if @onClose}}
        <CloseButton
          @class={{this.classNames.closeButton}}
          @title={{@closeButtonTitle}}
          @onPress={{@onClose}}
          tabindex={{@closeButtonTabIndex}}
          disabled={{@isDisabled}}
          data-part="close-button"
          {{on "keydown" this.handleRemoveKey}}
        />
      {{/if}}
    </div>
  </template>
}

export { Chip, type ChipSignature };
export default Chip;
