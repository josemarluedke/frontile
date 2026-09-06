---
title: Color contrast & motion
order: 5
category: accessibility
---

# Color contrast & motion

## Contrast

Frontile's semantic color system generates a matching `on-{category}-{level}` contrast color
for every background — e.g. `text-on-primary-firm` is the readable text color for a
`bg-primary-firm` background. These aren't hand-picked; they're computed to meet WCAG contrast
guidelines against their paired background, in both light and dark mode, and regenerated
whenever the underlying color changes. See
[Colors](../../docs/theming/design-tokens/colors.md) in the theming docs for the full token
reference and how to override them in your own theme configuration.

Practically, this means: when you use a semantic background utility, use its matching `on-*`
text utility rather than picking a text color yourself, and you get WCAG-appropriate contrast
without having to check it.

## Motion

Frontile's support for `prefers-reduced-motion` is currently limited: the `InputOTP`
component stops its caret from blinking when reduced motion is requested, but that's the only
place it's handled today. Transitions and animations elsewhere (overlay enter/exit,
notification transitions) do not yet check for this preference. If motion sensitivity matters
for your application, you may need to add your own `prefers-reduced-motion` overrides for
now — this is an area of the library with room to grow rather than a guarantee you can rely
on across every component.
