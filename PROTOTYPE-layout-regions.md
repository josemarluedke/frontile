# Prototype: route templates filling `AppLayout` regions

Branch `proto/layout-regions`, cut from `feat/app-layout` at `5d25bf5c`.
This is a throwaway prototype written to answer design questions. It is not
a feature proposal. Every new symbol is marked `PROTOTYPE` in its JSDoc.

## What was built

| Piece | File | Role |
| --- | --- | --- |
| `service:app-layout` | `packages/frontile/src/services/app-layout.ts` | The single mounted `AppLayout` registers here. Holds named regions (target element + ordered sources), the breadcrumb trail, and "region emptied" listeners. |
| `layout.Region @name @multiple` | `components/layout/region.gts` | Target. A `display: contents` div (new theme slot `region`). Its block is a fallback, shown while nothing fills it. Exposes `data-has-content`. |
| `LayoutRegion @name` | `components/layout/layout-region.gts` | Source. Usable anywhere, including inside `{{outlet}}`. Renders its block through `{{#in-element target insertBefore=null}}`, with no wrapper element. |
| `layout.Aside @region="aside"` + `LayoutAside` | `aside.gts`, `layout-aside.gts` | Route-driven aside. Empty region: no column, no `AsideToggle`. Emptying it closes the aside. The `<aside>` element itself is the target, whether inline or inside the `Drawer` below `lg`. |
| `{{breadcrumb "Orders" route="…"}}` + `layout.Breadcrumbs` | `helpers/breadcrumb.ts`, `layout-breadcrumbs.gts` | Data-only crumbs that stack like `{{page-title}}`. The trail is rendered with `Breadcrumbs @items`. |
| Demo routes | `test-app/app/templates/regions-demo{,/…}` | `/regions-demo` → `orders` → `orders/:order_id`. Each level fills the navbar `actions` region, the aside and a crumb. |

Tests:

- `test-app/tests/integration/components/layout/regions-test.gts` has 13
  tests:
  - no wrapper element
  - order independence: target mounted after the source, a remount, and a
    source placed before the layout
  - stacking, and restore on exit
  - `@multiple`
  - fallback blocks
  - `hasContent`
  - aside and toggle hiding, and closing when emptied
  - a source swap does not close the aside
  - content follows the target into the drawer and back, never twice
  - breadcrumb stacking and in-place update
  - the backtracking experiment
  - the same-runloop check
- `test-app/tests/acceptance/layout-regions-routing-test.gts` has 2 tests
  over real nested routes: the full parent → child → parent → index walk,
  and a deep link.

All 15 pass. A mutation run turned 4 tests red as expected:

- making the oldest source win
- dropping close-on-empty
- forcing `AsideToggle` visible

## Answers

### 1. Does updating a region during render hit the backtracking assertion? What fixes it?

**Yes, and I measured it.** The test `writing a region synchronously during
render trips the backtracking assertion` flips `syncWritesForTesting` and
captures this error:

> You attempted to update `sources` on `LayoutRegionState` … but it had
> already been used previously in the same computation.

The layout renders before `{{outlet}}`, so `layout.Region` in the navbar has
already read `hasContent` (`sources`) by the time a route's `LayoutRegion`
constructor writes it. The same applies to everything the layout reads and a
route writes: region sources, aside availability, and breadcrumbs. Even
`registerLayout` reading `this.layout` and then writing it in one call trips
it.

**Fix:** every write goes through `schedule('afterRender', …)`. That covers
registering and removing a source, a target, a crumb, or the layout. It is
the same pattern `AppLayout` already uses for `registerSidebar` and
`registerBottomNav`, and ember-page-title's pattern too.

Consequences, each tested:

- **Costs one extra render pass, but not a frame.** The test `the deferred
  fill lands in the same runloop` checks this: the region content is in the
  DOM synchronously when `run()` returns. Backburner loops back to the
  `render` queue from `afterRender`, so no paint can happen between the two
  passes.
- **Swaps never pass through empty.** Removals are deferred as well. When
  child A gives way to child B, B's add is scheduled during render, before
  A's teardown. So the region goes 1 → 2 → 1, never 0, and the aside does not
  close on a sibling or child navigation.

### 2. What renders under SSR?

I worked this out from Glimmer's source (`ember-source` 7.3.0). I did **not**
run it against the site's Vite SSR prototype.

- **Glimmer can serialize `{{in-element}}`.**
  `SerializeBuilder.pushRemoteElement` writes a `<script glmr="N">` marker
  into the target, and `RehydrateBuilder.__pushRemoteElement` looks for it.
  That only covers a remote block rendered **in the initial render pass**,
  with its target already present.
- **This design never has a target in the initial pass.** Targets and
  sources both register in `afterRender`, so the first pass renders:
  - each `Region`'s fallback block
  - no route-driven aside
  - `AsideToggle` *shown*, because no `Aside` has registered yet
  - an empty breadcrumb trail

  The fill comes from the afterRender re-render, through the normal update
  path, which writes no rehydration markers. `visit()` settles before
  serializing, so the server HTML probably contains the filled regions.
  However, they are unmarked, and they come from a different tree than the
  client's first pass.
- **On the client,** the first rehydrating pass again expects the fallbacks.
  It meets the server's filled content, treats it as a mismatch and clears
  it, then the afterRender pass renders it again. The final DOM should be
  correct, but region content is rebuilt rather than hydrated.
- **Recommendation:**
  - Keep anything that must be right in the first SSR pass (titles,
    breadcrumbs, a page header) **data-driven and computed in the first
    pass**. `buildRouteInfoMetadata()` read from `router.currentRoute` in
    the layout is pull-based and needs no registration, so it has no
    backtracking risk and no second pass.
  - Use block regions (`LayoutRegion`) for interactive chrome, where a
    client-only fill is acceptable.
  - Before relying on any of this, verify it with the `site/ssr` prototype
    (PR #500).

### 3. Should aside open state persist across routes?

What the prototype does, covered by the acceptance test:

- Open state is **layout state, not per-route**.
- It **persists while consecutive routes fill the aside**: orders → order 1
  → orders stays open, with the content swapped.
- It **closes when the aside empties**: leaving for a route that does not
  fill it.
- It **stays closed on return**: going back to orders does not reopen it.

I recommend this as the default for the inline column. The open/closed
state is the user's choice about the view, as in Linear's or GitHub's detail
panels. Resetting it on every route would snap the panel shut on each
child navigation.

Two refinements worth making:

- **Below `lg`, close the drawer on route change.** The drawer is modal, so
  persisting means a modal survives navigation. Navigation usually starts
  from inside the drawer, which makes this easy to miss. Not implemented.
- **Clamp a stale `asideOpen`.** `defaultAsideOpen` (or an `@asideOpen`
  left true) with an empty region keeps `asideOpen` true while nothing
  shows. The aside then pops open on the first fill. Either clamp it to
  false while the region is empty, or decide that "open on first fill" is a
  feature. A route that wants the aside open on entry can already set
  `appLayout.layout.state.asideOpen = true`; that is why the layout
  registers with the service.

### 4. Naming: Region vs Slot vs Outlet

- **Outlet:** no. It implies `{{outlet}}` and the router. These regions are
  filled by any component, not by routes.
- **Slot:** overloaded in this codebase. Frontile's styling API is built on
  tv *slots* (`SlotsToClasses`, `@classes`, `data-part`), so
  `classes.region` would sit next to a "slot" that means something else.
  Glimmer named blocks are also informally called slots. Web components'
  `<slot>` is semantically the closest match, which makes the clash worse,
  not better.
- **Region:** recommended. It is unused in Frontile and accurately means "a
  named area of the layout".

However, the prototype's pair, `layout.Region` (target) and `LayoutRegion`
(source), reads as two names for one thing. I suggest keeping
`layout.Region` for the target and naming the source after what it does:
`<InRegion @name="actions">`, which echoes `{{in-element}}`. Name the aside
source `<InAside>`, or keep `LayoutAside`.

## Other findings

- **Stacking is render order.** A parent route must place its
  `LayoutRegion` **before** `{{outlet}}`. Otherwise the child registers
  first and the parent wins. A parent source that re-renders (say inside a
  toggled `{{#if}}`) jumps to the top of the stack. ember-page-title has the
  same model. The robust alternative is ordering by route depth, which a
  component cannot see without help from the route.
- **A target that moves rebuilds the content.** Crossing `lg` swaps the
  aside between the column and the `Drawer`. The `{{in-element}}` block is
  torn down and rebuilt, so state inside it (input values, scroll position)
  is lost. The test confirms content moves and never duplicates.
- **Region names are global strings.** A typo silently renders nothing. A
  dev-only warning for a source that never finds a target, plus a typed
  registry of region names, would help.
- `@name` and `@region` are read once.
- **Mounting a second `AppLayout`** logs a warning; the newest wins.
- **`AsideToggle` shows for one render pass** before a route-driven `Aside`
  registers. This is the same settle-after-first-render behavior as the
  other registrations, and the source of the SSR mismatch above.
- **The service is app-reexported as `service:app-layout`.** It would
  collide with an app's own service of that name. Consider a namespaced name
  (`frontile-layout`) before shipping.
- **`{{breadcrumb}}` updates its token in place**, so a changed label keeps
  its position, and it is removed in `willDestroy`. It renders an empty
  text node.
