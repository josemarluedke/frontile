# Frontile v0.18 API Naming

Frontile v0.18 renamed two styling axes across most components. What an old spelling does
depends on the installed version (check `node_modules/frontile/package.json`):

- **0.18.x:** it still resolves, maps to the new value, and logs a deprecation warning once per
  component/arg pair. Nothing fails, so a stale example keeps "working".
- **0.19.0 and later:** it is **removed**. In a development or test build it fails an assertion
  that names the replacement (`Button: @appearance was removed in 0.19.0. Use @variant.`). In a
  production build the assertion is stripped and the old arg is silently ignored.

Either way, always write the new names. The mapping tables below are what you need to convert
old call sites.

## The two axes

| Axis           | Old prop      | New prop                            | Meaning                           |
| -------------- | ------------- | ----------------------------------- | --------------------------------- |
| How it's drawn | `@appearance` | `@variant`                          | filled, tinted, bordered, or bare |
| What it means  | `@intent`     | `@color` (or `@status` — see below) | which semantic color              |

`@variant`'s shared value vocabulary: `solid \| soft \| subtle \| outline \| ghost \| plain`
(components use a subset: check the per-component table).

`@color`'s shared value vocabulary: `neutral \| primary \| secondary \| tertiary \| success \| warning \| danger`.

`default` → `neutral` on every color axis. `default` → `solid` on every variant axis (where
`default` existed as a variant value).

## `@color` vs `@status`: pick the right one

**`@color` is decoration. `@status` is meaning.** On most components the value only picks a
color. On three components (**Alert**, **NotificationCard**, **FormFeedback**) the value
_also_ decides the ARIA role or, for FormFeedback, whether the message is announced
assertively or politely. Passing `@color` to these three is wrong even though it may look like
it "should" work by analogy with Button/Chip/etc:

| Component          | Prop                                                  | The value also selects                                                                           |
| ------------------ | ----------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| `Alert`            | `@status`                                             | icon + ARIA role (`status` vs `alert`; `warning`/`danger` → `alert`, everything else → `status`) |
| `NotificationCard` | `status` on the notification, **not** a `@status` arg | icon + ARIA role + the action button's color                                                     |
| `FormFeedback`     | `@status`                                             | whether the message is `aria-live="assertive"` or `"polite"`                                     |

`@status` values: `neutral \| primary \| success \| warning \| danger` (no `secondary`/`tertiary`,
verified against `AlertStatus` in `alert.gts` and `FormFeedbackVariants['status']`).

NotificationCard is the exception to the column above: it takes no `@status` argument. It
reads `@notification.status`, so the value is set when the notification is created, via the
service call `this.notifications.add('Saved', { status: 'success' })`, not on the component tag.

Every other component with a color axis (Button, ButtonGroup, ToggleButton, Chip, Listbox,
Dropdown, Select, Autocomplete, CloseButton is variant-only, Spinner, ProgressBar, Switch,
Calendar, Pagination, SegmentedControl, Tabs, Tooltip) takes `@color`.

Alert and NotificationCard were added during the 0.18 pre-release cycle and shipped with only
`@status`. There is no deprecated `@intent`/`@color` alias for them, so nothing warns if you
get this wrong; Glint will only catch it if you also pass an invalid variant value. FormFeedback
carried a deprecated `@intent` alias through 0.18.x, because that component's prop already
existed pre-0.18; it was removed in 0.19.0. A FormFeedback whose `@intent` is ignored falls back
to its default status, `danger`, so a stale `@intent="success"` renders as an error.

## Per-component value rename table

Verified against `docs/migrations/v0.18/component-api-naming.md` and cross-checked against the
`tv()` variant definitions in `packages/theme/src/components/*.ts`.

| Component                                  | `@appearance` → `@variant`                                                                           | `@intent` → `@color`/`@status` |
| ------------------------------------------ | ---------------------------------------------------------------------------------------------------- | ------------------------------ |
| Button / ButtonGroup / ToggleButton        | `default \| outlined \| minimal \| custom` → `solid \| outline \| plain \| custom`                   | `@color`                       |
| Chip                                       | `default \| outlined \| faded` → `solid \| outline \| soft`                                          | `@color`                       |
| Listbox / Dropdown / Select / Autocomplete | `default \| outlined \| faded` → `solid \| outline \| subtle`                                        | `@color`                       |
| CloseButton                                | `transparent \| subtle` → `ghost \| soft` (the prop was already named `@variant`, not `@appearance`) | —                              |
| Spinner, ProgressBar, Switch               | —                                                                                                    | `@color`                       |
| Alert, NotificationCard                    | — (see note below)                                                                                   | `@status`                      |
| FormFeedback                               | —                                                                                                    | `@status`                      |

### Other removed arguments

These warned in 0.18.x and were removed in 0.19.0. Drop them, or switch to the replacement:

| Component   | Old prop   | Replacement                                                  |
| ----------- | ---------- | ------------------------------------------------------------ |
| Chip        | `@radius`  | none: Chip is always a pill. Use `Badge` for a squared label |
| CloseButton | `@onClick` | `@onPress`                                                   |

### The `faded` trap — same old name, different new value per component

`faded` does **not** map to the same thing everywhere. This is the single easiest mistake to
make, because copying a working Chip call site to a Listbox/Select/Dropdown/Autocomplete call
site (or vice versa) silently produces the wrong visual:

- **Chip**: `@appearance="faded"` → `@variant="soft"`: a borderless tint.
- **Listbox / Dropdown / Select / Autocomplete**: `@appearance="faded"` → `@variant="subtle"`:
  a tint **with** a border.

Verified in `packages/theme/src/components/chip.ts` (`variant: solid | outline | soft`) and
`packages/theme/src/components/listbox.ts` (`variant: solid | outline | subtle`), and in the
`variant?:` union types declared in `chip.gts` and `listbox.gts`.

### Button's full appearance union is wider than the migration table shows

The migration doc's table only lists `default | outlined | minimal | custom`, but the 0.18.x
`appearance` union on Button was:

```ts
appearance?: 'default' | 'soft' | 'outlined' | 'minimal' | 'tonal' | 'custom';
```

`soft` and `tonal` were deprecated values too, and in 0.18.x they warned under the same
deprecation id as the rest. Full Button mapping:

| `@appearance` | `@variant` |
| ------------- | ---------- |
| `default`     | `solid`    |
| `outlined`    | `outline`  |
| `minimal`     | `plain`    |
| `soft`        | `subtle`   |
| `tonal`       | `soft`     |
| `custom`      | `custom`   |

**`@appearance="soft"` changes meaning, not just name.** Old `soft` was a tint _with_ a border;
new `@variant="soft"` is a tint _without_ one. If you used `@appearance="soft"`, the value you
want is `@variant="subtle"`, not `@variant="soft"`. Nothing catches this automatically since
`soft` is a valid value on both sides.

`@appearance="custom"` on Button becomes `@variant="custom"`: the value keeps its name and still
produces empty variant classes.

### `default` → `neutral`, `info` → `primary`

`default` becomes `neutral` on every color axis (`@intent="default"` → `@color="neutral"`).

On `Alert` and `NotificationCard` specifically, `info` folds into `primary`. It painted
`primary`'s classes already and only differed in its default icon, which now stays attached to
`primary`. Verified in `alert.gts`: `AlertStatus = 'neutral' | 'primary' | 'success' | 'warning' | 'danger'`.
There is no separate `info` value in the current API at all (it only existed pre-stable).

## Components added during the 0.18 pre-release cycle (no deprecation warning)

These never shipped in a stable release before being renamed, so there is nothing to warn you
with: an old spelling here either leaves the type union (Glint rejects it at build time) or,
for Alert/NotificationCard's status axis, simply isn't present as a prop at all:

| Component                                                          | Pre-release                                  | v0.18 final                                                            |
| ------------------------------------------------------------------ | -------------------------------------------- | ---------------------------------------------------------------------- |
| Kbd                                                                | `@appearance="default \| outlined \| faded"` | `@variant="solid \| outline \| subtle"` (`inherit`, `plain` unchanged) |
| Accordion                                                          | `@variant="outlined \| faded"`               | `@variant="separated \| soft"` (`ghost`, `enclosed` unchanged)         |
| Drawer                                                             | `@appearance="default \| ghost"`             | `@variant="sectioned \| flat"`                                         |
| Alert / NotificationCard                                           | `@variant="default \| tonal"`                | `@variant="surface \| soft"` (`solid` unchanged)                       |
| Alert / NotificationCard                                           | `@intent="default \| info"`                  | `@status="neutral \| primary"`                                         |
| Calendar, Kbd, Pagination, SegmentedControl, Tabs, TabNav, Tooltip | `@intent`                                    | `@color`                                                               |

Verified Kbd's current variant union in `kbd.gts`/`kbd.ts`: `solid \| outline \| subtle \| inherit \| plain`.
Verified Accordion's current variant union in `accordion.ts`: `ghost \| separated \| soft \| enclosed`.
Verified Alert/NotificationCard's variant union: `surface \| soft \| solid` (in both `alert.gts`
and `notification-card.gts`).

## The notifications service

The notifications service takes `status:`. There is no `intent:` option here: that axis was
never named `intent` on notifications, so do not go looking for it:

```js
this.notifications.add('Saved', { status: 'success' });
```

The old option was `appearance:` (`info | success | warning | error`), deprecated in 0.18.x and
removed in 0.19.0, along with its `NotificationAppearance` type. It applied both to `add()` options
and to the `'@frontile/notifications'` defaults in `config/environment.js`. Convert it to `status:`
(`neutral | primary | success | warning | danger`). Two values change rather than passing
through:

| `appearance:` | becomes `status:` |
| ------------- | ----------------- |
| `error`       | `danger`          |
| `info`        | `primary`         |

From 0.19.0, a stale `appearance:` fails a development assertion, and in production it is
ignored, so the notification renders with the default `neutral` status.

## Listbox and its items

`Listbox` forwards its `@color`/`@variant` down to its items, and an item's own arg wins over the
inherited one. When converting old call sites, migrate a Listbox and all of its items together.

## Quick reference: is a call site correct?

1. Is this Alert, NotificationCard, or FormFeedback? → use `@status`, not `@color`.
2. Is this Chip using `faded`? → `@variant="soft"`. Is it Listbox/Dropdown/Select/Autocomplete
   using `faded`? → `@variant="subtle"`. Never assume these two match.
3. Is this Button using `@appearance="soft"`? → the new value is `@variant="subtle"`, not
   `@variant="soft"` (meaning changed, not just the name).
4. Is this Button using `@appearance="tonal"`? → `@variant="soft"`.
5. Any `default` on a color axis → `neutral`. Any `default` on a variant axis → `solid`.
6. `info` on Alert/NotificationCard → `primary` (and there's no `info` value left to pass at
   all in the current API).
