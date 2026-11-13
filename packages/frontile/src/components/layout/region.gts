import Component from '@glimmer/component';
import { service } from '@ember/service';
import { modifier } from 'ember-modifier';
import type AppLayoutService from '../../services/app-layout';
import { standaloneStyles, type AppLayoutContext } from './context';

interface RegionArgs {
  /** The region's name, matched by `LayoutRegion @name`. */
  name: string;

  /**
   * Render every source, in render order, instead of only the newest.
   *
   * @defaultValue false
   */
  multiple?: boolean;

  /**
   * Supplied by `AppLayout`. Not part of the public API.
   *
   * @internal
   */
  layout?: AppLayoutContext;
}

interface RegionSignature {
  Args: RegionArgs;
  Blocks: {
    /** Rendered while no source fills the region. */
    default: [];
  };
  Element: HTMLDivElement;
}

/**
 * PROTOTYPE. A named target in the layout that route templates fill with
 * `LayoutRegion`. The element is `display: contents` (the theme's `region` slot), so the filled-in
 * content takes part in its parent's layout as if it were rendered there.
 */
class Region extends Component<RegionSignature> {
  @service('app-layout') declare appLayout: AppLayoutService;

  register = modifier(
    (element: HTMLElement, [name, multiple]: [string, boolean | undefined]) =>
      this.appLayout.registerTarget(name, element, { multiple })
  );

  get classNames(): string {
    const styles = this.args.layout?.styles ?? standaloneStyles();
    return styles.region({ class: this.args.layout?.classes?.region });
  }

  get hasContent(): boolean {
    return this.appLayout.hasContent(this.args.name);
  }

  get hasContentString(): 'true' | 'false' {
    return this.hasContent ? 'true' : 'false';
  }

  <template>
    <div
      data-part="region"
      data-region={{@name}}
      data-has-content={{this.hasContentString}}
      class={{this.classNames}}
      {{this.register @name @multiple}}
      ...attributes
    >
      {{#unless this.hasContent}}{{yield}}{{/unless}}
    </div>
  </template>
}

export { Region, type RegionSignature, type RegionArgs };
export default Region;
