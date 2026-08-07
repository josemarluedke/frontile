import type { TOC } from '@ember/component/template-only';
import { useStyles, type SkeletonVariants } from '@frontile/theme';

const Skeleton: TOC<{
  Args: {
    class?: string;
    /**
     * Shape preset. `text` fills its container at text height; `circle` and
     * `square` are equal-sided and match Avatar's radii; `rounded` and `rect`
     * fill their container for image and card placeholders.
     *
     * @defaultValue 'text'
     */
    shape?: SkeletonVariants['shape'];
    /**
     * Size preset. For `circle` and `square` this sets both dimensions from
     * Avatar's scale; for the other shapes it sets the height.
     *
     * @defaultValue 'md'
     */
    size?: SkeletonVariants['size'];
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
      class={{styles.skeleton
        class=@class
        shape=@shape
        size=@size
        animation=@animation
      }}
      aria-hidden="true"
      data-component="skeleton"
      ...attributes
    ></div>
  {{/let}}
</template>;

export { Skeleton };
export default Skeleton;
