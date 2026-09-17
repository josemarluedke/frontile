import { readFileSync } from 'fs';

export function loadInventory(componentInventoryJsonPath) {
  let source;
  try {
    source = readFileSync(componentInventoryJsonPath, 'utf-8');
  } catch (error) {
    throw new Error(
      `[docfy-plugin-page-descriptions] Could not read ${componentInventoryJsonPath}: ${error.message}`,
      { cause: error },
    );
  }

  let categories;
  try {
    categories = JSON.parse(source);
  } catch (error) {
    throw new Error(
      `[docfy-plugin-page-descriptions] Could not parse ${componentInventoryJsonPath} as JSON: ${error.message}`,
      { cause: error },
    );
  }

  return categories.flatMap((category) => category.items);
}

// Docfy index pages end in `/`, so a page URL and an inventory path can
// disagree on a trailing slash while still referring to the same page.
function normalizeUrl(url) {
  return url.length > 1 && url.endsWith('/') ? url.slice(0, -1) : url;
}

export function docfyPluginPageDescriptions(inventoryItems) {
  return {
    runAfter(ctx) {
      const matchedPaths = new Set();

      ctx.pages.forEach((page) => {
        const pageUrl = normalizeUrl(page.meta.url);
        const item = inventoryItems.find(
          (candidate) => normalizeUrl(candidate.path) === pageUrl,
        );

        if (!item) {
          // Guide pages legitimately have no inventory entry - not warned.
          return;
        }

        matchedPaths.add(item.path);

        // An explicit per-page frontmatter description is hand-written for
        // that page and wins over the inventory's generic one.
        if (page.meta.frontmatter.description) {
          return;
        }

        // `@docfy/core` builds `nestedPageMetadata` from
        // `ctx.pages.map(p => p.meta)` AFTER this `runAfter` stage runs, and
        // the llms.txt builder reads `frontmatter.description` off those same
        // meta objects - so this is the field that has to be set, not some
        // other spot on `page`.
        page.meta.frontmatter.description = item.description;
      });

      inventoryItems.forEach((item) => {
        if (!matchedPaths.has(item.path)) {
          console.warn(
            `[docfy-plugin-page-descriptions] No page found for inventory item at ${item.path} — has it been renamed or removed?`,
          );
        }
      });
    },
  };
}

export default docfyPluginPageDescriptions;
