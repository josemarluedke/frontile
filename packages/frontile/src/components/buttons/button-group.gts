import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import Button, { type ButtonSignature } from './button';
import type { ButtonArgs } from './button';
import ToggleButton, { type ToggleButtonSignature } from './toggle-button';
import type { ComponentLike, WithBoundArgs } from '@glint/template';
import { renamedArgValue } from '../../-private/deprecated-args';

interface ButtonGroupArgs extends Pick<
  ButtonArgs,
  'variant' | 'appearance' | 'intent' | 'size' | 'class'
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
  get variant() {
    return renamedArgValue(
      this.args.variant,
      this.args.appearance,
      {
        default: 'solid',
        outlined: 'outline',
        minimal: 'plain',
        soft: 'subtle',
        tonal: 'soft'
      } as const,
      {
        component: 'ButtonGroup',
        from: 'appearance',
        to: 'variant',
        id: 'frontile.button-group.appearance'
      }
    );
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
            Button isInGroup=true variant=this.variant intent=@intent size=@size
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
