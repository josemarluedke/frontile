import Component from '@glimmer/component';
import { Overlay, type OverlaySignature } from './overlay';
import { tracked } from '@glimmer/tracking';
import { Velcro } from 'ember-velcro';
import { assert } from '@ember/debug';
import { guidFor } from '@ember/object/internals';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { modifier } from 'ember-modifier';
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

    flipOptions?: VelcroSignature['Args']['Named']['flipOptions'];
    middleware?: VelcroSignature['Args']['Named']['middleware'];
    shiftOptions?: VelcroSignature['Args']['Named']['shiftOptions'];

    /**
     * @defaultValue 5
     */
    offsetOptions?: VelcroSignature['Args']['Named']['offsetOptions'];

    /**
     * @defaultValue 'absolute'
     */
    strategy?: VelcroSignature['Args']['Named']['strategy'];

    onClose: () => void;
  };
  Element: HTMLUListElement;
  Blocks: {
    default: [
      {
        anchor: ModifierLike<{ Element: HTMLElement }>;
        toggle: () => void;
        trigger: ModifierLike<{ Element: HTMLElement }>;
        Content: WithBoundArgs<
          typeof Content,
          'loop' | 'isOpen' | 'id' | 'onClose' | 'blockScroll' | 'backdrop'
        >;
      }
    ];
  };
}

class Popover extends Component<PopoverSignature> {
  triggerEl?: HTMLElement;
  menuId = guidFor(this);
  @tracked isOpen = false;

  toggle = () => {
    this.isOpen = !this.isOpen;
  };

  close = () => {
    this.isOpen = false;
    if (typeof this.args.onClose === 'function') {
      this.args.onClose();
    }
  };

  trigger = modifier((el: HTMLElement) => {
    this.triggerEl = el as HTMLLIElement;

    el.addEventListener('click', this.toggle);
    el.setAttribute('aria-haspopup', 'true');
    el.setAttribute('aria-controls', this.menuId);
    el.setAttribute('aria-expanded', this.isOpen.toString());

    return () => {
      el.removeEventListener('click', this.toggle);
      this.triggerEl = undefined;
    };
  });

  updateAriaExtanded = modifier((_: HTMLElement) => {
    if (this.triggerEl) {
      this.triggerEl.setAttribute('aria-expanded', this.isOpen.toString());
    }
  });

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
          toggle=this.toggle
          trigger=this.trigger
          Content=(component
            Content
            id=this.menuId
            loop=velcro.loop
            isOpen=this.isOpen
            onClose=this.close
          )
        )
      }}
    </Velcro>
  </template>
}

interface ContentArgs
  extends Pick<
    OverlaySignature['Args'],
    | 'onOpen'
    | 'didClose'
    | 'renderInPlace'
    | 'destinationElementId'
    | 'transitionDuration'
    | 'backdrop'
    | 'disableTransitions'
    | 'disableFocusTrap'
    | 'focusTrapOptions'
    | 'closeOnOutsideClick'
    | 'closeOnEscapeKey'
    | 'backdropTransition'
    | 'blockScroll'
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
  onClose: () => void;

  id: string;

  class?: string;

  /**
   * The transition to be used in the Modal.
   *
   * @defaultValue {name: 'overlay-transition--scale'}
   */
  transition?: OverlaySignature['Args']['transition'];
}

export interface ContentSignature {
  Args: ContentArgs;
  Element: HTMLUListElement;
  Blocks: { default: [] };
}

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
    return popover({ class: this.args.class });
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
  <template>
    <Overlay
      @blockScroll={{this.blockScroll}}
      @transition={{this.transition}}
      @backdrop={{this.backdrop}}
      @customContentModifier={{this.loop}}
      @disableFlexContent={{true}}
      @isOpen={{@isOpen}}
      @onClose={{@onClose}}
      @onOpen={{@onOpen}}
      @didClose={{@didClose}}
      @renderInPlace={{@renderInPlace}}
      @destinationElementId={{@destinationElementId}}
      @transitionDuration={{@transitionDuration}}
      @disableTransitions={{@disableTransitions}}
      @disableFocusTrap={{@disableFocusTrap}}
      @focusTrapOptions={{@focusTrapOptions}}
      @closeOnOutsideClick={{@closeOnOutsideClick}}
      @closeOnEscapeKey={{@closeOnEscapeKey}}
      @backdropTransition={{@backdropTransition}}
    >
      <div class={{this.classNames}} tabindex="0">
        {{yield}}
      </div>
    </Overlay>
  </template>
}

export { Popover, type PopoverSignature };
export default Popover;
