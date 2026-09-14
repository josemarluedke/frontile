---
title: Component API Naming Migration
order: 9
category: migrations
subcategory: v0.18
---

# Component API Naming Migration Guide

v0.18 renames **both** of Frontile's styling axes onto the vocabulary the wider
ecosystem uses. They ship together, so migrate them together.

| Axis                | Before        | After                                                            |
| ------------------- | ------------- | ---------------------------------------------------------------- |
| How it is **drawn** | `@appearance` | `@variant`                                                       |
| What it **means**   | `@intent`     | `@color` — or `@status` on Alert, NotificationCard, FormFeedback |

## The two axes

`@variant` controls how a component is drawn — filled, tinted, bordered, or
bare:

```
solid | soft | subtle | outline | ghost | plain
```

`@color` controls which semantic color it uses:

```
neutral | primary | secondary | tertiary | success | warning | danger
```

### Why three components use `@status` instead of `@color`

**`@color` is decoration. `@status` is meaning.**

On most components the value only picks a color — a `danger` Button is a red
Button. On three components it also decides what a screen reader does:

| Component          | The value also selects                                       |
| ------------------ | ------------------------------------------------------------ |
| `Alert`            | the icon, and the ARIA role (`status` vs `alert`)            |
| `NotificationCard` | the icon, the ARIA role, and the action button's color       |
| `FormFeedback`     | whether the message is announced **assertively or politely** |

Naming that `@color` would mean a prop named for decoration silently deciding
whether a screen reader interrupts the user. Those three take `@status`:

```
neutral | primary | success | warning | danger
```

## Value renames

`default` becomes **`neutral`** on every color axis — the palette category has
always been called `neutral`.

```hbs
{{! before }}
<Button @intent='default'>Cancel</Button>

{{! after }}
<Button @color='neutral'>Cancel</Button>
```

On `Alert` and `NotificationCard`, `info` becomes **`primary`**. It was already
a pure alias, painting `primary`'s classes and differing only in the default
glyph, which stays attached to `primary`.

## Upgrading from v0.17

These components had a stable axis in v0.17.1. The old spelling still works in
all of 0.18.x: it maps to the new value and logs a deprecation warning. It is
removed in v0.19.0.

| Component                                  | `@appearance` → `@variant`                                                         | `@intent` → `@color`/`@status` |
| ------------------------------------------ | ---------------------------------------------------------------------------------- | ------------------------------ |
| Button / ButtonGroup / ToggleButton        | `default \| outlined \| minimal \| custom` → `solid \| outline \| plain \| custom` | `@color`                       |
| Chip                                       | `default \| outlined \| faded` → `solid \| outline \| soft`                        | `@color`                       |
| Listbox / Dropdown / Select / Autocomplete | `default \| outlined \| faded` → `solid \| outline \| subtle`                      | `@color`                       |
| CloseButton                                | `transparent \| subtle` → `ghost \| soft` (prop was already `@variant`)            | —                              |
| Spinner, ProgressBar, Switch               | —                                                                                  | `@color`                       |
| FormFeedback                               | —                                                                                  | **`@status`**                  |

Notes:

- Chip's `faded` becomes `soft` (a borderless tint). Listbox's `faded` becomes
  `subtle` (a tint **with** a border). Same old name, different treatments —
  do not assume one map applies to both.
- `@appearance="custom"` on Button keeps its name and passes through unchanged.
- Select, Dropdown, and Autocomplete forward both axes to the Listbox they
  render internally. Pass the new prop at whichever level you set the old one.

### Example

```gts
{{! Before }}
<Button @appearance='outlined' @intent='danger'>Delete</Button>
<Chip @appearance='faded' @intent='default'>Draft</Chip>

{{! After }}
<Button @variant='outline' @color='danger'>Delete</Button>
<Chip @variant='soft' @color='neutral'>Draft</Chip>
```

### Deprecation ids

Silence them individually while you migrate if you need to:

```
frontile.button.appearance        frontile.button.intent
frontile.button-group.appearance  frontile.button-group.intent
frontile.toggle-button.appearance frontile.toggle-button.intent
frontile.chip.appearance          frontile.chip.intent
frontile.listbox.appearance       frontile.listbox.intent
frontile.dropdown.appearance      frontile.dropdown.intent
frontile.select.appearance        frontile.select.intent
frontile.autocomplete.appearance  frontile.autocomplete.intent
frontile.close-button.variant-values
frontile.spinner.intent           frontile.progress-bar.intent
frontile.switch.intent            frontile.form-feedback.intent
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
guide is the only signal you get. Everything else here fails loudly: the old
spelling leaves the type union, so Glint rejects it at build time.

| Component                                                          | Pre-release                                  | v0.18 final                                                            |
| ------------------------------------------------------------------ | -------------------------------------------- | ---------------------------------------------------------------------- |
| Kbd                                                                | `@appearance="default \| outlined \| faded"` | `@variant="solid \| outline \| subtle"` (`inherit`, `plain` unchanged) |
| Accordion                                                          | `@variant="outlined \| faded"`               | `@variant="separated \| soft"` (`ghost`, `enclosed` unchanged)         |
| Drawer                                                             | `@appearance="default \| ghost"`             | `@variant="sectioned \| flat"`                                         |
| Alert / NotificationCard                                           | `@variant="default \| tonal"`                | `@variant="surface \| soft"` (`solid` unchanged)                       |
| Alert / NotificationCard                                           | `@intent="default \| info"`                  | `@status="neutral \| primary"`                                         |
| Calendar, Kbd, Pagination, SegmentedControl, Tabs, TabNav, Tooltip | `@intent`                                    | `@color`                                                               |
| Button                                                             | `@appearance="soft"`                         | `@variant="subtle"`                                                    |
| Button                                                             | `@appearance="tonal"`                        | `@variant="soft"`                                                      |

### The notifications service option

The notification `intent:` option was also added during the 0.18 cycle. It is
now `status:`:

```js
this.notifications.add('Saved', { status: 'success' });
```

`NotificationIntent` is renamed `NotificationStatus`.

The older `appearance:` option — which _did_ ship in v0.17 — still works and
still warns, but its advice now names `status` directly rather than routing you
through `intent`. `error` continues to map onto `danger`.

## Mixing the axes across levels

`Listbox` forwards its value down to its items, and an item's own arg wins. But
mixing the old and new names across those two levels does **not** behave as you
might hope:

```hbs
{{! the listbox-level @color wins — the item renders primary, not danger }}
<Listbox @color='primary' as |l|>
  <l.Item @intent='danger'>…</l.Item>
</Listbox>
```

The inherited value arrives as the new arg, and the new arg takes precedence
over the deprecated one. `@variant`/`@appearance` behaves the same way.

**Migrate a `Listbox` and its items together** and this never arises.

## Need help?

- [Upgrading to v0.18](./index.md) for the full list of 0.18 breaking changes
- Search or open an issue on [GitHub](https://github.com/josemarluedke/frontile)
