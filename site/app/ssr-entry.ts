// Prerender entry point. Bundled for Node by the `isSsrBuild` branch of
// vite.config.mjs and driven by ssr/prerender.mjs — see ssr/README.md.
import type { BootOptions } from '@ember/engine/instance';
import { settled } from '@ember/test-helpers';
import App from './app';
import config from './config/environment';

export interface RenderResult {
  html: string;
  /**
   * The route that was rendered, e.g. `docs.components.buttons.button`. The
   * prerenderer maps it to the lazy route chunks the page will need.
   */
  routeName: string | undefined;
  /**
   * Read before the instance is torn down — ember-page-title clears
   * `document.title` on teardown, so the caller cannot recover it afterwards.
   */
  title: string;
}

let appPromise: Promise<App> | undefined;

/** Boot the Application once and reuse it for every route. */
function getApp(): Promise<App> {
  return (appPromise ??= App.create({
    ...config.APP,
    autoboot: false,
  }).boot());
}

/**
 * Render `url` into `document` and return the serialized HTML.
 *
 * Each call gets a fresh `ApplicationInstance`, which keeps route state from
 * leaking between pages. That isolation isn't free — Glimmer caches compiled
 * templates per owner, so a new instance recompiles the shared chrome — but at
 * ~30ms a route it is a trade worth making. The `Application` itself is booted
 * only once.
 *
 * `_renderMode: 'serialize'` is what selects Glimmer's `serializeBuilder` over
 * the normal `clientBuilder`, emitting the `<!--%+b:0%-->` boundary markers the
 * client needs in order to rehydrate rather than render a second copy of the app.
 */
export async function render(
  url: string,
  document: Document
): Promise<RenderResult> {
  const app = await getApp();
  const instance = app.buildInstance();

  const bootOptions: BootOptions = {
    isBrowser: false,
    document,
    // Ember types `rootElement` as a SimpleDOM element; ours is a real DOM one.
    // (`@simple-dom/interface` is only a transitive type dep, so name the type
    // through BootOptions rather than importing it.)
    rootElement: document.body as unknown as BootOptions['rootElement'],
    shouldRender: true,
    location: 'none',
    _renderMode: 'serialize',
  };

  try {
    await instance.boot(bootOptions);
    // `visit` takes the same boot options as a second argument; the public
    // types only describe the single-argument form.
    await (
      instance.visit as (url: string, options: BootOptions) => Promise<unknown>
    )(url, bootOptions);

    const router = instance.lookup('service:router') as {
      currentRouteName?: string;
    };

    const result = {
      html: `<!DOCTYPE html>\n${document.documentElement.outerHTML}`,
      title: document.title,
      routeName: router.currentRouteName,
    };

    // Wait for work the transition did not await before the owner is destroyed.
    // With `splitAtRoutes`, rendering a page's sidebar pulls route handlers for
    // every split route it links to, and @embroider/router answers those with
    // `registerBundle(bundle).then(() => original(name))` — a continuation with
    // no `isDestroying` guard, unlike `registerBundle` itself. Tearing down
    // immediately makes those chains throw
    // `Cannot call .lookup('route:…') after the owner has been destroyed`.
    //
    // `settled()` resolves once the run loop, pending timers and pending
    // requests are quiet, which is long enough for those already-resolved
    // dynamic imports to finish. Note it is *not* tracking them via test
    // waiters: @ember/test-waiters compiles to a no-op outside a development
    // build, so @embroider/router's lazy-route waiter contributes nothing here.
    // The HTML is snapshotted above so nothing below can alter the output.
    await settled();

    return result;
  } finally {
    instance.destroy();
  }
}
