# Toast Notification Redesign

Status: approved for planning
Date: 2026-09-04
Branch: `claude/toast-notification-redesign-d0c0af`

## Problem

Toast notification styling is broken. `packages/theme/src/components/notification-card.ts`
paints the card with `bg-success-soft`, `bg-warning-soft` and `bg-danger-soft`. In
`packages/theme/src/colors/semantic.ts` the `soft` level of every semantic category is
deliberately translucent (15–25% alpha), which is correct for an inline badge sitting on a
known surface and wrong for a toast floating over arbitrary page content. Page content shows
through the card. Only `info` looks correct, because it uses the opaque `bg-neutral-firm`.

Two further problems ride along:

1. The visual language is dated relative to the rest of Frontile — `rounded-xl`, square-ish,
   no icons, no title/description hierarchy.
2. The enter animation is a JS hack: `transitionIn` in `notification-card.gts` animates
   `element.style.height` inside nested `requestAnimationFrame` calls plus an `@ember/runloop`
   `later()`, with manual teardown to avoid touching a destroyed element.

## Goals

- Opaque, correct-in-both-themes toast surfaces.
- Visual refresh matching Frontile's rounder design language, referencing shadcn/sonner and
  HeroUI toasts.
- Sonner-style collapsed stack that expands on hover or focus.
- Title + description content model.
- `notifications.promise()` for promise-driven toasts that mutate in place.

## Non-goals

Swipe-to-dismiss, a focus hotkey (sonner's `⌥T`), and arbitrary custom component bodies inside
a toast. These are deliberately out of scope for this change.

## Decisions

These were settled during design and should not be re-litigated during implementation.

| Decision | Choice |
| --- | --- |
| Color placement | Neutral opaque card by default; appearance color carried by the icon **and** the title |
| Action buttons | Primary custom action takes the appearance color; secondary actions are minimal/neutral |
| Stacking | Full collapsed stack with hover/focus expansion (not an opt-in flag) |
| Content API | `message` becomes the title; add `description`; add an object overload. No breakage. |
| Promise API | `notifications.promise(p, { loading, success, error })`. `update()` stays internal. |
| Semantic naming | Add `intent` with `danger`; deprecate `appearance` and `error` |
| Toast surface | Reuse `surface.modal` — no new semantic role |
| Variant names | `default` \| `tonal` \| `solid` |

### Recorded trade-off: `surface.modal` in dark mode

`surface.modal` resolves to `gray-950` in dark, against an app background of `black`. The
contrast between card and page is therefore very slight, and the card reads more as a bordered
outline than a lifted surface — flatter than the shadcn reference. This was accepted knowingly
in favour of not adding another semantic role. It is mitigated by `border-surface-overlay-mild`
and `shadow-lg`. If the result reads too flat in review, the fallback is a new `surface.toast`
role (light `white`, dark `gray-900`); that change would be isolated to
`packages/theme/src/colors/semantic.ts`, `types.ts`, `plugin/resolve.ts` and one class in
`notification-card.ts`.

## Design

### 1. Theme — `packages/theme/src/components/notification-card.ts`

Rewritten `tv()` with slots `base`, `icon`, `content`, `title`, `description`, `customActions`,
`customActionButton`, `closeButton`, and two variant axes.

Base card: `rounded-2xl p-4 gap-3 shadow-lg border` — rounder, matching the current design
language. `min-h-16` and the old `py-3 px-4` go away.

`intent` × `variant` matrix:

| variant | Surface | Icon | Title | Description |
| --- | --- | --- | --- | --- |
| `default` | `bg-surface-modal`, `border-surface-overlay-mild` | `text-{intent}` | `text-{intent}` | `text-neutral` |
| `tonal` | `bg-{intent}-subtle` (opaque in both themes), `border-{intent}-muted` | `text-{intent}` | `text-{intent}` | `text-neutral` |
| `solid` | `bg-{intent}` | `text-on-{intent}` | `text-on-{intent}` | `text-on-{intent}/80` |

`intent` values are `info`, `success`, `warning`, `danger`. For `info` under `default`/`tonal`
the accent colour is `primary`; the mapping intent → colour token lives in one place in the
theme file.

No `*-soft` token appears anywhere in this component. `*-subtle` is opaque in both themes
(`green-50` light / `green-950` dark), which is what makes `tonal` safe.

### 2. Icons — `packages/frontile/src/components/notifications/icons.gts`

New file following the existing pattern in `components/forms/icons.gts`: `IconSuccess`
(check-circle), `IconWarning` (triangle), `IconDanger` (x-circle), `IconInfo` (info-circle),
as template-only components. The loading state reuses the existing `Spinner` component rather
than a new icon.

The card resolves its icon from `intent`, unless `options.icon` supplies a component or
`options.hideIcon` is true. The icon must be swappable at runtime because `promise()` swaps
spinner → result icon in place.

### 3. Stacking and animation

The `transitionIn` and `transitionOut` modifiers in `notification-card.gts` and the
`cssTransition` usage are deleted. `ember-css-transitions` stays a package dependency — it is
still used by `components/overlays/backdrop.gts` and `overlay.gts`.

Layout model:

- The container is the positioning context, fixed at `@placement`.
- Every card is `position: absolute`, pinned to the placement edge, `z-index: N - i` where `i`
  is the index from the front of the stack (front = newest).
- **Collapsed:** card `i` gets `translateY(±i·gap) scale(1 − i·0.05)`, and its height is clamped
  to the front card's height so taller cards behind do not stick out. Cards with
  `i >= @visibleToasts` (default 3) get `opacity: 0`.
- **Expanded:** `translateY(±Σ heights of cards in front of i)` with `scale(1)`.
- The container's own height animates between front-card height (collapsed) and total stack
  height (expanded), so a collapsed stack does not swallow pointer events across a large region
  of the screen.
- The sign of every `translateY` is driven by whether `@placement` is a top or bottom placement.

Measurement: one `ResizeObserver` per card reports its height into a tracked registry keyed by
notification. This also makes promise-driven content swaps reflow the stack for free.

Motion: `transform 400ms cubic-bezier(0.21, 1.02, 0.73, 1)`, `opacity 300ms`. Enter slides in
from the placement edge with a slight scale-up; exit is fade plus scale-down. A
`prefers-reduced-motion: reduce` branch drops all transforms and transitions opacity only.

Expansion triggers: `mouseenter`/`mouseleave` and `focusin`/`focusout` on the container.
Focus matters — without it, keyboard users cannot reach toasts hidden behind the stack.
While expanded, timers pause for **every** toast in the stack, not just a hovered one. This
replaces the current per-card `mouseenter`/`mouseleave` pause.

### 4. `NotificationStack` — isolating the math

All stack geometry lives in a plain TypeScript class (no Ember, no DOM), e.g.
`packages/frontile/src/-private/notification-stack.ts`.

- **Input:** ordered card heights, `isExpanded`, `gap`, `visibleToasts`, `placement`.
- **Output:** for each index, `{ transform, zIndex, opacity, height }`, plus the container's
  target height.
- **Depends on:** nothing.

The card component applies what it is handed and computes none of it. This keeps the hardest
part of the change unit-testable in isolation and keeps `notification-card.gts` small.

### 5. Public API

Content model — the existing positional-string signature keeps working unchanged, so every
current call site renders correctly as a title-only toast:

```ts
notifications.add('Event created');
notifications.add('Event created', { description: 'Starts at 8:00 AM.' });
notifications.add({ title: 'Event created', description: 'Starts at 8:00 AM.' });
```

A title-only toast stays on one line, vertically centred against its icon.

Promise API:

```ts
notifications.promise(saveEvent(), {
  loading: 'Saving…',
  success: (event) => ({ title: 'Saved', description: event.name }),
  error: (e) => `Could not save: ${e.message}`
}); // returns the original promise
```

`loading` accepts a string or `{ title, description }`. `success` and `error` accept a string,
a `{ title, description }` object, or a function of the resolved value / rejection reason
returning either. Any other `NotificationOptions` pass through.

Behaviour: adds a preserved, non-closable toast with a `Spinner` in the icon slot, then mutates
**that same notification** on settle — icon cross-fades, text swaps, `allowClosing` flips true,
the auto-dismiss timer starts. No exit/enter flash. If the user dismissed the toast before the
promise settled, settling is a no-op.

This requires `Notification`'s `message`, `description`, `intent` and `allowClosing` to become
`@tracked` rather than `readonly`, and an internal `update()` method. `update()` is not part of
the documented public API; only `promise()` is documented.

Container arguments: existing `@placement` and `@spacing` are kept. `@spacing` (default 16) is
the `gap` input to `NotificationStack` — it is the peek offset between collapsed cards and the
gap between expanded cards, replacing its current role of feeding the JS height animation. New
`@variant`, `@visibleToasts` (default 3), and `@expand` (force the stack always-expanded).

### 6. Deprecation: `appearance` → `intent`, `error` → `danger`

`NotificationOptions` gains `intent?: 'info' | 'success' | 'warning' | 'danger'`.
`appearance?: 'info' | 'success' | 'warning' | 'error'` is retained and, when supplied, emits a
deprecation via `deprecate()` from `@ember/debug` and maps to `intent`, with `error` → `danger`.
`NotificationsContainer` gains `@variant`; there is no old container-level argument to deprecate.

Normalisation happens in exactly one place — the `Notification` constructor — so nothing
downstream ever sees the legacy names.

### 7. Accessibility

Current markup puts `role="alert" aria-live="assertive" aria-atomic="true"` on the container,
making every toast — including routine info toasts — interrupt a screen reader.

New behaviour: the container is `role="region"` with `aria-label="Notifications"` and
`aria-live="polite"`. Each card carries `role="status"` for `info`/`success` and `role="alert"`
for `warning`/`danger`.

Toasts stacked beyond `@visibleToasts` are visually hidden but remain in the accessibility
tree; `focusin` expands the stack so they are reachable by keyboard.

## Testing

**Unit — `NotificationStack`:** collapsed offsets and scale per index; expanded offsets from
summed heights; z-index ordering; opacity cutoff at `visibleToasts`; sign inversion between top
and bottom placements; container target height in both states; empty and single-card cases.

**Unit — `promise()`:** resolve path; reject path; string, object and function forms of
`success`/`error`; dismissed-before-settle is a no-op; the returned promise resolves and
rejects with the original value/reason.

**Unit — deprecation:** `appearance: 'error'` maps to `intent: 'danger'` and warns; `intent`
alone does not warn.

**Integration:** description renders and title-only stays single-line; correct icon per intent;
`hideIcon` and custom `icon`; hover and `focusin` set the expanded state; timers pause for all
toasts while expanded and resume on leave; each `variant` applies its expected classes; close
button and custom actions; `prefers-reduced-motion` path.

Every existing test in `test-app/tests/integration/components/notifications/` and
`test-app/tests/unit/notifications/` must stay green — the string-only `add()` signature is
unchanged.

## Documentation

`packages/frontile/docs/notifications-usage.md` gains sections for `description`, `@variant`,
`promise()`, and the stacking arguments (`@visibleToasts`, `@expand`), plus a migration note for
`appearance` → `intent`. The `frontile-docs` skill governs this work. JSDoc on
`NotificationOptions` and both component signatures must move with the code, since it generates
the API tables.

## Build order

`@frontile/theme` first (semantic tokens and the card styles feed generated Tailwind classes),
then `frontile`.
