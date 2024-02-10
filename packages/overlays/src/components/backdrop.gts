import Component from '@glimmer/component';
import { cssTransition } from 'ember-css-transitions';
import type { CssTransitionSignature } from 'ember-css-transitions/modifiers/css-transition';
import { useStyles } from '@frontile/theme';

interface BackdropSignature {
  Args: {
    /**
     * @defaultValue 'faded'
     */
    type?: 'none' | 'transparent' | 'faded' | 'blur';
    class?: string;
    /**
     * @defaultValue false
     */
    inPlace?: boolean;

    transition?: CssTransitionSignature['Args']['Named'];
  };
  Element: HTMLDivElement;
  Blocks: {
    default: [];
  };
}

class Backdrop extends Component<BackdropSignature> {
  get classNames() {
    const { backdrop } = useStyles();
    return backdrop({
      class: this.args.class,
      type: this.args.type,
      inPlace: this.args.inPlace
    });
  }

  get transition() {
    let options: BackdropSignature['Args']['transition'] = {
      name: 'overlay-transition--fade'
    };

    if (typeof this.args.transition === 'object') {
      return { ...options, ...this.args.transition };
    }

    return options;
  }

  get isVisiable() {
    return this.args.type !== 'none';
  }

  <template>
    {{#if this.isVisiable}}
      <div
        {{cssTransition
          didTransitionIn=this.transition.didTransitionIn
          didTransitionOut=this.transition.didTransitionOut
          enterClass=this.transition.enterClass
          enterActiveClass=this.transition.enterActiveClass
          enterToClass=this.transition.enterToClass
          isEnabled=this.transition.isEnabled
          leaveClass=this.transition.leaveClass
          leaveActiveClass=this.transition.leaveActiveClass
          leaveToClass=this.transition.leaveToClass
          name=this.transition.name
          parentSelector=this.transition.parentSelector
        }}
        class={{this.classNames}}
        ...attributes
      >
      </div>
    {{/if}}
  </template>
}

export { Backdrop, type BackdropSignature };
export default Backdrop;
