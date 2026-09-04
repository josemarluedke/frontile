import Component from '@glimmer/component';
import { modifier } from 'ember-modifier';
import { twMerge } from '@frontile/theme';

export interface DrawerHeaderArgs {
  /**
   * The id used to reference labelledById in Drawer component
   */
  labelledById: string;

  class?: string;

  /**
   * @internal
   */
  classFromParent?: string;

  /**
   * Called with `true` when this header is rendered and `false` when it is
   * removed, so the Drawer knows whether it may point `aria-labelledby` at us.
   *
   * @internal
   */
  registerSelf?: (isRendered: boolean) => void;
}

export interface DrawerHeaderSignature {
  Args: DrawerHeaderArgs;
  Element: HTMLDivElement;
  Blocks: {
    default: [];
  };
}
export default class DrawerHeader extends Component<DrawerHeaderSignature> {
  register = modifier(() => {
    this.args.registerSelf?.(true);

    return () => {
      this.args.registerSelf?.(false);
    };
  });

  <template>
    <div
      id={{@labelledById}}
      class={{twMerge @classFromParent @class}}
      {{this.register}}
      ...attributes
    >
      {{yield}}
    </div>
  </template>
}
