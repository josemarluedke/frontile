import Component from '@glimmer/component';
import { guidFor } from '@ember/object/internals';
import { registerDestructor } from '@ember/destroyable';
import { warn } from '@ember/debug';
import { getDOM, getElementById } from '../../-private/dom';
import { standaloneStyles } from './context';
import { findLayoutRegions } from './regions';

interface InRegionSignature {
  Args: {
    /** The region to fill. Read once. */
    name: string;
  };
  Blocks: { default: [] };
  Element: HTMLDivElement;
}

/**
 * PROTOTYPE (layout regions, second attempt).
 *
 * Renders its block into a named region of the `AppLayout` it is inside,
 * from anywhere below the layout, a route template included:
 *
 * ```gts
 * <InRegion @name="actions"><Button>New order</Button></InRegion>
 * ```
 *
 * It leaves a `script` marker where it is written. The marker is how it finds
 * its layout (it walks up from it), and what the layout's CSS reads to know a
 * region has content.
 */
class InRegion extends Component<InRegionSignature> {
  id = `${guidFor(this)}-region-source`;
  /**
   * Called once from the template, after the marker above it is in the DOM.
   * Finds the layout by walking up from the marker and returns the region's
   * element. Nothing tracked is read or written.
   */
  resolveTarget = (): Element | null => {
    const doc = getDOM(this);
    const marker = doc ? getElementById(doc, this.id) : null;
    const regions = findLayoutRegions(marker);
    warn(
      `<InRegion @name="${this.args.name}"> is not inside an AppLayout, so it renders nothing.`,
      regions !== null,
      { id: 'frontile.in-region.no-layout' }
    );
    if (!regions) {
      return null;
    }
    registerDestructor(this, regions.addSource(this.args.name));
    return regions.element(this.args.name);
  };

  get className(): string {
    return standaloneStyles().regionContent();
  }

  <template>
    <script
      type="x/region-source"
      id={{this.id}}
      data-region-source={{@name}}
    ></script>
    {{#let (this.resolveTarget) as |target|}}
      {{#if target}}
        {{#in-element target insertBefore=null}}
          <div
            data-part="region-content"
            class={{this.className}}
            ...attributes
          >{{yield}}</div>
        {{/in-element}}
      {{/if}}
    {{/let}}
  </template>
}

export { InRegion, type InRegionSignature };
export default InRegion;
