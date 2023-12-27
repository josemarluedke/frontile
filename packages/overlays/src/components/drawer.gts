import Component from '@glimmer/component';
import { guidFor } from '@ember/object/internals';
import { concat, hash } from '@ember/helper';
import Overlay, { type OverlayArgs } from './overlay';
import DrawerBody from './drawer/body';
import DrawerFooter from './drawer/footer';
import DrawerHeader from './drawer/header';
import useFrontileClass from '@frontile/core/helpers/use-frontile-class';
import CloseButton from '@frontile/core/components/close-button';
import type { WithBoundArgs } from '@glint/template';

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
          WithBoundArgs<typeof DrawerHeader, 'size'>;
        Body: WithBoundArgs<typeof DrawerBody, 'size'>;
        Footer: WithBoundArgs<typeof DrawerFooter, 'size'>;
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

  get size(): string {
    const dir = ['top', 'bottom'].includes(this.placement)
      ? 'vertical'
      : 'horizontal';

    return `${this.args.size || 'md'}-${dir}`;
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
      {{#let
        (useFrontileClass "drawer" this.placement this.size part="close-btn")
        as |closeBtnClass|
      }}
        <div
          class={{useFrontileClass "drawer" this.placement this.size}}
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
                DrawerHeader
                labelledById=this.headerId
                placement=this.placement
                size=this.size
              )
              Body=(component
                DrawerBody placement=this.placement size=this.size
              )
              Footer=(component
                DrawerFooter placement=this.placement size=this.size
              )
              headerId=this.headerId
            )
          }}
        </div>
      {{/let}}
    </Overlay>
  </template>
}
