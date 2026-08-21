// Prerender every Docfy route to static HTML. See ssr/README.md.
//
// Run as part of `pnpm --filter site build`, or by hand:
//
//   pnpm build:client   # client bundle -> dist/
//   pnpm build:ssr      # node bundle   -> dist-ssr/
//   pnpm prerender      # 68 x <route>.html into dist/
//
// Takes route arguments for a fast iteration loop:
//
//   node ssr/prerender.mjs / /docs/components/forms/input
import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseHTML } from 'linkedom';

// Not `import.meta.dirname` — that lands in Node 20.11, and site/package.json
// still declares `node >= 18`.
const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const distDir = join(root, 'dist');

// Snapshot the untouched shell outside dist/, so it isn't deployed: prerendering
// "/" overwrites dist/index.html, and a second run would otherwise use its own
// output as the template.
const shellPath = join(root, 'dist-ssr', 'app-shell.html');
let shell;
try {
  shell = await readFile(shellPath, 'utf8');
} catch {
  shell = await readFile(join(distDir, 'index.html'), 'utf8');
  await writeFile(shellPath, shell, 'utf8');
}

// The flag index.html boots on: present means "this HTML was serialized by a
// server render, rehydrate it" (see the boot script in index.html). It is a
// build-wide constant, so it goes into the template once rather than being
// appended to each route's document. Injected after the snapshot is written, so
// the snapshot on disk stays a clean copy of the client build's output.
shell = shell.replace('</head>', '<meta name="x-prerendered"></head>');

/** A linkedom document that is close enough to a browser one for Glimmer. */
function createDocument() {
  // Re-parsing the 4KB shell per route measured at 12ms across all 68 — 0.6% of
  // the pass — and `parseHTML` is what mints the paired `window` each document
  // needs. Don't "optimize" this into a shared clone; isolation is the point.
  const { window, document } = parseHTML(shell);

  // Glimmer still reaches for this SimpleDOM-era API for `{{{html}}}`.
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
 * Make a fresh document the ambient one, and hand it back.
 *
 * Ember reads `globalThis.document` in places that don't take an explicit
 * document, so the global has to track whichever document we're rendering into.
 */
function installDocument() {
  const { window, document } = createDocument();

  globalThis.window = window;
  globalThis.document = document;

  return { window, document };
}

// --- install browser-ish globals BEFORE importing the app bundle -------------
// The ordering is load-bearing: app/config/environment.ts calls
// loadConfigFromMeta() at *module scope*, so a document holding the shell's
// `<meta name="site/config/environment">` has to be in place before the dynamic
// import below.
const bootstrap = installDocument();

// Ember's deprecation-workflow module assigns to `self` at import time.
globalThis.self = globalThis;

// The DOM globals the app actually reaches for during a render. Deliberately
// minimal: each one here was verified necessary by removing it and watching the
// build fail, and the full 68-route output is byte-for-byte identical to a run
// with a much larger shim list. Anything missing fails loudly with a
// ReferenceError at build time, so this list can stay honest rather than
// defensive.
//
// They have to come from linkedom rather than Node's built-ins: linkedom's
// `dispatchEvent` writes `event.eventPhase`, which is getter-only on a native
// Event, so a `new CustomEvent()` resolving to Node's version throws on dispatch.
// (linkedom's `window` inherits from globalThis, so assigning here is also what
// makes `window.foo` resolve inside the app.)
globalThis.CustomEvent = bootstrap.window.CustomEvent; // focus-visible polyfill
globalThis.Node = bootstrap.window.Node; // focus-visible polyfill
globalThis.Element = bootstrap.window.Element; // Glimmer

// Mirrors what @embroider/virtual/vendor.js sets in the browser. Read out of the
// config meta tag rather than restated, so the prerender can't boot Ember under
// different feature flags than the client bundle that rehydrates its output.
// Ember's current defaults happen to match, so dropping this changes nothing
// today — but it would diverge silently, unlike everything above.
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

// --- routes -----------------------------------------------------------------
const urls = JSON.parse(
  await readFile(join(distDir, 'docfy-urls.json'), 'utf8'),
);
const args = process.argv.slice(2);
const routes = args.length ? args : ['/', ...urls];

/**
 * Where a route's HTML goes.
 *
 * Flat `<path>.html`, not `<path>/index.html`. Every link the site renders is
 * extensionless and without a trailing slash (`/docs/components/buttons/button`,
 * and notably that holds for Docfy index pages too, whose URLs *do* carry a
 * slash). Netlify's Pretty URLs serve `/foo` straight from `foo.html`, whereas
 * `foo/index.html` is only reachable at `/foo/` — so directory output would put
 * a 301 in front of every cold page load and quietly move the site's canonical
 * URLs. Flat files keep today's URLs exactly as they are.
 */
function outputPathForUrl(url) {
  const relative = url.replace(/^\/+/, '').replace(/\/+$/, '');

  return relative === ''
    ? join(distDir, 'index.html')
    : join(distDir, `${relative}.html`);
}

let ok = 0;
let failed = 0;

// A ReferenceError thrown from inside Glimmer's render escapes the per-route
// try/catch via the run loop, so keep the process alive for the remaining
// routes — but still count it, so the build fails.
process.on('uncaughtException', (error) => {
  console.error(`  ! uncaught: ${error.message}`);
  failed++;
});

// Sequential by necessity, not by oversight: every render shares one Ember
// Application, one run loop, and the ambient `globalThis.document`, so two
// in-flight renders would read each other's document.
for (const url of routes) {
  const started = performance.now();
  try {
    const { document } = installDocument();

    const { html, title } = await render(url, document);

    const outPath = outputPathForUrl(url);
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

// Fail the build rather than silently letting the SPA fallback cover the gap.
if (failed > 0) {
  process.exitCode = 1;
}
