import Component from '@glimmer/component';
import { Overlay, type OverlaySignature } from './overlay';
import { tracked } from '@glimmer/tracking';
import { Velcro } from 'ember-velcro';
import { assert } from '@ember/debug';
import { guidFor } from '@ember/object/internals';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { modifier } from 'ember-modifier';
import { debounce } from '@ember/runloop';
import type { ModifierLike } from '@glint/template';
import type { WithBoundArgs } from '@glint/template';
import type { Signature as VelcroSignature } from 'ember-velcro/modifiers/velcro';

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
          Args: { Positional: [eventType?: 'click' | 'hover'] };
        }>;
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
        >;
      }
    ];
  };
}

class Popover extends Component<PopoverSignature> {
  triggerEl?: HTMLElement;

  /**
   * The element `measureWidth` is watching, when a consumer opts into measuring
   * something other than the trigger. Its presence is what gives `measureWidth`
   * precedence over `trigger` as the source of `triggerWidth`.
   */
  widthEl?: HTMLElement;

  menuId = guidFor(this);
  @tracked _isOpen = false;
  @tracked isClosing = false;
  @tracked preventFocusRestore = false;
  @tracked triggerWidth?: number;

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
    if (typeof this.args.onOpenChange === 'function') {
      this.args.onOpenChange(true);
    } else {
      this._isOpen = true;
    }
  };

  close = () => {
    this.isClosing = true;
    if (typeof this.args.onOpenChange === 'function') {
      this.args.onOpenChange(false);
    } else {
      this._isOpen = false;
    }

    if (typeof this.args.didClose === 'function') {
      this.args.didClose();
    }

    debounce(this, this.didClose, 90);
  };

  trigger = modifier(
    (el: HTMLElement, [eventType]: [eventType?: 'click' | 'hover']) => {
      this.triggerEl = el as HTMLLIElement;
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

      const debounceDuration = 100;

      const open = () => {
        debounce(this, this.open, debounceDuration);
      };

      const close = () => {
        debounce(this, this.close, debounceDuration);
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

        // Open when a letter is pressed
        if (!this.isOpen && event.code === `Key${event.key.toUpperCase()}`) {
          this.open();
        }
      };

      if (eventType === 'hover') {
        this.preventFocusRestore = true;
        el.addEventListener('mouseenter', open);
        el.addEventListener('mouseleave', close);
      } else {
        el.addEventListener('keydown', onKeydown);
        el.addEventListener('click', this.toggle);
      }

      el.setAttribute('aria-haspopup', 'true');
      el.setAttribute('aria-controls', this.menuId);
      el.setAttribute('aria-expanded', this.isOpen.toString());

      return () => {
        if (eventType === 'hover') {
          el.removeEventListener('mouseenter', open);
          el.removeEventListener('mouseleave', close);
        } else {
          el.removeEventListener('click', this.toggle);
          el.removeEventListener('keydown', onKeydown);
        }
        if (observer) {
          observer.disconnect();
        }
        this.triggerEl = undefined;
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

  updateAriaExtanded = modifier((_: HTMLElement) => {
    if (this.triggerEl) {
      this.triggerEl.setAttribute('aria-expanded', this.isOpen.toString());
    }
  });

  didClose = () => {
    if (!this.isDestroyed || !this.isDestroying) {
      this.isClosing = false;
    }
  };

  <template>
    <Velcro
      @placement={{if @placement @placement "bottom-start"}}
      @strategy={{if @strategy @strategy "absolute"}}
      @offsetOptions={{if @offsetOptions @offsetOptions 5}}
      @flipOptions={{@flipOptions}}
      @middleware={{@middleware}}
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
          Content=(component
            Content
            id=this.menuId
            loop=velcro.loop
            isOpen=this.isOpen
            toggle=this.toggle
            internalDidClose=this.didClose
            preventFocusRestore=this.preventFocusRestore
            triggerWidth=this.triggerWidth
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
      ...attributes
      {{this.updateTriggerWidth @triggerWidth}}
    >
      {{yield}}
    </Overlay>
  </template>
}

export { Popover, type PopoverSignature, type ContentSignature };
export default Popover;
