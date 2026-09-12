# Changelog

Notable changes to Frontile. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## Unreleased

### Breaking

- **Variant API:** the style axis on Button, ButtonGroup, ToggleButton, Chip,
  Listbox (and its Select/Dropdown/Autocomplete forwarders), and CloseButton
  is renamed from `@appearance` to `@variant`, with values moved onto the
  shared vocabulary `solid | soft | subtle | outline | ghost | plain`.
  `@appearance` still works and maps to the new value, logging a deprecation
  warning; it is removed in v0.19.0. Kbd, Alert, NotificationCard, Accordion,
  and Drawer never shipped a stable `@appearance`/`@variant` API, so their
  renames ship with no deprecation warning. See the
  [Variant API Migration Guide](docs/migrations/v0.18/variant-color-api.md).
- **Button `@appearance="soft"` changes meaning.** Independent of the rename
  above: on a `0.18.0-alpha`/`beta` build, `@appearance="soft"` was a tint
  **with** a border. In the final `@variant` vocabulary, `soft` is a tint
  **without** a border — that treatment is now named `subtle`. This is the one
  rename in the whole migration that does not fail loudly (`soft` stays a
  valid value, so neither Glint nor a runtime assertion catches it). If you
  used `@appearance="soft"` on Button, you want `@variant="subtle"`.
