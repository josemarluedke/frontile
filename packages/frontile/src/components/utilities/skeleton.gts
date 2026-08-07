import type { TOC } from '@ember/component/template-only';
import { useStyles, type SkeletonVariants } from '@frontile/theme';

const Skeleton: TOC<{
  Args: {
    class?: string;
    /**
     * Animation style for the placeholder.
     *
     * @defaultValue 'shimmer'
     */
    animation?: SkeletonVariants['animation'];
  };
  Element: HTMLDivElement;
}> = <template>
  {{#let (useStyles) as |styles|}}
    <div
      class={{styles.skeleton class=@class animation=@animation}}
      aria-hidden="true"
      data-component="skeleton"
      ...attributes
    ></div>
  {{/let}}
</template>;

export { Skeleton };
export default Skeleton;
