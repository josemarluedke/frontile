import Component from '@glimmer/component';
import { guidFor } from '@ember/object/internals';
import { hash } from '@ember/helper';
import Overlay, { type OverlayArgs } from '../overlay';
import ModalFooter from './footer';
import ModalBody from './body';
import ModalHeader from './header';
import useFrontileClass from '@frontile/core/helpers/use-frontile-class';
import CloseButton from '@frontile/core/components/close-button';
import type { WithBoundArgs } from '@glint/template';

export interface ModalArgs extends Omit<OverlayArgs, 'contentTransitionName'> {
  /**
   * The name of the transition to be used in the modal.
   * @defaultValue 'overlay-transition--zoom'
   */
  transitionName?: string;

  /**
   * If set to false, the close button will not be displayed,
   * closeOnOutsideClick will be set to false, and closeOnEscapeKey will also be set
   * to false.
   *
   * @defaultValue true
   */
  allowClosing?: boolean;

  /**
   * If set to false, the close button will not be displayed.
   *
   * @defaultValue true
   */
  allowCloseButton?: boolean;

  /**
   * The Close Button size.
   */
  closeButtonSize?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';

  /**
   * If set to true, the modal will be vertically centered
   *
   * @defaultValue false
   */
  isCentered?: boolean;

  /**
   * The Modal size.
   *
   * @defaultValue 'lg'
   */
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl' | 'full';
}

export interface ModalSignature {
  Args: ModalArgs;
  Blocks: {
    default: [
      {
        CloseButton: WithBoundArgs<typeof CloseButton, 'onClick'> &
          WithBoundArgs<typeof CloseButton, 'class'>;
        Header: WithBoundArgs<typeof ModalHeader, 'labelledById'> &
          WithBoundArgs<typeof ModalHeader, 'size'>;
        Body: WithBoundArgs<typeof ModalBody, 'size'>;
        Footer: WithBoundArgs<typeof ModalFooter, 'size'>;
        headerId: string;
      }
    ];
  };
  Element: HTMLDivElement;
}

export default class Modal extends Component<ModalSignature> {
  headerId = `${guidFor(this)}-header`;

  get preventClosing(): boolean {
    return this.args.allowClosing === false;
  }

  get showCloseButton(): boolean {
    return (
      this.args.allowClosing !== false && this.args.allowCloseButton !== false
    );
  }

  get size() {
    return this.args.size || 'lg';
  }

  <template>
    <Overlay
      @isOpen={{@isOpen}}
      @onClose={{@onClose}}
      @onOpen={{@onOpen}}
      @didClose={{@didClose}}
      @renderInPlace={{@renderInPlace}}
      @destinationElementId={{@destinationElementId}}
      @transitionDuration={{@transitionDuration}}
      @disableBackdrop={{@disableBackdrop}}
      @disableTransitions={{@disableTransitions}}
      @disableFocusTrap={{@disableFocusTrap}}
      @focusTrapOptions={{@focusTrapOptions}}
      @closeOnOutsideClick={{if this.preventClosing false @closeOnOutsideClick}}
      @closeOnEscapeKey={{if this.preventClosing false @closeOnEscapeKey}}
      @backdropTransitionName={{@backdropTransitionName}}
      @contentTransitionName={{if
        @transitionName
        @transitionName
        "overlay-transition--zoom"
      }}
    >
      {{#let
        (useFrontileClass "modal" this.size part="close-btn")
        as |closeBtnClass|
      }}
        <div
          class={{useFrontileClass
            "modal"
            (if @isCentered "centered")
            this.size
          }}
          tabindex="0"
          role="dialog"
          aria-labelledby={{this.headerId}}
          ...attributes
        >
          {{#if this.showCloseButton}}
            <CloseButton
              @onClick={{@onClose}}
              @size={{@closeButtonSize}}
              class={{closeBtnClass}}
            />
          {{/if}}

          {{yield
            (hash
              CloseButton=(component
                CloseButton onClick=@onClose class=closeBtnClass
              )
              Header=(component
                ModalHeader labelledById=this.headerId size=this.size
              )
              Body=(component ModalBody size=this.size)
              Footer=(component ModalFooter size=this.size)
              headerId=this.headerId
            )
          }}
        </div>
      {{/let}}
    </Overlay>
  </template>
}
