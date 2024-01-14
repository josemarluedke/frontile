import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import Button from './button';
import type { ButtonArgs } from './button';
import ToggleButton from './toggle-button';
import type { WithBoundArgs } from '@glint/template';

export interface ButtonGroupArgs
  extends Pick<ButtonArgs, 'appearance' | 'intent' | 'size' | 'class'> {}

export interface ButtonGroupSignature {
  Args: ButtonGroupArgs;
  Blocks: {
    default: [
      {
        Button: WithBoundArgs<typeof Button, 'isInGroup'>;
        ToggleButton: WithBoundArgs<typeof ToggleButton, 'isInGroup'>;
      }
    ];
  };
  Element: HTMLButtonElement;
}

export default class ButtonGroup extends Component<ButtonGroupSignature> {
  get classNames(): string {
    const { buttonGroup } = useStyles();

    return buttonGroup({
      class: this.args.class
    });
  }

  <template>
    <div class={{this.classNames}} role="group">
      {{yield (hash
          Button=(component Button isInGroup=true appearance=@appearance intent=@intent size=@size)
          ToggleButton=(component ToggleButton isInGroup=true intent=@intent size=@size)
        )
      }}
    </div>
  </template>
}
