import type { TOC } from '@ember/component/template-only';
import { useStyles, type SpinnerVariants } from '@frontile/theme';

const Spinner: TOC<{
  Args: {
    class?: string;
    /**
     * @defaultValue 'md'
     */
    size?: SpinnerVariants['size'];
    /**
     * @defaultValue 'default'
     */
    intent?: SpinnerVariants['intent'];
  };
  Element: SVGElement;
}> = <template>
  {{#let (useStyles) as |styles|}}
    <svg
      viewBox="0 0 16 16"
      xmlns="http://www.w3.org/2000/svg"
      class={{styles.spinner class=@class size=@size intent=@intent}}
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
  {{/let}}
</template>;

export { Spinner };
export default Spinner;
