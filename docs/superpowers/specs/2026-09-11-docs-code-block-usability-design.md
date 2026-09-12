# Docs Code Block Usability Design

## Goal

Improve code-block usability across the Frontile documentation site without
changing the presentation choices already made for standalone guide and
migration snippets.

## Installation commands

The installation page will continue to use Docfy's `:::code-tabs` directive
for the three supported package managers: pnpm, npm, and Yarn. Bun is out of
scope. The existing tabs will be verified through the generated site and an
interactive browser check.

## Long live-demo source

Only fenced blocks marked `preview` are eligible for new collapsing behavior.
A live-demo fence with more than 30 source lines will receive Docfy's
`collapsible` metadata flag. Shorter live demos remain fully expanded.

Standalone code fences in guides and migration pages are out of scope. Their
current expanded or collapsible state will not be changed.

## Copy button

The copy button already exists after client hydration. The site's custom CSS
sets its opacity to zero at rest and reveals it only while the code-block card
is hovered or the button has keyboard focus. This makes the control appear to
be missing.

The copy button will remain visible at rest. Its existing placement, label,
clipboard behavior, copied feedback, hover treatment, focus behavior, and
touch behavior will otherwise remain unchanged. No SSR or Docfy dependency
changes are required.

## Verification

- Confirm every `preview` fence over 30 lines has `collapsible` and no shorter
  preview fence is changed solely for this work.
- Confirm standalone fence metadata is unchanged.
- Build the documentation site and run its focused tests, linting, and type
  checks.
- In a real browser, verify the package-manager tabs, a long live-demo collapse
  control, and an always-visible copy button whose copy action still works.
