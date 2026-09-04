import Component from '@glimmer/component';
import { modifier } from 'ember-modifier';
import { twMerge } from '@frontile/theme';

export interface ModalHeaderArgs {
  class?: string;
  /**
   * The id used to reference labelledById in Modal component
   */
  labelledById: string;

  /**
   * @internal
   */
  classFromParent?: string;

  /**
   * Called with `true` when this header is rendered and `false` when it is
   * removed, so the Modal knows whether it may point `aria-labelledby` at us.
   *
   * @internal
   */
  registerSelf?: (isRendered: boolean) => void;
}

export interface ModalHeaderSignature {
  Args: ModalHeaderArgs;
  Element: HTMLDivElement;
  Blocks: {
    default: [];
  };
}

export default class ModalHeader extends Component<ModalHeaderSignature> {
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
