# Prerendering the site with Vite SSR

Every docs route is prerendered to static HTML at build time, and the client
**rehydrates** the existing DOM instead of re-rendering over it.

All 68 routes prerender in ~2s; the whole `pnpm --filter site build` pipeline
takes ~32s.

## Why not FastBoot

FastBoot is a dead end here. `ember-cli-fastboot` is a v1 ember-cli addon that
needs its own broccoli-driven `fastboot/` build tree; that integration was never
ported to Embroider + Vite ([embroider#112], [embroider#2035]). The Ember Core
Tooling Team's stated migration path is to deprecate `ember-cli-fastboot` and
`fastboot-app-server` in favour of **Vite's own SSR**, which is what this does.

Nothing in `ember-source` had to be worked around. Ember 6.6 still fully
supports server rendering through `ApplicationInstance` boot options —
`isBrowser: false`, a custom `document`, `rootElement`, and the private
`_renderMode` flag that selects Glimmer's `serializeBuilder` /
`rehydrationBuilder` instead of the normal `clientBuilder`. FastBoot was only
ever a wrapper around those.

[embroider#112]: https://github.com/embroider-build/embroider/issues/112
[embroider#2035]: https://github.com/embroider-build/embroider/issues/2035

## Why this is easy for _this_ site

Every addon the site depends on — `@docfy/ember`, `ember-page-title`,
`ember-modifier`, `@embroider/router`, `tracked-built-ins`,
`ember-cli-deprecation-workflow`, and all the `frontile` packages — is a **v2
addon**. `ember-resolver` and `ember-load-initializers` are plain npm packages.
The only v1 addon is `ember-auto-import`, which is build-time only.

The consequence: `dist/@embroider/virtual/vendor.js` is **316 bytes** — just
`window.EmberENV = {...}` and `var runningTests = false`. There is no AMD/loader
payload to evaluate, which is why this needs no `vm` sandbox and no script
evaluation ordering games. The whole app is real ESM that Vite bundles for Node
directly.

## Layout

| File                                            | Role                                                                                                                                       |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| [`app/ssr-entry.ts`](../app/ssr-entry.ts)       | Exports `render(url, document)`. Boots the app once, builds a fresh `ApplicationInstance` per route, visits, serializes.                   |
| [`vite.config.mjs`](../vite.config.mjs)         | One config for both builds. Shared plugin stack; `isSsrBuild` adds `outDir: dist-ssr` + `ssr.noExternal` and drops Tailwind/static-export. |
| [`prerender.mjs`](./prerender.mjs)              | Installs browser-ish globals, imports that bundle, loops `dist/docfy-urls.json`, writes `dist/<route>.html`.                               |
| [`app/utils/origin.ts`](../app/utils/origin.ts) | `window.location.origin` with a config-driven fallback for Node.                                                                           |

`pnpm --filter site build` — the command Netlify runs — chains all three:

```
build        → build:client && build:ssr && prerender
build:client → vite build                                # dist/
build:ssr    → vite build --ssr app/ssr-entry.ts           # dist-ssr/
prerender    → node ssr/prerender.mjs                     # 68 × <route>.html into dist/
```

For a fast iteration loop, `prerender.mjs` takes route arguments:

```bash
node ssr/prerender.mjs / /docs/components/forms/input
```

A failed route sets a non-zero exit code, so a prerender regression fails the
build instead of silently falling through to the SPA shell.

## Implementation notes

### The DOM

`linkedom` (fast, no layout engine), plus one shim: Glimmer still calls the
SimpleDOM-era `document.createRawHTMLSection` for `{{{html}}}`.

The shim list is deliberately tiny — `self`, and `CustomEvent` / `Node` /
`Element` taken from linkedom. Each was verified necessary by removing it and
watching the build fail, and the resulting 68-page output is byte-for-byte
identical (modulo asset hashes) to a run with a much longer list. Everything else
that was once shimmed here — `navigator`, `localStorage`, `sessionStorage`,
`Event`, `HTMLElement`, `Text`, `Comment`, `DocumentFragment`, `MutationObserver`,
`requestAnimationFrame`, `matchMedia` — turned out to be unnecessary, and a
missing global fails loudly with a `ReferenceError` at build time rather than
producing subtly wrong HTML. So the list can stay honest instead of defensive.

They must come from linkedom rather than Node's built-ins: linkedom's
`dispatchEvent` writes `event.eventPhase`, which is getter-only on a native
`Event`, so a `new CustomEvent(...)` resolving to Node's version throws on
dispatch. linkedom's `window` inherits from `globalThis`, which is why assigning
here is also what makes a bare `window.foo` resolve inside the app.

`matchMedia` used to be shimmed for `docfy-theme-switcher`, which called
`window.matchMedia` from its constructor — i.e. during render. It now guards that
call instead: following the OS colour-scheme preference only means anything in a
live browser, so the subscription is skipped server-side. Same pattern as the
`FileList` and `window.location` fixes — fix the render-time code, drop the shim.

`installDocument()` is called again for every route, and that reassignment of
`globalThis.document` _is_ load-bearing: `docfy-theme-switcher` reads a bare
`document.documentElement`, so without it every page would be rendered against
the bootstrap document instead of its own. Verified by removing it — the output
changes.

The route loop is sequential by necessity: every render shares one Ember
`Application`, one run loop, and the ambient `globalThis.document`, so two
in-flight renders would read each other's document. Real parallelism would need
worker processes, and at ~2s for the whole pass that is a clear loss.

### App config

`app/config/environment.ts` calls `loadConfigFromMeta('site')`, which reads a
`<meta name="site/config/environment">` tag at **module scope**. So
`globalThis.document` must already hold the parsed `dist/index.html` before the
SSR bundle is imported — that ordering in `prerender.mjs` is load-bearing.

The same meta tag is where `EmberENV` comes from, rather than being restated in
the driver. Otherwise the prerender could boot Ember under different feature
flags than the client bundle that rehydrates its output, and the symptom would be
a rehydration mismatch rather than a config error.

### Rehydration

This is the part that makes prerendering usable rather than actively harmful.

Ember does _not_ clear `rootElement` on boot — `renderer.appendTo` appends. So
prerendered HTML plus a normal boot yields **two copies of the whole app**. The
fix is Glimmer's rehydration:

- The server renders with `_renderMode: 'serialize'`, emitting `<!--%+b:0%-->`
  boundary markers.
- The client boots with `_renderMode: 'rehydrate'`, which walks those markers and
  adopts the existing DOM instead of building new nodes.

`_renderMode` is only reachable through explicit boot options, and **autoboot
provides no way to pass them** (`didBecomeReady` calls `instance._bootSync()`
with no arguments). So [`index.html`](../index.html) switches on the marker meta
tag the prerenderer injects:

```js
if (document.querySelector('meta[name="x-prerendered"]')) {
  const app = Application.create({ ...environment.APP, autoboot: false });
  app.visit(location.pathname + location.search + location.hash, {
    rootElement: document.body,
    _renderMode: 'rehydrate',
  });
} else {
  Application.create(environment.APP); // dev server, unchanged
}
```

### Origin-dependent rendering

`version-dropdown` and `docfy-copy-page` need the current origin, which does not
exist while prerendering. Both now go through `currentOrigin()`, which falls back
to `config.siteURL` (`https://frontile.dev`, overridable via `SITE_URL`). That
keeps the prerendered HTML _correct_, not merely crash-free; when the app
rehydrates, the real `window.location.origin` takes over, which is what makes the
version dropdown still work on the `next` subdomain.

## Numbers

- **68 routes in ~2.1s** (13–100ms each); full build pipeline ~32s.
- Client JS is **5.6 MB raw / 905 KB gzipped in a single chunk**. That is the
  point: readable content now paints before any of it parses.
- Serialize markers add 27–37% to raw HTML but are highly repetitive, so they
  compress away. Worst page (Table) is 621 KB raw → **37 KB gzipped**.
- No `<html>` class is baked in, so the inline theme script still picks
  light/dark at runtime — no new FOUC.

## Deployment

`netlify.toml`'s catch-all needs **no change**. Per Netlify's docs, "By default,
you can't shadow a URL that actually exists within the site" — a non-forced
`/* -> /index.html 200` rewrite only fires for paths with no matching file. So
prerendered pages win, and the SPA fallback still covers everything else,
including the `not-found` catch-all route.

Routes are written as flat `<route>.html` files, not `<route>/index.html`. Every
link the site renders is extensionless and slash-free
(`/docs/components/buttons/button` — and that holds for Docfy index pages too,
whose URLs _do_ carry a trailing slash). Netlify's Pretty URLs serve `/foo`
straight from `foo.html`, whereas `foo/index.html` is only reachable at `/foo/`.
Directory output therefore put a 301 in front of every cold page load and quietly
moved the site's canonical URLs — verified on the deploy preview for #500 before
switching to flat files.

`app-shell.html` (the pristine template snapshot, needed because prerendering `/`
overwrites `dist/index.html`) is written to `dist-ssr/`, not `dist/`, so it is
never deployed.

## Known gaps

- **`<meta name="description">` is still the generic shell one on every page.**
  Titles are per-page (ember-page-title runs server-side fine); descriptions are
  not. Biggest remaining SEO win, and the Docfy frontmatter is right there.
- No canonical URL or per-page Open Graph tags.
- Only static routes are prerendered; the `not-found` wildcard deliberately is
  not.
- No dev-mode SSR. Not needed for prerendering, but it means SSR breakage only
  shows up when the full two-build pipeline runs.

## Prior art

- [kmccullough/vite-ember-ssr-example](https://github.com/kmccullough/vite-ember-ssr-example)
  and its `vite-ember-ssr-server` — a fuller _request-time_ SSR server that ports
  FastBoot's `vm`-sandbox-per-request model to Vite. Useful reference (the
  `createRawHTMLSection` shim and the linkedom choice came from reading it), but
  far more machinery than build-time prerendering needs.
- [prember](https://github.com/ef4/prember) — the classic prerender-at-build-time
  addon, but built on FastBoot, so the same dead end.
