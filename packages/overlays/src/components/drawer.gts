import Component from '@glimmer/component';
import { guidFor } from '@ember/object/internals';
import { hash } from '@ember/helper';
import Overlay, { type OverlaySignature } from './overlay';
import DrawerBody from './drawer/body';
import DrawerFooter from './drawer/footer';
import DrawerHeader from './drawer/header';
import { CloseButton } from '@frontile/buttons';
import type { WithBoundArgs } from '@glint/template';
import { useStyles } from '@frontile/theme';

export interface DrawerArgs
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
   * The transition to be used in the Drawer.
   *
   * @defaultValue {name: 'overlay-transition--slide-from-[placement]'}
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
   * The Drawer can appear from any side of the screen. The 'placement'
   * option allows to choose where it appears from.
   *
   * @defaultValue 'right'
   */
  placement?: 'top' | 'bottom' | 'left' | 'right';

  /**
   * The Drawer size.
   *
   * @defaultValue 'md'
   */
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl' | 'full';
}

export interface DrawerSignature {
  Args: DrawerArgs;
  Blocks: {
    default: [
      {
        CloseButton: WithBoundArgs<typeof CloseButton, 'onClick'> &
          WithBoundArgs<typeof CloseButton, 'class'>;
        Header: WithBoundArgs<typeof DrawerHeader, 'labelledById'> &
          WithBoundArgs<typeof DrawerHeader, 'class'>;
        Body: WithBoundArgs<typeof DrawerBody, 'class'>;
        Footer: WithBoundArgs<typeof DrawerFooter, 'class'>;
        headerId: string;
      }
    ];
  };
  Element: HTMLDivElement;
}

export default class Drawer extends Component<DrawerSignature> {
  headerId = `${guidFor(this)}-header`;

  get preventClosing(): boolean {
    return this.args.allowClosing === false;
  }

  get showCloseButton(): boolean {
    return (
      this.args.allowClosing !== false && this.args.allowCloseButton !== false
    );
  }

  get placement() {
    return this.args.placement || 'right';
  }

  get classes() {
    const { drawer } = useStyles();

    const { base, closeButton, header, body, footer } = drawer({
      placement: this.placement,
      size: this.args.size || 'md'
    });

    return {
      base: base(),
      closeButton: closeButton(),
      header: header(),
      body: body(),
      footer: footer()
    };
  }
  get transition() {
    let options: OverlaySignature['Args']['transition'] = {
      name: `overlay-transition--slide-from-${this.placement}`
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
              DrawerHeader labelledById=this.headerId class=this.classes.header
            )
            Body=(component
              DrawerBody placement=this.placement class=this.classes.body
            )
            Footer=(component
              DrawerFooter placement=this.placement class=this.classes.footer
            )
            headerId=this.headerId
          )
        }}
      </div>
    </Overlay>
  </template>
}
