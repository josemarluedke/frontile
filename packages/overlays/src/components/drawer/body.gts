import Component from '@glimmer/component';

export interface DrawerBodyArgs {
  class?: string;
}

export interface DrawerBodySignature {
  Args: DrawerBodyArgs;
  Element: HTMLDivElement;
  Blocks: {
    default: [];
  };
}

export default class DrawerBody extends Component<DrawerBodySignature> {
  <template>
    <div class={{@class}} ...attributes>
      {{yield}}
    </div>
  </template>
}
