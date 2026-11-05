import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { useStyles } from '@frontile/theme';

/** Class names `Sidebar` hands the brand. */
export interface SidebarBrandClasses {
  sidebarBrand: string;
  sidebarBrandLogo: string;
  sidebarBrandText: string;
  sidebarBrandTitle: string;
  sidebarBrandSubtitle: string;
}

interface SidebarBrandArgs {
  /**
   * The product or workspace name. It is shown next to the logo and, with
   * `@href`, names the link. In the icon rail it is visually hidden but
   * stays available to assistive technology.
   */
  title: string;

  /** A second, smaller line under the title, such as a workspace or plan. */
  subtitle?: string;

  /**
   * Makes the whole brand (logo and text) one link to this URL. Without it
   * the brand is not interactive.
   */
  href?: string;

  /**
   * Draws the logo on a tinted square. Set it to `false` to show your own
   * logo as is, in the same 2rem square.
   *
   * @defaultValue true
   */
  tile?: boolean;

  /** Class names appended to the brand's theme classes. */
  class?: string;

  /**
   * Supplied by `Sidebar`. Not part of the public API. Without it (a brand
   * rendered on its own) the standalone sidebar's classes are used.
   *
   * @internal
   */
  classes?: SidebarBrandClasses;
}

interface SidebarBrandSignature {
  Args: SidebarBrandArgs;
  Blocks: {
    /**
     * The logo, shown in a 2rem square before the title. It stays visible in
     * the icon rail.
     */
    logo: [];
  };
  Element: HTMLAnchorElement | HTMLDivElement;
}

/**
 * The product's logo and name, for the sidebar's `Header`. With `@href` the
 * whole block is one link. In the icon rail only the logo shows; the title
 * and subtitle are visually hidden but keep naming the link.
 */
class SidebarBrand extends Component<SidebarBrandSignature> {
  @cached
  get classes(): SidebarBrandClasses {
    return this.args.classes ?? standaloneBrandClasses();
  }

  get className(): string {
    return this.args.class
      ? `${this.classes.sidebarBrand} ${this.args.class}`
      : this.classes.sidebarBrand;
  }

  get tile(): boolean {
    return this.args.tile ?? true;
  }

  <template>
    {{#if @href}}
      <a
        data-part="sidebar-brand"
        href={{@href}}
        class={{this.className}}
        ...attributes
      >
        {{#if (has-block "logo")}}
          <span
            data-part="sidebar-brand-logo"
            data-tile="{{this.tile}}"
            class={{this.classes.sidebarBrandLogo}}
          >{{yield to="logo"}}</span>
        {{/if}}
        <span
          data-part="sidebar-brand-text"
          data-sidebar-label
          class={{this.classes.sidebarBrandText}}
        >
          <span
            data-part="sidebar-brand-title"
            class={{this.classes.sidebarBrandTitle}}
          >{{@title}}</span>
          {{#if @subtitle}}
            <span
              data-part="sidebar-brand-subtitle"
              class={{this.classes.sidebarBrandSubtitle}}
            >{{@subtitle}}</span>
          {{/if}}
        </span>
      </a>
    {{else}}
      <div data-part="sidebar-brand" class={{this.className}} ...attributes>
        {{#if (has-block "logo")}}
          <span
            data-part="sidebar-brand-logo"
            data-tile="{{this.tile}}"
            class={{this.classes.sidebarBrandLogo}}
          >{{yield to="logo"}}</span>
        {{/if}}
        <span
          data-part="sidebar-brand-text"
          data-sidebar-label
          class={{this.classes.sidebarBrandText}}
        >
          <span
            data-part="sidebar-brand-title"
            class={{this.classes.sidebarBrandTitle}}
          >{{@title}}</span>
          {{#if @subtitle}}
            <span
              data-part="sidebar-brand-subtitle"
              class={{this.classes.sidebarBrandSubtitle}}
            >{{@subtitle}}</span>
          {{/if}}
        </span>
      </div>
    {{/if}}
  </template>
}

/** The brand's classes outside a `Sidebar`: the standalone sidebar's. */
function standaloneBrandClasses(): SidebarBrandClasses {
  const styles = useStyles().appLayout({
    variant: 'attached',
    standalone: true
  });
  return {
    sidebarBrand: styles.sidebarBrand(),
    sidebarBrandLogo: styles.sidebarBrandLogo(),
    sidebarBrandText: styles.sidebarBrandText(),
    sidebarBrandTitle: styles.sidebarBrandTitle(),
    sidebarBrandSubtitle: styles.sidebarBrandSubtitle()
  };
}

export { SidebarBrand, type SidebarBrandSignature, type SidebarBrandArgs };
export default SidebarBrand;
