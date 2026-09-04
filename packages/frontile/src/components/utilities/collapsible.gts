import Component from '@glimmer/component';
import { buildWaiter } from '@ember/test-waiters';
import { on } from '@ember/modifier';
import { modifier } from 'ember-modifier';
import safeStyles from '../../utils/safe-styles';
import type Owner from '@ember/owner';

const waiter = buildWaiter('frontile:collapsible');

/**
 * Runs a caller-supplied height through the browser's own CSS parser.
 *
 * `@initialHeight` ends up in an inline `style` attribute, so a value such as
 * `10px; position: fixed` would otherwise smuggle in a second declaration.
 * Assigning it to a detached element's `style.height` lets the CSSOM decide:
 * it accepts every real height (`10px`, `2rem`, `50%`, `0`,
 * `calc(1rem + 2px)`, `var(--x)`, …) and drops anything it cannot parse as a
 * single height value — a trailing declaration included. Returns the parsed
 * value, or `undefined` when the input is unusable.
 */
function parseHeight(value: string | undefined): string | undefined {
  if (!value) {
    return undefined;
  }

  // Reject anything that could terminate the declaration up front. The CSSOM
  // check below catches this too, but the explicit test keeps the guarantee
  // even where `document` has no real CSS parser (SSR / prerender).
  if (/[;}]/.test(value)) {
    return undefined;
  }

  if (typeof document === 'undefined') {
    return value;
  }

  const probe = document.createElement('div');
  probe.style.height = value;

  return probe.style.height || undefined;
}

interface CollapsibleArgs {
  /**
   * If true, the content will be visible
   */
  isOpen: boolean;

  /**
   * The height for the content in it's collapsed state.
   * The unit of the value should be included, eg. '10px'. Any CSS height is
   * accepted (`2rem`, `50%`, `calc(1rem + 2px)`, …); a value the CSS parser
   * rejects is ignored and the content collapses to `0`.
   *
   * @defaultValue 0
   */
  initialHeight?: string;
}

interface CollapsibleSignature {
  Args: CollapsibleArgs;
  Element: HTMLDivElement;
  Blocks: {
    default: [];
  };
}

class Collapsible extends Component<CollapsibleSignature> {
  isInitiallyOpen = false;
  waiterToken?: unknown;
  isCurrentlyOpen = false; // Internal value to track if open or not

  constructor(owner: Owner, args: CollapsibleArgs) {
    super(owner, args);

    if (this.args.isOpen) {
      this.isInitiallyOpen = true;
      this.isCurrentlyOpen = true;
    }
  }

  /**
   * `@initialHeight`, validated by the CSS parser. `undefined` when it was not
   * given or could not be parsed as a height, in which case the collapsed
   * state falls back to `0`.
   */
  get initialHeight(): string | undefined {
    return parseHeight(this.args.initialHeight);
  }

  get styles(): ReturnType<typeof safeStyles> {
    let styles: Record<string, string | number> = {};
    const initialHeight = this.initialHeight;

    if (!this.isInitiallyOpen) {
      styles = {
        ...styles,
        height: initialHeight || 0,
        opacity: initialHeight ? '1' : '0'
      };
    }

    if (initialHeight || !this.isInitiallyOpen) {
      styles = {
        ...styles,
        overflow: 'hidden'
      };
    }

    return safeStyles(styles);
  }

  hasSetupUpdate = false;
  update = modifier((element: HTMLElement, [isOpen]: boolean[]) => {
    // do not run update on the initial setup of modifier
    if (!this.hasSetupUpdate) {
      this.hasSetupUpdate = true;
      return;
    }

    if (this.isCurrentlyOpen !== !!isOpen) {
      // A previous transition may still be in flight; end its token first so
      // toggling faster than the animation cannot leak a test waiter.
      this.endWaiter();
      this.waiterToken = waiter.beginAsync();
    }

    if (isOpen) {
      this.expand(element);
    } else {
      this.contract(element);
    }
  });

  endWaiter(): void {
    if (this.waiterToken) {
      const token = this.waiterToken;
      // Clear before ending so the same token can never be ended twice.
      this.waiterToken = undefined;
      waiter.endAsync(token);
    }
  }

  willDestroy(): void {
    super.willDestroy();
    // Do not leave a waiter pending if we are torn down mid-transition.
    this.endWaiter();
  }

  onTransitionEnd = (event: TransitionEvent) => {
    // `transitionend` bubbles, so ignore transitions of our own descendants.
    // Otherwise any child that animates height/opacity would get our inline
    // styles stamped onto it.
    if (event.target !== event.currentTarget) {
      return;
    }

    const element = event.currentTarget as HTMLElement;

    if (
      (event.propertyName === 'height' || event.propertyName == 'opacity') &&
      this.args.isOpen
    ) {
      element.style.height = 'auto';
      element.style.overflow = '';
    }
    if (this.waiterToken) {
      // when is opened, wait for height transition to finish
      // when is opened, wait for opacity transition to finish at 1
      // when closed, wait for opacity transition to finish at 0
      // when closed and has initialHeight, wait for height transition to finish
      if (
        (this.args.isOpen && event.propertyName === 'height') ||
        (!this.args.isOpen &&
          event.propertyName === 'opacity' &&
          element.style.opacity == '0') ||
        (this.args.isOpen &&
          event.propertyName === 'opacity' &&
          element.style.opacity == '1') ||
        (!this.args.isOpen &&
          this.initialHeight &&
          event.propertyName === 'height')
      ) {
        this.endWaiter();
      }
    }
  };

  heightTransition(duration: number): string {
    return `height ${duration}s cubic-bezier(0.4, 0, 0.2, 1) 0ms`;
  }

  opacityTransition(duration: number): string {
    return `opacity ${duration}s ease-in-out 0ms`;
  }

  expand(element: HTMLElement): void {
    this.isCurrentlyOpen = true;
    element.style.transition = [
      this.heightTransition(0.4),
      this.opacityTransition(0.3)
    ].join(', ');
    element.style.overflow = 'hidden';

    const height = element.scrollHeight;
    window.requestAnimationFrame(() => {
      element.style.opacity = '1';
      element.style.height = `${height}px`;
    });
  }

  contract(element: HTMLElement): void {
    this.isCurrentlyOpen = false;
    const height = element.scrollHeight;
    element.style.transition = '';
    element.style.overflow = 'hidden';

    window.requestAnimationFrame(() => {
      element.style.height = `${height}px`;
      element.style.transition = [
        this.heightTransition(0.2),
        this.opacityTransition(0.3)
      ].join(', ');

      window.requestAnimationFrame(() => {
        const initialHeight = this.initialHeight;

        if (!initialHeight) {
          element.style.opacity = '0';
        }
        element.style.height = initialHeight || '0';
      });
    });
  }

  <template>
    <div
      style={{this.styles}}
      ...attributes
      {{this.update @isOpen}}
      {{on "transitionend" this.onTransitionEnd}}
    >
      {{yield}}
    </div>
  </template>
}

export { Collapsible, type CollapsibleSignature };
export default Collapsible;
