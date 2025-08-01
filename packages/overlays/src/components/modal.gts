import Component from '@glimmer/component';
import { guidFor } from '@ember/object/internals';
import { hash } from '@ember/helper';
import Overlay, { type OverlaySignature } from './overlay';
import ModalFooter from './modal/footer';
import ModalBody from './modal/body';
import ModalHeader from './modal/header';
import { CloseButton } from '@frontile/buttons';
import {
  useStyles,
  type SlotsToClasses,
  type ModalSlots,
  type ModalVariants
} from '@frontile/theme';
import type { WithBoundArgs } from '@glint/template';

export interface ModalArgs
  extends Pick<
    OverlaySignature['Args'],
    | 'isOpen'
    | 'onOpen'
    | 'onClose'
    | 'didClose'
    | 'renderInPlace'
    | 'target'
    | 'transitionDuration'
    | 'backdrop'
    | 'disableTransitions'
    | 'disableFocusTrap'
    | 'focusTrapOptions'
    | 'closeOnOutsideClick'
    | 'closeOnEscapeKey'
    | 'backdropTransition'
  > {
  /**
   * The transition to be used in the Modal.
   *
   * @defaultValue {name: 'overlay-transition--zoom'}
   */
  transition?: OverlaySignature['Args']['transition'];

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
  size?: ModalVariants['size'];

  classes?: SlotsToClasses<ModalSlots>;
}

export interface ModalSignature {
  Args: ModalArgs;
  Blocks: {
    default: [
      {
        CloseButton: WithBoundArgs<typeof CloseButton, 'onPress' | 'class'>;
        Header: WithBoundArgs<
          typeof ModalHeader,
          'labelledById' | 'classFromParent'
        >;
        Body: WithBoundArgs<typeof ModalBody, 'classFromParent'>;
        Footer: WithBoundArgs<typeof ModalFooter, 'classFromParent'>;
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

    return modal({
      size: this.size,
      isCentered: this.args.isCentered
    });
  }

  get transition() {
    let options: OverlaySignature['Args']['transition'] = {
      name: 'overlay-transition--zoom'
    };

    if (typeof this.args.transition === 'object') {
      return { ...options, ...this.args.transition };
    }

    return options;
  }

  <template>
    <Overlay
      @isOpen={{@isOpen}}
      @onClose={{@onClose}}
      @onOpen={{@onOpen}}
      @didClose={{@didClose}}
      @renderInPlace={{@renderInPlace}}
      @target={{@target}}
      @transitionDuration={{@transitionDuration}}
      @backdrop={{@backdrop}}
      @disableTransitions={{@disableTransitions}}
      @disableFocusTrap={{@disableFocusTrap}}
      @focusTrapOptions={{@focusTrapOptions}}
      @closeOnOutsideClick={{if this.preventClosing false @closeOnOutsideClick}}
      @closeOnEscapeKey={{if this.preventClosing false @closeOnEscapeKey}}
      @backdropTransition={{@backdropTransition}}
      @transition={{this.transition}}
      @closeOnOverlayElementClick={{true}}
    >
      <div
        class={{this.classes.base class=@classes.base}}
        tabindex="0"
        role="dialog"
        aria-labelledby={{this.headerId}}
        ...attributes
      >
        {{#if this.showCloseButton}}
          <CloseButton
            @onPress={{@onClose}}
            @size={{@closeButtonSize}}
            @class={{this.classes.closeButton class=@classes.closeButton}}
          />
        {{/if}}

        {{yield
          (hash
            CloseButton=(component
              CloseButton
              onPress=@onClose
              class=(this.classes.closeButton class=@classes.closeButton)
            )
            Header=(component
              ModalHeader
              labelledById=this.headerId
              classFromParent=(this.classes.header class=@classes.header)
            )
            Body=(component
              ModalBody classFromParent=(this.classes.body class=@classes.body)
            )
            Footer=(component
              ModalFooter
              classFromParent=(this.classes.footer class=@classes.footer)
            )
            headerId=this.headerId
          )
        }}
      </div>
    </Overlay>
  </template>
}
