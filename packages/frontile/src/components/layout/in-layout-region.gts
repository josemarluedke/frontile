import Component from '@glimmer/component';
import { service } from '@ember/service';
import { registerDestructor } from '@ember/destroyable';
import type FrontileLayoutRegionsService from '../../services/frontile-layout-regions';
import type Owner from '@ember/owner';

interface InLayoutRegionArgs {
  /**
   * The name of the region to render into: a `layout.Region @name`, or a
   * `layout.Aside @region`. Read once.
   */
  name: string;
}

interface InLayoutRegionSignature {
  Args: InLayoutRegionArgs;
  Blocks: {
    /** The content rendered in the region. */
    default: [];
  };
}

/**
 * Renders its block into the layout region of the same name, from anywhere
 * in the app, including a route template inside `{{outlet}}`. Nothing
 * renders where it sits, and the block gets no wrapper element.
 *
 * The source that rendered last is the one shown. When it goes away (a
 * child route exits) the previous one comes back. In a parent route
 * template, put it before `{{outlet}}` so the child's source renders later
 * and wins. With `@multiple` on the region, every source is shown.
 */
class InLayoutRegion extends Component<InLayoutRegionSignature> {
  @service('frontile-layout-regions')
  declare regions: FrontileLayoutRegionsService;

  token = {};
  /** `@name`, read once: the source stays in the region it joined. */
  name: string;

  constructor(owner: Owner, args: InLayoutRegionArgs) {
    super(owner, args);
    this.name = args.name;
    registerDestructor(this, this.regions.addSource(this.name, this.token));
  }

  get target(): Element | null {
    return this.regions.targetFor(this.name, this.token);
  }

  <template>
    {{#if this.target}}
      {{#in-element this.target insertBefore=null}}{{yield}}{{/in-element}}
    {{/if}}
  </template>
}

export {
  InLayoutRegion,
  type InLayoutRegionSignature,
  type InLayoutRegionArgs
};
export default InLayoutRegion;
