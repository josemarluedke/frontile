import Component from '@glimmer/component';
import { Overlay, type OverlaySignature } from './overlay';
import { tracked, cached } from '@glimmer/tracking';
import { Velcro } from 'ember-velcro';
import { arrow as arrowMiddleware } from '@floating-ui/dom';
import { assert } from '@ember/debug';
import { guidFor } from '@ember/object/internals';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { modifier } from 'ember-modifier';
import { debounce, later, cancel } from '@ember/runloop';
import type { Timer as EmberTimer } from '@ember/runloop';
import type { ModifierLike } from '@glint/template';
import type { WithBoundArgs } from '@glint/template';
import type { Signature as VelcroSignature } from 'ember-velcro/modifiers/velcro';
import type { MiddlewareArguments } from '@floating-ui/dom';

interface PopoverSignature {
  Args: {
    /**
     * Placement of the menu when open
     *
     * @defaultValue 'bottom-start'
     */
    placement?:
      | 'top'
      | 'top-start'
      | 'top-end'
      | 'right'
      | 'right-start'
      | 'right-end'
      | 'bottom'
      | 'bottom-start'
      | 'bottom-end'
      | 'left'
      | 'left-start'
      | 'left-end';

    /**
     * Options for the floating-ui flip middleware, which moves the content to
     * the opposite side when it would overflow the viewport.
     */
    flipOptions?: VelcroSignature['Args']['Named']['flipOptions'];

    /**
     * Additional floating-ui middleware, for positioning behavior beyond what
     * `placement`, `offsetOptions`, `flipOptions`, and `shiftOptions` cover.
     */
    middleware?: VelcroSignature['Args']['Named']['middleware'];

    /**
     * Options for the floating-ui shift middleware, which nudges the content
     * along its axis to keep it in view.
     */
    shiftOptions?: VelcroSignature['Args']['Named']['shiftOptions'];

    /**
     * @defaultValue 5
     */
    offsetOptions?: VelcroSignature['Args']['Named']['offsetOptions'];

    /**
     * @defaultValue 'absolute'
     */
    strategy?: VelcroSignature['Args']['Named']['strategy'];

    /**
     * Whether the popover is open. Pair with `onOpenChange` to control it;
     * leave it unset to let the popover manage its own state.
     */
    isOpen?: boolean;

    /**
     * Callback when the popover opens or closes, receiving the new state.
     */
    onOpenChange?: (isOpen: boolean) => void;

    /**
     * Callback when closing has finished, including any exit transition.
     */
    didClose?: () => void;

    /**
     * Milliseconds to wait before opening on hover or keyboard focus. Only
     * applies to a `trigger` installed in hover mode.
     *
     * @defaultValue 100
     */
    openDelay?: number;

    /**
     * Milliseconds to wait before closing after the pointer leaves the trigger
     * or the content. Only applies to a `trigger` installed in hover mode.
     *
     * This is also the window the pointer has to cross the gap between the
     * trigger and the content, so setting it to 0 makes content hover
     * unreachable in practice.
     *
     * @defaultValue 100
     */
    closeDelay?: number;
  };
  Element: HTMLUListElement;
  Blocks: {
    default: [
      {
        anchor: ModifierLike<{ Element: HTMLElement }>;

        /**
         * Nominates the element it is placed on as the width reference for
         * `@size="trigger"` content, instead of the element carrying `trigger`.
         */
        measureWidth: ModifierLike<{ Element: HTMLElement }>;
        isOpen: boolean;
        toggle: () => void;
        open: () => void;
        close: () => void;
        trigger: ModifierLike<{
          Element: HTMLElement;
          Args: {
            Positional: [eventType?: 'click' | 'hover'];
            Named: { aria?: 'menu' | 'describedby' | 'none' };
          };
        }>;

        /**
         * The floating-ui middleware data for the current position, including
         * the placement actually resolved after `flip`.
         */
        data: MiddlewareArguments;
        Content: WithBoundArgs<
          typeof Content,
          | 'loop'
          | 'isOpen'
          | 'id'
          | 'toggle'
          | 'internalDidClose'
          | 'blockScroll'
          | 'backdrop'
          | 'triggerWidth'
          | 'preventAutoFocus'
          | 'isHoverTrigger'
          | 'onContentHoverStart'
          | 'onContentHoverEnd'
          | 'registerArrow'
          | 'velcroData'
        >;
      }
    ];
  };
}

class Popover extends Component<PopoverSignature> {
  /**
   * The element `measureWidth` is watching, when a consumer opts into measuring
   * something other than the trigger. Its presence is what gives `measureWidth`
   * precedence over `trigger` as the source of `triggerWidth`.
   */
  widthEl?: HTMLElement;

  menuId = guidFor(this);

  /**
   * Whether the consumer is still owed a `@didClose`. Set by `close()` when a
   * popover that was actually open was closed, and cleared either by `didClose`
   * once it has fired the callback -- so it can only ever fire once per close --
   * or by `open()`, which means the close it was armed for never completed.
   */
  isDidClosePending = false;

  @tracked _isOpen = false;
  @tracked isClosing = false;
  @tracked preventFocusRestore = false;

  /**
   * Whether a `trigger` is installed in hover mode. Hover popovers must not
   * take focus -- `Overlay` focuses its content when the focus trap is
   * disabled, which for a hover popover means the pointer silently moves focus
   * and scrolls the content into view.
   */
  @tracked isHoverTrigger = false;
  @tracked triggerWidth?: number;

  /**
   * The arrow element, once `Content` has rendered one. Tracked because the
   * middleware array is derived from it -- `Velcro` re-runs when the array
   * identity changes, so the arrow is picked up whenever it appears, in either
   * render order.
   */
  @tracked arrowEl?: HTMLElement;

  registerArrow = modifier((el: HTMLElement) => {
    this.arrowEl = el;

    return () => {
      if (this.arrowEl === el) {
        this.arrowEl = undefined;
      }
    };
  });

  /**
   * `@cached` is load-bearing, not decorative: without it this getter would
   * build a brand-new array (and a brand-new `arrowMiddleware(...)` instance)
   * on every access. `{{this.middleware}}` sits in the same template block
   * that yields `velcro.data`, so a `Velcro`-driven position update re-renders
   * that block, which re-invokes the getter -- an unmemoized array would read
   * to `Velcro` as changed middleware and retrigger positioning, looping
   * forever. Caching keeps the array's identity stable across re-renders that
   * don't touch `this.args.middleware` or `this.arrowEl`, while still
   * producing a new array when either of those tracked dependencies changes
   * (e.g. when the arrow element first appears).
   */
  @cached
  get middleware(): VelcroSignature['Args']['Named']['middleware'] {
    const consumer = this.args.middleware ?? [];

    if (!this.arrowEl) {
      return this.args.middleware;
    }

    // `padding` keeps the arrow off the content's rounded corners, where it
    // would poke out past the radius.
    return [
      ...consumer,
      arrowMiddleware({ element: this.arrowEl, padding: 4 })
    ];
  }

  get isOpen(): boolean {
    if (
      typeof this.args.isOpen !== 'undefined' &&
      typeof this.args.onOpenChange === 'function'
    ) {
      return this.args.isOpen;
    }

    return this._isOpen;
  }

  toggle = (event?: Event) => {
    // stops event bubbling to prevent parent click event
    if (typeof event?.stopPropagation === 'function') {
      event.stopPropagation();
    }

    if (this.isOpen) {
      this.close();
    } else {
      this.open();
    }
  };

  open = () => {
    if (this.isClosing) {
      return;
    }

    // Opening settles any close that never finished. In controlled mode
    // `close()` only *asks* -- it calls `onOpenChange(false)` and the consumer
    // decides -- so a consumer that declines leaves the content mounted with
    // the callback still owed. Nothing clears that but `didClose`, which never
    // runs while the content stays up, so without this the debt would sit armed
    // and be paid out by whatever unrelated teardown came next.
    this.isDidClosePending = false;

    if (typeof this.args.onOpenChange === 'function') {
      this.args.onOpenChange(true);
    } else {
      this._isOpen = true;
    }
  };

  close = () => {
    // Only a popover that was actually open has a close to finish, and so a
    // `@didClose` to owe. `close()` is reachable with nothing open -- a stray
    // `mouseleave`, a consumer calling the yielded `close` -- and firing the
    // callback for those would be a lie.
    const wasOpen = this.isOpen;

    this.isClosing = true;
    if (typeof this.args.onOpenChange === 'function') {
      this.args.onOpenChange(false);
    } else {
      this._isOpen = false;
    }

    if (wasOpen) {
      this.isDidClosePending = true;
    }

    debounce(this, this.resetIsClosing, 90);
  };

  /**
   * The single pending hover intent, or `undefined`. One field rather than two
   * debounces: `debounce` keys on the target/method pair, so debouncing
   * `open` from `mouseenter` and `close` from `mouseleave` left the two unable
   * to cancel each other -- a leave-then-re-enter inside the window queued
   * both, and the close won.
   *
   * Scheduled with `@ember/runloop`'s `later`/`cancel`, like the rest of this
   * codebase (`-private/timer.ts`, `control-blur.ts`, `-private/manager.ts`,
   * `utils/listManager.ts`, `resetIsClosing` below), rather than a raw
   * `setTimeout`/`clearTimeout`. Run-loop tracking is what makes `settled()`
   * -- and so `await triggerEvent(...)`/`await click(...)` in
   * `@ember/test-helpers` -- wait out a pending hover open or close, the same
   * way every other timed transition in this component already does. Tests
   * that need to prove a pending close gets cancelled by a second event
   * (e.g. the pointer arriving on the content) dispatch the raw DOM events
   * directly and `await settled()` once afterward, instead of relying on
   * `await triggerEvent(...)`'s auto-wait -- see the "hover: leaving and
   * re-entering" tests below.
   */
  hoverTimer?: { id: EmberTimer; intent: 'open' | 'close' };

  get openDelay(): number {
    return typeof this.args.openDelay === 'number' ? this.args.openDelay : 100;
  }

  get closeDelay(): number {
    return typeof this.args.closeDelay === 'number'
      ? this.args.closeDelay
      : 100;
  }

  clearHoverTimer = () => {
    if (this.hoverTimer) {
      cancel(this.hoverTimer.id);
      this.hoverTimer = undefined;
    }
  };

  scheduleOpen = () => {
    this.clearHoverTimer();

    if (this.isOpen) {
      return;
    }

    const run = () => {
      this.hoverTimer = undefined;
      if (this.isDestroyed || this.isDestroying) return;
      // A hover open is never part of the click cascade `isClosing` guards
      // against, so it must not be gated by it -- that gate is what swallowed
      // opens on an adjacent trigger.
      this.isClosing = false;
      this.open();
    };

    if (this.openDelay === 0) {
      run();
      return;
    }

    this.hoverTimer = { id: later(run, this.openDelay), intent: 'open' };
  };

  scheduleClose = () => {
    this.clearHoverTimer();

    if (!this.isOpen) {
      return;
    }

    const run = () => {
      this.hoverTimer = undefined;
      if (this.isDestroyed || this.isDestroying) return;
      this.close();
    };

    if (this.closeDelay === 0) {
      run();
      return;
    }

    this.hoverTimer = { id: later(run, this.closeDelay), intent: 'close' };
  };

  /**
   * `Escape` must close a hover popover (WCAG 1.4.13), but in hover mode focus
   * is typically nowhere near the trigger, so a trigger-level `keydown` would
   * never see the key. Installed on the document while open in hover mode.
   */
  escapeListener?: (event: KeyboardEvent) => void;

  setupEscapeListener = () => {
    if (this.escapeListener) return;

    this.escapeListener = (event: KeyboardEvent) => {
      if (event.key === 'Escape' && this.isOpen) {
        this.clearHoverTimer();
        this.close();
      }
    };

    document.addEventListener('keydown', this.escapeListener);
  };

  teardownEscapeListener = () => {
    if (this.escapeListener) {
      document.removeEventListener('keydown', this.escapeListener);
      this.escapeListener = undefined;
    }
  };

  willDestroy(): void {
    super.willDestroy();
    this.clearHoverTimer();
    this.teardownEscapeListener();
  }

  trigger = modifier(
    (
      el: HTMLElement,
      [eventType]: [eventType?: 'click' | 'hover'],
      { aria }: { aria?: 'menu' | 'describedby' | 'none' } = {}
    ) => {
      // The trigger is only the width reference when nothing more specific was
      // nominated. `widthEl` is checked when the measurement happens rather than
      // when the modifier installs, so the two modifiers can install in either
      // order.
      requestAnimationFrame(() => {
        if (!this.widthEl) {
          this.triggerWidth = Math.round(el.offsetWidth);
        }
      });

      let observer: ResizeObserver;
      if (eventType !== 'hover') {
        observer = new ResizeObserver((entries) => {
          for (let entry of entries) {
            if (this.widthEl) {
              continue;
            }
            this.triggerWidth = Math.round(
              (entry.target as HTMLElement).offsetWidth
            );
          }
        });
        observer.observe(el);
      }

      const onFocusIn = () => {
        if (el.matches(':focus-visible')) {
          this.scheduleOpen();
        }
      };

      const onKeydown = (event: KeyboardEvent) => {
        if (this.isOpen && event.key === 'Escape') {
          this.close();
          event.stopPropagation();
        }
        if (
          !this.isOpen &&
          (event.key === 'ArrowDown' || event.key === 'ArrowUp')
        ) {
          this.open();
          event.stopPropagation();
        }

        if (this.isOpen && event.key === 'Tab') {
          this.preventFocusRestore = true;
          this.close();
        }

        // Open when a letter is pressed, so the content can be typed into.
        // Modifier combos belong to the browser or the OS (Cmd+R, Ctrl+F,
        // Alt+C) and still deliver a letter `key`, so without this check the
        // popover would pop open over whatever the shortcut does. Shift stays
        // allowed: a capital letter is legitimate type-ahead.
        if (
          !this.isOpen &&
          !event.metaKey &&
          !event.ctrlKey &&
          !event.altKey &&
          event.code === `Key${event.key.toUpperCase()}`
        ) {
          this.open();
        }
      };

      if (eventType === 'hover') {
        this.preventFocusRestore = true;
        this.isHoverTrigger = true;
        // The modifier body re-runs on every open/close (it reads
        // `this.isOpen` below to keep `aria-expanded` in sync), and the
        // returned cleanup below always tears the listener down first -- so
        // gating the install on `isOpen` here is what keeps the document
        // listener attached only while open, matching the doc comment on
        // `escapeListener`.
        if (this.isOpen) {
          this.setupEscapeListener();
        }

        el.addEventListener('mouseenter', this.scheduleOpen);
        el.addEventListener('mouseleave', this.scheduleClose);
        // Keyboard-only: a mouse click also fires `focusin`, and opening on
        // that would leave content up after the pointer had already left.
        el.addEventListener('focusin', onFocusIn);
        el.addEventListener('focusout', this.scheduleClose);
      } else {
        el.addEventListener('keydown', onKeydown);
        el.addEventListener('click', this.toggle);
      }

      // Reading `this.isOpen` here is what keeps these attributes in sync: the
      // modifier consumes the tracked state, so its whole body re-runs on every
      // open and close. That is more work than an attribute needs -- the
      // listeners are rebuilt too -- but it is the only mechanism that covers
      // `@isOpen` being flipped from outside in controlled mode, which an
      // imperative update from `open()`/`close()` would miss.
      const ariaMode = aria ?? 'menu';

      if (ariaMode === 'menu') {
        el.setAttribute('aria-haspopup', 'true');
        el.setAttribute('aria-controls', this.menuId);
        el.setAttribute('aria-expanded', this.isOpen.toString());
      } else if (ariaMode === 'describedby') {
        // A tooltip is its trigger's description, not a popup it owns. The
        // attribute only exists while there is something to describe --
        // pointing at an unrendered id is worse than pointing at nothing.
        if (this.isOpen) {
          el.setAttribute('aria-describedby', this.menuId);
        } else {
          el.removeAttribute('aria-describedby');
        }
      }

      return () => {
        if (eventType === 'hover') {
          this.isHoverTrigger = false;
          this.clearHoverTimer();
          this.teardownEscapeListener();
          el.removeEventListener('mouseenter', this.scheduleOpen);
          el.removeEventListener('mouseleave', this.scheduleClose);
          el.removeEventListener('focusin', onFocusIn);
          el.removeEventListener('focusout', this.scheduleClose);
        } else {
          el.removeEventListener('click', this.toggle);
          el.removeEventListener('keydown', onKeydown);
        }
        if (observer) {
          observer.disconnect();
        }
      };
    }
  );

  /**
   * Nominates the element it is placed on as the popover's width reference,
   * instead of the element carrying `trigger`.
   *
   * `@size="trigger"` content is sized from `--trigger-width`, which is normally
   * the trigger's own width. That is only right while the toggle and the box the
   * content should line up with are the same element. When they are not -- a
   * field whose trigger is one of several things inside it, say -- put this on
   * the element the content should match.
   *
   * It takes precedence over `trigger`'s own measurement for as long as it is
   * installed, so the two never race.
   */
  measureWidth = modifier((el: HTMLElement) => {
    this.widthEl = el;

    requestAnimationFrame(() => {
      if (this.widthEl === el) {
        this.triggerWidth = Math.round(el.offsetWidth);
      }
    });

    const observer = new ResizeObserver((entries) => {
      for (const entry of entries) {
        if (this.widthEl !== el) {
          continue;
        }
        this.triggerWidth = Math.round(
          (entry.target as HTMLElement).offsetWidth
        );
      }
    });
    observer.observe(el);

    return () => {
      observer.disconnect();
      if (this.widthEl === el) {
        this.widthEl = undefined;
      }
    };
  });

  /**
   * Clears the short window during which `open()` refuses to re-open.
   *
   * The 90ms this is debounced by is deliberately not the transition duration
   * (200ms): the window exists to absorb a single event cascade -- the Overlay's
   * outside-click handler closing while the trigger's own click handler is
   * about to re-open -- not to wait for the animation out. Stretching it to the
   * transition would leave the trigger feeling dead for a fifth of a second
   * after every close, which is far more noticeable than a re-click inside 90ms
   * being dropped.
   */
  resetIsClosing = () => {
    if (!this.isDestroyed && !this.isDestroying) {
      this.isClosing = false;
    }
  };

  /**
   * Passed to `Content` as `internalDidClose`, so it runs once the Overlay has
   * finished tearing down -- that is, after the exit transition. That is the
   * moment `@didClose` documents, which is why the consumer's callback is fired
   * from here and not from `close()`.
   *
   * A popover whose `Content` never mounted never gets here, and never owes the
   * callback: there was no overlay, so there was no close to finish.
   */
  didClose = () => {
    this.resetIsClosing();

    if (this.isDidClosePending) {
      this.isDidClosePending = false;

      if (typeof this.args.didClose === 'function') {
        this.args.didClose();
      }
    }
  };

  <template>
    <Velcro
      @placement={{if @placement @placement "bottom-start"}}
      @strategy={{if @strategy @strategy "absolute"}}
      @offsetOptions={{if @offsetOptions @offsetOptions 5}}
      @flipOptions={{@flipOptions}}
      @middleware={{this.middleware}}
      @shiftOptions={{@shiftOptions}}
      as |velcro|
    >
      {{yield
        (hash
          anchor=velcro.hook
          measureWidth=this.measureWidth
          isOpen=this.isOpen
          open=this.open
          close=this.close
          toggle=this.toggle
          trigger=this.trigger
          data=velcro.data
          Content=(component
            Content
            id=this.menuId
            loop=velcro.loop
            isOpen=this.isOpen
            toggle=this.toggle
            internalDidClose=this.didClose
            preventFocusRestore=this.preventFocusRestore
            preventAutoFocus=this.isHoverTrigger
            triggerWidth=this.triggerWidth
            isHoverTrigger=this.isHoverTrigger
            onContentHoverStart=this.clearHoverTimer
            onContentHoverEnd=this.scheduleClose
            registerArrow=this.registerArrow
            velcroData=velcro.data
          )
        )
      }}
    </Velcro>
  </template>
}

interface ContentArgs extends Pick<
  OverlaySignature['Args'],
  | 'onOpen'
  | 'didClose'
  | 'renderInPlace'
  | 'target'
  | 'transitionDuration'
  | 'backdrop'
  | 'disableTransitions'
  | 'focusTrapOptions'
  | 'closeOnOutsideClick'
  | 'closeOnEscapeKey'
  | 'backdropTransition'
  | 'blockScroll'
  | 'preventAutoFocus'
> {
  /**
   * @internal
   */
  loop: ModifierLike<{ Element: HTMLElement }>;
  /**
   * @internal
   */
  isOpen: boolean;

  /**
   * @internal
   */
  toggle: () => void;

  /**
   * @ignore
   */
  internalDidClose: () => void;

  /**
   * @internal
   */
  id: string;

  /**
   * @internal
   */
  preventFocusRestore?: boolean;

  /**
   * @internal
   */
  triggerWidth?: number;

  /**
   * @internal
   */
  isHoverTrigger?: boolean;

  /**
   * @internal
   */
  onContentHoverStart?: () => void;

  /**
   * @internal
   */
  onContentHoverEnd?: () => void;

  /**
   * Renders an arrow pointing at the anchor.
   *
   * @defaultValue false
   */
  arrow?: boolean;

  /**
   * @internal
   */
  registerArrow?: ModifierLike<{ Element: HTMLElement }>;

  /**
   * @internal
   */
  velcroData?: MiddlewareArguments;

  /**
   * Closes as soon as the pointer leaves the trigger, instead of letting it
   * move into the content. Only meaningful for a hover trigger.
   *
   * @defaultValue false
   */
  disableInteractive?: boolean;

  /**
   * Custom class name for the content element, merged with the default ones
   * using Tailwind Merge.
   */
  class?: string;

  /**
   * The transition to be used in the Modal.
   *
   * @defaultValue {name: 'overlay-transition--scale'}
   */
  transition?: OverlaySignature['Args']['transition'];

  /**
   * @defaultValue true
   */
  disableFocusTrap?: boolean;

  /**
   * The size of the content.
   *
   * @defaultValue 'md'
   */
  size?: 'sm' | 'md' | 'lg' | 'xl' | 'trigger';
}

interface ContentSignature {
  Args: ContentArgs;
  Element: HTMLDivElement;
  Blocks: { default: [] };
}

/**
 * Component yielded from Popover
 */
class Content extends Component<ContentSignature> {
  get loop() {
    assert(
      'The Popover is not properly configured; the @loop is undefined. This issue may arise from failing to set up the anchor.',
      this.args.loop
    );
    return this.args.loop;
  }

  get classNames() {
    const { popover } = useStyles();
    return popover({ size: this.args.size, class: this.args.class });
  }

  get backdrop(): OverlaySignature['Args']['backdrop'] {
    return this.args.backdrop || 'none';
  }

  get transition() {
    let options: OverlaySignature['Args']['transition'] = {
      name: 'overlay-transition--scale'
    };

    if (typeof this.args.transition === 'object') {
      return { ...options, ...this.args.transition };
    }

    return options;
  }

  get blockScroll() {
    if (typeof this.args.blockScroll !== 'undefined') {
      return this.args.blockScroll;
    }
    return false;
  }

  get disableFocusTrap() {
    if (this.args.disableFocusTrap === false) {
      return false;
    }
    return true;
  }

  didClose = () => {
    if (typeof this.args.internalDidClose === 'function') {
      this.args.internalDidClose();
    }

    if (typeof this.args.didClose === 'function') {
      this.args.didClose();
    }
  };

  updateTriggerWidth = modifier((el: HTMLDivElement) => {
    if (el && this.args.triggerWidth) {
      el.style.setProperty('--trigger-width', `${this.args.triggerWidth}px`);
    }
  });

  /**
   * `{{#if}}` cannot guard a modifier, so the decision lives inside it: when
   * the trigger is not in hover mode, or the consumer opted out, this installs
   * no listeners at all.
   *
   * Also tracks focus, not just the pointer: a keyboard user tabbing from the
   * trigger into a focusable element inside the content triggers the
   * trigger's own `focusout`, which unconditionally schedules a close. With
   * nothing here to cancel it, that close would fire out from under a
   * keyboard user after `closeDelay`, even though the pointer analogue --
   * moving onto the content -- keeps it open. `focusin`/`focusout` reuse the
   * same callbacks as `mouseenter`/`mouseleave` because they need to do
   * exactly the same thing: cancel or (re)schedule the one pending hover
   * intent.
   */
  trackContentHover = modifier((el: HTMLElement) => {
    if (
      this.args.isHoverTrigger !== true ||
      this.args.disableInteractive === true
    ) {
      return;
    }

    const enter = () => this.args.onContentHoverStart?.();
    const leave = () => this.args.onContentHoverEnd?.();

    el.addEventListener('mouseenter', enter);
    el.addEventListener('mouseleave', leave);
    el.addEventListener('focusin', enter);
    el.addEventListener('focusout', leave);

    return () => {
      el.removeEventListener('mouseenter', enter);
      el.removeEventListener('mouseleave', leave);
      el.removeEventListener('focusin', enter);
      el.removeEventListener('focusout', leave);
    };
  });

  get placement(): string | undefined {
    return this.args.velcroData?.placement;
  }

  get arrowClass(): string {
    const { overlayArrow } = useStyles();
    return overlayArrow();
  }

  /**
   * Positions the arrow from the floating-ui `arrow` middleware: it supplies
   * the offset along the content's edge (`x` for a top/bottom placement, `y`
   * for left/right), and the side the arrow sits on is the one opposite the
   * resolved placement. Inline styles rather than classes -- the offset is a
   * computed pixel value that changes on every reposition.
   */
  positionArrow = modifier((el: HTMLElement) => {
    const data = this.args.velcroData;
    const offset = data?.middlewareData?.arrow;
    const placement = data?.placement;

    if (!offset || !placement) {
      return;
    }

    const staticSides: Record<string, string> = {
      top: 'bottom',
      bottom: 'top',
      left: 'right',
      right: 'left'
    };
    const side = placement.split('-')[0] as string;
    const staticSide = staticSides[side] ?? 'bottom';

    el.style.left = typeof offset.x === 'number' ? `${offset.x}px` : '';
    el.style.top = typeof offset.y === 'number' ? `${offset.y}px` : '';
    el.style.right = '';
    el.style.bottom = '';
    // Half the arrow's 8px box, so the rotated square straddles the edge.
    el.style[staticSide as 'top' | 'bottom' | 'left' | 'right'] = '-4px';
  });

  <template>
    <Overlay
      @blockScroll={{this.blockScroll}}
      @transition={{this.transition}}
      @backdrop={{this.backdrop}}
      @customContentModifier={{this.loop}}
      @disableFlexContent={{true}}
      @isOpen={{@isOpen}}
      @onClose={{@toggle}}
      @onOpen={{@onOpen}}
      @didClose={{this.didClose}}
      @renderInPlace={{@renderInPlace}}
      @target={{@target}}
      @transitionDuration={{@transitionDuration}}
      @disableTransitions={{@disableTransitions}}
      @disableFocusTrap={{this.disableFocusTrap}}
      @focusTrapOptions={{@focusTrapOptions}}
      @closeOnOutsideClick={{@closeOnOutsideClick}}
      @closeOnEscapeKey={{@closeOnEscapeKey}}
      @backdropTransition={{@backdropTransition}}
      @class={{this.classNames}}
      @preventFocusRestore={{@preventFocusRestore}}
      @preventAutoFocus={{@preventAutoFocus}}
      @closeOnOverlayElementClick={{false}}
      id={{@id}}
      data-placement={{this.placement}}
      ...attributes
      {{this.updateTriggerWidth @triggerWidth}}
      {{this.trackContentHover @isHoverTrigger @disableInteractive}}
    >
      {{yield}}
      {{#if @arrow}}
        <span
          class={{this.arrowClass}}
          data-part="arrow"
          {{@registerArrow}}
          {{! @velcroData is passed but never read by the modifier body: supplying
              it is what makes ember-modifier re-run this on every reposition.
              Remove the argument and the arrow positions once, then never moves. }}
          {{this.positionArrow @velcroData}}
        ></span>
      {{/if}}
    </Overlay>
  </template>
}

export {
  Popover,
  Content as PopoverContent,
  type PopoverSignature,
  type ContentSignature
};
export default Popover;
