import { later, cancel } from '@ember/runloop';

/**
 * How long to wait before deciding that a focus loss with no identifiable
 * destination really left the control.
 *
 * Only the targetless case waits at all (see {@link ControlBlurTracker}): a
 * `focusout` that names where focus went is answered synchronously. Targetless
 * blurs are the ones a click on something unfocusable produces -- the page
 * background, a backdrop, the dropdown's own padding -- and the browser
 * dispatches the rest of that click (mouseup, click) in later tasks, which is
 * where an outside click gets around to closing the popover. Deciding before
 * that would read a control that still looks open and stay silent. A beat is
 * long enough for the click to finish and short enough that blur validation
 * still feels immediate.
 */
const FOCUS_SETTLE_MS = 150;

interface ControlBlurTrackerOptions {
  /**
   * The element the popover's `trigger` modifier is installed on. Its
   * `aria-controls` is how the portaled content is found, so this must be the
   * element that opens the dropdown, not merely something inside the control.
   */
  trigger: () => HTMLElement | null | undefined;

  /** The control's outermost element: trigger, chips, clear button and all. */
  container: () => HTMLElement | null | undefined;

  /** Whether the control's dropdown is currently open. */
  isOpen: () => boolean;

  /** Whether the owning component has been (or is being) destroyed. */
  isDestroyed: () => boolean;

  /** Called once each time focus genuinely leaves the control. */
  onBlur: () => void;
}

/**
 * Decides when a composite control -- a trigger plus a dropdown -- has really
 * lost focus, and reports it once.
 *
 * A trigger's own blur is not the answer. Clicking an option moves focus onto
 * that option, which is *inside* the control as far as the user is concerned
 * but is not a DOM descendant of the trigger: the popover content is portaled
 * to the end of the document. And in multiple selection mode the dropdown
 * stays open across several such clicks, so a trigger-blur-means-blur rule
 * fires mid-interaction -- which is what made blur validation paint "pick at
 * least three" under a field the user was still filling in.
 *
 * So the control is treated as two regions, the container and the popover
 * content, and focus leaving one for the other is not a blur:
 *
 * - **`focusout` naming its destination** (`relatedTarget`) is answered
 *   immediately, with no timer at all. This covers every deliberate exit --
 *   Tab, or a click on another focusable thing -- and every move *into* the
 *   dropdown, including the option click that starts a selection.
 * - **A targetless `focusout`** is deferred by {@link FOCUS_SETTLE_MS} and then
 *   judged on `document.activeElement`. Focus nowhere (`body`) while the
 *   dropdown is open is still part of the interaction -- a click on the
 *   dropdown's padding -- so it is not a blur; once the dropdown has closed,
 *   the same state means the user clicked away.
 *
 * The portaled content is located through the trigger's `aria-controls`, which
 * the popover's trigger modifier sets to the content's id. That needs no extra
 * plumbing through the popover and stays correct wherever the content is
 * rendered.
 *
 * Callers must call {@link cancel} from `willDestroy`: a pending timer would
 * otherwise resolve against a torn-down component and both write tracked state
 * and call a callback the consumer has stopped expecting.
 */
class ControlBlurTracker {
  #timer?: ReturnType<typeof later>;

  private readonly options: ControlBlurTrackerOptions;

  constructor(options: ControlBlurTrackerOptions) {
    this.options = options;
  }

  /**
   * Wire this to `focusout` on the trigger -- not `blur`, whose
   * `relatedTarget` browsers are not obliged to populate.
   */
  handleFocusOut = (event: FocusEvent): void => {
    this.cancel();

    const next = event.relatedTarget;

    if (next instanceof Element) {
      if (!this.#holdsFocus(next)) {
        this.#report();
      }
      return;
    }

    this.#timer = later(this, this.#settle, FOCUS_SETTLE_MS);
  };

  /** Cancels a pending decision. Call from the owner's `willDestroy`. */
  cancel = (): void => {
    if (this.#timer) {
      cancel(this.#timer);
      this.#timer = undefined;
    }
  };

  #settle = (): void => {
    this.#timer = undefined;

    if (this.options.isDestroyed()) {
      return;
    }

    const active = document.activeElement;

    if (!active || active === document.body) {
      // Focus is nowhere. While the dropdown is open that is the user clicking
      // an unfocusable part of it; once it has closed it is the user having
      // clicked away from the control entirely.
      if (!this.options.isOpen()) {
        this.#report();
      }
      return;
    }

    if (!this.#holdsFocus(active)) {
      this.#report();
    }
  };

  /** Whether `el` is part of the control: the field itself, or its dropdown. */
  #holdsFocus(el: Element): boolean {
    const container = this.options.container();
    if (container && container.contains(el)) {
      return true;
    }

    const content = this.#popoverContent();
    return !!content && content.contains(el);
  }

  #popoverContent(): HTMLElement | null {
    const id = this.options.trigger()?.getAttribute('aria-controls');
    return id ? document.getElementById(id) : null;
  }

  #report(): void {
    if (this.options.isDestroyed()) {
      return;
    }
    this.options.onBlur();
  }
}

export { ControlBlurTracker, type ControlBlurTrackerOptions };
