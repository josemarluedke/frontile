import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { VisuallyHidden } from '../../utilities/visually-hidden';
import { ChevronRightIcon } from '../../../-private/icons';
import type { BreadcrumbsItemData } from './collapse';
import type { ComponentLike } from '@glint/template';

interface BreadcrumbsEllipsisArgs {
  /**
   * Drives the visually-hidden announcement. The `@items` form passes it; in
   * the block form an author may supply it, and without it the announcement
   * falls back to an uncounted one rather than making the author count their
   * own crumbs.
   */
  hiddenCount?: number;

  /** The crumbs this marker stands in for. Yielded straight back to the block. */
  hiddenItems?: BreadcrumbsItemData[];

  /** Class names appended to this marker's theme classes. */
  class?: string;

  /** @internal */
  itemClass: string;

  /** @internal */
  ellipsisClass: string;

  /** @internal */
  separatorClass: string;

  /** @internal */
  separator?: ComponentLike<{ Element: SVGElement }>;
}

interface BreadcrumbsEllipsisSignature {
  Args: BreadcrumbsEllipsisArgs;
  Blocks: {
    /** Replaces the glyph. This is where a `Dropdown` goes. */
    default: [{ hiddenCount?: number; hiddenItems: BreadcrumbsItemData[] }];
  };
  Element: HTMLElement;
}

/**
 * The gap marker standing in for a run of crumbs.
 *
 * It renders its own `<li>` including a separator, structurally identical to
 * what `Item` renders -- a bare `<span>` would fall outside the
 * `group-last/item:hidden` scheme that hides the trailing separator, and the
 * trail would end in a dangling chevron whenever an ellipsis came last.
 */
class BreadcrumbsEllipsis extends Component<BreadcrumbsEllipsisSignature> {
  get hiddenItems(): BreadcrumbsItemData[] {
    return this.args.hiddenItems ?? [];
  }

  /**
   * `undefined` rather than a number when the count is unknown, so the template
   * can pick between the two announcements without an `eq` helper.
   */
  get hiddenCount(): number | undefined {
    return this.args.hiddenCount;
  }

  <template>
    <li data-part="item" class={{@itemClass}}>
      {{#if (has-block)}}
        {{! A supplied block carries its own accessible name -- a Dropdown
            trigger, typically -- so the built-in announcement is suppressed
            rather than read alongside it. }}
        <span
          data-part="ellipsis"
          class="{{@ellipsisClass}} {{@class}}"
          ...attributes
        >
          {{yield
            (hash hiddenCount=this.hiddenCount hiddenItems=this.hiddenItems)
          }}
        </span>
      {{else}}
        <span
          data-part="ellipsis"
          aria-hidden="true"
          class="{{@ellipsisClass}} {{@class}}"
          ...attributes
        >&hellip;</span>
        {{#if this.hiddenCount}}
          <VisuallyHidden>{{this.hiddenCount}} more levels</VisuallyHidden>
        {{else}}
          <VisuallyHidden>More levels</VisuallyHidden>
        {{/if}}
      {{/if}}

      <span data-part="separator" aria-hidden="true" class={{@separatorClass}}>
        {{#if @separator}}<@separator />{{else}}<ChevronRightIcon />{{/if}}
      </span>
    </li>
  </template>
}

export {
  BreadcrumbsEllipsis,
  type BreadcrumbsEllipsisSignature,
  type BreadcrumbsEllipsisArgs
};
export default BreadcrumbsEllipsis;
