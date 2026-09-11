import Component from '@glimmer/component';
import { cached, tracked } from '@glimmer/tracking';
import { modifier } from 'ember-modifier';
import type { TOC } from '@ember/component/template-only';
import { useStyles } from '@frontile/theme';
import { press, type PressEvent } from '../../modifiers/press';
import { Spinner } from '../utilities/spinner';

/**
 * Sets `disabled` on the element while `loading` is true, restoring whatever
 * the consumer had before. This is a modifier rather than a plain attribute
 * because splattributes are applied last: `disabled={{@isLoading}}` written
 * before `...attributes` is clobbered by a consumer's own `disabled`, and
 * written after it a consumer's `disabled={{false}}` would erase ours.
 * Modifiers run after attributes, so neither ordering problem applies.
 *
 * Known limitation: this re-runs only when `loading` changes, so `previous`
 * is a snapshot taken once at install time — it goes stale if the consumer's
 * own `disabled` binding changes while loading is already in flight, in
 * either direction:
 *
 * - true → false: Glimmer rewrites the attribute to `false`, we do not
 *   re-run, so the button stays disabled (from our own `el.disabled = true`)
 *   until loading ends and teardown restores the stale `previous` (`false`),
 *   which happens to match — net: the button goes live at the same moment,
 *   with the disabling outliving the intent for no visible reason.
 * - false → true: Glimmer rewrites the attribute to `true`, we do not
 *   re-run, so `previous` is left holding the stale `false`. When loading
 *   ends, teardown restores `previous` and sets `disabled = false` — the
 *   button ends up enabled even though the consumer's binding says
 *   `disabled={{true}}`. This is a fail-open: the consumer's disable is
 *   silently and indefinitely lost. See the
 *   `'known limitation: a consumer disable applied mid-load is lost when
 *   loading ends'` test in buttons-test.gts, which pins this exact case.
 *
 * Closing this would need a MutationObserver watching `disabled` for a case
 * nobody has hit; the project has decided not to add one.
 */
const disableWhile = modifier((el: HTMLButtonElement, [loading]: [boolean]) => {
  if (!loading) {
    return;
  }

  const previous = el.disabled;
  el.disabled = true;

  return () => {
    el.disabled = previous;
  };
});

/**
 * The spinner stands in for the icon while loading, on whichever side
 * `@iconPlacement` puts it. Extracted so the spinner-or-icon choice is written
 * once; the caller passes the icon through as this component's default block.
 *
 * The invocation below is still written twice, once per side, and that is
 * deliberate: the block contains `{{yield to="icon"}}`, and Glimmer has no way
 * to hoist a block-yielding invocation into a `{{#let}}` or a helper. Only the
 * choice was deduplicated, not the two call sites.
 */
const SpinnerOrIcon: TOC<{
  Args: {
    isLoading: boolean;
    spinnerClass: string;
  };
  Blocks: {
    default: [];
  };
}> = <template>
  {{#if @isLoading}}
    <Spinner @class={{@spinnerClass}} />
  {{else}}
    {{yield}}
  {{/if}}
</template>;

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
  appearance?: 'default' | 'soft' | 'outlined' | 'minimal' | 'tonal' | 'custom';

  /**
   * The intent of the button
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
   * The size of the button
   */
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl' | '2xl';

  /**
   * Disable rendering the button element. It yields an object with classNames instead.
   */
  isRenderless?: boolean;

  /**
   * Custom class name, it will override the default ones using Tailwind Merge library.
   */
  class?: string;

  /**
   * If button is part of a group. Most of the time, this is automatically set
   * when using the ButtonGroup component.
   */
  isInGroup?: boolean;

  /**
   * Renders a spinner in place of the icon and disables the button.
   *
   * @defaultValue false
   */
  isLoading?: boolean;

  /**
   * Which side the `icon` block — and the loading spinner that replaces it —
   * sits on.
   *
   * @defaultValue 'start'
   */
  iconPlacement?: 'start' | 'end';

  /**
   * Callback for when the button is pressed.
   */
  onPress?: (event: PressEvent) => void;
}

interface ButtonSignature {
  Args: ButtonArgs;
  Blocks: {
    default: [{ classNames: string; isLoading: boolean }];
    icon?: [];
    loading?: [];
  };
  Element: HTMLButtonElement;
}

class Button extends Component<ButtonSignature> {
  @tracked isPressed = false;

  get type(): string {
    if (this.args.type) {
      return this.args.type;
    }
    return 'button';
  }

  get isLoading(): boolean {
    return this.args.isLoading === true;
  }

  get isIconAtEnd(): boolean {
    return this.args.iconPlacement === 'end';
  }

  get isIconAtStart(): boolean {
    return !this.isIconAtEnd;
  }

  @cached
  get classNames(): string {
    const { button } = useStyles();

    return button({
      intent: this.args.intent || 'default',
      size: this.args.size,
      appearance: this.args.appearance || 'default',
      isInGroup: this.args.isInGroup,
      isLoading: this.isLoading,
      class: this.args.class
    });
  }

  @cached
  get spinnerClassNames(): string {
    const { buttonSpinner } = useStyles();

    return buttonSpinner();
  }

  /**
   * The object yielded to the default block (and, when `@isRenderless`, in
   * place of rendering). Hoisted so the shape is written once — it's part of
   * this component's public contract, asserted on directly by tests.
   */
  @cached
  get yieldedHash(): { classNames: string; isLoading: boolean } {
    return { classNames: this.classNames, isLoading: this.isLoading };
  }

  handlePressChange = (isPressed: boolean): void => {
    this.isPressed = isPressed;
  };

  onPress = (event: PressEvent) => {
    if (typeof this.args.onPress === 'function') {
      this.args.onPress(event);
    }
  };

  <template>
    {{#if @isRenderless}}
      {{yield this.yieldedHash}}
    {{else}}
      <button
        type={{this.type}}
        class={{this.classNames}}
        aria-busy={{if this.isLoading "true"}}
        data-loading={{if this.isLoading "true"}}
        data-pressed={{if this.isPressed "true"}}
        data-component="button"
        data-part="base"
        {{press this.onPress onPressChange=this.handlePressChange}}
        ...attributes
        {{disableWhile this.isLoading}}
      >
        {{#if this.isIconAtStart}}
          <SpinnerOrIcon
            @isLoading={{this.isLoading}}
            @spinnerClass={{this.spinnerClassNames}}
          >
            {{yield to="icon"}}
          </SpinnerOrIcon>
        {{/if}}

        {{#if this.isLoading}}
          {{#if (has-block "loading")}}
            {{yield to="loading"}}
          {{else}}
            {{yield this.yieldedHash}}
          {{/if}}
        {{else}}
          {{yield this.yieldedHash}}
        {{/if}}

        {{#if this.isIconAtEnd}}
          <SpinnerOrIcon
            @isLoading={{this.isLoading}}
            @spinnerClass={{this.spinnerClassNames}}
          >
            {{yield to="icon"}}
          </SpinnerOrIcon>
        {{/if}}
      </button>
    {{/if}}
  </template>
}

export { Button, type ButtonSignature };
export default Button;
