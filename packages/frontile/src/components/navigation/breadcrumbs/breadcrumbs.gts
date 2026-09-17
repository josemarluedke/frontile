import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { modifier } from 'ember-modifier';
import { warn } from '@ember/debug';
import { useStyles, type SlotsToClasses } from '@frontile/theme';
import BreadcrumbsItemComponent from './item';
import BreadcrumbsEllipsisComponent from './ellipsis';
import {
  collapseBreadcrumbs,
  type BreadcrumbsItemData,
  type BreadcrumbsSlot
} from './collapse';
import type { BreadcrumbsSlots, BreadcrumbsVariants } from '@frontile/theme';
import type { ComponentLike, WithBoundArgs } from '@glint/template';

interface BreadcrumbsArgs {
  /**
   * Accessible name for the navigation landmark.
   *
   * @defaultValue 'Breadcrumb'
   */
  label?: string;

  /**
   * @defaultValue 'md'
   */
  size?: BreadcrumbsVariants['size'];

  /**
   * The colour of the hover and current-page ink.
   *
   * Three categories rather than the usual seven: the others are fill colours,
   * meant to carry `text-on-*` on top of them, and as ink on a light surface
   * they fall below the contrast a reader needs. See `breadcrumbs.ts` in the
   * theme for the measurements.
   *
   * @defaultValue 'neutral'
   */
  color?: BreadcrumbsVariants['color'];

  /**
   * @defaultValue 'hover'
   */
  underline?: BreadcrumbsVariants['underline'];

  /**
   * Replaces the separator glyph. A component argument rather than a named
   * block because the separator is rendered inside each `<li>`, which `Item`
   * owns -- a named block on this component cannot be handed down to a child.
   *
   * @defaultValue ChevronRightIcon
   */
  separator?: ComponentLike<{ Element: SVGElement }>;

  /** Class names for each slot of the component, merged with the theme's. */
  classes?: SlotsToClasses<BreadcrumbsSlots>;

  /**
   * Renders the trail from an array instead of from blocks. Passing it is what
   * makes `@maxItems` meaningful -- yielded blocks cannot be counted before
   * they render, so in the block form there is nothing for it to divide.
   */
  items?: BreadcrumbsItemData[];

  /**
   * Collapses the middle of the trail once there are more crumbs than this.
   * `@items` form only.
   */
  maxItems?: number;

  /** @defaultValue 1 */
  itemsBeforeCollapse?: number;

  /** @defaultValue 1 */
  itemsAfterCollapse?: number;
}

/** What the `item` block receives, once per rendered crumb. */
interface BreadcrumbsItemContext {
  item: BreadcrumbsItemData;
  index: number;
  isCurrent: boolean;
  itemClass: string;
  linkClass: string;
  separatorClass: string;
}

/** One rendered slot, prebuilt so the template needs no sub-expression calls. */
interface RenderedSlot {
  key: string;
  isEllipsis: boolean;
  item?: BreadcrumbsItemData;
  /**
   * `true`/`false` for a crumb the root could judge on its own; `undefined`
   * for a `@route` crumb it could not, so `Item`'s own precedence takes over
   * and asks the router -- exactly as in the block form.
   */
  resolvedIsCurrent?: boolean;
  hiddenCount?: number;
  hiddenItems: BreadcrumbsItemData[];
  /**
   * Always populated, even for an ellipsis slot -- Glimmer's `{{#if
   * slot.isEllipsis}}...{{else if (has-block "item")}}` does not narrow this
   * field's type the way a plain TS `if` would, so making it optional here
   * would make every `{{yield slot.context to="item"}}` a type error despite
   * being reached only for a non-ellipsis slot at runtime.
   */
  context: BreadcrumbsItemContext;
}

interface BreadcrumbsSignature {
  Args: BreadcrumbsArgs;
  Blocks: {
    default: [
      {
        Item: WithBoundArgs<
          typeof BreadcrumbsItemComponent,
          | 'itemClass'
          | 'linkClass'
          | 'separatorClass'
          | 'separator'
          | 'setupItem'
        >;
        Ellipsis: WithBoundArgs<
          typeof BreadcrumbsEllipsisComponent,
          'itemClass' | 'ellipsisClass' | 'separatorClass' | 'separator'
        >;
        itemClass: string;
        linkClass: string;
        separatorClass: string;
        setupItem: Breadcrumbs['setupItem'];
      }
    ];
    item: [BreadcrumbsItemContext];
    ellipsis: [{ hiddenCount?: number; hiddenItems: BreadcrumbsItemData[] }];
  };
  Element: HTMLElement;
}

/**
 * An ordered trail of links ending in the current page.
 *
 * Like `TabNav`, it deliberately does **not** use roving focus: these are
 * links, so every one of them stays individually reachable by Tab and the
 * arrow keys are left to the browser.
 */
class Breadcrumbs extends Component<BreadcrumbsSignature> {
  get label(): string {
    return this.args.label ?? 'Breadcrumb';
  }

  @cached
  get styles() {
    const { breadcrumbs } = useStyles();

    return breadcrumbs({
      size: this.args.size,
      color: this.args.color,
      underline: this.args.underline
    });
  }

  @cached
  get itemClass(): string {
    return this.styles.item({ class: this.args.classes?.item });
  }

  @cached
  get linkClass(): string {
    return this.styles.link({ class: this.args.classes?.link });
  }

  @cached
  get separatorClass(): string {
    return this.styles.separator({ class: this.args.classes?.separator });
  }

  @cached
  get ellipsisClass(): string {
    return this.styles.ellipsis({ class: this.args.classes?.ellipsis });
  }

  /**
   * Presence, not truthiness: Glimmer treats an empty array as falsy, so
   * `{{#if @items}}` would send `@items={{(array)}}` down the block-form
   * branch and silently render nothing rather than an empty trail.
   */
  get usesItemsForm(): boolean {
    return this.args.items !== undefined;
  }

  /**
   * The indices the root can see as current *without* consulting the router:
   * an explicit `isCurrent: true`, or a crumb with no link target at all
   * *and* no explicit `isCurrent` of its own. The no-target fallback must not
   * override an explicit `isCurrent: false` -- that would make the `@items`
   * form disagree with the block form, where `@isCurrent={{false}}` always
   * wins (see the "in both directions" test on `Breadcrumbs.Item`).
   * Router-derived currency stays with `Item`, so this deliberately does not
   * cover `route` crumbs.
   */
  @cached
  get staticallyCurrentIndices(): number[] {
    return (this.args.items ?? []).reduce<number[]>((found, item, index) => {
      if (
        item.isCurrent === true ||
        (item.isCurrent === undefined && !item.route && !item.href)
      ) {
        found.push(index);
      }

      return found;
    }, []);
  }

  /**
   * Last wins. Two unlinked crumbs would otherwise render two
   * `aria-current="page"` elements, which is invalid; the root can see the
   * whole array, so it fixes the trail rather than only complaining about it.
   * The warning is there so the author still learns about the ambiguity.
   */
  get currentIndex(): number | undefined {
    const indices = this.staticallyCurrentIndices;

    warn(
      `<Breadcrumbs>: @items has ${indices.length} crumbs that resolve to the current page. ` +
        `Only the last one will be marked aria-current="page".`,
      indices.length <= 1,
      { id: 'frontile.breadcrumbs.multiple-current' }
    );

    return indices.at(-1);
  }

  /**
   * A placeholder satisfying `RenderedSlot.context`'s required type for an
   * ellipsis slot, which never actually yields it -- see the field doc on
   * `RenderedSlot.context` for why the field can't be optional instead. Named
   * so its unreachability is obvious at the one place it's constructed,
   * rather than only in a comment several lines above.
   */
  @cached
  get unreachableEllipsisContext(): BreadcrumbsItemContext {
    return {
      item: {},
      index: -1,
      isCurrent: false,
      itemClass: this.itemClass,
      linkClass: this.linkClass,
      separatorClass: this.separatorClass
    };
  }

  @cached
  get slots(): RenderedSlot[] {
    const collapsed: BreadcrumbsSlot[] = collapseBreadcrumbs(
      this.args.items ?? [],
      {
        maxItems: this.args.maxItems,
        itemsBeforeCollapse: this.args.itemsBeforeCollapse,
        itemsAfterCollapse: this.args.itemsAfterCollapse
      }
    );
    const currentIndex = this.currentIndex;

    return collapsed.map((slot): RenderedSlot => {
      if (slot.type === 'ellipsis') {
        return {
          key: 'ellipsis',
          isEllipsis: true,
          hiddenCount: slot.hiddenItems.length,
          hiddenItems: slot.hiddenItems,
          context: this.unreachableEllipsisContext
        };
      }

      // Whether the root is entitled to decide this crumb's currency at all.
      // An explicit `isCurrent` (either value) and a crumb with no target both
      // qualify; a bare `route` crumb does not, and gets `undefined`.
      const isRootsToJudge =
        slot.item.isCurrent !== undefined ||
        !(slot.item.route || slot.item.href);

      const resolvedIsCurrent = isRootsToJudge
        ? slot.index === currentIndex
        : undefined;

      return {
        key: `item-${slot.index}`,
        isEllipsis: false,
        hiddenItems: [],
        item: slot.item,
        resolvedIsCurrent,
        context: {
          item: slot.item,
          index: slot.index,
          isCurrent: resolvedIsCurrent ?? false,
          itemClass: this.itemClass,
          linkClass: this.linkClass,
          separatorClass: this.separatorClass
        }
      };
    });
  }

  /**
   * Marks an element as the current page. Yielded so a consumer can bring
   * their own link component -- `ember-link`, a custom `<AppLink>`, a plain
   * `<a>` -- and still get the correct ARIA. `Breadcrumbs.Item` applies this
   * internally, so there is exactly one definition of what "current" writes to
   * the DOM.
   */
  setupItem = modifier((element: HTMLElement, [isCurrent]: [boolean]) => {
    element.setAttribute('data-current', String(Boolean(isCurrent)));

    if (isCurrent) {
      element.setAttribute('aria-current', 'page');
    } else {
      element.removeAttribute('aria-current');
    }
  });

  <template>
    <nav
      data-component="breadcrumbs"
      data-part="base"
      aria-label={{this.label}}
      class={{this.styles.base class=@classes.base}}
      ...attributes
    >
      <ol data-part="list" class={{this.styles.list class=@classes.list}}>
        {{#if this.usesItemsForm}}
          {{#each this.slots key="key" as |slot|}}
            {{#if slot.isEllipsis}}
              {{#if (has-block "ellipsis")}}
                <BreadcrumbsEllipsisComponent
                  @hiddenCount={{slot.hiddenCount}}
                  @hiddenItems={{slot.hiddenItems}}
                  @itemClass={{this.itemClass}}
                  @ellipsisClass={{this.ellipsisClass}}
                  @separatorClass={{this.separatorClass}}
                  @separator={{@separator}}
                >
                  {{yield
                    (hash
                      hiddenCount=slot.hiddenCount hiddenItems=slot.hiddenItems
                    )
                    to="ellipsis"
                  }}
                </BreadcrumbsEllipsisComponent>
              {{else}}
                <BreadcrumbsEllipsisComponent
                  @hiddenCount={{slot.hiddenCount}}
                  @hiddenItems={{slot.hiddenItems}}
                  @itemClass={{this.itemClass}}
                  @ellipsisClass={{this.ellipsisClass}}
                  @separatorClass={{this.separatorClass}}
                  @separator={{@separator}}
                />
              {{/if}}
            {{else if (has-block "item")}}
              {{yield slot.context to="item"}}
            {{else}}
              <BreadcrumbsItemComponent
                @route={{slot.item.route}}
                @model={{slot.item.model}}
                @models={{slot.item.models}}
                @query={{slot.item.query}}
                @href={{slot.item.href}}
                @isCurrent={{slot.resolvedIsCurrent}}
                @isDisabled={{slot.item.isDisabled}}
                @itemClass={{this.itemClass}}
                @linkClass={{this.linkClass}}
                @separatorClass={{this.separatorClass}}
                @separator={{@separator}}
                @setupItem={{this.setupItem}}
              >{{slot.item.label}}</BreadcrumbsItemComponent>
            {{/if}}
          {{/each}}
        {{else}}
          {{yield
            (hash
              Item=(component
                BreadcrumbsItemComponent
                itemClass=this.itemClass
                linkClass=this.linkClass
                separatorClass=this.separatorClass
                separator=@separator
                setupItem=this.setupItem
              )
              Ellipsis=(component
                BreadcrumbsEllipsisComponent
                itemClass=this.itemClass
                ellipsisClass=this.ellipsisClass
                separatorClass=this.separatorClass
                separator=@separator
              )
              itemClass=this.itemClass
              linkClass=this.linkClass
              separatorClass=this.separatorClass
              setupItem=this.setupItem
            )
          }}
        {{/if}}
      </ol>
    </nav>
  </template>
}

export {
  Breadcrumbs,
  type BreadcrumbsSignature,
  type BreadcrumbsArgs,
  type BreadcrumbsItemContext
};
export default Breadcrumbs;
