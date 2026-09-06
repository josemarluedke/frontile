---
title: Color contrast & motion
order: 5
category: accessibility
---

# Color contrast & motion

## Contrast

Frontile's semantic color system generates a matching `on-{category}-{level}` contrast color
for every background — e.g. `text-on-primary-firm` is the readable text color for a
`bg-primary-firm` background. These aren't hand-picked; they're computed by choosing whichever
of black or white has the higher WCAG contrast ratio against the paired background, in both
light and dark mode, and regenerated whenever the underlying color changes. See
[Colors](../../docs/theming/design-tokens/colors.md) in the theming docs for the full token
reference and how to override them in your own theme configuration.

Practically, this means: when you use a semantic background utility, use its matching `on-*`
text utility rather than picking a text color yourself, and you get the better of black or
white against that background without having to check it yourself.

## Motion

Frontile handles `prefers-reduced-motion` in several places, via `motion-reduce:` Tailwind
utilities and `@media (prefers-reduced-motion: reduce)` blocks built into `@frontile/theme`:

- **`Command`'s palette** animation drops its scale/rise transform under reduced motion while
  keeping the opacity fade, so the palette still reads as appearing or disappearing without
  any travel. (`Modal`, `Drawer`, and `Popover` use their own transform-based transitions —
  zoom, slide, and scale respectively — which don't currently have the same reduced-motion
  handling; `Dropdown`'s default transition is a plain opacity fade with no transform to begin
  with.)
- **Notifications** — `NotificationCard` drops its transform-based slide/scale choreography
  entirely and falls back to a faster opacity-only transition; `NotificationsContainer`'s
  own height transition (used when the toast stack expands or collapses) is removed
  altogether.
- **`SegmentedControl`** removes the transition on its sliding selection indicator.
- **`Table`** disables the entrance animation on skeleton loading rows.
- **`InputOTP`** stops its caret from blinking.

This is applied per-component in the theme rather than being a systematic, enforced guarantee
across the library — there's no mechanism that would catch a future animation added without a
`motion-reduce:` variant. And it only covers what Frontile itself renders: any custom
animation you write in your own application code (including inside a component's yielded
content) is your own responsibility to make reduced-motion-aware.
