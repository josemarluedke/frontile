import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { modifier } from 'ember-modifier';
import { useStyles, type SlotsToClasses } from '@frontile/theme';
import BreadcrumbsItemComponent from './item';
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
        itemClass: string;
        linkClass: string;
        separatorClass: string;
        setupItem: Breadcrumbs['setupItem'];
      }
    ];
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
            itemClass=this.itemClass
            linkClass=this.linkClass
            separatorClass=this.separatorClass
            setupItem=this.setupItem
          )
        }}
      </ol>
    </nav>
  </template>
}

export { Breadcrumbs, type BreadcrumbsSignature, type BreadcrumbsArgs };
export default Breadcrumbs;
