import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import Button, { type ButtonSignature } from './button';
import type { ButtonArgs } from './button';
import ToggleButton, { type ToggleButtonSignature } from './toggle-button';
import type { ComponentLike, WithBoundArgs } from '@glint/template';
import { assertRemovedArg } from '../../-private/removed-args';
import type Owner from '@ember/owner';

interface ButtonGroupArgs extends Pick<
  ButtonArgs,
  'variant' | 'color' | 'size' | 'class'
> {}

interface ButtonGroupSignature {
  Args: ButtonGroupArgs;
  Blocks: {
    default: [
      {
        Button: WithBoundArgs<ComponentLike<ButtonSignature>, 'isInGroup'>;
        ToggleButton: WithBoundArgs<
          ComponentLike<ToggleButtonSignature>,
          'isInGroup'
        >;
      }
    ];
  };
  Element: HTMLDivElement;
}

class ButtonGroup extends Component<ButtonGroupSignature> {
  constructor(owner: Owner, args: ButtonGroupSignature['Args']) {
    super(owner, args);

    assertRemovedArg('ButtonGroup', args, 'appearance', 'variant');
    assertRemovedArg('ButtonGroup', args, 'intent', 'color');
  }

  get classNames(): string {
    const { buttonGroup } = useStyles();

    return buttonGroup({
      class: this.args.class
    });
  }

  <template>
    <div
      class={{this.classNames}}
      role="group"
      data-component="button-group"
      data-part="base"
      ...attributes
    >
      {{yield
        (hash
          Button=(component
            Button isInGroup=true variant=@variant color=@color size=@size
          )
          ToggleButton=(component
            ToggleButton isInGroup=true color=@color size=@size
          )
        )
      }}
    </div>
  </template>
}

export { ButtonGroup, type ButtonGroupSignature };
export default ButtonGroup;
