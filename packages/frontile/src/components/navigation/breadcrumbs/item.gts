import Component from '@glimmer/component';
import { ChevronRightIcon } from '../../../-private/icons';
import type { ComponentLike, ModifierLike } from '@glint/template';

interface BreadcrumbsItemArgs {
  /** Renders a plain anchor. */
  href?: string;

  /**
   * Overrides the current-page state. Wins over every other rule.
   */
  isCurrent?: boolean;

  /**
   * Marks the crumb as disabled. An anchor cannot be natively disabled, so the
   * href is dropped as well -- `aria-disabled` alone still leaves it
   * clickable.
   *
   * @defaultValue false
   */
  isDisabled?: boolean;

  /** Class names appended to this crumb's theme classes. */
  class?: string;

  /**
   * Supplied by Breadcrumbs. Not part of the public API.
   *
   * @internal
   */
  itemClass: string;

  /** @internal */
  linkClass: string;

  /** @internal */
  separatorClass: string;

  /** @internal */
  separator?: ComponentLike<{ Element: SVGElement }>;

  /** @internal */
  setupItem: ModifierLike<{
    Element: HTMLElement;
    Args: { Positional: [boolean] };
  }>;
}

interface BreadcrumbsItemSignature {
  Args: BreadcrumbsItemArgs;
  Blocks: { default: [] };
  /**
   * Not `HTMLAnchorElement`: this component's crumb element varies -- an `<a>`
   * or a `<span>` for an unlinked current crumb -- so the signature has to name
   * the common supertype or `...attributes` is mistyped for the span case.
   */
  Element: HTMLElement;
}

/**
 * One crumb: its `<li>`, the crumb itself, and the separator that follows it.
 *
 * The separator is rendered here rather than by the root, and hidden on the
 * last crumb by CSS. That is what lets both authoring forms work without
 * either one knowing an item's position.
 */
class BreadcrumbsItem extends Component<BreadcrumbsItemSignature> {
  get isDisabled(): boolean {
    return this.args.isDisabled ?? false;
  }

  /** Whether this crumb points anywhere at all. */
  get hasTarget(): boolean {
    return Boolean(this.args.href);
  }

  /**
   * A crumb with no link target is the page you are on -- that is the rule
   * that lets `<b.Item>Title</b.Item>` be correct with no arguments.
   */
  get isCurrent(): boolean {
    if (this.args.isCurrent !== undefined) {
      return this.args.isCurrent;
    }

    return !this.hasTarget;
  }

  <template>
    <li data-part="item" class={{@itemClass}}>
      {{#if this.hasTarget}}
        {{! template-lint-disable no-unsupported-role-attributes }}
        <a
          data-part="link"
          href={{unless this.isDisabled @href}}
          class="{{@linkClass}} {{@class}}"
          aria-disabled="{{this.isDisabled}}"
          data-disabled="{{this.isDisabled}}"
          {{@setupItem this.isCurrent}}
          ...attributes
        >
          {{yield}}
        </a>
      {{else}}
        <span
          data-part="link"
          class="{{@linkClass}} {{@class}}"
          {{@setupItem this.isCurrent}}
          ...attributes
        >
          {{yield}}
        </span>
      {{/if}}

      <span data-part="separator" aria-hidden="true" class={{@separatorClass}}>
        {{#if @separator}}<@separator />{{else}}<ChevronRightIcon />{{/if}}
      </span>
    </li>
  </template>
}

export {
  BreadcrumbsItem,
  type BreadcrumbsItemSignature,
  type BreadcrumbsItemArgs
};
export default BreadcrumbsItem;
