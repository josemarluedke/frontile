import Component from '@glimmer/component';
import { guidFor } from '@ember/object/internals';
import { concat, hash } from '@ember/helper';
import Overlay, { type OverlayArgs } from './overlay';
import DrawerBody from './drawer/body';
import DrawerFooter from './drawer/footer';
import DrawerHeader from './drawer/header';
import CloseButton from '@frontile/utilities/components/close-button';
import type { WithBoundArgs } from '@glint/template';
import { useStyles } from '@frontile/theme';

export interface DrawerArgs extends Omit<OverlayArgs, 'contentTransitionName'> {
  /**
   * The name of the transition to be used in the Drawer.
   *
   * @defaultValue 'overlay-transition--slide-from-[placement]'
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
        (concat "overlay-transition--slide-from-" this.placement)
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
