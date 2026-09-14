---
title: Variant API Migration
order: 9
category: migrations
subcategory: v0.18
---

# Variant API Migration Guide

v0.18 renames Frontile's style axis from `@appearance` to `@variant`, and moves
its values onto a shared vocabulary used across every component:

```
solid | soft | subtle | outline | ghost | plain
```

`@variant` controls **how a component is drawn** — filled, tinted, bordered, or
bare. It is a different axis from `@intent`, which controls **which semantic
color** a component uses (`primary`, `success`, `danger`, …). `@intent` is
**not** renamed in this release — it becomes `@color`/`@status` in a later
release, covered by its own migration guide when that ships. If you are only
touching `@appearance`/`@variant`, nothing below changes your `@intent` usage.

This guide has two sections, for two different starting points:

- **[Upgrading from v0.17](#upgrading-from-v017)** — six components whose
  `@appearance` API shipped stable in v0.17.1. `@appearance` still works; it
  now warns at runtime and is removed in v0.19.0.
- **[Upgrading from a v0.18 pre-release](#upgrading-from-a-v018-pre-release)**
  — components and values added during the 0.18 alpha/beta cycle, renamed
  outright with no deprecation.

If you're upgrading straight from v0.17.1, read section 1 only — you never used
the pre-release spellings in section 2.

## Upgrading from v0.17

These six components had a stable `@appearance` (or, for CloseButton, `@variant`)
axis in v0.17.1. The old spelling still works in all of 0.18.x: it maps to the
new value and logs a deprecation warning. It is removed in v0.19.0.

| Component                                  | Old                                                      | New                                              |
| ------------------------------------------ | -------------------------------------------------------- | ------------------------------------------------ |
| Button / ButtonGroup / ToggleButton        | `@appearance="default \| outlined \| minimal \| custom"` | `@variant="solid \| outline \| plain \| custom"` |
| Chip                                       | `@appearance="default \| outlined \| faded"`             | `@variant="solid \| outline \| soft"`            |
| Listbox / Dropdown / Select / Autocomplete | `@appearance="default \| outlined \| faded"`             | `@variant="solid \| outline \| subtle"`          |
| CloseButton                                | `@variant="transparent \| subtle"`                       | `@variant="ghost \| soft"`                       |

Notes:

- The prop itself is renamed on every component above except CloseButton,
  which already used `@variant` — only its values move.
- Chip's `faded` becomes `soft` (a borderless tint). Listbox's `faded` becomes
  `subtle` (a tint **with** a border). These are different components with
  different treatments for the same old value name — do not assume one map
  applies to both.
- `@appearance="custom"` on Button keeps its name; it is not in the deprecation
  value map and passes through unchanged.
- Select, Dropdown, and Autocomplete forward `@variant` to the Listbox they
  render internally. Pass the new prop at whichever level you currently set
  `@appearance`.

### Example

```gts
{{! Before }}
<Button @appearance='outlined'>Cancel</Button>
<Chip @appearance='faded'>Draft</Chip>

{{! After }}
<Button @variant='outline'>Cancel</Button>
<Chip @variant='soft'>Draft</Chip>
```

## Upgrading from a v0.18 pre-release

> **`@appearance="soft"` on Button changes meaning rather than breaking.** It
> used to be a tint **with** a border; `@variant="soft"` is a tint **without**
> one. `soft` is still a valid value, so nothing catches this — not Glint, not
> a runtime assertion, not a test that only asserts a class is present. If you
> used `@appearance="soft"`, you want `@variant="subtle"`.

The components and values in this section were added during the 0.18
alpha/beta cycle and never shipped in a stable release. There is nothing to
deprecate them from, so **renaming them produces no runtime warning** — this
guide is the only signal you get. Everything else in this section fails
loudly: the old spelling leaves the type union, so Glint rejects it at build
time.

| Component                | Pre-release                                  | v0.18 final                                                            |
| ------------------------ | -------------------------------------------- | ---------------------------------------------------------------------- |
| Kbd                      | `@appearance="default \| outlined \| faded"` | `@variant="solid \| outline \| subtle"` (`inherit`, `plain` unchanged) |
| Alert / NotificationCard | `@variant="default \| tonal"`                | `@variant="surface \| soft"` (`solid` unchanged)                       |
| Accordion                | `@variant="outlined \| faded"`               | `@variant="separated \| soft"` (`ghost`, `enclosed` unchanged)         |
| Drawer                   | `@appearance="default \| ghost"`             | `@variant="sectioned \| flat"`                                         |
| Button                   | `@appearance="soft"`                         | `@variant="subtle"`                                                    |
| Button                   | `@appearance="tonal"`                        | `@variant="soft"`                                                      |

If you were not tracking a `0.18.0-alpha.*`/`beta.*` build, none of this
applies to you — go back to [Upgrading from v0.17](#upgrading-from-v017).

## Need help?

- [Upgrading to v0.18](./index.md) for the full list of 0.18 breaking changes
- Search or open an issue on [GitHub](https://github.com/josemarluedke/frontile)
