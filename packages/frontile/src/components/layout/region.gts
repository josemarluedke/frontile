import Component from '@glimmer/component';
import { service } from '@ember/service';
import { modifier } from 'ember-modifier';
import { standaloneStyles, type AppLayoutContext } from './context';
import type FrontileLayoutRegionsService from '../../services/frontile-layout-regions';
import type Owner from '@ember/owner';

interface RegionArgs {
  /**
   * The region's name, matched by `InLayoutRegion @name`. Names are global
   * to the app. Read once, when the region renders.
   */
  name: string;

  /**
   * Render every source, in the order they rendered, instead of only the
   * newest. Read once, when the region renders.
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
    /** Rendered while no `InLayoutRegion` fills the region. */
    default: [];
  };
  Element: HTMLDivElement;
}

/**
 * A named place in the layout that any template, including a route template
 * inside `{{outlet}}`, fills with `InLayoutRegion`. Its element is
 * `display: contents`, so the content lays out as if it were written where
 * the region sits. `data-has-content` is `true` while a source fills it.
 */
class Region extends Component<RegionSignature> {
  @service('frontile-layout-regions')
  declare regions: FrontileLayoutRegionsService;

  constructor(owner: Owner, args: RegionArgs) {
    super(owner, args);
    this.regions.declare(args.name);
  }

  register = modifier(
    (element: HTMLElement, [name, multiple]: [string, boolean | undefined]) =>
      this.regions.registerTarget(name, element, { multiple })
  );

  get classNames(): string {
    const styles = this.args.layout?.styles ?? standaloneStyles();
    return styles.region({ class: this.args.layout?.classes?.region });
  }

  get hasContent(): boolean {
    return this.regions.hasContent(this.args.name);
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
