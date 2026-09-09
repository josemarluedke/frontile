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
 *
 * WARNING FOR A FUTURE UPGRADER: this cast is verified against
 * `ember-modifier@4.3.0`'s *function-based* modifier manager, whose
 * `createModifier`/`updateModifier`/`installModifier` call the given function
 * directly as `instance(element, positional, named)` -- i.e. the manager adds
 * no wrapping of its own, so invoking `p.trigger`/`p.anchor` here as plain
 * functions is genuinely calling the same code the manager would call.
 * `ModifierLike` has no call signature *by design* (it exists specifically to
 * stop application code from doing this), so there is no type-safe
 * alternative to the cast. A major `ember-modifier` upgrade could change the
 * manager's calling convention (or start wrapping the function) with no
 * compiler signal at this cast site -- re-verify against the new
 * `dist/index.js` before assuming this still holds. The runtime `assert`
 * calls at the call sites below exist so a break here fails loudly (a thrown
 * dev-mode assertion) instead of silently (a tooltip that never opens).
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
 * both. Same upgrade warning as `PopoverTriggerFn` above: `ember-velcro`'s
 * `hook` is built with the identical `setModifierManager(() => MANAGER, fn)`
 * pattern, so the same function-based-modifier assumption applies here too.
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
   *
   * ANCHOR CHURN GUARD: the wrapper function below reads `this.isOpen`
   * *transitively* -- not directly, but through `trigger`'s own autotracking
   * of `aria-describedby` -- so `ember-modifier` tears the whole wrapper down
   * and reinstalls it on every open/close. Without a guard, that would call
   * `anchor(element)` again on every cycle, and `Velcro`'s `hook` reassigns
   * its own `@tracked hook` field each time it runs, which tears down and
   * restarts floating-ui's `autoUpdate` positioning loop for no reason -- a
   * normal `Popover` consumer never pays this cost, because there `anchor`
   * and `trigger` are two separate modifiers and `anchor`'s body reads
   * nothing tracked, so it installs once and never re-runs.
   *
   * The fix keys the anchor's lifecycle on the *element* in instance state
   * (`anchoredElement`/`anchorTeardown`), not on the wrapper modifier's own
   * re-run: `ensureAnchor` below only calls `anchor(element)` when the
   * element actually changes. The wrapper's own destructor -- called by
   * `ember-modifier` before *every* re-run, same-element re-runs included --
   * must therefore never touch the anchor; it only tears down `trigger`,
   * which is the half that legitimately needs to re-run on every open/close
   * (that's what keeps `aria-describedby` in sync, and Task 5 documented it
   * as required for controlled mode). The anchor is torn down only when
   * `ensureAnchor` sees a different element arrive, or when the component
   * itself is destroyed (`willDestroy`, below) -- never on a same-element
   * wrapper re-run.
   */
  cachedTrigger?: {
    anchor: unknown;
    trigger: unknown;
    modifier: ModifierLike<{ Element: HTMLElement }>;
  };

  /**
   * The element the anchor is currently installed on, and the teardown
   * `anchor(element)` handed back for it. Lives on the component instance
   * (not in the modifier's own closure) so it survives every open/close
   * re-run of the wrapper modifier -- see the churn-guard note above.
   */
  anchoredElement?: HTMLElement | SVGElement;
  anchorTeardown?: () => void;

  /**
   * Installs `anchor` on `element` only if it is not already installed
   * there. Called on every wrapper re-run (every open/close), but is a no-op
   * on all but the first call and any call where the element genuinely
   * changed.
   *
   * Declared as a regular (prototype) method rather than an arrow-function
   * class field -- unlike `makeTrigger`, it is only ever called as
   * `this.ensureAnchor(...)`, never passed by reference, so it doesn't need
   * per-instance `this`-binding. Living on the prototype also makes it the
   * one seam the test suite can wrap to count real anchor installations
   * (see `tooltip-test.gts`'s anchor-churn-guard test).
   */
  ensureAnchor(anchor: unknown, element: HTMLElement | SVGElement) {
    if (this.anchoredElement === element) {
      return;
    }

    // A different element arrived (or this is the first install for this
    // wrapper): tear down whatever anchor is currently installed before
    // installing the new one, so we never leak a stale `autoUpdate` loop.
    this.anchorTeardown?.();

    assert(
      "Expected `p.anchor` to be a callable function (ember-velcro's `hook`, built the same way `ember-modifier`'s `modifier()` builds a callable function-based modifier). If this fires, an `ember-modifier` or `ember-velcro` upgrade likely changed how modifier values are constructed -- see the `PopoverAnchorFn`/`PopoverTriggerFn` comments above.",
      typeof anchor === 'function'
    );

    const teardown = (anchor as unknown as PopoverAnchorFn)(element);

    this.anchoredElement = element;
    this.anchorTeardown = teardown ?? undefined;
  }

  willDestroy() {
    super.willDestroy();
    this.anchorTeardown?.();
    this.anchoredElement = undefined;
    this.anchorTeardown = undefined;
  }

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
          this.ensureAnchor(anchor, element);

          if (this.args.isDisabled) {
            return undefined;
          }

          assert(
            "Expected `p.trigger` to be a callable function (a modifier built by `ember-modifier`'s `modifier()`). If this fires, an `ember-modifier` upgrade likely changed how function-based modifiers are constructed -- see the `PopoverTriggerFn` comment above.",
            typeof trigger === 'function'
          );

          const teardownTrigger = (trigger as unknown as PopoverTriggerFn)(
            element,
            ['hover'],
            { aria: 'describedby' }
          );

          // Only the trigger half is torn down here. `ember-modifier` calls
          // this destructor before *every* re-run -- including a same-element
          // re-run driven by `this.isOpen` churn -- so tearing the anchor
          // down here would defeat the guard above. The anchor's teardown is
          // handled by `ensureAnchor` (on a genuine element change) and by
          // `willDestroy` (on real component destruction).
          return () => {
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
 *
 * Its constructor also asserts that `@content` and a `<t.Content>` block are
 * never used together: `hasContentArg` is set only on the bound `Content`
 * yielded to the consumer (see `TooltipContentSignature['Args']`), so this
 * component renders with it `true` exactly when the consumer both passed
 * `@content` to `Tooltip` *and* invoked the yielded `Content` block. The
 * check has to live here, on the content side, rather than on `Tooltip`
 * itself, because a Glimmer component has no way to observe whether a
 * consumer invoked one of its yielded blocks -- `Tooltip` cannot tell
 * `<t.Content>` was used at all until this component actually renders.
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
