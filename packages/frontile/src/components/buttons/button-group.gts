import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import Button, { type ButtonSignature } from './button';
import type { ButtonArgs } from './button';
import ToggleButton, { type ToggleButtonSignature } from './toggle-button';
import type { ComponentLike, WithBoundArgs } from '@glint/template';

interface ButtonGroupArgs
  extends Pick<ButtonArgs, 'appearance' | 'intent' | 'size' | 'class'> {}

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
  get classNames(): string {
    const { buttonGroup } = useStyles();

    return buttonGroup({
      class: this.args.class
    });
  }

  <template>
    <div class={{this.classNames}} role="group" ...attributes>
      {{yield
        (hash
          Button=(component
            Button
            isInGroup=true
            appearance=@appearance
            intent=@intent
            size=@size
          )
          ToggleButton=(component
            ToggleButton isInGroup=true intent=@intent size=@size
          )
        )
      }}
    </div>
  </template>
}

export { ButtonGroup, type ButtonGroupSignature };
export default ButtonGroup;
