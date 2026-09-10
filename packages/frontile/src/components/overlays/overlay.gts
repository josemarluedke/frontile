/* eslint-disable ember/no-runloop */
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { later } from '@ember/runloop';
import { on } from '@ember/modifier';
import { cssTransition } from 'ember-css-transitions';
import { useStyles } from '@frontile/theme';
import { modifier } from 'ember-modifier';
import { focusTrap, type FocusTrapModifierSignature } from 'ember-focus-trap';
import onClickOutside from 'ember-click-outside/modifiers/on-click-outside';
import { Backdrop, type BackdropSignature } from './backdrop';
import {
  afterFirstPaint,
  hasPainted,
  shouldDeferMount,
  shouldSkipEnterTransition,
  withoutEnterTransition
} from './mount-animation';
import { Portal, findParentPortal, type PortalSignature } from './portal';
import type { ModifierLike } from '@glint/template';
import type { CssTransitionSignature } from 'ember-css-transitions/modifiers/css-transition';
import { isTesting, macroCondition } from '@embroider/macros';

type FocusTrapOptions = NonNullable<
  FocusTrapModifierSignature['Args']['Named']['focusTrapOptions']
>;

/**
 * Whether `target` sits inside a portal nested within this overlay's own
 * portal.
 *
 * The question a click handler needs answered is about *this* click, not about
 * the mere existence of a nested portal. Asking only "is a nested portal
 * mounted?" made a parent overlay ignore every outside click for as long as a
 * child was open -- so with a Dropdown submenu (or a Select inside a Modal)
 * open, clicking the page did not close anything.
 *
 * A portal that is not a descendant of this overlay's portal -- one given an
 * explicit `@target`, or opted out of `appendToParentPortal` -- is not nested,
 * and a click in it is a genuine outside click.
 */
function isWithinNestedPortal(
  contentElement: HTMLElement,
  target: EventTarget | null
): boolean {
  const ownPortal = findParentPortal(contentElement);
  if (!ownPortal || !(target instanceof Element)) {
    return false;
  }

  const targetPortal = target.closest('[data-portal="true"]');
  if (!targetPortal || targetPortal === ownPortal) {
    return false;
  }

  return ownPortal.contains(targetPortal);
}

// Blocking the body scroll mutates global state, so it has to be reference
// counted: nested overlays (a Drawer opened from a Modal, a Select inside a
// Modal) each lock on open and unlock on close, and only the last one out is
// allowed to restore the page. We also remember the inline value the app had
// before the first lock, so restoring does not silently wipe an app-level
// `body { overflow: ... }`.
let bodyScrollLockCount = 0;
let previousBodyOverflow = '';

function lockBodyScroll(): void {
  if (bodyScrollLockCount === 0) {
    previousBodyOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
  }
  bodyScrollLockCount++;
}

function unlockBodyScroll(): void {
  if (bodyScrollLockCount === 0) {
    return;
  }

  bodyScrollLockCount--;

  if (bodyScrollLockCount === 0) {
    document.body.style.overflow = previousBodyOverflow;
    previousBodyOverflow = '';
  }
}

// finds if the el has a parent with the id `ember-basic-dropdown-wormhole` or a role of `alert`
function hasWormholeOrAlertParentElement(el: HTMLElement) {
  let parent = el.parentElement;
  while (parent) {
    if (
      parent.id === 'ember-basic-dropdown-wormhole' ||
      parent.role === 'alert'
    ) {
      return true;
    }
    parent = parent.parentElement;
  }
  return false;
}

interface Args extends Pick<
  PortalSignature['Args'],
  'renderInPlace' | 'target'
> {
  /**
   * Duration of the animation
   *
   * @defaultValue 200
   */
  transitionDuration?: number;

  /**
   * How the area behind the overlay is rendered: `none` omits the backdrop
   * entirely, `transparent` keeps it clickable but invisible, `faded` dims the
   * page, and `blur` blurs it.
   */
  backdrop?: BackdropSignature['Args']['type'];

  /**
   * Transition classes for the backdrop, overriding the defaults used when it
   * fades in and out.
   */
  backdropTransition?: BackdropSignature['Args']['transition'];

  /**
   * Disable css transitions
   *
   * @defaultValue false
   */
  disableTransitions?: boolean;

  /**
   * Whether an overlay that is *already open the first time it renders* --
   * deep-linked open, or restored by a page refresh -- animates in.
   *
   * When true (the default) the overlay waits for the browser's first paint
   * before mounting, so the animation plays against a page the user has
   * already seen instead of starting before anything has been painted. Set it
   * to false for an already-open overlay that should simply be there, with no
   * reveal. Either way, an overlay opened later by interaction animates
   * normally, and the close animation is unaffected.
   *
   * @defaultValue true
   */
  animateOnMount?: boolean;

  /**
   * Whether the focus trap is disabled or not
   *
   * @defaultValue false
   */
  disableFocusTrap?: boolean;

  /**
   * Focus trap options
   *
   * @defaultValue { clickOutsideDeactivates: true, allowOutsideClick: true }
   */
  focusTrapOptions?: FocusTrapOptions;

  /**
   * Whether it is open or not
   */
  isOpen: boolean;

  /**
   * A function that will be called when closed
   */
  onClose?: () => void;

  /**
   * A function that will be called when closing is finished executing, this
   * includes waiting for animations/transitions to finish.
   */
  didClose?: () => void;

  /**
   * A function that will be called when opened
   */
  onOpen?: () => void;

  /**
   * Whether to close when the area outside (the backdrop) is clicked
   *
   * @defaultValue true
   */
  closeOnOutsideClick?: boolean;

  /**
   * Whether to close when the overlay element is clicked, used for modal and drawer components.
   * This is set to true by default to allow "outside click" functionality to work properly.
   * Most overlay content is wrapped with an inner element, preventing accidental closure.
   *
   * @defaultValue true
   */
  closeOnOverlayElementClick?: boolean;

  /**
   * Whether to close when the escape key is pressed
   *
   * @defaultValue true
   */
  closeOnEscapeKey?: boolean;

  /**
   * Transition options
   *
   * @defaultValue {name:'overlay-transition--fade'}
   */
  transition?: CssTransitionSignature['Args']['Named'];

  /**
   * Opt out of the flex layout applied to the content element, for overlays
   * that need to lay their content out themselves.
   *
   * @defaultValue false
   */
  disableFlexContent?: boolean;

  /**
   * An extra modifier applied to the content element, for behavior the overlay
   * doesn't provide itself.
   */
  customContentModifier?: ModifierLike<{ Element: HTMLElement }>;

  /**
   * Custom class name for the content element, merged with the default ones
   * using Tailwind Merge.
   */
  class?: string;
  /**
   * @defaultValue false
   */
  preventFocusRestore?: boolean;

  /**
   * When focusTrap is disabled, by default Oberlay will be auto focused. This option prevents that.
   * @defaultValue false
   */
  preventAutoFocus?: boolean;

  /**
   * @defaultValue true
   */
  blockScroll?: boolean;
}

interface OverlaySignature {
  Args: Args;
  Element: HTMLDivElement;
  Blocks: { default: [] };
}

class Overlay extends Component<OverlaySignature> {
  @tracked keepOpen = false;

  // Whether the browser has painted since this overlay was created. Only ever
  // consulted while the mount is being deferred; see `mount-animation.ts`.
  @tracked hasWaitedForPaint = false;

  // Whether the page had already painted when this overlay was created.
  hadPaintedAtMount = false;

  // Whether `@isOpen` was already true on the very first render. Captured once
  // rather than derived, because the whole question is about what the args
  // looked like at mount.
  isOpenAtMount = this.args.isOpen === true;

  // Latched when the first open tears down, so a *reopen* of the same overlay
  // animates normally. It is written from the content modifier's destructor,
  // which runs after the render transaction has closed, rather than during the
  // first open: flipping it while the overlay is still up would swap the enter
  // class names out from under the running modifier, which cleans up using
  // whatever names it holds when the transition ends.
  @tracked hasMountedOnce = false;

  contentElement: HTMLElement | undefined;
  focusedElement: Element | null | undefined;
  mouseDownContentElement: EventTarget | null = null;

  // Whether *this* overlay is holding a reference on the body scroll lock. We
  // record the decision made when opening instead of re-deriving it at
  // teardown, because the args can change while the overlay is open and an
  // asymmetric lock/unlock would leak the reference count.
  didLockBodyScroll = false;

  cancelPaintWait: (() => void) | undefined;

  constructor(owner: unknown, args: Args) {
    super(owner as never, args);

    // Captured once, before any waiting: whether the page had painted at the
    // moment this overlay was created is what decides if there is anything to
    // wait for.
    this.hadPaintedAtMount = hasPainted();

    if (!this.shouldDeferMount) {
      return;
    }

    this.cancelPaintWait = afterFirstPaint(() => {
      if (!this.isDestroying && !this.isDestroyed) {
        this.hasWaitedForPaint = true;
      }
    });
  }

  willDestroy(): void {
    super.willDestroy();
    this.cancelPaintWait?.();
  }

  handleClose(): void {
    if (this.args.isOpen && typeof this.args.onClose === 'function') {
      this.args.onClose();
    }
  }

  @action handleContentClick(event: MouseEvent): void {
    if (
      this.args.closeOnOutsideClick !== false &&
      this.args.closeOnOverlayElementClick !== false &&
      event.target === this.contentElement &&
      this.mouseDownContentElement == this.contentElement &&
      !isWithinNestedPortal(this.contentElement, event.target) &&
      !hasWormholeOrAlertParentElement(event.target as HTMLElement)
    ) {
      this.handleClose();
    }
    this.mouseDownContentElement = null;
  }

  @action handleOutsideClick(e: Event): void {
    if (
      this.args.closeOnOutsideClick !== false &&
      this.contentElement &&
      !isWithinNestedPortal(this.contentElement, e.target) &&
      !hasWormholeOrAlertParentElement(e.target as HTMLElement)
    ) {
      this.handleClose();
      e.preventDefault();
    }
  }

  @action
  handleContentMouseDown(event: MouseEvent): void {
    if (this.args.closeOnOverlayElementClick !== false) {
      this.mouseDownContentElement = event.target;
    }
  }

  @action
  handleKeyDown(event: KeyboardEvent): void {
    if (event.key === 'Escape' && this.args.closeOnEscapeKey !== false) {
      this.handleClose();
      event.preventDefault();
      event.stopImmediatePropagation();
    }
  }

  setupContent = modifier((el: HTMLDivElement) => {
    let transitionDuration = this.args.transitionDuration || 200;
    if (!this.isAnimationEnabled) {
      transitionDuration = 0;
    }
    later(() => {
      if (this.isDestroyed) return;
      if (this.args.disableFocusTrap !== true) return;
      if (this.args.preventAutoFocus === true) return;
      el.focus();
    }, transitionDuration);

    this.contentElement = el;
    this.keepOpen = true;
    this.focusedElement = document.activeElement;

    if (this.args.renderInPlace !== true && this.args.blockScroll !== false) {
      this.didLockBodyScroll = true;
      lockBodyScroll();
    }

    if (typeof this.args.onOpen === 'function') {
      this.args.onOpen();
    }
    return () => {
      this.contentElement = undefined;
      this.hasMountedOnce = true;

      if (this.didLockBodyScroll) {
        this.didLockBodyScroll = false;
        unlockBodyScroll();
      }

      const { didClose } = this.args;
      later(() => {
        if (!this.isDestroyed) this.keepOpen = false;
        if (typeof didClose === 'function' && !this.isDestroyed) {
          didClose();
        }

        // restore focus
        if (
          !this.args.preventFocusRestore &&
          this.focusedElement &&
          (this.focusedElement as HTMLElement).tabIndex > -1 &&
          typeof (this.focusedElement as HTMLElement).focus !== 'undefined'
        ) {
          (this.focusedElement as HTMLElement).focus();
        }
      }, transitionDuration);
    };
  });

  get mountAnimationState() {
    return {
      isOpenAtMount: this.isOpenAtMount && !this.hasMountedOnce,
      animationsEnabled: this.isAnimationEnabled,
      animateOnMount: this.args.animateOnMount,
      canWaitForFrame: typeof requestAnimationFrame === 'function',
      hasPainted: this.hadPaintedAtMount
    };
  }

  get shouldDeferMount(): boolean {
    return shouldDeferMount(this.mountAnimationState);
  }

  get skipEnterTransition(): boolean {
    return shouldSkipEnterTransition(this.mountAnimationState);
  }

  get isVisible(): boolean {
    if (this.shouldDeferMount && !this.hasWaitedForPaint) {
      return false;
    }

    return this.args.isOpen || this.keepOpen;
  }

  get backdrop(): BackdropSignature['Args']['type'] {
    if (!this.args.isOpen) {
      return 'none';
    }
    return this.args.backdrop || 'faded';
  }

  get isAnimationEnabled(): boolean {
    if (macroCondition(isTesting())) {
      return false;
    }
    return !(this.args.disableTransitions === true);
  }

  get focusTrapOptions(): FocusTrapOptions {
    return (
      this.args.focusTrapOptions || {
        clickOutsideDeactivates: true,
        allowOutsideClick: true
      }
    );
  }

  get classes() {
    const { overlay } = useStyles();

    return overlay({
      class: this.args.class,
      inPlace: this.args.renderInPlace,
      enableFlexContent: !(this.args.disableFlexContent === true)
    });
  }

  get customContentModifier() {
    if (this.args.customContentModifier) {
      return this.args.customContentModifier;
    }

    return modifier(() => {});
  }

  get backdropTransition() {
    const options = this.args.backdropTransition || {
      isEnabled: this.isAnimationEnabled
    };

    if (this.skipEnterTransition) {
      return withoutEnterTransition(options);
    }

    return options;
  }

  get transition() {
    let options: BackdropSignature['Args']['transition'] = {
      name: 'overlay-transition--fade',
      isEnabled: this.isAnimationEnabled
    };

    if (typeof this.args.transition === 'object') {
      options = { ...options, ...this.args.transition };
    }

    if (this.skipEnterTransition) {
      return withoutEnterTransition(options);
    }

    return options;
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    {{! template-lint-disable no-pointer-down-event-binding }}

    {{#if this.isVisible}}
      <Portal @renderInPlace={{@renderInPlace}} @target={{@target}}>
        <Backdrop
          @type={{this.backdrop}}
          @inPlace={{@renderInPlace}}
          @transition={{this.backdropTransition}}
        />

        {{#if @isOpen}}
          <div
            {{this.setupContent}}
            {{on "click" this.handleContentClick}}
            {{on "keydown" this.handleKeyDown}}
            {{on "mousedown" this.handleContentMouseDown}}
            {{cssTransition
              didTransitionIn=this.transition.didTransitionIn
              didTransitionOut=this.transition.didTransitionOut
              enterClass=this.transition.enterClass
              enterActiveClass=this.transition.enterActiveClass
              enterToClass=this.transition.enterToClass
              isEnabled=this.transition.isEnabled
              leaveClass=this.transition.leaveClass
              leaveActiveClass=this.transition.leaveActiveClass
              leaveToClass=this.transition.leaveToClass
              name=this.transition.name
              parentSelector=this.transition.parentSelector
            }}
            {{onClickOutside this.handleOutsideClick capture=true}}
            {{focusTrap
              isActive=(if @disableFocusTrap false @isOpen)
              focusTrapOptions=this.focusTrapOptions
            }}
            class={{this.classes}}
            {{! Keep this custom modifer by last}}
            {{this.customContentModifier}}
            data-component="overlay"
            tabindex="0"
            ...attributes
          >
            {{yield}}
          </div>
        {{/if}}
      </Portal>
    {{/if}}
  </template>
}

export { Overlay, type OverlaySignature };
export default Overlay;
