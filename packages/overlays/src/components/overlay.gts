/* eslint-disable ember/no-runloop */
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { later } from '@ember/runloop';
import { on } from '@ember/modifier';
import { getDOM, getElementById } from '../-private/dom';
import { cssTransition } from 'ember-css-transitions';
import { useStyles } from '@frontile/theme';
import { modifier } from 'ember-modifier';
// @ts-ignore
import { focusTrap } from 'ember-focus-trap';
import onClickOutside from 'ember-click-outside/modifiers/on-click-outside';
import { Backdrop, type BackdropSignature } from './backdrop';
import type { TOC } from '@ember/component/template-only';
import type { ModifierLike } from '@glint/template';
import type { CssTransitionSignature } from 'ember-css-transitions/modifiers/css-transition';

const MaybeInElement: TOC<{
  Args: {
    destinationElement?: Element | null;
    renderInPlace?: boolean;
  };
  Blocks: {
    default: [];
  };
}> = <template>
  {{#if @renderInPlace}}
    {{yield}}
  {{else if @destinationElement}}
    {{#in-element @destinationElement insertBefore=null}}
      {{yield}}
    {{/in-element}}
  {{/if}}
</template>;

function hasNextSibblingOverlay(element: HTMLElement): boolean {
  // Get the next sibling of the element
  let nextSibling = element.nextElementSibling;

  // Search for elements with the selector `[data-component="overlay"]` until the end of the DOM
  while (nextSibling) {
    if (
      nextSibling.matches &&
      nextSibling.matches('[data-component="overlay"]')
    ) {
      return true;
    }
    nextSibling = nextSibling.nextElementSibling;
  }

  return false;
}

// finds if the el has a parent with the id `ember-basic-dropdown-wormhole`
function hasWormholeParentElement(el: HTMLElement) {
  let parent = el.parentElement;
  while (parent) {
    if (parent.id === 'ember-basic-dropdown-wormhole') {
      return true;
    }
    parent = parent.parentElement;
  }
  return false;
}

interface OverlaySignature {
  Args: {
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

    backdrop?: BackdropSignature['Args']['type'];

    backdropTransition?: BackdropSignature['Args']['transition'];

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
     * @defaultValue { clickOutsideDeactivates: true, allowOutsideClick: true }
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
     *
     * @defaultValue false
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

    disableFlexContent?: boolean;
    customContentModifier?: ModifierLike<{ Element: HTMLElement }>;
    class?: string;

    /**
     * @defaultValue true
     */
    blockScroll?: boolean;
  };
  Element: HTMLDivElement;
  Blocks: { default: [] };
}

class Overlay extends Component<OverlaySignature> {
  @tracked keepOpen = false;

  contentElement: HTMLElement | undefined;
  focusedElement: Element | null | undefined;
  mouseDownContentElement: EventTarget | null = null;

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

  handleClose(): void {
    if (this.args.isOpen && typeof this.args.onClose === 'function') {
      this.args.onClose();
    }
  }

  @action handleContentClick(event: MouseEvent): void {
    if (
      this.args.closeOnOutsideClick !== false &&
      this.args.closeOnOverlayElementClick === true &&
      event.target === this.contentElement &&
      this.mouseDownContentElement == this.contentElement
    ) {
      this.handleClose();
    }
    this.mouseDownContentElement = null;
  }

  @action handleOutsideClick(e: Event): void {
    if (
      this.args.closeOnOutsideClick !== false &&
      this.contentElement &&
      !hasNextSibblingOverlay(this.contentElement) &&
      !hasWormholeParentElement(e.target as HTMLElement)
    ) {
      this.handleClose();
      e.preventDefault();
    }
  }

  @action
  handleContentMouseDown(event: MouseEvent): void {
    if (this.args.closeOnOverlayElementClick === true) {
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
    if (this.args.disableTransitions === true) {
      transitionDuration = 0;
    }
    later(() => {
      if (this.isDestroyed) return;
      if (this.args.disableFocusTrap !== true) return;
      el.focus();
    }, transitionDuration);

    this.contentElement = el;
    this.keepOpen = true;
    this.focusedElement = document.activeElement;

    if (this.args.renderInPlace !== true && this.args.blockScroll !== false) {
      document.body.style.overflow = 'hidden';
    }

    if (typeof this.args.onOpen === 'function') {
      this.args.onOpen();
    }
    return () => {
      this.contentElement = undefined;

      if (this.args.renderInPlace !== true && this.args.blockScroll !== false) {
        document.body.style.overflow = '';
      }

      const { didClose } = this.args;
      later(() => {
        if (!this.isDestroyed) this.keepOpen = false;
        if (typeof didClose === 'function' && !this.isDestroyed) {
          didClose();
        }

        // restore focus
        if (
          this.focusedElement &&
          (this.focusedElement as HTMLElement).tabIndex > -1 &&
          typeof (this.focusedElement as HTMLElement).focus !== 'undefined'
        ) {
          (this.focusedElement as HTMLElement).focus();
        }
      }, transitionDuration);
    };
  });

  get isVisible(): boolean {
    return this.args.isOpen || this.keepOpen;
  }

  get backdrop(): BackdropSignature['Args']['type'] {
    if (!this.args.isOpen) {
      return 'none';
    }
    return this.args.backdrop || 'faded';
  }

  get isAnimationEnabled(): boolean {
    return !(this.args.disableTransitions === true);
  }

  get focusTrapOptions(): unknown {
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
    if (this.args.backdropTransition) {
      return this.args.backdropTransition;
    }

    return { isEnabled: this.isAnimationEnabled };
  }

  get transition() {
    let options: BackdropSignature['Args']['transition'] = {
      name: 'overlay-transition--fade',
      isEnabled: this.isAnimationEnabled
    };

    if (typeof this.args.transition === 'object') {
      return { ...options, ...this.args.transition };
    }

    return options;
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    {{! template-lint-disable no-pointer-down-event-binding }}

    {{#if this.isVisible}}
      <MaybeInElement
        @renderInPlace={{@renderInPlace}}
        @destinationElement={{this.destinationElement}}
      >
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
            {{onClickOutside
              this.handleOutsideClick
              exceptSelector='[data-component="overlay"]'
              capture=true
            }}
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
      </MaybeInElement>
    {{/if}}
  </template>
}

export { Overlay, type OverlaySignature };
export default Overlay;
