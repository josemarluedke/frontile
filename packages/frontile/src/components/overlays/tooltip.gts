import Component from '@glimmer/component';
import { assert } from '@ember/debug';
import { hash } from '@ember/helper';
import { modifier } from 'ember-modifier';
import { useStyles } from '@frontile/theme';
import { Popover, type PopoverSignature } from './popover';
import type {
  TooltipVariants,
  TooltipSlots,
  SlotsToClasses
} from '@frontile/theme';
import type { ModifierLike, WithBoundArgs } from '@glint/template';
import type Owner from '@ember/owner';

/**
 * The type of `Popover`'s yielded `Content`, already bound to its internal
 * wiring (`loop`, `isOpen`, `id`, ...). Reusing this instead of
 * `ComponentLike<ContentSignature>` matters: the latter is the *unbound*
 * signature, so invoking it in a template would again require every one of
 * those internal args -- exactly what `WithBoundArgs` exists to avoid.
 */
type BoundPopoverContent = PopoverSignature['Blocks']['default'][0]['Content'];

/**
 * The concrete function signature backing `PopoverTriggerModifier`. Glint's
 * `ModifierLike` is deliberately opaque -- it exists to keep a modifier from
 * being invoked as a plain function in application code -- so there is no
 * type-safe way to call through to it. This narrow, well-understood cast is
 * the exception: `modifier()` from `ember-modifier` returns the exact
 * function it was given (see its `dist/index.js`, `setModifierManager(() =>
 * MANAGER, fn); return fn;` with no wrapping), so at runtime `p.trigger`
 * *is* that function. `(el, positional, named) => teardown` is how
 * `Popover`'s own `trigger` is declared.
 */
type PopoverTriggerFn = (
  element: HTMLElement,
  positional: ['hover'],
  named: { aria: 'describedby' }
) => void | (() => void);

/**
 * `p.anchor` (`Velcro`'s `hook`) needs the same runtime call-through as
 * `p.trigger` above -- it is what makes `velcro.loop`/`p.Content`'s `@loop`
 * resolve at all. A consumer normally applies `{{p.anchor}}` and
 * `{{p.trigger}}` as two separate modifiers on the trigger element (see
 * `popover-test.gts`); a tooltip's single yielded `t.trigger` has to install
 * both.
 */
type PopoverAnchorFn = (
  element: HTMLElement | SVGElement
) => void | (() => void);

interface TooltipSignature {
  Args: {
    /**
     * The tooltip's text. A shorthand for the common case; pass a `Content`
     * block instead when the tooltip needs markup. Passing both asserts.
     */
    content?: string;

    /**
     * @defaultValue 'top'
     */
    placement?: PopoverSignature['Args']['placement'];

    /**
     * Renders an arrow pointing at the trigger.
     *
     * @defaultValue false
     */
    arrow?: boolean;

    /**
     * @defaultValue 'md'
     */
    size?: TooltipVariants['size'];

    /**
     * @defaultValue 'default'
     */
    intent?: TooltipVariants['intent'];

    /**
     * Milliseconds before opening on hover or keyboard focus.
     *
     * @defaultValue 200
     */
    openDelay?: number;

    /**
     * Milliseconds before closing. Also the window the pointer has to cross
     * the gap into the tooltip, so a very small value makes the tooltip
     * effectively non-interactive.
     *
     * @defaultValue 150
     */
    closeDelay?: number;

    /**
     * Closes as soon as the pointer leaves the trigger, rather than letting it
     * move onto the tooltip.
     *
     * @defaultValue false
     */
    disableInteractive?: boolean;

    /**
     * Installs the trigger but never opens. For a tooltip whose text is
     * conditionally irrelevant.
     *
     * @defaultValue false
     */
    isDisabled?: boolean;

    isOpen?: boolean;
    onOpenChange?: (isOpen: boolean) => void;
    didClose?: () => void;

    /**
     * @defaultValue 8
     */
    offsetOptions?: PopoverSignature['Args']['offsetOptions'];
    flipOptions?: PopoverSignature['Args']['flipOptions'];
    shiftOptions?: PopoverSignature['Args']['shiftOptions'];
    middleware?: PopoverSignature['Args']['middleware'];
    strategy?: PopoverSignature['Args']['strategy'];

    /**
     * Custom class for the tooltip, merged with the theme's using Tailwind
     * Merge.
     */
    class?: string;

    /**
     * Class names for each slot, merged with the theme's.
     */
    classes?: SlotsToClasses<TooltipSlots>;
  };
  Element: HTMLDivElement;
  Blocks: {
    default: [
      {
        trigger: ModifierLike<{ Element: HTMLElement }>;
        Content: WithBoundArgs<
          typeof TooltipContent,
          | 'PopoverContent'
          | 'classNames'
          | 'arrow'
          | 'disableInteractive'
          | 'hasContentArg'
        >;
        isOpen: boolean;
        open: () => void;
        close: () => void;
      }
    ];
  };
}

class Tooltip extends Component<TooltipSignature> {
  get classNames() {
    const { tooltip } = useStyles();

    const { base, arrow } = tooltip({
      size: this.args.size,
      intent: this.args.intent
    });

    return {
      base: base({ class: [this.args.classes?.base, this.args.class] }),
      arrow: arrow({ class: this.args.classes?.arrow })
    };
  }

  get placement(): PopoverSignature['Args']['placement'] {
    return this.args.placement ?? 'top';
  }

  get offsetOptions() {
    return this.args.offsetOptions ?? 8;
  }

  get openDelay(): number {
    return typeof this.args.openDelay === 'number' ? this.args.openDelay : 200;
  }

  get closeDelay(): number {
    return typeof this.args.closeDelay === 'number'
      ? this.args.closeDelay
      : 150;
  }

  /**
   * `p.trigger` cannot be curried in a `.gts` template with the template's
   * `(modifier ...)` keyword: even binding a single positional argument onto
   * a wrapper modifier -- whatever its declared type -- makes Glint's
   * `--declaration` pass fail with "Type instantiation is excessively deep
   * and possibly infinite" (reproduces the same way typed as `unknown`).
   * Applying a modifier directly (`{{this.someModifier someArg}}`) type-checks
   * fine; it is specifically the currying keyword's overload resolution that
   * Glint chokes on, matching the brief's anticipated fallback: build the
   * bound modifier value from plain JS instead of templated currying.
   *
   * `modifier()` from `ember-modifier` returns the exact function it is
   * given, with only a modifier manager attached out of band (see its
   * `dist/index.js`: `setModifierManager(() => MANAGER, fn); return fn;`),
   * and `ember-velcro`'s `hook` (`p.anchor`) is built the same way. So both
   * `p.anchor` and `p.trigger` are, at runtime, genuinely just those
   * functions -- calling them directly from plain JS is well-defined, even
   * though Glint's opaque `ModifierLike` intentionally exposes no call
   * signature for either.
   *
   * `t.trigger` has to install *both*: a tooltip's trigger element is also
   * its `Velcro` anchor. A normal `Popover` consumer applies `{{p.anchor}}`
   * and `{{p.trigger}}` as two separate modifiers on the same element (see
   * `popover-test.gts`); missing the anchor doesn't fail loudly by itself --
   * it just leaves `velcro.loop` (and so `p.Content`'s `@loop`) undefined,
   * which then asserts inside `Content`.
   *
   * Memoized on the `(anchor, trigger)` pair's identity (both stable for a
   * given `Popover` instance, since `Popover`/`Velcro` each assign their
   * fields once) so `t.trigger` keeps a stable identity across re-renders
   * instead of tearing down and reinstalling on every one.
   *
   * `@isDisabled` is read *inside* the installed function below, rather than
   * baked into this cache -- deliberately. `modifier()`'s function autotracks:
   * reading `this.args.isDisabled` there is what makes ember-modifier tear
   * down and reinstall the trigger's listeners when it changes, without
   * needing a new outer modifier identity (so the element itself is never
   * remounted). The brief's sketch instead made `@isDisabled` an unreachable
   * `openDelay` (`Number.MAX_SAFE_INTEGER`) passed through to `Popover`. That
   * does not work: `@ember/test-helpers`' `settled()` -- which every
   * `await triggerEvent(...)` calls internally -- waits on
   * `backburner.hasTimers()`, which is true for *any* pending `later()` call
   * no matter how far in the future, so a `mouseenter` scheduling an
   * effectively-infinite open left every subsequent `await` hanging until
   * the QUnit test timeout (confirmed: the test hung at exactly 60000ms).
   * Skipping the hover installation entirely while disabled avoids ever
   * scheduling that timer in the first place.
   */
  cachedTrigger?: {
    anchor: unknown;
    trigger: unknown;
    modifier: ModifierLike<{ Element: HTMLElement }>;
  };

  makeTrigger = (
    anchor: unknown,
    trigger: unknown
  ): ModifierLike<{ Element: HTMLElement }> => {
    if (
      !this.cachedTrigger ||
      this.cachedTrigger.anchor !== anchor ||
      this.cachedTrigger.trigger !== trigger
    ) {
      this.cachedTrigger = {
        anchor,
        trigger,
        modifier: modifier((element: HTMLElement) => {
          const teardownAnchor = (anchor as unknown as PopoverAnchorFn)(
            element
          );

          if (this.args.isDisabled) {
            return () => teardownAnchor?.();
          }

          const teardownTrigger = (trigger as unknown as PopoverTriggerFn)(
            element,
            ['hover'],
            { aria: 'describedby' }
          );

          return () => {
            teardownAnchor?.();
            teardownTrigger?.();
          };
        }) as unknown as ModifierLike<{ Element: HTMLElement }>
      };
    }

    return this.cachedTrigger.modifier;
  };

  <template>
    <Popover
      @placement={{this.placement}}
      @offsetOptions={{this.offsetOptions}}
      @flipOptions={{@flipOptions}}
      @shiftOptions={{@shiftOptions}}
      @middleware={{@middleware}}
      @strategy={{@strategy}}
      @openDelay={{this.openDelay}}
      @closeDelay={{this.closeDelay}}
      @isOpen={{@isOpen}}
      @onOpenChange={{@onOpenChange}}
      @didClose={{@didClose}}
      as |p|
    >
      {{yield
        (hash
          trigger=(this.makeTrigger p.anchor p.trigger)
          isOpen=p.isOpen
          open=p.open
          close=p.close
          Content=(component
            TooltipContent
            PopoverContent=p.Content
            classNames=this.classNames
            arrow=@arrow
            disableInteractive=@disableInteractive
            hasContentArg=(if @content true false)
          )
        )
      }}

      {{#if @content}}
        <TooltipContent
          @PopoverContent={{p.Content}}
          @classNames={{this.classNames}}
          @arrow={{@arrow}}
          @disableInteractive={{@disableInteractive}}
          ...attributes
        >
          {{@content}}
        </TooltipContent>
      {{/if}}
    </Popover>
  </template>
}

interface TooltipContentSignature {
  Args: {
    /**
     * @internal
     */
    PopoverContent: BoundPopoverContent;

    /**
     * @internal
     */
    classNames: { base: string; arrow: string };

    /**
     * @internal
     */
    arrow?: boolean;

    /**
     * @internal
     */
    disableInteractive?: boolean;

    /**
     * @internal
     * Set only on the bound `Content` yielded to the consumer. Lets this
     * component assert when it renders while `@content` is also in use --
     * a `Tooltip` cannot otherwise tell whether the consumer invoked the
     * yielded `Content` block.
     */
    hasContentArg?: boolean;
  };
  Element: HTMLDivElement;
  Blocks: { default: [] };
}

/**
 * The tooltip's content. Configures `Popover.Content` for a tooltip: no focus
 * trap, no autofocus, no scroll lock, `role="tooltip"`, and `tabindex="-1"` so
 * it is never a tab stop -- `Overlay` sets `tabindex="0"` but spreads
 * `...attributes` after it, so this wins.
 */
class TooltipContent extends Component<TooltipContentSignature> {
  constructor(owner: Owner, args: TooltipContentSignature['Args']) {
    super(owner, args);

    assert(
      '<Tooltip> received both @content and a <t.Content> block. Use one or the other.',
      !this.args.hasContentArg
    );
  }

  <template>
    <@PopoverContent
      @class={{@classNames.base}}
      @arrow={{@arrow}}
      @disableInteractive={{@disableInteractive}}
      @transition={{hash name="overlay-transition--tooltip"}}
      @blockScroll={{false}}
      @backdrop="none"
      role="tooltip"
      tabindex="-1"
      ...attributes
    >
      {{yield}}
    </@PopoverContent>
  </template>
}

export { Tooltip, type TooltipSignature };
export default Tooltip;
