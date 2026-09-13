import Component from '@glimmer/component';
import { useStyles, type SpinnerVariants } from '@frontile/theme';
import { renamedArgValue } from '../../-private/deprecated-args';

interface SpinnerSignature {
  Args: {
    /**
     * Custom class name, it will override the default ones using Tailwind Merge
     * library. Use `fill-*` for the highlighted arc and `text-*` for the track.
     */
    class?: string;

    /**
     * The size of the spinner.
     *
     * @defaultValue 'md'
     */
    size?: SpinnerVariants['size'];

    /**
     * The color of the spinner.
     *
     * @defaultValue 'neutral'
     */
    color?: SpinnerVariants['color'];

    /**
     * @deprecated Use `color`. `default` is now `neutral`.
     */
    intent?:
      | 'default'
      | 'primary'
      | 'secondary'
      | 'tertiary'
      | 'success'
      | 'warning'
      | 'danger';
  };
  Element: SVGElement;
}

class Spinner extends Component<SpinnerSignature> {
  get classNames() {
    const { spinner } = useStyles();

    return spinner({
      class: this.args.class,
      size: this.args.size,
      color:
        renamedArgValue(
          this.args.color,
          this.args.intent,
          { default: 'neutral' } as const,
          {
            component: 'Spinner',
            from: 'intent',
            to: 'color',
            id: 'frontile.spinner.intent'
          }
        ) || 'neutral'
    });
  }

  <template>
    {{! A spinner is decorative: the loading state belongs on the region that
    is loading, not on the graphic. Hidden by default so it is not announced as
    an unnamed image; attributes are applied last, so a caller that really wants
    it announced can pass its own aria-hidden and label. }}
    <svg
      viewBox="0 0 16 16"
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      data-component="spinner"
      data-part="base"
      class={{this.classNames}}
      ...attributes
    >
      <path
        d="M8 1.5a6.5 6.5 0 100 13 6.5 6.5 0 000-13zM0 8a8 8 0 1116 0A8 8 0 010 8z"
        fill="currentColor"
        fill-rule="evenodd"
        clip-rule="evenodd"
      />

      <path
        d="M7.25.75A.75.75 0 018 0a8 8 0 018 8 .75.75 0 01-1.5 0A6.5 6.5 0 008 1.5a.75.75 0 01-.75-.75z"
        fill="currentFill"
        fill-rule="evenodd"
        clip-rule="evenodd"
      />
    </svg>
  </template>
}

export { Spinner, type SpinnerSignature };
export default Spinner;
