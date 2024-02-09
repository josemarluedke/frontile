import Component from '@glimmer/component';
import { guidFor } from '@ember/object/internals';
import { hash } from '@ember/helper';
import Overlay, { type OverlayArgs } from './overlay';
import ModalFooter from './modal/footer';
import ModalBody from './modal/body';
import ModalHeader from './modal/header';
import CloseButton from '@frontile/utilities/components/close-button';
import { useStyles } from '@frontile/theme';
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
          WithBoundArgs<typeof ModalHeader, 'class'>;
        Body: WithBoundArgs<typeof ModalBody, 'class'>;
        Footer: WithBoundArgs<typeof ModalFooter, 'class'>;
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

  get classes() {
    const { modal } = useStyles();

    const { base, closeButton, header, body, footer } = modal({
      size: this.size,
      isCentered: this.args.isCentered
    });

    return {
      base: base(),
      closeButton: closeButton(),
      header: header(),
      body: body(),
      footer: footer()
    };
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
      <div
        class={{this.classes.base}}
        tabindex="0"
        role="dialog"
        aria-labelledby={{this.headerId}}
        ...attributes
      >
        {{#if this.showCloseButton}}
          <CloseButton
            @onClick={{@onClose}}
            @size={{@closeButtonSize}}
            @class={{this.classes.closeButton}}
          />
        {{/if}}

        {{yield
          (hash
            CloseButton=(component
              CloseButton onClick=@onClose class=this.classes.closeButton
            )
            Header=(component
              ModalHeader labelledById=this.headerId class=this.classes.header
            )
            Body=(component ModalBody class=this.classes.body)
            Footer=(component ModalFooter class=this.classes.footer)
            headerId=this.headerId
          )
        }}
      </div>
    </Overlay>
  </template>
}
