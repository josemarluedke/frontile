/**
 * The component inventory, taken from the routes Docfy actually generates
 * (site/public/docfy-urls.json). Legacy packages are deliberately excluded:
 * `forms-legacy` and `changeset-form` are deprecated and slated for removal
 * before v1, so counting them would overstate what Frontile currently offers.
 *
 * If a component gains or loses a docs page, update this list. It is the only
 * place the homepage and the /docs/components/overview page name components,
 * so nothing else has to be kept in step.
 *
 * The data itself lives in the sibling `component-inventory.json` — this file
 * is just the typed wrapper around it.
 */

import inventoryData from './component-inventory.json';

export interface InventoryItem {
  name: string;
  path: string;
  /** What the component does, in one sentence. Shown on /docs/components/overview. */
  description: string;
}

export interface InventoryCategory {
  name: string;
  /** What this group is for, in the product's own terms. */
  summary: string;
  items: InventoryItem[];
}

export const inventory: InventoryCategory[] = inventoryData;

export const componentCount: number = inventory.reduce(
  (total, category) => total + category.items.length,
  0
);
