import Component from '@glimmer/component';
import { service } from '@ember/service';
import Breadcrumbs from '../navigation/breadcrumbs/breadcrumbs';
import type AppLayoutService from '../../services/app-layout';
import type { AppLayoutContext } from './context';

interface LayoutBreadcrumbsSignature {
  Args: {
    /** Collapses the middle of the trail past this many crumbs. */
    maxItems?: number;
    /**
     * Supplied by `AppLayout`. Not part of the public API.
     *
     * @internal
     */
    layout?: AppLayoutContext;
  };
  Element: HTMLElement;
}

/**
 * PROTOTYPE. `Breadcrumbs` rendered from the `{{breadcrumb}}` calls in the
 * current route hierarchy, outermost first.
 */
class LayoutBreadcrumbs extends Component<LayoutBreadcrumbsSignature> {
  @service('app-layout') declare appLayout: AppLayoutService;

  <template>
    <Breadcrumbs
      @items={{this.appLayout.breadcrumbs}}
      @maxItems={{@maxItems}}
      ...attributes
    />
  </template>
}

export { LayoutBreadcrumbs, type LayoutBreadcrumbsSignature };
export default LayoutBreadcrumbs;
