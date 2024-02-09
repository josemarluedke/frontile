import Component from '@glimmer/component';

export interface MyComponentSignature {
  Args: {
    MyArg?: string;
  };
  Blocks: {
    default: [string | null];
  };
  Element: HTMLDivElement;
}

export default class MyComponent extends Component<MyComponentSignature> {
  <template>
    <div ...attributes>
      My component
    </div>
  </template>
}
