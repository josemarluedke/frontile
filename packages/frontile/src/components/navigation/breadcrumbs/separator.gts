import { ChevronRightIcon } from '../../../-private/icons';
import type { TOC } from '@ember/component/template-only';
import type { ComponentLike } from '@glint/template';

export interface BreadcrumbsSeparatorSignature {
  Args: {
    /** The `separator` slot's resolved classes, from the root. */
    class: string;

    /** The root's `@separator`, when the consumer supplied one. */
    separator?: ComponentLike<{ Element: SVGElement }>;
  };
  Element: HTMLSpanElement;
}

/**
 * The punctuation between two crumbs.
 *
 * Shared because both `Item` and `Ellipsis` render their own `<li>` and so both
 * need one. They are separate components by necessity -- an ellipsis is not a
 * crumb -- but the separator is the same mark in both, and the CSS that hides
 * it on the last `<li>` (`group-last/item:hidden`, on the `separator` slot)
 * only works if the two stay byte-identical. One definition is what guarantees
 * that; two copies would let them drift silently.
 *
 * `aria-hidden` unconditionally: the trail's structure is carried by the `<ol>`
 * and by `aria-current`, so a screen reader announcing a chevron between every
 * crumb would be reading decoration.
 */
const BreadcrumbsSeparator: TOC<BreadcrumbsSeparatorSignature> = <template>
  <span data-part="separator" aria-hidden="true" class={{@class}} ...attributes>
    {{#if @separator}}<@separator />{{else}}<ChevronRightIcon />{{/if}}
  </span>
</template>;

export { BreadcrumbsSeparator };
export default BreadcrumbsSeparator;
