---
title: Color and Status API Migration
order: 10
category: migrations
subcategory: v0.18
---

# Color and Status API Migration Guide

Frontile's semantic axis was named `@intent`. It is now `@color` on most
components and `@status` on three of them.

## Why two names

**`@color` is decoration. `@status` is meaning.**

On most components the value only picks a colour — a `danger` Button is a red
Button. Those take `@color`.

Three components are different, because there the value also decides what a
screen reader does:

| Component          | The value also selects                                       |
| ------------------ | ------------------------------------------------------------ |
| `Alert`            | the icon, and the ARIA role (`status` vs `alert`)            |
| `NotificationCard` | the icon, the ARIA role, and the action button's colour      |
| `FormFeedback`     | whether the message is announced **assertively or politely** |

Calling that `@color` would mean a prop named for decoration silently changing
whether a screen reader interrupts the user. Those three take `@status`.

## Value changes, library-wide

`default` becomes **`neutral`** on every colour axis. The palette category has
always been called `neutral`; `default` was the odd one out.

```hbs
{{! before }}
<Button @intent='default'>Cancel</Button>

{{! after }}
<Button @color='neutral'>Cancel</Button>
```

On `Alert` and `NotificationCard`, `info` becomes **`primary`**. `info` was
already a pure alias — it painted `primary`'s classes and differed only in the
default glyph, which stays attached to `primary`.

Final value sets:

```
@color  = neutral | primary | secondary | tertiary | success | warning | danger
@status = neutral | primary | success | warning | danger
```

## Upgrading from v0.17

These components shipped `@intent` in v0.17, so they keep accepting it behind a
deprecation until v0.19. You will see a deprecation warning until you migrate.

| Component                                       | Before    | After         |
| ----------------------------------------------- | --------- | ------------- |
| `Button`, `ButtonGroup`, `ToggleButton`         | `@intent` | `@color`      |
| `Chip`                                          | `@intent` | `@color`      |
| `Listbox`, `Dropdown`, `Select`, `Autocomplete` | `@intent` | `@color`      |
| `Spinner`                                       | `@intent` | `@color`      |
| `ProgressBar`                                   | `@intent` | `@color`      |
| `Switch`                                        | `@intent` | `@color`      |
| `FormFeedback`                                  | `@intent` | **`@status`** |

Deprecation ids, should you need to silence them while migrating:

```
frontile.button.intent          frontile.spinner.intent
frontile.button-group.intent    frontile.progress-bar.intent
frontile.toggle-button.intent   frontile.switch.intent
frontile.chip.intent            frontile.form-feedback.intent
frontile.listbox.intent         frontile.dropdown.intent
frontile.select.intent          frontile.autocomplete.intent
```

## Upgrading from a v0.18 pre-release

These components were added during the 0.18 alpha/beta cycle and never shipped
stable, so there is nothing to deprecate from. **They produce no runtime
warning** — this guide is the only signal you get.

| Component                                                                        | Pre-release                 | v0.18 final                    |
| -------------------------------------------------------------------------------- | --------------------------- | ------------------------------ |
| `Calendar`, `Kbd`, `Pagination`, `SegmentedControl`, `Tabs`, `TabNav`, `Tooltip` | `@intent`                   | `@color`                       |
| `Alert`                                                                          | `@intent="default \| info"` | `@status="neutral \| primary"` |
| `NotificationCard`                                                               | `@intent="default \| info"` | `@status="neutral \| primary"` |

Every one of these fails **loudly**: the old spelling leaves the type union, so
Glint rejects it and you will see a build error rather than a silent change.

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
{{! the listbox-level @color wins -- the item renders primary, not danger }}
<Listbox @color='primary' as |l|>
  <l.Item @intent='danger'>…</l.Item>
</Listbox>
```

The inherited value arrives as the new arg, and the new arg takes precedence
over the deprecated one. `@variant`/`@appearance` behaves the same way.

**Migrate a `Listbox` and its items together** and this never arises.

## What did not change

`@variant` is untouched by this release's semantic-axis work — see the
[Variant API Migration](./variant-color-api.md) guide for that axis.
