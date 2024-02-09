import Component from '@glimmer/component';

interface MyComponentSignature {
  Args: {
    MyArg?: string;
  };
  Blocks: {
    default: [string | null];
  };
  Element: HTMLDivElement;
}

class MyComponent extends Component<MyComponentSignature> {
  <template>
    <div ...attributes>
      My component
    </div>
  </template>
}

export { MyComponent, type MyComponentSignature };
export default MyComponent;
