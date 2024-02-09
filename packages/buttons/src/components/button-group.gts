import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import Button from './button';
import type { ButtonArgs } from './button';
import ToggleButton from './toggle-button';
import type { WithBoundArgs } from '@glint/template';

interface ButtonGroupArgs
  extends Pick<ButtonArgs, 'appearance' | 'intent' | 'size' | 'class'> {}

interface ButtonGroupSignature {
  Args: ButtonGroupArgs;
  Blocks: {
    default: [
      {
        Button: WithBoundArgs<typeof Button, 'isInGroup'>;
        ToggleButton: WithBoundArgs<typeof ToggleButton, 'isInGroup'>;
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
