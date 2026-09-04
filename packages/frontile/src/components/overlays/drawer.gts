import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { guidFor } from '@ember/object/internals';
import { hash } from '@ember/helper';
import { modifier } from 'ember-modifier';
import { warnIfDialogHasNoAccessibleName } from '../../-private/dialog';
import Overlay, { type OverlaySignature } from './overlay';
import DrawerBody, { type DrawerBodySignature } from './drawer/body';
import DrawerFooter, { type DrawerFooterSignature } from './drawer/footer';
import DrawerHeader, { type DrawerHeaderSignature } from './drawer/header';
import {
  CloseButton,
  type CloseButtonSignature
} from '../buttons/close-button';
import type { ComponentLike, WithBoundArgs } from '@glint/template';
import {
  useStyles,
  type SlotsToClasses,
  type DrawerSlots,
  type DrawerVariants
} from '@frontile/theme';

export interface DrawerArgs extends Pick<
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

  /**
   * Class names for each slot of the component, merged with the theme's.
   */
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
          'labelledById' | 'classFromParent' | 'registerSelf'
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

  // `aria-labelledby` is only useful if it points at an element that actually
  // exists — a dangling reference leaves the dialog with no accessible name at
  // all. The yielded `Header` reports when it is rendered and when it goes
  // away, which keeps the reference correct even for a conditional header.
  // The count itself is deliberately untracked: registration happens while the
  // header's modifier is installing, and reading a tracked value there before
  // writing it trips Glimmer's backtracking assertion. Only the derived flag is
  // tracked, and it is always written, never read, from the callback.
  //
  // The `ref` utility looks like it should replace all of this, and it was
  // tried. It cannot: `Ref.setup` clears `current` unconditionally on teardown,
  // so it answers "what is the current element?" where this needs "does any
  // header exist?" — and those diverge when a header is *replaced* rather than
  // added or removed. Glimmer installs the modifiers of newly rendered elements
  // before tearing down the ones they replace (see the comments in
  // `utils/listManager.ts`), so with a `ref` a header swapped between the
  // branches of an `{{#if}}` leaves `current` undefined and the dialog silently
  // loses its accessible name. A `+1/-1` count is order-independent, which is
  // the whole point of it being a count.
  renderedHeaders = 0;
  @tracked hasHeader = false;

  registerHeader = (isRendered: boolean): void => {
    if (this.isDestroying || this.isDestroyed) {
      return;
    }

    this.renderedHeaders += isRendered ? 1 : -1;
    this.hasHeader = this.renderedHeaders > 0;
  };

  get labelledById(): string | undefined {
    return this.hasHeader ? this.headerId : undefined;
  }

  // What makes reading `hasHeader` here safe is *when* modifiers run, not in
  // what order: modifier install happens after the render transaction has
  // closed, so the template has already consumed `hasHeader` (through
  // `labelledById`) before any modifier hook fires. The header's write during
  // its own install therefore cannot invalidate a value still being rendered,
  // which is what would trip Glimmer's backtracking assertion.
  //
  // Whether the header's registration precedes this modifier is a separate,
  // unspecified Glimmer implementation detail. All it decides is whether this
  // first-render check already sees a registered header; if that order ever
  // inverted, the failure mode is a spurious development warning on a dialog
  // that does have a `Header` — not a broken render.
  //
  // Consumer-supplied names come through `...attributes`, which we cannot see
  // in args, hence inspecting the element itself.
  warnIfUnnamed = modifier((element: HTMLElement) => {
    warnIfDialogHasNoAccessibleName(element, this.hasHeader, 'drawer');
  });

  /**
   * `aria-modal="true"` promises assistive technology that the rest of the page
   * is unreachable while this dialog is open. That promise only holds while the
   * overlay's focus trap is active, so when the consumer turns the trap off we
   * omit the attribute rather than lie about it — screen readers then keep
   * exposing the page behind, which is what actually happens.
   */
  get ariaModal(): 'true' | undefined {
    return this.args.disableFocusTrap === true ? undefined : 'true';
  }

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
        aria-modal={{this.ariaModal}}
        aria-labelledby={{this.labelledById}}
        {{this.warnIfUnnamed}}
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
              registerSelf=this.registerHeader
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
