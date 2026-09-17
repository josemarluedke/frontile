import { ChevronRightIcon } from '../../../-private/icons';
import type { TOC } from '@ember/component/template-only';
import type { ComponentLike } from '@glint/template';

export interface BreadcrumbsSeparatorSignature {
  Args: {
    /** The `separator` slot's resolved classes, from the root. */
    class: string;

    /** The consumer's `@separator`, replacing the default chevron. */
    separator?: ComponentLike<{ Element: SVGElement }>;
  };
  Element: HTMLSpanElement;
}

/**
 * The punctuation between two crumbs.
 *
 * Shared by `Item` and `Ellipsis`, which each render their own `<li>` and so
 * each need one. The CSS that hides it on the last `<li>` only works while the
 * two stay identical, which one definition guarantees and two copies don't.
 *
 * Always `aria-hidden`: the `<ol>` and `aria-current` carry the structure, so
 * announcing a chevron between every crumb would be reading decoration.
 */
const BreadcrumbsSeparator: TOC<BreadcrumbsSeparatorSignature> = <template>
  <span data-part="separator" aria-hidden="true" class={{@class}} ...attributes>
    {{#if @separator}}<@separator />{{else}}<ChevronRightIcon />{{/if}}
  </span>
</template>;

export { BreadcrumbsSeparator };
export default BreadcrumbsSeparator;
