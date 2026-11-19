# Prototype 2: `AppLayout` regions without `afterRender`

Branch `proto/layout-regions-portals`, cut from `main` at `183a78d2` (v0.18.12).
Throwaway code written to answer design questions; not for merge. Every new
symbol is marked `PROTOTYPE`. Breadcrumbs are out of scope.

The first prototype is `proto/layout-regions` (PR #650) and its write-up is
`PROTOTYPE-layout-regions.md` on that branch.

## The design in one paragraph

A region is **a DOM element the layout owns**, one per name, created the
first time anyone asks for it. A source (`<InRegion @name="actions">`)
renders its block into that element with `{{in-element}}`. A display site
(`<layout.Region @name="actions" />`, or a blockless `<layout.Aside />`)
puts the element in the page by rendering it as content: `{{this.element}}`.
The two sides never register with each other. "Does this region have
content" is answered by CSS `:has()`, reading a `<script>` marker each
source leaves where it is written. No tracked state, no service, nothing
scheduled.

| Piece | File |
| --- | --- |
| `LayoutRegions` (the elements, a plain source count) | `packages/frontile/src/components/layout/regions.ts` |
| `InRegion @name` (source) | `components/layout/in-region.gts` |
| `layout.Region @name @multiple` (display site, block is the fallback) | `components/layout/region.gts` |
| blockless `layout.Aside` shows the `aside` region | `components/layout/aside.gts` |
| `AsideToggle` always renders; CSS hides it | `components/layout/aside-toggle.gts` |
| CSS rules (`base`, `region`, `regionContent`, `regionFallback` slots) | `packages/theme/src/components/app-layout.ts` |
| Demo routes `/regions-demo` → `orders` → `orders/:order_id` | `test-app/app/templates/regions-demo*` |

## Why not the existing `Portal` + `PortalTarget`

I tested the pair as it is, as the region mechanism
(`regions-portal-experiment-test.gts`, 4 tests, all measured):

- A target written **before** the source is filled in the first pass. This
  is the navbar case and it works.
- A target written **after** the source (an `Aside` after `Main`) is missed.
  The content falls through to the default container, outside the layout.
- A target that **appears later** (the aside opening) is never found.
- A target that is **rebuilt** (inline column to drawer) loses the content.

The cause is one thing: `Portal` finds its target with an untracked DOM read
during render, once. Making that read reactive means a tracked value the
target writes and the source reads. With the target after the source in the
template, that is the backtracking assertion again.

The prototype keeps what is good about a portal (`{{in-element}}`, a marker
to find the layout by walking up the DOM) and removes the lookup of a
*rendered* target. The target is not rendered by anyone; it exists before
both sides.

## Comparison with the first prototype

### Backtracking and scheduling

| | Prototype 1 | Prototype 2 |
| --- | --- | --- |
| Writes during render | every register/unregister, deferred with `schedule('afterRender')` | none |
| Render passes to fill a region | 2 | 1 |
| `AsideToggle` on first pass | hidden, shown after | shown |

Measured:

- `grep` of the three new files for `schedule`, `afterRender`,
  `queueMicrotask`, `MutationObserver`, `requestAnimationFrame`,
  `setTimeout`, `@tracked` and `modifier` finds only a comment.
- The test `the fill is complete in the first render pass, and nothing
  changes after it` renders a probe last in the template. During the first
  pass it reads the navbar region, the aside and the toggle's computed
  `display`: all correct. It then starts a `MutationObserver` on the layout
  root. After settling, the observer has recorded **zero** mutations.
  Positive control: with `AsideToggle` put back on `layout.hasAside` (the
  `afterRender` registration on `main`), the same observer records 14.
- All tests run in a debug build, where the backtracking assertion is live.
- One write remains, on purpose. When the last `aside` source is destroyed,
  the layout sets `asideOpen = false`. It happens in a destructor, which
  runs after the render that removed the source, so it does not assert
  (tested). It costs one extra render when leaving a route with the aside
  open. A route swap does not reach it: the incoming source is constructed
  before the outgoing one is destroyed, so the count goes 1 → 2 → 1. Tested
  with an `{{#if}}` swap, and with two sibling routes that each fill the
  aside (orders → customers keeps it open).

### SSR first-pass output

Measured with Glimmer's own builders, in the browser against the real DOM
(`layout-regions-rehydration-experiment-test.gts`). It boots the demo at
`/regions-demo/orders/7` with `_renderMode: 'serialize'`, takes the HTML,
puts it in a new root as text, then boots a second instance over it with
`_renderMode: 'rehydrate'`.

- **Serialized HTML has the regions filled**, with Glimmer's `<script glmr>`
  in-element markers inside the region element.
- **As static HTML, before any script runs**, the navbar shows the deepest
  route's actions, the parent's are hidden and the toggle is shown. The CSS
  does this; no JavaScript is involved.
- **Rehydration adopts the server's nodes.** The region element, its content
  and the page are the same DOM nodes afterwards, and the content is live (a
  route change updates it).

That last point needed one fix found by this test. Glimmer keeps the server's
node where `{{element}}` is displayed, so a freshly created client element is
never attached and the visible content is dead HTML. `LayoutRegions` now looks
for an existing `[data-region]` under its layout root before creating one.

Not measured:

- A server DOM (SimpleDOM, linkedom). The code uses `getDOM` and the
  `-private/dom` helpers and guards `querySelector`, but I did not run it in
  Node. The site's SSR prototype (PR #500) is the place to check.
- An **open** aside in serialized output, and the drawer below `lg`.
- A closed aside's content is rendered into a detached element, so it is not
  in the server HTML. That seems right for a closed panel.

### Aside open state

Same behaviour as the first prototype, covered by the acceptance test:

- Open state is layout state. It persists while consecutive routes fill the
  aside (orders → order 1 → order 2 → orders stays open).
- It closes when the aside empties, and stays closed on return.

Different from the first prototype:

- **Content survives.** Closing and reopening, a child route covering the
  parent, and the move into the `Drawer` below `lg` all keep the same DOM
  nodes, so input values are kept (tested by node identity). The first
  prototype rebuilt the content on the drawer move.
- **A stale `asideOpen` shows no empty column, from `lg` up.** With
  `@defaultAsideOpen` and nothing filling the aside, CSS hides the column. It
  still opens on the first fill, as before.
- **Known gap below `lg`:** the same stale `asideOpen` opens an **empty
  drawer**. The drawer is portalled out of the layout root, so the root's
  CSS cannot hide it, and no source is destroyed to close it. Pinned by a
  test named `KNOWN GAP`. Closing it needs either a write after the first
  render or a rule that the drawer never starts open.
- Still not implemented: closing the drawer on route change below `lg`.

### Naming

- `layout.Region @name` for the display site and `<InRegion @name>` for the
  source, as the first write-up suggested. Still recommended over Slot and
  Outlet for the reasons given there.
- A blockless `<layout.Aside />` means "show the `aside` region". It reads
  well but it is implicit. An explicit `@region` argument may be clearer.
- No service, so nothing collides with an app's `service:app-layout`.

## What this design costs

- **Stacking hides, it does not unrender.** Every source of a region stays in
  the DOM; CSS shows the last one. A covered parent keeps its state, which is
  useful, but its elements, ids and form fields still exist, and a test's
  `querySelector` finds them. `@multiple` just drops the CSS rule.
- **A fallback block is always rendered**, and hidden while the region is
  filled.
- **Each source has a wrapper element** (`display: contents`). CSS needs an
  element to select. The first prototype had no wrapper.
- **It needs `:has()`.** The repo's targets are the last version of Chrome,
  Firefox and Safari, which all have it. From memory, unverified, the first
  versions were Chrome 105, Safari 15.4 and Firefox 121.
- **There is no JavaScript `hasContent`.** A consumer cannot write
  `{{#if region.hasContent}}`. Any tracked version of it is a write against
  render order, which needs deferral in some form. This is the real trade.
- **`AsideToggle` is now always in the DOM** and hidden with `display: none`
  when there is no aside. Two existing tests changed from `doesNotExist` to
  `isNotVisible`. `layout.hasAside` and `registerAside` are no longer read by
  the toggle and could be removed.
- **Stacking is still render order.** A parent's source must come before
  `{{outlet}}`. Unchanged from the first prototype.
- **Aside content is rendered while the aside is closed**, into a detached
  element.
- **A region is one element**, so a name can be displayed in one place at a
  time.
- **A source finds its layout by DOM ancestry.** One rendered inside a modal
  or another portal is outside the layout root and renders nothing (it
  warns). The CSS has the same limit, and an outer layout's `:has()` also
  sees a nested layout's markers.
- `@name` is read once.
- `data-aside-open="true"` can now be on the root while no aside shows.

## Other options considered, not built

- **Pull-based route metadata.** The layout reads `router.currentRoute` and
  each route's `buildRouteInfoMetadata()` returns components per region.
  Nothing registers, stacking is by route depth, and `hasContent` is a plain
  derived value, so it has none of the costs above. But the content is
  declared in the route class, not the route template, which is what was
  asked for. It is the better fit for data that must be right on the server,
  such as titles and breadcrumbs.
- **Source-owned containers attached by a modifier.** Each source renders
  into its own detached element and the display site attaches only the
  newest. Stacking would truly unrender, but modifiers do not run on the
  server, so the server HTML would have empty regions.
- **CSS-only with a rendered target.** Covered by the `Portal` experiment
  above: the ordering problem is in finding the target, not in `hasContent`.

## Test results

- `regions-test.gts`: 13 integration tests, one of them the `KNOWN GAP`.
- `layout-regions-routing-test.gts`: 3 acceptance tests over nested and
  sibling routes.
- `layout-regions-rehydration-experiment-test.gts`: 1.
- `regions-portal-experiment-test.gts`: 4.
- Full `test-app` suite at the final commit: 3239 tests, 3236 pass, 3
  skipped, 0 fail.
- Mutation run (before the last three tests were added): removing the four
  CSS rules, the close-on-empty and the server-element adoption turned 10
  tests red.
- `frontile` and `@frontile/theme` type-check clean. `test-app` type-check
  has one new error, a missing declaration for the `test-app/app` import in
  the rehydration experiment.
- `pnpm lint:hbs` reports `no-forbidden-elements` for the two new `<script>`
  markers. `portal.gts` on `main` has the same error for its marker.
