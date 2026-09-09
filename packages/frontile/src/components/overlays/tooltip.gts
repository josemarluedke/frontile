import Component from '@glimmer/component';
import { assert } from '@ember/debug';
import { hash } from '@ember/helper';
import { modifier } from 'ember-modifier';
/* eslint-disable ember/no-runloop */
import { next, cancel } from '@ember/runloop';
import type { Timer as EmberTimer } from '@ember/runloop';
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

    /**
     * Whether the tooltip is open. Pair with `onOpenChange` to control it;
     * leave it unset to let the tooltip manage its own state. Passing
     * `isOpen` alone, without `onOpenChange`, falls back to uncontrolled
     * behavior.
     */
    isOpen?: boolean;

    /**
     * Callback when the tooltip opens or closes, receiving the new state.
     */
    onOpenChange?: (isOpen: boolean) => void;

    /**
     * Callback when closing has finished, including any exit transition.
     */
    didClose?: () => void;

    /**
     * @defaultValue 8
     */
    offsetOptions?: PopoverSignature['Args']['offsetOptions'];

    /**
     * Options for the floating-ui flip middleware, which moves the tooltip
     * to the opposite side when it would overflow the viewport. Forwarded
     * to the underlying `Popover`.
     */
    flipOptions?: PopoverSignature['Args']['flipOptions'];

    /**
     * Options for the floating-ui shift middleware, which nudges the
     * tooltip along its axis to keep it in view. Forwarded to the
     * underlying `Popover`.
     */
    shiftOptions?: PopoverSignature['Args']['shiftOptions'];

    /**
     * Additional floating-ui middleware, for positioning behavior beyond
     * what `placement`, `offsetOptions`, `flipOptions`, and `shiftOptions`
     * cover. Forwarded to the underlying `Popover`.
     */
    middleware?: PopoverSignature['Args']['middleware'];

    /**
     * The CSS positioning strategy, forwarded to the underlying
     * `Popover`/floating-ui.
     *
     * @defaultValue 'absolute'
     */
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
        /**
         * The modifier to apply to the element the tooltip describes. Installs
         * the hover/focus listeners that open and close the tooltip, and keeps
         * `aria-describedby` in sync while it does.
         */
        trigger: ModifierLike<{ Element: HTMLElement }>;
        Content: WithBoundArgs<
          typeof TooltipContent,
          | 'PopoverContent'
          | 'classNames'
          | 'arrow'
          | 'disableInteractive'
          | 'hasContentArg'
        >;

        /**
         * Whether the tooltip is currently open.
         */
        isOpen: boolean;

        /**
         * Opens the tooltip.
         */
        open: () => void;

        /**
         * Closes the tooltip.
         */
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
   * therefore does not tear the anchor down synchronously; it only tears
   * down `trigger` immediately (the half that legitimately needs to re-run on
   * every open/close -- that's what keeps `aria-describedby` in sync, and
   * Task 5 documented it as required for controlled mode) and *defers* the
   * anchor decision via `scheduleAnchorTeardownCheck`.
   *
   * FIX ROUND 2 -- the leak this guard introduced, and why a deferred check:
   * `ember-modifier` gives the destructor no way to tell "about to re-run for
   * the same element" apart from "genuinely destroyed" -- both call the same
   * returned closure. Guarding the anchor by comparing `element` identity (as
   * fix round 1 did) is correct for the re-run case but has no destructor
   * path left for the case where `element` is removed entirely while
   * `Tooltip` itself keeps living (e.g. `{{#if this.show}}<button
   * {{t.trigger}}>{{/if}}`) -- nothing ever calls `ensureAnchor` again to
   * notice the change, and `willDestroy` only runs when `Tooltip` itself is
   * torn down. `scheduleAnchorTeardownCheck`/`confirmAnchorTeardown` resolve
   * the ambiguity by deferring one runloop turn (`@ember/runloop`'s `next`):
   * if the wrapper re-runs for the same element, `ensureAnchor` cancels the
   * pending check synchronously, before it fires; if `element` was genuinely
   * removed, nothing cancels it and the anchor is torn down for real one turn
   * later. The anchor is therefore torn down in exactly three places:
   * `ensureAnchor` (a different element arrived), `confirmAnchorTeardown`
   * (the deferred check fired unchallenged), and `willDestroy` (the component
   * itself is destroyed) -- never synchronously inside the wrapper's own
   * destructor.
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
   * A scheduled-but-not-yet-confirmed anchor teardown, set by the wrapper
   * modifier's destructor (see `makeTrigger`) and cancelled by `ensureAnchor`
   * if the wrapper turns out to have just re-run for the same element.
   *
   * WHY THIS EXISTS: `ember-modifier` calls the wrapper's destructor before
   * *every* re-run (same-element open/close churn included) as well as on
   * genuine removal, and does not tell us which. So the destructor alone
   * cannot decide whether to tear the anchor down. Deferring the decision by
   * one runloop turn resolves the ambiguity: if the wrapper is only
   * re-running, `ensureAnchor` runs synchronously afterwards (same tick,
   * before the deferred check fires) and cancels this; if the element was
   * genuinely removed, nothing calls `ensureAnchor` again, so the deferred
   * check fires and the anchor is torn down for real.
   *
   * Scheduled with `@ember/runloop`'s `next`/`cancel`, like the rest of this
   * codebase's timer usage (see `popover.gts`'s `hoverTimer`), rather than a
   * bespoke `setTimeout`.
   */
  pendingAnchorTeardown?: {
    element: HTMLElement | SVGElement;
    timer: EmberTimer;
  };

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
    // The wrapper modifier re-ran for this same element -- any anchor
    // teardown its destructor speculatively scheduled (see
    // `scheduleAnchorTeardownCheck`) is stale: the element didn't actually go
    // away, so cancel the pending check before it can fire.
    if (
      this.pendingAnchorTeardown &&
      this.pendingAnchorTeardown.element === element
    ) {
      cancel(this.pendingAnchorTeardown.timer);
      this.pendingAnchorTeardown = undefined;
    }

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

  /**
   * Called from the wrapper modifier's destructor -- i.e. on *every*
   * re-run of the wrapper, not only on genuine removal of `element`. Defers
   * the decision by one runloop turn: schedules `confirmAnchorTeardown` via
   * `next()`, which only actually tears the anchor down if nothing cancels
   * it first. `ensureAnchor` (above) is what cancels it, synchronously,
   * within the same runloop turn, if the wrapper turns out to have simply
   * re-run for the same element.
   */
  scheduleAnchorTeardownCheck(element: HTMLElement | SVGElement) {
    // Superseding an earlier pending check for a different element should
    // not normally happen (a new one would already have been resolved by an
    // intervening `ensureAnchor` call), but cancel defensively rather than
    // leak the earlier timer.
    if (this.pendingAnchorTeardown) {
      cancel(this.pendingAnchorTeardown.timer);
    }

    const timer = next(() => this.confirmAnchorTeardown(element));
    this.pendingAnchorTeardown = { element, timer };
  }

  /**
   * Runs one runloop turn after the wrapper modifier's destructor scheduled
   * it. If it gets here at all (i.e. `ensureAnchor` did not cancel it in the
   * meantime), the wrapper never re-ran for `element` -- the element was
   * genuinely removed -- so the anchor installed on it is torn down for
   * real.
   */
  confirmAnchorTeardown(element: HTMLElement | SVGElement) {
    if (
      !this.pendingAnchorTeardown ||
      this.pendingAnchorTeardown.element !== element
    ) {
      // Already superseded/cancelled (or, in principle, stale) -- nothing to
      // do.
      return;
    }

    this.pendingAnchorTeardown = undefined;

    if (this.anchoredElement === element) {
      this.anchorTeardown?.();
      this.anchoredElement = undefined;
      this.anchorTeardown = undefined;
    }
  }

  willDestroy() {
    super.willDestroy();
    if (this.pendingAnchorTeardown) {
      cancel(this.pendingAnchorTeardown.timer);
      this.pendingAnchorTeardown = undefined;
    }
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

          // `ember-modifier` calls this destructor before *every* re-run --
          // including a same-element re-run driven by `this.isOpen` churn --
          // and on genuine removal of `element`, with no way to tell which
          // from here. The trigger half always tears down and reinstalls
          // (that's what keeps `aria-describedby` in sync). The anchor half
          // cannot follow the same rule -- unconditionally tearing it down
          // here would reintroduce the churn this guard exists to prevent --
          // so it's handled by deferred confirmation: `scheduleAnchorTeardownCheck`
          // only *actually* tears the anchor down one runloop turn later, and
          // only if `ensureAnchor` doesn't cancel it first because the
          // wrapper turned out to just be re-running for the same element.
          // See the doc comments on `pendingAnchorTeardown` /
          // `scheduleAnchorTeardownCheck` / `confirmAnchorTeardown` above.
          return () => {
            teardownTrigger?.();
            this.scheduleAnchorTeardownCheck(element);
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
