// Prerender every Docfy route to static HTML. See ssr/README.md.
//
// Run as part of `pnpm --filter site build`, or by hand:
//
//   pnpm build:client   # client bundle -> dist/
//   pnpm build:ssr      # node bundle   -> dist-ssr/
//   pnpm prerender      # 68 x index.html into dist/
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

/** A linkedom document that is close enough to a browser one for Glimmer. */
function createDocument() {
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

// --- install browser-ish globals BEFORE importing the app bundle -------------
const { window, document } = createDocument();

globalThis.window = window;
globalThis.document = document;
globalThis.self = globalThis;
// Take every DOM constructor from linkedom rather than letting Node's built-in
// Event/CustomEvent leak in: linkedom's dispatchEvent writes `eventPhase`,
// which is getter-only on a native Event.
for (const name of [
  'Event',
  'CustomEvent',
  'Node',
  'Element',
  'HTMLElement',
  'HTMLDocument',
  'DocumentFragment',
  'Text',
  'Comment',
  'MutationObserver',
  'CSS',
  'getComputedStyle',
  'requestAnimationFrame',
  'cancelAnimationFrame',
  'matchMedia',
  'localStorage',
  'sessionStorage',
  'navigator',
]) {
  if (window[name] === undefined) continue;
  Object.defineProperty(globalThis, name, {
    value: window[name],
    writable: true,
    configurable: true,
  });
}
if (!globalThis.navigator?.userAgent) {
  Object.defineProperty(globalThis, 'navigator', {
    value: { userAgent: 'node' },
    writable: true,
    configurable: true,
  });
}
globalThis.matchMedia ??= () => ({
  matches: false,
  addEventListener() {},
  removeEventListener() {},
  addListener() {},
  removeListener() {},
});
globalThis.requestAnimationFrame ??= (cb) =>
  setTimeout(() => cb(Date.now()), 0);
globalThis.cancelAnimationFrame ??= (id) => clearTimeout(id);
globalThis.localStorage ??= {
  getItem: () => null,
  setItem() {},
  removeItem() {},
  clear() {},
};
let ok = 0;
let failed = 0;

// A ReferenceError thrown from inside Glimmer's render escapes the per-route
// try/catch via the run loop, so keep the process alive for the remaining
// routes — but still count it, so the build fails.
process.on('uncaughtException', (error) => {
  console.error(`  ! uncaught: ${error.message}`);
  failed++;
});
globalThis.EmberENV = {
  EXTEND_PROTOTYPES: false,
  FEATURES: {},
  _APPLICATION_TEMPLATE_WRAPPER: false,
  _DEFAULT_ASYNC_OBSERVERS: true,
  _JQUERY_INTEGRATION: false,
  _NO_IMPLICIT_ROUTE_MODEL: true,
  _TEMPLATE_ONLY_GLIMMER_COMPONENTS: true,
};
globalThis.runningTests = false;

const { render } = await import(join(root, 'dist-ssr/ssr-entry.mjs'));

// --- routes -----------------------------------------------------------------
const urls = JSON.parse(
  await readFile(join(distDir, 'docfy-urls.json'), 'utf8'),
);
const only = process.argv.slice(2).filter((a) => !a.startsWith('-'));
const routes = only.length ? only : ['/', ...urls];

for (const url of routes) {
  const started = performance.now();
  try {
    const fresh = createDocument();
    globalThis.window = fresh.window;
    globalThis.document = fresh.document;

    const marker = fresh.document.createElement('meta');
    marker.setAttribute('name', 'x-prerendered');
    marker.setAttribute('content', url);
    fresh.document.head.appendChild(marker);

    const result = await render(url, fresh.document);

    const outPath = join(distDir, url.replace(/^\//, ''), 'index.html');
    await mkdir(dirname(outPath), { recursive: true });
    await writeFile(outPath, result.html, 'utf8');

    const ms = Math.round(performance.now() - started);
    console.log(
      `✓ ${url}  ${(result.html.length / 1024).toFixed(0)}kb  ${ms}ms  title=${JSON.stringify(result.title)}`,
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
