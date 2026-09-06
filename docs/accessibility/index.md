---
title: Accessibility overview
order: 1
category: accessibility
---

# Accessibility

Frontile's components handle a substantial amount of accessibility work for you: focus
management, keyboard navigation, and the ARIA attributes each component's role requires are
built in and covered by the test suite. This section documents the mechanisms that are
shared across components. For the exact ARIA attributes and keyboard bindings a specific
component uses, see that component's own **Accessibility** section — for example
[Table's](../../packages/frontile/src/components/collections/table.md#accessibility),
[Modal's](../../packages/frontile/src/components/overlays/modal.md#accessibility), or
[Dropdown's](../../packages/frontile/src/components/collections/dropdown.md#accessibility).

## What Frontile handles vs. what you own

Frontile owns:

- Correct ARIA roles, states, and relationships for each component (e.g. `aria-modal`,
  `aria-invalid`).
- Keyboard navigation within a component — arrow keys, Home/End, typeahead, and Tab
  behavior for lists, menus, tables, and grouped controls.
- Focus behavior around opening and closing overlays — where focus goes when a modal opens,
  and where it returns when it closes.
- The `:focus-visible` behavior that shows a focus ring for keyboard users without showing
  one for mouse users.

You own:

- An accessible name for anything Frontile can't infer one for — e.g. passing `aria-label`
  or `aria-labelledby` to a `Modal`, or wrapping icon-only buttons in `VisuallyHidden` text.
- The meaning of your own content — alt text on images you render inside a component,
  correct heading levels in the content you put inside a `Modal.Header`.
- Testing your specific application with a screen reader. Frontile's ARIA wiring gives
  assistive technology the right information, but only you know whether your page's content
  makes sense when read in order.

## Where to look for component-specific detail

Every component's `.md` file has its own `## Accessibility` section documenting the exact
ARIA attributes it sets and the exact keys it responds to. This section (`docs/accessibility/`)
covers the *shared* mechanisms behind those components — read both when you need the full
picture for a specific component.

## Testing posture

Frontile's integration test suite asserts ARIA attributes and keyboard behavior across the
component set — concentrated in `roving-focus-test.gts`, `listbox-test.gts`, `table-test.gts`,
`command-test.gts`, `dropdown-test.gts`, `select-test.gts`, `autocomplete-test.gts`, and
`segmented-control-test.gts`, plus the forms and overlays suites. That gives strong regression
coverage for the behavior these docs describe, but it is not the same as a formal accessibility
audit or a tested matrix of screen readers and browsers. If you're shipping something
compliance-critical, test it yourself with a real screen reader (VoiceOver, NVDA, or JAWS) —
don't rely on Frontile's test suite as a substitute.
