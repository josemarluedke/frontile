/**
 * Working out what a prerendered page should preload.
 *
 * Vite emits `<link rel="modulepreload">` for the chunks the *entry* needs, but
 * it cannot know which lazily loaded route chunk any given prerendered page will
 * ask for — that is decided at runtime by @embroider/router. The result is a
 * second request wave that only starts once the app has booted and resolved its
 * route. Since prerendering already knows the route, the chunks can be declared
 * in the HTML instead and fetched alongside everything else.
 */

/** `assets/-embroider-route-entrypoint.js_route_docs.theming-Bf3x1y2z.js` */
const ROUTE_BUNDLE_FILE = /_route_(.+?)-[A-Za-z0-9_-]+\.js$/;
const ROUTE_ENTRYPOINT_KEY = /-embroider-route-entrypoint\.js:route=(.+)$/;

/**
 * Map each `splitAtRoutes` split point to the files a page under it needs.
 *
 * One bundle covers every route beneath its split point, and the manifest keys
 * it by whichever route was encountered first — so the split point is read from
 * the emitted filename rather than the key. The top-level `docs` bundle carries
 * no `_route_` marker, and falls back to the key.
 *
 * Static `imports` are followed transitively: a section bundle pulls in shared
 * chunks (the generated signature data is 405 kB of it) that would otherwise
 * form a third wave.
 */
export function routeBundles(manifest) {
  const fileFor = (key) => manifest[key]?.file;
  const bundles = new Map();

  const collect = (key, seen) => {
    if (seen.has(key)) {
      return;
    }
    seen.add(key);

    for (const imported of manifest[key]?.imports ?? []) {
      collect(imported, seen);
    }
  };

  for (const key of Object.keys(manifest)) {
    const keyMatch = ROUTE_ENTRYPOINT_KEY.exec(key);
    if (!keyMatch) {
      continue;
    }

    const file = fileFor(key);
    const splitPoint = ROUTE_BUNDLE_FILE.exec(file ?? '')?.[1] ?? keyMatch[1];

    const seen = new Set();
    collect(key, seen);

    bundles.set(splitPoint, [...seen].map(fileFor).filter(Boolean).sort());
  }

  return bundles;
}

/** True when `splitPoint` is `routeName` or one of its ancestors. */
function covers(splitPoint, routeName) {
  return routeName === splitPoint || routeName.startsWith(`${splitPoint}.`);
}

/**
 * The files a page on `routeName` will load, newest split point last.
 *
 * Every ancestor split point contributes: visiting
 * `docs.components.buttons.button` activates the `docs` route as well, so both
 * bundles are fetched.
 */
export function routeChunksFor(bundles, routeName) {
  if (!routeName) {
    return [];
  }

  const files = new Set();

  for (const [splitPoint, bundleFiles] of bundles) {
    if (covers(splitPoint, routeName)) {
      bundleFiles.forEach((file) => files.add(file));
    }
  }

  return [...files].sort();
}

/**
 * Hashed URLs for the given font families, read out of the built stylesheet.
 *
 * The build's own manifest does not expose the emitted font filenames at the
 * point the HTML is generated, and the stylesheet is the thing that actually
 * references them, so it is the honest source.
 */
export function fontUrls(css, families) {
  return families
    .map((family) => {
      const match = new RegExp(
        `url\\((/[^)"']*${family}[^)"']*\\.woff2)\\)`,
      ).exec(css);

      return match?.[1];
    })
    .filter(Boolean);
}

/**
 * Font families worth preloading for a page.
 *
 * `open-sans` (body) and `source-code-pro` (code) are used on every page.
 * `domine` sets the headings on the homepage — including its `h1`, which is the
 * largest text on the page — but is not fetched at all on a docs page, so
 * preloading it everywhere would waste 39 kB per page and earn an unused-preload
 * warning. The italics are conditional and never above the fold.
 */
export function fontFamiliesFor(routeName) {
  const everywhere = ['open-sans-variable', 'source-code-pro-variable'];

  return routeName === 'index'
    ? [...everywhere, 'domine-variable']
    : everywhere;
}
