// Render every Docfy route to static HTML. See ssr/README.md.
//
// Needs both builds present: `pnpm build:client` (dist/) and `pnpm build:ssr`
// (dist-ssr/). `pnpm --filter site build` runs all three in order.
//
// Accepts route arguments to render a subset:
//
//   node ssr/prerender.mjs / /docs/components/forms/input
import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseHTML } from 'linkedom';

import { outputPathForUrl } from './output-path.mjs';

// `import.meta.dirname` needs Node 20.11; package.json declares `node >= 18`.
const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const distDir = join(root, 'dist');

// Every page is rendered into a copy of the client build's shell. Rendering "/"
// overwrites dist/index.html, so the pristine shell is snapshotted outside dist/
// — otherwise the next run would template off its own output, and the snapshot
// would ship.
const shellPath = join(root, 'dist-ssr', 'app-shell.html');
let shell;
try {
  shell = await readFile(shellPath, 'utf8');
} catch {
  shell = await readFile(join(distDir, 'index.html'), 'utf8');
  await writeFile(shellPath, shell, 'utf8');
}

// Tells index.html's boot script to rehydrate rather than render fresh. Added to
// the template once rather than per document, and after the snapshot is written
// so the file on disk stays a clean copy of the client build.
shell = shell.replace('</head>', '<meta name="x-prerendered"></head>');

/**
 * A document Glimmer can render into, paired with its own `window`.
 *
 * Parsed per call rather than cloned: each route needs an isolated document, and
 * `parseHTML` is what mints the paired `window`. Parsing the 4KB shell 68 times
 * costs 12ms of a ~2s pass.
 */
function createDocument() {
  const { window, document } = parseHTML(shell);

  // Glimmer calls this for `{{{html}}}`; it is a SimpleDOM-era API that no
  // standard DOM implements.
  document.createRawHTMLSection = (html) => {
    const el = document.createElement('div');
    el.innerHTML = html;
    const fragment = document.createDocumentFragment();
    fragment.append(...el.childNodes);
    return fragment;
  };

  return { window, document };
}

/**
 * Make a fresh document the ambient one and return it.
 *
 * Render-time code reads bare `document` (docfy-theme-switcher takes
 * `document.documentElement`), so the global must point at the document being
 * rendered into — not just the one passed to `render()`.
 */
function installDocument() {
  const { window, document } = createDocument();

  globalThis.window = window;
  globalThis.document = document;

  return { window, document };
}

// --- browser globals, installed before the app bundle is imported ------------
// The order matters. app/config/environment.ts calls loadConfigFromMeta() at
// module scope, so the shell's `<meta name="site/config/environment">` must be
// reachable through the ambient document before the dynamic import below runs.
const bootstrap = installDocument();

// Ember's deprecation-workflow module assigns to `self` when imported.
globalThis.self = globalThis;

// The only DOM globals render-time code reaches for. They come from linkedom
// rather than Node's built-ins because linkedom's `dispatchEvent` writes
// `event.eventPhase`, which is getter-only on a native Event — so a
// `new CustomEvent()` resolving to Node's class throws on dispatch. linkedom's
// `window` inherits from globalThis, so these also answer `window.foo` in app
// code.
//
// Keep this list minimal. A global that is missing raises a ReferenceError and
// fails the build; a global that is present but wrong produces subtly bad HTML.
// Prefer guarding the call site (see ssr/README.md) over adding a shim.
globalThis.CustomEvent = bootstrap.window.CustomEvent; // focus-visible polyfill
globalThis.Node = bootstrap.window.Node; // focus-visible polyfill
globalThis.Element = bootstrap.window.Element; // Glimmer

// What @embroider/virtual/vendor.js sets in the browser. Taken from the config
// meta tag rather than restated here, so a flag change in config/environment.js
// cannot leave the prerender booting Ember differently from the client that
// rehydrates its output.
const appConfig = JSON.parse(
  decodeURIComponent(
    bootstrap.document
      .querySelector('meta[name="site/config/environment"]')
      .getAttribute('content'),
  ),
);
globalThis.EmberENV = appConfig.EmberENV;
globalThis.runningTests = false;

const { render } = await import(join(root, 'dist-ssr/ssr-entry.mjs'));

// --- render ------------------------------------------------------------------
const urls = JSON.parse(
  await readFile(join(distDir, 'docfy-urls.json'), 'utf8'),
);
const args = process.argv.slice(2);
const routes = args.length ? args : ['/', ...urls];

let ok = 0;
let failed = 0;

// Errors thrown inside Glimmer's render reach the run loop, not the try/catch
// below. Counting them here keeps the remaining routes running while still
// failing the build — without this, a broken render reports success and ships
// near-empty pages.
process.on('uncaughtException', (error) => {
  console.error(`  ! uncaught: ${error.message}`);
  failed++;
});

// Sequential by necessity: renders share one Ember Application, one run loop and
// one ambient document, so concurrent ones would read each other's state.
for (const url of routes) {
  const started = performance.now();
  try {
    const { document } = installDocument();

    const { html, title } = await render(url, document);

    const outPath = outputPathForUrl(distDir, url);
    await mkdir(dirname(outPath), { recursive: true });
    await writeFile(outPath, html, 'utf8');

    const ms = Math.round(performance.now() - started);
    console.log(
      `✓ ${url}  ${(html.length / 1024).toFixed(0)}kb  ${ms}ms  title=${JSON.stringify(title)}`,
    );
    ok++;
  } catch (error) {
    console.error(
      `✗ ${url}\n    ${error?.stack?.split('\n').slice(0, 6).join('\n    ')}`,
    );
    failed++;
  }
}

console.log(`\n${ok} rendered, ${failed} failed`);

// Fail the build rather than let the SPA fallback quietly cover a missing page.
if (failed > 0) {
  process.exitCode = 1;
}
