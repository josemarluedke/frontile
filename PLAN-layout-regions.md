# Layout Regions Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let any template, including a route template inside `{{outlet}}`, render a block into a named region of the mounted `AppLayout`, and let the aside be filled the same way.

**Architecture:** An internal service holds, per region name, the target element and an ordered list of sources as tracked state. `layout.Region` and a route-driven `layout.Aside` register an element as the target; `InLayoutRegion` registers as a source and renders its block with `{{in-element}}`. Every write to the tracked state is deferred with `schedule('afterRender', …)`, which re-renders once in the same runloop.

**Tech Stack:** Ember 7.4 / Glimmer components in `.gts`, `ember-modifier`, `@ember/runloop`, tailwind-variants via `@frontile/theme`, QUnit with `@ember/test-helpers`.

**Spec:** `SPEC-layout-regions.md` (repo root). Read it first. Prototype 1 is the reference implementation: branch `origin/proto/layout-regions`, read files with `git show "origin/proto/layout-regions:<path>"`.

## Global Constraints

- Work on a new branch `feat/layout-regions` cut from `origin/main`, in its own worktree. Never push to `main`. The working tree this plan was written in is a different prototype branch; do not build on it. Copy `SPEC-layout-regions.md` and this file into the new worktree and commit them with Task 1.
- A fresh worktree needs `CI=true pnpm install` and `pnpm build` before anything runs.
- Stage files by name. Never `git add -A` or `git add .`.
- Tests first: every test in a task is written and seen failing before its implementation.
- Run tests with `cd test-app && CI=true pnpm ember test --filter="<name>"`. Chrome needs the command sandbox disabled.
- After changing `packages/theme`, run `pnpm --filter @frontile/theme build`. After changing `packages/frontile`, run `pnpm --filter "frontile..." build` before running tests.
- Before each commit: `pnpm lint:js --fix`, `pnpm lint:hbs` (never with `--fix`), `pnpm --filter frontile lint:types`, `cd test-app && pnpm lint:types`.
- Components are `.gts`. Import helpers explicitly. No `eq` helper.
- No `:has()` selectors and no `<script>` marker elements.
- No wrapper element around a source's content and none where the source sits.
- Only public Ember API.
- Names are fixed: source component `InLayoutRegion`, target `layout.Region`, aside argument `@region`, service key `frontile-layout-regions`, theme slot `region` with class `contents`.
- No breadcrumb helper, no `layout.Breadcrumbs`, no `registerLayout`, no synchronous test mode in the service.

## Review Focus

1. **A loading state between two routes that fill the aside, at `lg` and up.** The region goes 1 → 0 → 1. The panel must be open again afterwards. Test in Task 4.
2. **A parent route that puts `InLayoutRegion` after `{{outlet}}`.** The parent's content covers the child's. Nothing breaks, but the docs must say so. Test pins the behaviour in Task 1; docs in Task 6.
3. **A region name with no target (typo).** Nothing renders and a development warning names the region. Test in Task 2.
4. **The aside crossing `lg` while filled and open.** Content moves between the column and the drawer, is never rendered twice, and no duplicate-target warning fires. Tests in Tasks 2 and 3.
5. **A source removed while the layout is being torn down.** No error and no write to a destroyed service. Test in Task 1.

---

### Task 1: Registry service, `layout.Region` and `InLayoutRegion`

**Files:**
- Create: `packages/frontile/src/services/frontile-layout-regions.ts`
- Create: `packages/frontile/src/components/layout/region.gts`
- Create: `packages/frontile/src/components/layout/in-layout-region.gts`
- Modify: `packages/frontile/package.json` (`ember-addon.app-js`, next to the `notifications` entry)
- Modify: `packages/frontile/src/components/layout/index.ts`
- Modify: `packages/frontile/src/components/layout/app-layout.gts` (signature block near line 170 of the yielded hash type; `hash` near line 668)
- Modify: `packages/theme/src/components/app-layout.ts` (after `asideToggle`, line 350)
- Test: `test-app/tests/integration/components/layout/regions-test.gts`

**Interfaces:**
- Produces, in `services/frontile-layout-regions.ts`:

```ts
export class LayoutRegionState {
  @tracked target: Element | null;
  @tracked multiple: boolean;
  @tracked sources: readonly object[]; // reassigned, never mutated
  declared: boolean;                   // untracked
  get hasContent(): boolean;
  targetFor(source: object): Element | null; // null when not shown
}
export default class FrontileLayoutRegionsService extends Service {
  region(name: string): LayoutRegionState;      // created on first use
  hasContent(name: string): boolean;
  declare(name: string): void;                  // synchronous, sets `declared`
  registerTarget(name: string, element: Element, options?: { multiple?: boolean }): () => void;
  addSource(name: string, source: object): () => void;
  onEmpty(name: string, listener: () => void): () => void;
}
// declare module '@ember/service' { interface Registry { 'frontile-layout-regions': … } }
```

- Produces: `Region` (`RegionSignature`, `RegionArgs`: `name: string`, `multiple?: boolean`, internal `layout?: AppLayoutContext`; `Element: HTMLDivElement`; default block is the fallback) and `InLayoutRegion` (`InLayoutRegionSignature`, `InLayoutRegionArgs`: `name: string`; default block; no `Element`).
- Produces: `AppLayout` yields `Region` as `WithBoundArgs<typeof Region, 'layout'>`.

Start from prototype 1's `services/app-layout.ts`, `components/layout/region.gts` and `components/layout/layout-region.gts`. Differences from the prototype:

- Drop `registerLayout`, `layout`, all breadcrumb members, and `syncWritesForTesting`. `#write` always schedules.
- Add `declared` and `declare(name)`. `Region` calls `declare(@name)` in its constructor.
- The service is injected as `@service('frontile-layout-regions')`.
- The source component is named `InLayoutRegion`.

- [ ] **Step 1: Write the failing tests**

Module `Integration | Layout regions | frontile/layout`. Port these from prototype 1's `regions-test.gts`, renaming `LayoutRegion` to `InLayoutRegion` and the service lookup to `service:frontile-layout-regions`:

| Test name | Key assertions |
| --- | --- |
| `a source renders its block into the target with no wrapper` | the button's `parentElement` is `[data-region="actions"]`; nothing renders at the source's position |
| `order independence: the target may mount after the source` | content appears after the target is toggled in; survives toggling the target out and in again |
| `the source may also sit before the layout in the tree` | content is in the target |
| `stacking: the most recent source wins, and an exit restores the previous` | only the child's content while both exist; the parent's again after the child is removed |
| `@multiple accumulates every source in render order` | both blocks present, in order |
| `a target renders its own block while no source fills it` | fallback shown while empty, gone while filled, back when emptied |
| `data-has-content reflects whether a source fills the region` | attribute is `"false"` then `"true"` |
| `the deferred fill lands in the same runloop` | content is in the DOM synchronously after `run(() => …)` returns |

New tests:

```gts
test('a source placed after a later-rendered sibling source covers it', async function (assert) {
  // parent source rendered AFTER the child source: the parent wins.
  await render(<template>
    <AppLayout as |layout|>
      <layout.Navbar><layout.Region @name="actions" /></layout.Navbar>
      <layout.Main>
        <InLayoutRegion @name="actions"><span data-test-child /></InLayoutRegion>
        <InLayoutRegion @name="actions"><span data-test-parent /></InLayoutRegion>
      </layout.Main>
    </AppLayout>
  </template>);
  assert.dom('[data-region="actions"] [data-test-parent]').exists();
  assert.dom('[data-test-child]').doesNotExist();
});

test('tearing down the layout and its sources together does not throw', async function (assert) {
  // render layout + source inside {{#if show.current}}, then set false.
  // Assert the render settles and `[data-region]` is gone.
});
```

- [ ] **Step 2: Run them and confirm they fail**

Run: `cd test-app && CI=true pnpm ember test --filter="Layout regions"`
Expected: FAIL at import, `InLayoutRegion` is not exported from `frontile`.

- [ ] **Step 3: Add the theme slot**

In `packages/theme/src/components/app-layout.ts`, after `asideToggle`: `region: 'contents'`, with a comment that the region's children lay out as children of its parent. Build the theme.

- [ ] **Step 4: Implement the service, `Region`, `InLayoutRegion`, the exports and the yield**

- `package.json` `app-js`: `"./services/frontile-layout-regions.js": "./dist/_app_/services/frontile-layout-regions.js"`.
- `index.ts`: export `Region`, `RegionSignature`, `RegionArgs`, `InLayoutRegion`, `InLayoutRegionSignature`, `InLayoutRegionArgs`. Do not export the service from a barrel.
- `Region` template: `<div data-part="region" data-region={{@name}} data-has-content={{…"true"|"false"}} class={{…styles.region}} {{this.register @name @multiple}} ...attributes>{{#unless this.hasContent}}{{yield}}{{/unless}}</div>`.
- Every argument gets JSDoc; it generates the docs API table.

- [ ] **Step 5: Build and run the tests**

Run: `pnpm --filter "frontile..." build && cd test-app && CI=true pnpm ember test --filter="Layout regions"`
Expected: all Task 1 tests PASS.

- [ ] **Step 6: Lint, type-check, commit**

```bash
git add SPEC-layout-regions.md PLAN-layout-regions.md packages/frontile/package.json packages/frontile/src/services/frontile-layout-regions.ts packages/frontile/src/components/layout/region.gts packages/frontile/src/components/layout/in-layout-region.gts packages/frontile/src/components/layout/index.ts packages/frontile/src/components/layout/app-layout.gts packages/theme/src/components/app-layout.ts test-app/tests/integration/components/layout/regions-test.gts
git commit -m "feat(layout): add layout regions (Region, InLayoutRegion)"
```

---

### Task 2: Development warnings

**Files:**
- Modify: `packages/frontile/src/services/frontile-layout-regions.ts`
- Test: `test-app/tests/integration/components/layout/regions-test.gts`

**Interfaces:**
- Consumes: `LayoutRegionState.declared`, `addSource`, `registerTarget` from Task 1.
- Produces: two `warn()` calls from `@ember/debug`, ids `frontile.layout-region.undeclared` and `frontile.layout-region.duplicate-target`.

- [ ] **Step 1: Write the failing tests**

Capture warnings with `registerWarnHandler` from `@ember/debug`, collecting `options.id`; restore the previous handler in `afterEach`.

```gts
test('warns once when a source names a region nothing declares', …)
// render two <InLayoutRegion @name="actoins"> with a layout that only has "actions".
// assert exactly one warning with id frontile.layout-region.undeclared,
// and its message contains "actoins".

test('does not warn when the target is declared in the same render, in any order', …)
// source before the layout in the tree: zero warnings.

test('warns when a second live target registers for the same name', …)
// two <layout.Region @name="actions" /> in one layout:
// one warning with id frontile.layout-region.duplicate-target.
```

- [ ] **Step 2: Run them and confirm they fail**

Run: `cd test-app && CI=true pnpm ember test --filter="Layout regions"`
Expected: the three new tests FAIL with zero warnings collected.

- [ ] **Step 3: Implement**

- Undeclared: inside the deferred callback of `addSource`, if `!region.declared` and this name has not been warned about, call `warn`. Declarations are synchronous in constructors, so every target rendered in the same render has declared by then. Keep a `Set<string>` of warned names.
- Duplicate target: inside the deferred callback of `registerTarget`, warn if `region.target` is set, is not `element`, and `region.target.isConnected`. The `isConnected` check is what keeps the aside's move between column and drawer silent. The newest target still wins.
- `warn(message, false, { id })` is a no-op in production builds; no extra guard.

- [ ] **Step 4: Build and run the tests**

Run: `pnpm --filter "frontile..." build && cd test-app && CI=true pnpm ember test --filter="Layout regions"`
Expected: PASS.

- [ ] **Step 5: Lint, type-check, commit**

```bash
git add packages/frontile/src/services/frontile-layout-regions.ts test-app/tests/integration/components/layout/regions-test.gts
git commit -m "feat(layout): warn about undeclared regions and duplicate targets"
```

---

### Task 3: Route-driven aside (`@region`)

**Files:**
- Modify: `packages/frontile/src/components/layout/aside.gts`
- Modify: `packages/frontile/src/components/layout/context.ts` (`registerAside`, new `RegisteredAside`)
- Modify: `packages/frontile/src/components/layout/app-layout.gts` (`asidePart` line 354, `registeredAside` line 368, context `hasAside` line 600)
- Test: `test-app/tests/integration/components/layout/regions-test.gts`
- Test: `test-app/tests/integration/components/layout/aside-test.gts` (must stay green, unchanged)

**Interfaces:**
- Consumes: `declare`, `registerTarget`, `hasContent` from Task 1.
- Produces:

```ts
// context.ts
export interface RegisteredAside { readonly available?: boolean } // omitted = true
registerAside(aside: RegisteredAside): () => void;
// aside.gts, new argument
/** Fill the aside from `InLayoutRegion @name=<this>` instead of its block. Read once. */
region?: string;
// Aside getters
get hasContent(): boolean; // true without @region
get available(): boolean;  // = hasContent
```

- `AppLayout.hasAside` becomes `registeredAside !== undefined && (registeredAside.available ?? true)`; the context's `hasAside` returns it.

Reference: prototype 1's `aside.gts` diff. Do not port its `onEmpty` subscription here; that is Task 4.

- [ ] **Step 1: Write the failing tests**

Use `mockMatchMedia(1200)` for `lg` and up and `mockMatchMedia(500)` below, from `test-app/tests/helpers/match-media`, restored in `afterEach` as `aside-test.gts` does.

| Test name | Key assertions |
| --- | --- |
| `a route-driven aside: no column or toggle while nothing fills it` | with `@defaultAsideOpen={{true}}` and no source: no `[data-part="aside"]`, no `[data-part="aside-toggle"]`; after a source appears both exist and the content's parent is the `<aside>` |
| `the aside stays open when another source replaces the current one` | swap source A for B in one render: aside still present, shows B only |
| `below lg the content follows the target into the drawer` | at 1200 content is in `[data-part="aside"]`; after `media.setWidth(500)` and reopening it is in `[data-part="mobile-aside"]`; content exists exactly once at every step |
| `below lg an empty route-driven aside renders no drawer` | `@defaultAsideOpen={{true}}`, no source, width 500: no `[role="dialog"]` |
| `crossing lg while filled raises no duplicate-target warning` | zero warnings collected |
| `an Aside without @region is unchanged, with or without a block` | blockless `<layout.Aside />` with `asideOpen` renders an empty `[data-part="aside"]` and the toggle is shown |
| `a standalone Aside with @region and @state is filled by a source` | outside `AppLayout`: content's parent is the `<aside>` |

- [ ] **Step 2: Run them and confirm they fail**

Run: `cd test-app && CI=true pnpm ember test --filter="Layout regions"`
Expected: new tests FAIL; the route-driven ones because the aside renders an empty panel and the toggle is shown.

- [ ] **Step 3: Implement**

- `Aside` constructor: when `@region` is set, call `declare(region)`.
- Template: wrap the existing branches in `{{#if this.hasContent}}`. In each branch, when `@region` is set render the `<aside>` with a target modifier (`registerTarget(region, element)`) and no `{{yield}}`; otherwise the element exactly as on `main`.
- `Aside` passes itself to `registerAside`, so `available` is read from it.

- [ ] **Step 4: Build and run the tests**

Run: `pnpm --filter "frontile..." build && cd test-app && CI=true pnpm ember test --filter="layout"`
Expected: PASS, including every existing test in `aside-test.gts` and `app-layout-test.gts`.

- [ ] **Step 5: Lint, type-check, commit**

```bash
git add packages/frontile/src/components/layout/aside.gts packages/frontile/src/components/layout/context.ts packages/frontile/src/components/layout/app-layout.gts test-app/tests/integration/components/layout/regions-test.gts
git commit -m "feat(layout): fill the aside from a region with @region"
```

---

### Task 4: What an emptied aside does to its open state

**Files:**
- Modify: `packages/frontile/src/components/layout/aside.gts`
- Test: `test-app/tests/integration/components/layout/regions-test.gts`

**Interfaces:**
- Consumes: `onEmpty(name, listener)` from Task 1; `Aside.inDrawer` and `state.closeAside()` (existing).
- Produces: no new names.

Rule from the spec: when the region loses its last source, call `state.closeAside()` only if the aside is in the drawer (`inDrawer`, i.e. below `lg`) at that moment. At `lg` and up, write nothing.

- [ ] **Step 1: Write the failing tests**

| Test name | Setup | Assertions |
| --- | --- | --- |
| `at lg and up an emptied aside keeps asideOpen and is open again when refilled` | width 1200, uncontrolled, toggle open, remove the source, add it back | while empty: no aside, `layout.state.asideOpen` is `true`; after refill: `[data-part="aside"]` exists without clicking the toggle |
| `at lg and up a pass through empty between two sources leaves the panel open` | source A removed in one render, source B added in a later render | aside exists with B's content |
| `below lg an emptied aside closes and stays closed` | width 500, open the drawer, remove the source, add it back | no `[role="dialog"]` after refill; `asideOpen` is `false` |
| `@defaultAsideOpen opens a route-driven aside on its first fill` | width 1200, `@defaultAsideOpen={{true}}`, source added later | no aside before; aside exists after, no click |
| `controlled @asideOpen is told to close only below lg` | `@asideOpen={{true}}` with a recording `@onAsideOpenChange`; empty at 1200, then at 500 | zero calls at 1200; one call with `false` at 500 |

- [ ] **Step 2: Run them and confirm they fail**

Run: `cd test-app && CI=true pnpm ember test --filter="Layout regions"`
Expected: the two "below lg" tests FAIL (the drawer reopens on refill; no callback).

- [ ] **Step 3: Implement**

In the `Aside` constructor, when `@region` is set: `registerDestructor(this, this.regions.onEmpty(region, () => { if (this.inDrawer) this.state.closeAside(); }))`.

- [ ] **Step 4: Build and run the tests**

Run: `pnpm --filter "frontile..." build && cd test-app && CI=true pnpm ember test --filter="layout"`
Expected: PASS.

- [ ] **Step 5: Lint, type-check, commit**

```bash
git add packages/frontile/src/components/layout/aside.gts test-app/tests/integration/components/layout/regions-test.gts
git commit -m "feat(layout): close an emptied aside drawer, keep the inline panel's state"
```

---

### Task 5: Nested routes in the test app and acceptance tests

**Files:**
- Modify: `test-app/app/router.js`
- Create: `test-app/app/templates/regions-demo.gjs`, `regions-demo/index.gjs`, `regions-demo/orders.gjs`, `regions-demo/orders/index.gjs`, `regions-demo/orders/show.gjs`
- Create: `test-app/app/routes/regions-demo/orders/show.ts`
- Test: `test-app/tests/acceptance/layout-regions-routing-test.gts`

**Interfaces:**
- Consumes: `AppLayout`, `InLayoutRegion`, `layout.Region`, `layout.Aside @region` from Tasks 1 to 4.
- Produces: routes `regions-demo` (index has no sources), `regions-demo.orders`, `regions-demo.orders.show` at `/regions-demo/orders/:order_id`.

Port from prototype 1's files of the same names. Remove every `{{breadcrumb}}` and `layout.Breadcrumbs`, rename the source component, use `<layout.Aside @region="aside" />` and `<InLayoutRegion @name="aside">`. In `orders.gjs` the sources come before `{{outlet}}`. A `.gjs` file must not start with a `{{! }}` comment; use `//`.

- [ ] **Step 1: Write the failing tests**

Module `Acceptance | Layout regions routing`, width 1200 via `mockMatchMedia`.

```gts
test('nested routes stack navbar actions and the aside', async function (assert) {
  await visit('/regions-demo/orders');
  // actions region shows the orders action; aside toggle exists.
  await click('[data-part="aside-toggle"]');
  // aside shows the orders content.
  await visit('/regions-demo/orders/1');
  // actions region shows only the order action; aside still open, shows order 1.
  await visit('/regions-demo/orders');
  // orders action and orders aside content are back; aside still open.
  await visit('/regions-demo');
  // no aside, no toggle, actions region shows its fallback.
  await visit('/regions-demo/orders');
  // aside is open again without clicking (option C at lg and up).
});

test('a deep link renders the child route content on first render', async function (assert) {
  await visit('/regions-demo/orders/7');
  // actions region shows the order action for 7; no orders-level action.
});
```

Fill in each comment with `assert.dom(...)` calls against `data-test-*` attributes you put in the templates.

- [ ] **Step 2: Run them and confirm they fail**

Run: `cd test-app && CI=true pnpm ember test --filter="Layout regions routing"`
Expected: FAIL, route `regions-demo` not found.

- [ ] **Step 3: Add the routes and templates**

- [ ] **Step 4: Run the acceptance tests, then the full suite**

Run: `cd test-app && CI=true pnpm ember test`
Expected: 0 failures.

- [ ] **Step 5: Lint, type-check, commit**

```bash
git add test-app/app/router.js test-app/app/templates/regions-demo.gjs test-app/app/templates/regions-demo test-app/app/routes/regions-demo test-app/tests/acceptance/layout-regions-routing-test.gts
git commit -m "test(layout): cover layout regions over nested routes"
```

---

### Task 6: Documentation and the server-rendering check

**Files:**
- Modify: `packages/frontile/src/components/layout/app-layout.md`

**Interfaces:**
- Consumes: everything above.

Use the `frontile-contributor-docs` skill in this repo for the house style.

- [ ] **Step 1: Write the "Regions" section**

Placed after the "Aside" section. It covers, each with the spec's wording as the source of truth:
- `layout.Region` as target and `InLayoutRegion` as source, with one live demo.
- The fallback block and `@multiple`.
- Stacking: the newest-rendered source wins; a parent route puts its `InLayoutRegion` before `{{outlet}}`; a parent source that re-renders while a child is active covers the child.
- Region names are global to the app; one `AppLayout` at a time.
- Region content is rebuilt, losing its state, when its target moves.
- Add `Region` to the parts table near line 83.

Every live demo on this page uses region names no other demo uses (`demo-actions`, `demo-aside`), because the page mounts many layouts.

- [ ] **Step 2: Write the route-driven subsection under "Aside"**

- `@region`, filled with `<InLayoutRegion @name="…">`, one live demo.
- No column and no `AsideToggle` while empty.
- Open state: persists across routes that fill it; at `lg` and up an emptied aside is hidden and comes back open; below `lg` the drawer closes and stays closed; `@defaultAsideOpen` opens on the first fill.
- The limit: below `lg`, a loading state between two sibling routes that each fill the aside closes the drawer; fill it from a shared parent route to avoid that.

- [ ] **Step 3: Build the site, which prerenders every page on the server**

Run: `pnpm build && cd site && pnpm build`
Expected: completes with no error. A failure in `prerender` on the app-layout page is a defect in Tasks 1 to 4 (something touched the DOM or threw on the server); fix it there, with a test if one can be written.

- [ ] **Step 4: Check the two demos in a browser and record the server result**

Run the site (`cd site && pnpm start`), open the AppLayout page, and confirm both demos show their region content and the console has no errors or warnings. Then open the prerendered HTML for that page and see whether the region content is present in it. Add one "Server rendering" paragraph to the Regions section stating what you observed: either region content is rendered on the client after hydration, or it is in the server HTML and rebuilt on hydration.

- [ ] **Step 5: Run the site tests**

Run: `cd site && pnpm vite build --mode development && pnpm testem ci --port 7412`
Expected: 0 failures.

- [ ] **Step 6: Commit**

```bash
git add packages/frontile/src/components/layout/app-layout.md
git commit -m "docs(layout): document layout regions and the route-driven aside"
```

---

## After the last task

Run the whole pre-commit checklist from `CLAUDE.md` once more on the branch, then open a pull request against `main`. Its description links the spec and prototype PRs #650 and #677.
