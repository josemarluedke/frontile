import Component from '@glimmer/component';
import type { AppLayoutContext } from './context';

interface RegionSignature {
  Args: {
    /** The region's name, which `InRegion @name` fills. Read once. */
    name: string;

    /**
     * Show every source, in render order, instead of only the newest.
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
  };
  Blocks: {
    /** Fallback content, shown while nothing fills the region. */
    default: [];
  };
}

/**
 * PROTOTYPE (layout regions, second attempt).
 *
 * Where a region is displayed. It renders the layout's element for `@name`
 * right here, and its own block as a fallback after it:
 *
 * ```gts
 * <layout.Navbar>
 *   <layout.Region @name="actions" />
 * </layout.Navbar>
 * ```
 *
 * Display a name in one place at a time: it is one element.
 */
class Region extends Component<RegionSignature> {
  get element(): Element | null {
    const element = this.args.layout?.regions.element(this.args.name) ?? null;
    if (element) {
      if (this.args.multiple) {
        element.setAttribute('data-multiple', '');
      } else {
        element.removeAttribute('data-multiple');
      }
    }
    return element;
  }

  get fallbackClass(): string | undefined {
    const layout = this.args.layout;
    return layout?.styles.regionFallback({
      class: layout.classes?.regionFallback
    });
  }

  <template>
    {{! A DOM node rendered as content is inserted as it is. }}
    {{this.element}}
    {{#if (has-block)}}
      <div data-part="region-fallback" class={{this.fallbackClass}}>
        {{yield}}
      </div>
    {{/if}}
  </template>
}

export { Region, type RegionSignature };
export default Region;
