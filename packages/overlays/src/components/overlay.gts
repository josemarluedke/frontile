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
import type { TOC } from '@ember/component/template-only';
import type { ModifierLike } from '@glint/template';

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
   * Whether to close when the escape key is pressed
   *
   * @defaultValue true
   */
  closeOnEscapeKey?: boolean;

  /**
   * The name of the transition to be used in the backdrop.
   *
   * @defaultValue 'overlay-transition--fade'
   */
  backdropTransitionName?: string;

  /**
   * The name of the transition to be used in the content.
   *
   * @defaultValue 'overlay-transition--fade'
   */
  contentTransitionName?: string;

  disableFlexContent?: boolean;
  customContentModifier?: ModifierLike<{ Element: HTMLElement }>;
  contentClass?: string;
}

export interface OverlaySignature {
  Args: OverlayArgs;
  Element: HTMLDivElement;
  Blocks: { default: [] };
}

export default class Overlay extends Component<OverlaySignature> {
  @tracked keepOpen = false;

  wrapperElement: HTMLElement | undefined;
  backdropElement: HTMLElement | undefined;
  contentElement: HTMLElement | undefined;
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
    return (
      this.args.focusTrapOptions || {
        allowOutsideClick: (e: MouseEvent) => {
          if (
            e.target == this.backdropElement ||
            e.target == this.wrapperElement
          ) {
            return true;
          }
          return false;
        }
      }
    );
  }

  @action handleOverlayClick(e: MouseEvent): void {
    if (
      this.args.closeOnOutsideClick !== false &&
      (e.target == this.backdropElement || e.target == this.wrapperElement)
    ) {
      this.handleClose();
      e.preventDefault();
    }
  }

  @action handleContentClick(event: MouseEvent): void {
    if (
      this.args.closeOnOutsideClick !== false &&
      event.target === this.contentElement &&
      this.mouseDownContentElement == this.contentElement
    ) {
      this.handleClose();
    }
    this.mouseDownContentElement = null;
  }

  @action handleClose(): void {
    if (this.args.isOpen && typeof this.args.onClose === 'function') {
      this.args.onClose();
    }
  }

  @action
  handleContentMouseDown(event: MouseEvent): void {
    this.mouseDownContentElement = event.target;
  }

  @action
  handleKeyDown(event: KeyboardEvent): void {
    if (event.key === 'Escape' && this.args.closeOnEscapeKey !== false) {
      this.handleClose();
    }
  }

  setupContent = modifier((el: HTMLDivElement) => {
    this.contentElement = el;
    this.keepOpen = true;

    if (this.args.renderInPlace !== true) {
      document.body.style.overflow = 'hidden';
    }

    if (typeof this.args.onOpen === 'function') {
      this.args.onOpen();
    }
    return () => {
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
        if (typeof didClose === 'function' && !this.isDestroyed) {
          didClose();
        }
      }, duration);
    };
  });

  setupBackdrop = modifier((el: HTMLDivElement) => {
    this.backdropElement = el;
    return () => {
      this.backdropElement = undefined;
    };
  });

  setupWrapper = modifier((el: HTMLDivElement) => {
    this.wrapperElement = el;
    return () => {
      this.wrapperElement = undefined;
    };
  });

  get classes() {
    const { overlay } = useStyles();

    const { base, backdrop, content } = overlay({
      inPlace: this.args.renderInPlace,
      enableFlexContent: !(this.args.disableFlexContent === true)
    });

    return {
      base: base(),
      backdrop: backdrop(),
      content: content({ class: this.args.contentClass })
    };
  }

  get customContentModifier() {
    if (this.args.customContentModifier) {
      return this.args.customContentModifier;
    }

    return modifier(() => {});
  }

  <template>
    {{#if this.isVisible}}
      <MaybeInElement
        @renderInPlace={{@renderInPlace}}
        @destinationElement={{this.destinationElement}}
      >
        <div
          {{this.setupWrapper}}
          class={{this.classes.base}}
          {{on "click" this.handleOverlayClick}}
          ...attributes
        >

          {{! template-lint-disable no-invalid-interactive }}
          {{#if this.isBackdropVisible}}
            <div
              {{this.setupBackdrop}}
              {{on "click" this.handleOverlayClick}}
              {{cssTransition
                (if
                  @backdropTransitionName
                  @backdropTransitionName
                  "overlay-transition--fade"
                )
                isEnabled=this.isAnimationEnabled
              }}
              class={{this.classes.backdrop}}
            ></div>
          {{/if}}

          {{!
            This is required to make css-transition work with 2
            sibling elements been removed at the same time.
          }}
          <span data-is-visible={{this.isVisible}}></span>

          {{#if @isOpen}}
            {{! template-lint-disable no-pointer-down-event-binding }}
            <div
              {{this.setupContent}}
              {{on "click" this.handleContentClick}}
              {{on "keydown" this.handleKeyDown}}
              {{on "mousedown" this.handleContentMouseDown}}
              {{cssTransition
                (if
                  @contentTransitionName
                  @contentTransitionName
                  "overlay-transition--fade"
                )
                isEnabled=this.isAnimationEnabled
              }}
              {{focusTrap
                isActive=(if @disableFocusTrap false @isOpen)
                focusTrapOptions=this.focusTrapOptions
              }}
              class={{this.classes.content}}
              {{! Keep this custom modifer by last}}
              {{this.customContentModifier}}
            >
              {{! template-lint-enable no-pointer-down-event-binding }}
              {{yield}}
            </div>
          {{/if}}
          {{! template-lint-enable no-invalid-interactive }}
        </div>
      </MaybeInElement>
    {{/if}}
  </template>
}
