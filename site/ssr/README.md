# Prerendering

Every Docfy route is rendered to static HTML at build time. The browser gets
readable markup immediately, and the Ember app then **rehydrates** it — adopting
the existing DOM instead of rendering a second copy over it.

The client bundle is ~5.6 MB (905 KB gzipped) in one chunk, so this is the
difference between content on screen before that parses and content after.

## The pipeline

`pnpm --filter site build` — the command Netlify runs — is three steps:

```
build:client → vite build                        # browser bundle + shell   → dist/
build:ssr    → vite build --ssr app/ssr-entry.ts # same app, built for Node → dist-ssr/
prerender    → node ssr/prerender.mjs            # 68 x <route>.html        → dist/
```

Both builds come from the same [`vite.config.mjs`](../vite.config.mjs), branching
on Vite's `isSsrBuild`. That is deliberate: the bundle that _generates_ the HTML
and the bundle that _rehydrates_ it must be compiled by the same Ember/babel
stack. If they diverge the serialized markup stops matching what the client
expects — and both builds still succeed, so nothing tells you.

A failed route exits non-zero, so a regression fails the build instead of
silently falling back to the SPA shell.

## Why this works without FastBoot

Server rendering is a first-class `ApplicationInstance` capability:
`isBrowser: false`, a caller-supplied `document`, a `rootElement`, and
`_renderMode`. FastBoot wrapped those in a v1-addon build pipeline that was never
ported to Embroider + Vite. We use the boot options directly.

Two properties of this app make it cheap. Every addon it depends on is a v2
addon, so `dist/@embroider/virtual/vendor.js` is 316 bytes of `EmberENV` with no
AMD payload to evaluate — the app is plain ESM that Vite can bundle for Node. And
the docs are static, so nothing needs per-request rendering.

## Rehydration

Ember **appends** to `rootElement` rather than clearing it. Prerendered HTML plus
an ordinary boot therefore yields two copies of the entire app. Glimmer's
rehydration is what makes prerendering safe rather than actively harmful:

- The server renders with `_renderMode: 'serialize'`, which emits `<!--%+b:0%-->`
  boundary markers alongside the HTML.
- The client boots with `_renderMode: 'rehydrate'`, which walks those markers and
  adopts the existing nodes.

`_renderMode` is reachable only through explicit boot options, and autoboot
passes none (`didBecomeReady` calls `instance._bootSync()` with no arguments), so
a prerendered page cannot use autoboot. [`index.html`](../index.html) picks its
boot path from a marker the prerenderer injects:

```js
if (document.querySelector('meta[name="x-prerendered"]')) {
  const app = Application.create({ ...environment.APP, autoboot: false });
  app.visit(location.pathname + location.search + location.hash, {
    rootElement: document.body,
    _renderMode: 'rehydrate',
  });
} else {
  Application.create(environment.APP); // dev server
}
```

The dev server never sees the marker, so `pnpm start` is unaffected — and equally,
nothing in CI exercises the rehydrate path. See [Gaps](#gaps).

## The Node environment

Rendering needs a DOM in Node. The requirements are narrow but specific:

1. **Parse the built `dist/index.html`.** `app/config/environment.ts` calls
   `loadConfigFromMeta()`, which does
   `document.querySelector('meta[name="site/config/environment"]')` — at _module
   scope_. A parsed shell must be the ambient document before the SSR bundle is
   even imported.
2. **Serialize back to HTML**, markers and all.
3. **Be absent, not half-present**, for anything it does not implement, so
   render-time feature detection in app code behaves.

`linkedom` satisfies all three. `SimpleDOM` — what FastBoot used, and what
ember-source's own docs name — fails (1): no parser, no `querySelector`. That is
why FastBoot rendered into a bare document and string-spliced head and body into
the shell template; parsing the real shell is why nothing here needs to. `jsdom`
satisfies (1) and (2) but not (3): `window.scrollTo` exists and throws
`Not implemented` ~200 times a run, and it is roughly 2x slower.

Two consequences worth knowing:

- linkedom's `window` inherits from `globalThis`, so a global assigned in
  `prerender.mjs` is also visible as `window.foo` inside the app.
- Glimmer calls `document.createRawHTMLSection` for `{{{html}}}`, a SimpleDOM-era
  API no standard DOM has. `createDocument()` shims it.

The global shim list is deliberately short — `self`, plus `CustomEvent`, `Node`
and `Element` from linkedom. A missing global is a `ReferenceError` that fails the
build, never subtly wrong HTML, so the list can stay honest instead of defensive.

Render-time app code must therefore not assume a browser. Two places already
handle this, and new ones should follow the pattern rather than grow the shim
list:

| Where                                                                          | Guard                                                         |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------- |
| [`docfy-theme-switcher.gts`](../app/components/docfy/docfy-theme-switcher.gts) | Skips the `matchMedia` subscription when it is not a function |
| [`app/utils/origin.ts`](../app/utils/origin.ts)                                | `window.location.origin`, falling back to `config.siteURL`    |

`origin.ts` keeps prerendered HTML _correct_, not merely crash-free: pages are
built with the canonical origin and the real one takes over on rehydration, which
is what still lets the version dropdown work on the `next` subdomain.

## Output layout

Routes are written as flat `<route>.html`, not `<route>/index.html`.

Every link the site renders is extensionless and slash-free
(`/docs/components/buttons/button`) — including Docfy index pages, whose URLs do
carry a trailing slash. Netlify's Pretty URLs serve `/foo` from `foo.html`, while
`foo/index.html` answers only at `/foo/`. Directory output therefore puts a 301 in
front of every cold page load and moves the site's canonical URLs.

`netlify.toml`'s SPA catch-all needs no change: a non-forced rewrite cannot shadow
a file that exists, so prerendered pages win and the fallback still covers the
`not-found` route.

`dist-ssr/app-shell.html` is a snapshot of the untouched shell, needed because
prerendering `/` overwrites `dist/index.html` — which would otherwise become the
template for the next run. It lives outside `dist/` so it is never deployed.

## Invariants

Three things in `prerender.mjs` look incidental and are not:

- **Globals are installed before the SSR bundle is imported.** Requirement (1)
  above. A static import, or hoisting the dynamic one, breaks config loading.
- **A fresh document is installed per route.** Render-time code reads bare
  `document` (`docfy-theme-switcher` reads `document.documentElement`), so without
  this every page renders against the bootstrap document.
- **The route loop is sequential.** One `Application`, one run loop and one
  ambient `globalThis.document` are shared, so concurrent renders would read each
  other's document.

## Numbers

- 68 routes in ~2s; full pipeline ~32s.
- Serialize markers add 27-37% to raw HTML and compress away — the largest page is
  621 KB raw, 37 KB gzipped.
- No `<html>` class is baked in, so the inline theme script still chooses
  light/dark at runtime.

## Route splitting

`site/ember-cli-build.js` passes `splitAtRoutes` to `compatBuild`, so everything
under `app/templates/docs/**` loads lazily and the homepage ships without it.
Prerendering and splitting compose: the route bundle is an ordinary dynamic
import that `app.visit()` awaits, and the serialize markers are intact by the
time rehydration walks them.

One interaction needs handling. Rendering a page's sidebar pulls route handlers
for every split route it links to, and `@embroider/router` answers those with
`registerBundle(bundle).then(() => original(name))` — a continuation with no
`isDestroying` guard, unlike `registerBundle` itself. Those chains are not part
of the transition, so `visit()` resolves without them and destroying the instance
immediately makes them throw `Cannot call .lookup('route:…') after the owner has
been destroyed`. The HTML is complete either way, but the errors fail the build.

`render()` therefore snapshots the HTML and awaits `settled()` before returning,
which yields until the run loop, timers and pending requests are quiet — long
enough for those already-resolved imports to finish.

Settling is the right layer, not a workaround for a missing one-line guard.
`registerBundle` already grew an `isDestroying` check (embroider `ac3bd92c`,
"Protect against early destruction"), and that check is precisely what leaves
this exposed: it returns early without setting `entry.loaded`, while the promise
still resolves, so the continuation runs `original(name)` against a destroyed
owner. Adding the same guard to the continuation does not work — returning
`undefined` from `getRoute` breaks router_js, which does
`route._internalName = this.name` on the resolved value. An upstream fix has to
abort the chain rather than resolve it to nothing. Until then, an owner with
in-flight route loads must not be destroyed, which is what `settled()` ensures.

Importing `@ember/test-helpers` for `settled()` costs ~376 KB in the Node bundle
(never shipped) and one shim: it reads `document.location.search` at module
scope, and linkedom supplies no location.

## Prior art: vite-ember-ssr

[evoactivity/vite-ember-ssr](https://github.com/evoactivity/vite-ember-ssr) (npm
`vite-ember-ssr`, experimental) solves this problem as a published, general
package. If the constraint below ever lifts, prefer it over maintaining this.

It arrives at the same mechanism we do — `autoboot: false` plus
`app.visit(url, { _renderMode: 'rehydrate' })`, a page-level flag choosing the
boot path, a snapshot of the shell as a template. Two independent
implementations converging is decent evidence the approach is sound. Beyond that
it does considerably more: request-time SSR and dev-mode SSR as well as SSG, a
tinypool worker pool with optional process isolation, a shoebox that captures
server `fetch` responses and replays them during rehydration, Playwright
coverage, and benchmarks. It renders with happy-dom.

**We cannot use it here: it targets compatless apps only** — no
`@embroider/compat`, no `ember-cli-build.js`, no `classicEmberSupport()`. This
site is all three, and `ember-resolver` with `compatModules` rather than
`ember-strict-application-resolver`. The blocker that matters most is indirect:
`splitAtRoutes` lives only in `@embroider/compat`, so going compatless to adopt
this would also give up route splitting. Smaller friction: its SSG takes a
static `routes` array in the Vite config, while ours are derived from the
`docfy-urls.json` that Docfy emits during the build.

Two notes for a future revisit:

- Its SSG writes `<route>/index.html`, the convention that 301s every cold load
  on Netlify (see [Output layout](#output-layout)). Ember's `LinkTo` emits
  slash-free hrefs, so this likely affects any Ember app deployed there — worth
  raising upstream rather than rediscovering.
- `settled()` from `@ember/test-helpers` is how it waits for a render to finish.
  We now do the same — see [Route splitting](#route-splitting). Worth knowing that
  test waiters compile to no-ops outside a development build, so in a production
  SSR bundle `settled()` is waiting on the run loop, timers and requests, not on
  waiters.

## Gaps

- **Nothing in CI runs the prerender or the rehydrate path.** CI runs `pnpm build`
  (addons) and the test suites, never `pnpm --filter site build`, so the only
  signal is a Netlify deploy. An Ember bump that changed `_renderMode` would ship
  two copies of the app with CI green.
- `<meta name="description">` is the shell's on every page; titles are per-page
  because ember-page-title runs server-side. No canonical or per-page OG tags.
- Only static routes; the `not-found` wildcard is deliberately not prerendered.
- No dev-mode SSR, so SSR breakage only surfaces from the full two-build pipeline.
