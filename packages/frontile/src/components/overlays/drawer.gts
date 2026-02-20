import Component from '@glimmer/component';
import { guidFor } from '@ember/object/internals';
import { hash } from '@ember/helper';
import Overlay, { type OverlaySignature } from './overlay';
import DrawerBody, { type DrawerBodySignature } from './drawer/body';
import DrawerFooter, { type DrawerFooterSignature } from './drawer/footer';
import DrawerHeader, { type DrawerHeaderSignature } from './drawer/header';
import { CloseButton, type CloseButtonSignature } from '../buttons/close-button';
import type { ComponentLike, WithBoundArgs } from '@glint/template';
import {
  useStyles,
  type SlotsToClasses,
  type DrawerSlots,
  type DrawerVariants
} from '@frontile/theme';

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
  placement?: DrawerVariants['placement'];

  /**
   * The Drawer size.
   *
   * @defaultValue 'md'
   */
  size?: DrawerVariants['size'];

  classes?: SlotsToClasses<DrawerSlots>;
}

export interface DrawerSignature {
  Args: DrawerArgs;
  Blocks: {
    default: [
      {
        CloseButton: WithBoundArgs<
          ComponentLike<CloseButtonSignature>,
          'onPress' | 'class'
        >;
        Header: WithBoundArgs<
          ComponentLike<DrawerHeaderSignature>,
          'labelledById' | 'classFromParent'
        >;
        Body: WithBoundArgs<
          ComponentLike<DrawerBodySignature>,
          'classFromParent'
        >;
        Footer: WithBoundArgs<
          ComponentLike<DrawerFooterSignature>,
          'classFromParent'
        >;
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

    return drawer({
      placement: this.placement,
      size: this.args.size || 'md'
    });
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
              DrawerHeader
              labelledById=this.headerId
              classFromParent=(this.classes.header class=@classes.header)
            )
            Body=(component
              DrawerBody
              placement=this.placement
              classFromParent=(this.classes.body class=@classes.body)
            )
            Footer=(component
              DrawerFooter
              placement=this.placement
              classFromParent=(this.classes.footer class=@classes.footer)
            )
            headerId=this.headerId
          )
        }}
      </div>
    </Overlay>
  </template>
}
