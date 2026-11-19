# Layout regions for `AppLayout`: design

Status: draft for approval, 2026-11-18. Nothing here is built yet.

Primary sources:

- Prototype 1, the basis of this design:
  [PR #650](https://github.com/josemarluedke/frontile/pull/650), branch
  `proto/layout-regions`, write-up `PROTOTYPE-layout-regions.md` on that
  branch.
- Prototype 2 and the combined design, not chosen:
  [PR #677](https://github.com/josemarluedke/frontile/pull/677), branch
  `proto/layout-regions-portals`, write-up `PROTOTYPE-layout-regions-2.md`.

Items marked **(my call)** were decided by the author of this document and
have not been discussed. Everything else was decided in conversation.

## Intent

A route template renders inside `{{outlet}}`, below the layout, so it cannot
put anything in the layout's chrome. Apps need exactly that: page-specific
buttons in the navbar, and a details panel (the aside) whose content and
presence depend on the current route.

This feature lets any template, including a route template, render a block
into a named area of the mounted `AppLayout`.

```gts
{{! application template }}
<AppLayout as |layout|>
  <layout.Navbar>
    <layout.Region @name="actions" />
    <layout.AsideToggle />
  </layout.Navbar>
  <layout.Main>{{outlet}}</layout.Main>
  <layout.Aside @label="Details" @region="aside" />
</AppLayout>

{{! orders route template }}
<InLayoutRegion @name="actions"><Button>New order</Button></InLayoutRegion>
<InLayoutRegion @name="aside"><OrderFilters /></InLayoutRegion>
{{outlet}}
```

## Goals

- A source (`InLayoutRegion`) works from anywhere in the app, in any render order
  relative to the layout.
- A child route's source replaces its parent's while the child is active,
  and the parent's comes back when the child exits.
- The aside can be route-driven: no column and no `AsideToggle` while no
  route fills it.
- "Has content" is tracked JavaScript state inside Frontile, so `Region`,
  `Aside` and `AsideToggle` react to it without CSS.
- Only public Ember API.

## Non-goals

- **Region content in server-rendered HTML.** See "Server rendering".
- **Breadcrumbs.** No `{{breadcrumb}}` helper and no `layout.Breadcrumbs`.
  They are better built from route metadata, as a separate feature.
- **Typed region names.** Names are plain strings.
- **More than one `AppLayout` at a time.**
- **Preserving state inside region content when its target moves** (the
  aside crossing `lg`). The content is rebuilt.
- **Rendering a source in place when no target exists.**
- **A public "has content" for app templates.** `Region` exposes
  `data-has-content` and a fallback block; nothing is yielded. Can be added
  later without breaking anything. **(my call)**
- **A way for a route to open the aside on entry.** Prototype 1 exposed the
  layout's state through the service for this. An app that needs it uses
  controlled `@asideOpen`. **(my call)**

## Anti-goals

- No `:has()` selectors and no `<script>` marker elements to decide what is
  shown. This is why prototype 2 was not chosen.
- No wrapper element around a source's content, and none where the source
  sits.
- The aside must not close and reopen when one route's aside content is
  swapped for another's.

## Approaches considered

1. **Tracked registry with writes deferred to `afterRender` (chosen).**
   Prototype 1. A service holds each region's target element and sources.
   Sources and targets register after render, which re-renders once in the
   same runloop. Costs a second render pass with no paint in between, and
   region content is not part of the first server pass. Gives tracked "has
   content" and uses the pattern `AppLayout` already uses for `Sidebar`,
   `BottomNav` and `Aside` registration.
2. **Layout-owned element, stacking decided during render, "has content" in
   CSS.** Prototype 2 combined design. One pass and content in the server
   HTML, but it needs `:has()` rules and `<script>` markers, and has no
   JavaScript "has content". Rejected for the CSS and markers.
3. **Middle option: layout-owned element for content, tracked "has content"
   written in `afterRender`.** Not built. Would still need the markers.
4. **`ember-stargate`.** Same shape as approach 1 but defers with `next()`,
   a later runloop, so a paint can happen before the fill. No stacking with
   restore. Adds three dependencies.

The user chose approach 1 after confirming that
`schedule('afterRender', …)` is public API.

## Design

### Public API

| Piece | Kind | Notes |
| --- | --- | --- |
| `layout.Region @name @multiple` | yielded by `AppLayout` | The target. Block is the fallback. |
| `InLayoutRegion @name` | exported from `frontile/layout` and the root | The source. |
| `layout.Aside @region="aside"` | new argument on the existing component | Makes the aside route-driven. |

`Region` was agreed. The source is `InLayoutRegion`, the user's choice over the shorter `InRegion`: it is imported on its own into route templates, where nothing else says which kind of region it means. "Slot" clashes with the theme's
tv slots and "outlet" implies the router.

### `layout.Region`

- Renders
  `<div data-part="region" data-region={{@name}} data-has-content="true|false">`
  with the new theme slot `region` (`contents`), so its children lay out as
  children of the region's parent. Accepts `...attributes`.
- Its block is a fallback, rendered only while the region has no source.
- `@multiple={{true}}` renders every source in registration order instead
  of only the newest.
- Registers its element as the target from a modifier and unregisters on
  teardown.
- `@name` and `@multiple` are read when the target registers. Changing
  them later is unsupported. **(my call)**

### `InLayoutRegion`

- Renders nothing where it sits.
- Registers as a source in its constructor and removes itself in a
  destructor.
- While it is the shown source and the region has a target, it renders its
  block with `{{#in-element target insertBefore=null}}`, with no wrapper.
- `@name` is read once, in the constructor. **(my call)**
- It has no `Element`, so it takes no attributes.

### Stacking

- Sources are kept in registration order. Registration order is render
  order.
- Without `@multiple`, the newest source is shown. When it is removed, the
  previous one is shown again.
- **Rule for route templates:** a parent route puts its `InLayoutRegion` before
  `{{outlet}}`, so the child registers later and wins. This must be in the
  docs.
- **Known fragility, accepted:** a parent source that is torn down and
  re-rendered while its child is active (inside a toggled `{{#if}}`)
  re-registers as the newest and covers the child. `ember-page-title` has
  the same model. **(my call to accept it.)**

### The registry service

- A service, because a component inside `{{outlet}}` cannot see the
  layout's yielded context.
- Name: `frontile-layout-regions`, in
  `packages/frontile/src/services/frontile-layout-regions.ts`. The existing
  `addon.appReexports(['services/**/*.js'])` picks it up; add the matching
  `app-js` entry in `package.json` next to `notifications`. The prefixed
  name avoids colliding with an app's own service. **(my call)**
- It is internal. It is not documented and not exported from a barrel.
  **(my call)**
- Per region name it holds: `target` (element or null), `multiple`,
  `sources` (array reassigned on every change, never mutated), and whether
  any target has ever declared the name.
- API, taken from prototype 1 minus the layout and breadcrumb parts:
  `region(name)`, `hasContent(name)`, `declare(name)`,
  `registerTarget(name, element, { multiple })`, `addSource(name, token)`,
  `onEmpty(name, listener)`. Each register call returns its undo function.
- It does **not** hold a reference to the layout or its state. Prototype
  1's `registerLayout` is dropped; nothing needs it. **(my call)**

### Write timing

- Every write to the registry's tracked state goes through
  `schedule('afterRender', …)`: adding and removing a source, setting and
  clearing a target. Skip the write if the service is being destroyed.
- Reason: the layout renders before `{{outlet}}` and has already read the
  state when a route's source wants to write it. A synchronous write trips
  Glimmer's backtracking assertion. Prototype 1 has a test that captures
  that error.
- Removals are deferred too. That is what makes a swap go 1 → 2 → 1 and
  never 0: the incoming source's add is scheduled during render, before the
  outgoing source's destructor schedules its removal.
- The second render happens in the same runloop, before paint. Prototype 1
  has a test for this.
- No test-only synchronous mode in the shipped service. The backtracking
  demonstration stays in the prototype. **(my call)**

### Route-driven aside

- `<layout.Aside @region="aside" />` is route-driven: `@region` names the
  region that fills it, and its own block is ignored. Without `@region` it
  behaves exactly as on `main` today, including a blockless aside, so
  nothing released changes. `@region` is read once. **(my call, as in
  prototype 1. An explicit name is also what lets several demo layouts sit
  on one docs page, each with its own region name.)**
- A route fills it with `<InLayoutRegion @name="aside">`, using whatever name
  the aside was given. There is no separate `LayoutAside`/`InAside`
  component. **(my call)**
- A standalone `Aside` (outside an `AppLayout`, with `@state`) accepts
  `@region` too and works the same way, minus the toggle. **(my call)**
- The `<aside>` element is the target, both inline and inside the `Drawer`
  below `lg`. It registers with the same target modifier as `Region`. The
  aside calls `declare(region)` in its constructor, because the inline
  element only exists while `asideOpen` is true.
- While the region has no source:
  - the aside renders nothing, including no `Drawer`;
  - `AppLayoutContext.hasAside` is false, so `AsideToggle` renders nothing.
    Implement as in prototype 1: `registerAside` takes a `RegisteredAside`
    with an optional `available` getter, and `hasAside` is
    `registered && (available ?? true)`.
- When the region loses its last source **while the aside is in the drawer
  (below `lg`)**, the aside calls `state.closeAside()`. With controlled
  `@asideOpen` that calls `@onAsideOpenChange(false)` only if it was open,
  through the existing `ControlledAppLayoutState`. At `lg` and up nothing
  is written: the inline aside is only hidden while empty.

### Aside open state

Decided by the user (option C below).

- Open state is layout state, not per route.
- It persists while consecutive routes fill the aside. Content swaps and
  the panel stays open.
- **At `lg` and up, emptying the region hides the aside and leaves
  `asideOpen` alone.** When content returns, the panel is open again if it
  was open before. This covers a loading state between two filling routes,
  and it also means returning from a route without an aside shows the
  panel again.
- **Below `lg`, emptying the region closes the drawer** (`closeAside`), and
  it stays closed when content returns, so a modal drawer never opens as a
  result of navigation.
- Which rule applies is decided by `belowAsideBreakpoint` at the moment the
  region empties.
- **`@defaultAsideOpen` with a route-driven aside means "open on the first
  fill".** The region is always empty on the first pass, so nothing may
  clamp `asideOpen` to false while empty. **(my call)** Below `lg` this
  opens the drawer on first fill, which matches what `main` documents for
  a block aside that starts open on a narrow screen.
- **No close-on-route-change for the drawer below `lg`.** If the next
  route fills the aside, the drawer keeps showing the new content. If it
  does not, the region empties and the drawer closes. **(my call)**
- Known limit below `lg`, reasoned and not tested: two sibling routes that
  each fill the aside, with a loading substate between them, empty the
  region for a moment and close the drawer. A shared parent route that
  fills the aside avoids it. Document it.

Options that were considered for the emptied region:

- A. Close on empty at every width. A loading state between two filling
  routes would also close the inline panel.
- B. Never close, only hide. Below `lg` a modal drawer would open on
  navigation.
- **C. B at `lg` and up, A below `lg`. Chosen.**


### Developer warnings

- In development only, warn once per name when a source has registered for
  a name that no `Region` or `Aside` has declared by the time that render
  settles. This catches typos and a missing `layout.Region`. Key it on the
  declaration, not on the target element, because a closed aside has
  sources and no element. Exact scheduling is left to the builder.
- In development only, warn when a second target registers for a name that
  already has a live target. The newest target wins.

### Second `AppLayout`

Unsupported. Region names are global to the app instance. Two layouts that
declare the same name trigger the duplicate-target warning. **(my call)**

### Server rendering

Not a goal, and **not verified**. What is expected, from reading Glimmer's
source during prototype 1:

- Sources and targets register after the first pass, so the first pass
  renders fallbacks, no route-driven aside and no `AsideToggle`.
- Targets register from a modifier. Modifiers may not run during server
  rendering, in which case the server HTML keeps the first-pass output.
- If the fill does reach the server HTML, the client's rehydrating pass
  will not match it and will rebuild it.

Requirements: rendering on the server must not throw, and the DOM must be
correct once the client has rendered. The builder checks this once against
the site's SSR setup and records the result in the docs.

### Theme

Add one slot to `packages/theme/src/components/app-layout.ts`:
`region: 'contents'`. No other style changes.

### Docs

- `packages/frontile/src/components/layout/app-layout.md`: a "Regions"
  section (target, source, fallback, `@multiple`, the before-`{{outlet}}`
  rule, the server-rendering limit, content rebuilt across `lg`) and a
  route-driven subsection under "Aside". Demos render `InLayoutRegion` in the
  same template as the layout, since Docfy demos have no routes. Region
  names are global and that page mounts many layouts, so every demo uses
  its own region names (`demo-actions`, `demo-aside`, …).
- JSDoc on every new argument, which generates the API tables.

## Tests

Port prototype 1's tests, without the breadcrumb and synchronous-write
cases, written test-first:

- Integration (`test-app/tests/integration/components/layout/regions-test.gts`):
  no wrapper element; target mounted after the source; target remount;
  source rendered before the layout; stacking and restore on exit;
  `@multiple`; fallback block; `data-has-content`; aside and toggle hidden
  while empty; at `lg` and up an emptied aside keeps `asideOpen` and is open
  again when refilled; below `lg` an emptied aside closes and stays closed; a source swap does not close the
  aside; a blockless `Aside` without `@region` is unchanged; content follows the target into the drawer and back and is never
  rendered twice; the fill lands in the same runloop; `@defaultAsideOpen`
  opens on first fill; controlled `@asideOpen` gets
  `onAsideOpenChange(false)` on empty below `lg` only; both developer warnings; an `Aside`
  with a block is unchanged.
- Acceptance (`test-app/tests/acceptance/layout-regions-routing-test.gts`)
  over real nested routes in the test app: the parent → child → parent →
  index walk, and a deep link.

## Left to the builder

- The demo routes' names and content in the test app.
- How the "undeclared name" warning is scheduled.
- Whether `Region` and `Aside` share one target modifier or each define
  their own.
- Wording of warnings and docs.

## Delivery

A new branch from `main`, one PR. Prototypes #650 and #677 stay open as
references until it merges, then get closed.
