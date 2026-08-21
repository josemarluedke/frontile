// Prerender entry point. Bundled for Node by vite.config.ssr.mjs and driven by
// ssr/prerender.mjs — see ssr/README.md.
import type ApplicationInstance from '@ember/application/instance';
import App from './app';
import config from './config/environment';

export interface RenderResult {
  html: string;
  title: string | undefined;
}

/**
 * The boot options a server render needs. `_renderMode` is private API — it is
 * what selects Glimmer's `serializeBuilder` over the normal `clientBuilder`,
 * emitting the `<!--%+b:0%-->` boundary markers the client needs to rehydrate
 * instead of rendering a second copy of the app. It is absent from the public
 * `BootOptions` type, hence the cast at the call sites below.
 */
interface SsrBootOptions {
  isBrowser: false;
  document: Document;
  rootElement: Element;
  shouldRender: true;
  location: 'none';
  _renderMode: 'serialize';
}

type BootOptionsArg = Parameters<ApplicationInstance['boot']>[0];

let appPromise: Promise<App> | undefined;

/** Boot the Application once and reuse it for every route. */
async function getApp(): Promise<App> {
  appPromise ??= (async () => {
    const app = App.create({ ...config.APP, autoboot: false });
    await app.boot();
    return app;
  })();

  return appPromise;
}

/**
 * Render `url` into `document` and return the serialized HTML.
 *
 * Each call gets a fresh `ApplicationInstance` — cheap, and it keeps route
 * state from leaking between pages — while the `Application` itself is booted
 * only once.
 */
export async function render(
  url: string,
  document: Document
): Promise<RenderResult> {
  const app = await getApp();
  const instance = app.buildInstance();

  const bootOptions: SsrBootOptions = {
    isBrowser: false,
    document,
    rootElement: document.body,
    shouldRender: true,
    location: 'none',
    _renderMode: 'serialize',
  };

  try {
    await instance.boot(bootOptions as unknown as BootOptionsArg);
    // `visit` takes the same boot options as a second argument; the public
    // types only describe the single-argument form.
    await (
      instance.visit as (url: string, options: unknown) => Promise<unknown>
    )(url, bootOptions);

    return {
      html: `<!DOCTYPE html>\n${document.documentElement.outerHTML}`,
      title: document.title,
    };
  } finally {
    instance.destroy();
  }
}
