import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { later } from '@ember/runloop';
import { getDOM, getElementById } from '../-private/dom';

export interface OverlayArgs {
  /**
   * Whether to render in place or in the specified/default destination
   *
   * @defaultValue false
   */
  renderInPlace?: boolean;

  /**
   * The destination where the overlay will be inserted, defaults to
   * `document.body`
   *
   * @defaultValue undefined
   */
  destinationElementId?: string;

  /**
   * Duration of the animation
   *
   * @defaultValue 200
   */
  transitionDuration?: number;

  /**
   * Whether to hide the backdrop or not
   *
   * @defaultValue false
   */
  disableBackdrop?: boolean;

  /**
   * Disable css transitions
   *
   * @defaultValue false
   */
  disableTransitions?: boolean;

  /**
   * Whether the focus trap is disabled or not
   *
   * @defaultValue false
   */
  disableFocusTrap?: boolean;

  /**
   * Focus trap options
   *
   * @defaultValue { allowOutsideClick: true }
   */
  focusTrapOptions?: unknown;

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
   * Whether to close when the area outside (the backdrop) is clicked
   *
   * @defaultValue true
   */
  closeOnOutsideClick?: boolean;

  /**
   * Whether to close when the escape key is pressed
   *
   * @defaultValue true
   */
  closeOnEscapeKey?: boolean;

  /**
   * The name of the transition to be used in the backdrop.
   *
   * @defaultValue `overlay-transition--fade`
   */
  backdropTransitionName?: string;

  /**
   * The name of the transition to be used in the content.
   *
   * @defaultValue 'overlay-transition--fade'
   */
  contentTransitionName?: string;
}

export default class Overlay extends Component<OverlayArgs> {
  @tracked keepOpen = false;
  contentElement: HTMLElement | undefined;

  get destinationElement(): HTMLElement | null {
    const doc = getDOM(this);

    if (!doc) {
      return null;
    }

    if (this.args.destinationElementId) {
      return getElementById(doc, this.args.destinationElementId);
    } else {
      return doc.body;
    }
  }

  get isVisible(): boolean {
    return this.args.isOpen || this.keepOpen;
  }

  get isBackdropVisible(): boolean {
    return Boolean(this.args.isOpen && this.args.disableBackdrop !== true);
  }

  get isAnimationEnabled(): boolean {
    return !(this.args.disableTransitions === true);
  }

  get focusTrapOptions(): unknown {
    return this.args.focusTrapOptions || { allowOutsideClick: true };
  }

  @action handleOverlayClick(): void {
    if (this.args.closeOnOutsideClick !== false) {
      this.handleClose();
    }
  }

  @action handleContentClick(event: MouseEvent): void {
    if (
      this.args.closeOnOutsideClick !== false &&
      event.target === this.contentElement
    ) {
      this.handleClose();
    }
  }

  @action handleClose(): void {
    if (typeof this.args.onClose === 'function') {
      this.args.onClose();
    }
  }

  @action
  handleKeyDown(event: KeyboardEvent): void {
    if (event.key === 'Escape' && this.args.closeOnEscapeKey !== false) {
      this.handleClose();
    }
  }

  @action setup(element: HTMLElement): void {
    this.contentElement = element;
    this.keepOpen = true;

    if (this.args.renderInPlace !== true) {
      document.body.style.overflow = 'hidden';
    }
  }

  @action teardown(): void {
    this.contentElement = undefined;

    if (this.args.renderInPlace !== true && document.body.classList) {
      document.body.style.overflow = '';
    }

    let duration = this.args.transitionDuration || 200;

    if (this.args.disableTransitions === true) {
      duration = 0;
    }

    const { didClose } = this.args;
    later(() => {
      if (!this.isDestroyed) this.keepOpen = false;
      if (typeof didClose === 'function') {
        didClose();
      }
    }, duration);
  }
}
