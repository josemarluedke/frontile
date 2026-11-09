import Helper from '@ember/component/helper';
import { service } from '@ember/service';
import { BreadcrumbToken } from '../services/app-layout';
import type AppLayoutService from '../services/app-layout';
import type { BreadcrumbsItemData } from '../components/navigation/breadcrumbs/collapse';
import type Owner from '@ember/owner';

interface BreadcrumbSignature {
  Args: {
    Positional: [label: string];
    Named: Omit<BreadcrumbsItemData, 'label'>;
  };
  Return: '';
}

/**
 * PROTOTYPE. Data-only: `{{breadcrumb "Orders" route="orders"}}` adds a
 * crumb to the layout's trail for as long as it is rendered, like
 * `{{page-title}}`. Crumbs stack in render order, so a child route's comes
 * after its parent's, and pops when the child exits.
 */
export default class BreadcrumbHelper extends Helper<BreadcrumbSignature> {
  @service('app-layout') declare appLayout: AppLayoutService;

  token = new BreadcrumbToken();
  #remove: () => void;

  constructor(owner: Owner) {
    super(owner);
    this.#remove = this.appLayout.addBreadcrumb(this.token);
  }

  compute([label]: [string], named: Omit<BreadcrumbsItemData, 'label'>): '' {
    this.appLayout.updateBreadcrumb(this.token, { ...named, label });
    return '';
  }

  willDestroy(): void {
    super.willDestroy();
    this.#remove();
  }
}

export { BreadcrumbHelper as breadcrumb };
