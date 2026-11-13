import Component from '@glimmer/component';
import { service } from '@ember/service';
import { registerDestructor } from '@ember/destroyable';
import type AppLayoutService from '../../services/app-layout';
import type Owner from '@ember/owner';

interface LayoutRegionArgs {
  /** The name of the `layout.Region` to render into. Read once. */
  name: string;
}

interface LayoutRegionSignature {
  Args: LayoutRegionArgs;
  Blocks: { default: [] };
}

/**
 * PROTOTYPE. Renders its block into the layout's region of the same name,
 * from anywhere in the app, including route templates inside `{{outlet}}`.
 * Nothing renders where it sits.
 *
 * The newest source wins; when it is torn down (a child route exits) the
 * previous one comes back. With `@multiple` on the target, all render.
 * "Newest" is render order, so in a parent route template put it before
 * `{{outlet}}`.
 */
class LayoutRegion extends Component<LayoutRegionSignature> {
  @service('app-layout') declare appLayout: AppLayoutService;

  token = {};

  constructor(owner: Owner, args: LayoutRegionArgs) {
    super(owner, args);
    const remove = this.appLayout.addSource(args.name, this.token);
    registerDestructor(this, remove);
  }

  get target(): Element | null {
    return this.appLayout.region(this.args.name).targetFor(this.token);
  }

  <template>
    {{#if this.target}}
      {{#in-element this.target insertBefore=null}}{{yield}}{{/in-element}}
    {{/if}}
  </template>
}

export { LayoutRegion, type LayoutRegionSignature, type LayoutRegionArgs };
export default LayoutRegion;
