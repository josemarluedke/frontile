---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Tabs

A set of panels shown one at a time, with an indicator that slides between the
tabs. Use it when the content belongs to one page and switching between it
should not change the URL — for navigation between routes, reach for
[TabNav](./tab-nav) instead.

## Import

```js
import { Tabs } from 'frontile';
```

## Usage

`@defaultValue` picks the tab that starts selected, and `Tabs` tracks the rest
itself. `t.List` groups the tabs and needs an accessible `@label`; each
`t.Panel` is paired with a `t.Tab` of the same `@value` and only the selected
one renders.

```gts preview
import { Tabs } from 'frontile';

<template>
  <Tabs @defaultValue='account' as |t|>
    <t.List @label='Settings'>
      <t.Tab @value='account'>Account</t.Tab>
      <t.Tab @value='security'>Security</t.Tab>
      <t.Tab @value='billing'>Billing</t.Tab>
    </t.List>

    <t.Panel @value='account'>Update your name, email, and photo.</t.Panel>
    <t.Panel @value='security'>Manage passwords and two-factor auth.</t.Panel>
    <t.Panel @value='billing'>View invoices and update your plan.</t.Panel>
  </Tabs>
</template>
```

## Controlled and uncontrolled

The mode is decided by whether `@value` is _passed_, not by what it holds.
Omit the argument entirely and `Tabs` is uncontrolled; write it at all —
including `@value={{undefined}}` — and it is controlled.

Without `@value`, `@defaultValue` seeds the initial selection and `Tabs` keeps
the current one internally, while `@onChange` still fires on every pick so you
can observe the value without owning it. Passing `@value` makes the selection
reflect only what you pass, so pair it with `@onChange` and assign the new
value back to your own state — reach for this when something outside `Tabs`
also drives the selection, such as a query parameter.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Tabs } from 'frontile';

export default class Example extends Component {
  @tracked section = 'account';

  onChange = (value: string): void => {
    this.section = value;
  };

  <template>
    <div class='flex flex-col items-start gap-3'>
      <Tabs @value={{this.section}} @onChange={{this.onChange}} as |t|>
        <t.List @label='Settings'>
          <t.Tab @value='account'>Account</t.Tab>
          <t.Tab @value='security'>Security</t.Tab>
        </t.List>

        <t.Panel @value='account'>Account panel</t.Panel>
        <t.Panel @value='security'>Security panel</t.Panel>
      </Tabs>

      <p class='text-body-sm text-neutral-strong'>Selected: {{this.section}}</p>
    </div>
  </template>
}
```

## Variants

`@variant='solid'` (the default) renders a filled, pill-shaped indicator on a
recessed track. `@variant='underline'` drops the track and pins a thin bar to
the leading edge instead — reach for it in a denser layout, such as a page
header, where the solid track would compete with surrounding content.

```gts preview
import { Tabs } from 'frontile';

<template>
  <div class='flex flex-col items-start gap-6'>
    <Tabs @defaultValue='account' @variant='solid' as |t|>
      <t.List @label='Solid'>
        <t.Tab @value='account'>Account</t.Tab>
        <t.Tab @value='security'>Security</t.Tab>
        <t.Tab @value='billing'>Billing</t.Tab>
      </t.List>
    </Tabs>

    <Tabs @defaultValue='account' @variant='underline' as |t|>
      <t.List @label='Underline'>
        <t.Tab @value='account'>Account</t.Tab>
        <t.Tab @value='security'>Security</t.Tab>
        <t.Tab @value='billing'>Billing</t.Tab>
      </t.List>
    </Tabs>
  </div>
</template>
```

## Intents

`@intent` colors the indicator, so the selected tab carries the meaning
rather than the whole component. `default` keeps the neutral fill; the rest
tint it and switch the selected label to the matching contrast ink in the
`solid` variant.

```gts preview
import { Tabs } from 'frontile';
import { array } from '@ember/helper';

<template>
  <div class='flex flex-col items-start gap-3'>
    {{#each
      (array
        'default' 'primary' 'secondary' 'tertiary' 'success' 'warning' 'danger'
      )
      as |intent|
    }}
      <Tabs @defaultValue='account' @intent={{intent}} as |t|>
        <t.List @label='{{intent}} intent'>
          <t.Tab @value='account'>Account</t.Tab>
          <t.Tab @value='security'>Security</t.Tab>
        </t.List>
      </Tabs>
    {{/each}}
  </div>
</template>
```

## Sizes

```gts preview
import { Tabs } from 'frontile';
import { array } from '@ember/helper';

<template>
  <div class='flex flex-col items-start gap-3'>
    {{#each (array 'sm' 'md' 'lg') as |size|}}
      <Tabs @defaultValue='account' @size={{size}} as |t|>
        <t.List @label='{{size}} size'>
          <t.Tab @value='account'>Account</t.Tab>
          <t.Tab @value='security'>Security</t.Tab>
        </t.List>
      </Tabs>
    {{/each}}
  </div>
</template>
```

## Vertical

`@orientation='vertical'` stacks the tabs in a column, switches the arrow
keys that move between them to up/down, and lays the panel out beside the
list rather than beneath it.

```gts preview
import { Tabs } from 'frontile';

<template>
  <Tabs @defaultValue='account' @orientation='vertical' as |t|>
    <t.List @label='Settings'>
      <t.Tab @value='account'>Account</t.Tab>
      <t.Tab @value='security'>Security</t.Tab>
      <t.Tab @value='billing'>Billing</t.Tab>
    </t.List>

    <t.Panel @value='account'>Update your name, email, and photo.</t.Panel>
    <t.Panel @value='security'>Manage passwords and two-factor auth.</t.Panel>
    <t.Panel @value='billing'>View invoices and update your plan.</t.Panel>
  </Tabs>
</template>
```

Both variants work vertically. `underline` pins its bar to the inline start
edge and runs the rule down the side of the list, so it suits a settings
sidebar where a filled track would compete with the panel beside it.

```gts preview
import { Tabs } from 'frontile';

<template>
  <Tabs
    @defaultValue='account'
    @orientation='vertical'
    @variant='underline'
    as |t|
  >
    <t.List @label='Settings'>
      <t.Tab @value='account'>Account</t.Tab>
      <t.Tab @value='security'>Security</t.Tab>
      <t.Tab @value='billing'>Billing</t.Tab>
    </t.List>

    <t.Panel @value='account'>Update your name, email, and photo.</t.Panel>
    <t.Panel @value='security'>Manage passwords and two-factor auth.</t.Panel>
    <t.Panel @value='billing'>View invoices and update your plan.</t.Panel>
  </Tabs>
</template>
```

## Full width

`@isFullWidth={{true}}` stretches the tab list to its container and gives
every tab equal width.

```gts preview
import { Tabs } from 'frontile';

<template>
  <div
    class='flex w-96 max-w-full flex-col items-start gap-3 rounded-lg border border-neutral-soft p-4'
  >
    <Tabs @defaultValue='account' as |t|>
      <t.List @label='Default width'>
        <t.Tab @value='account'>Account</t.Tab>
        <t.Tab @value='security'>Security</t.Tab>
      </t.List>
    </Tabs>

    <Tabs @defaultValue='account' @isFullWidth={{true}} as |t|>
      <t.List @label='Full width'>
        <t.Tab @value='account'>Account</t.Tab>
        <t.Tab @value='security'>Security</t.Tab>
      </t.List>
    </Tabs>
  </div>
</template>
```

## Disabled tabs

An individual tab can be disabled with its own `@isDisabled`; keyboard
navigation skips it and it cannot be clicked or selected. `@isDisabled` on
`Tabs` disables every tab.

```gts preview
import { Tabs } from 'frontile';

<template>
  <Tabs @defaultValue='account' as |t|>
    <t.List @label='Settings'>
      <t.Tab @value='account'>Account</t.Tab>
      <t.Tab @value='billing' @isDisabled={{true}}>Billing</t.Tab>
      <t.Tab @value='security'>Security</t.Tab>
    </t.List>
  </Tabs>
</template>
```

## Manual activation

`@activationMode='manual'` changes what the arrow keys do: they move focus
between tabs without selecting them, and the focused tab is only selected on
`Enter` or `Space`. The default, `automatic`, selects a tab as soon as focus
reaches it. Reach for `manual` when selecting a tab is expensive enough — a
network request, a heavy re-render — that arrowing past several tabs
shouldn't trigger it each time.

```gts preview
import { Tabs } from 'frontile';

<template>
  <Tabs @defaultValue='account' @activationMode='manual' as |t|>
    <t.List @label='Settings'>
      <t.Tab @value='account'>Account</t.Tab>
      <t.Tab @value='security'>Security</t.Tab>
      <t.Tab @value='billing'>Billing</t.Tab>
    </t.List>

    <t.Panel @value='account'>Account panel</t.Panel>
    <t.Panel @value='security'>Security panel</t.Panel>
    <t.Panel @value='billing'>Billing panel</t.Panel>
  </Tabs>
</template>
```

## Custom styling

Every tab publishes `data-selected` (`"true"` / `"false"`) and
`data-disabled`, so a `@classes.tab` override that should only affect the
selected tab needs a `data-[selected=true]:` modifier rather than reaching
for `aria-selected` or `:disabled`.

```gts preview
import { Tabs } from 'frontile';
import { hash } from '@ember/helper';

<template>
  <Tabs
    @defaultValue='account'
    @classes={{hash
      tab='data-[selected=true]:text-on-primary'
      indicator='bg-primary'
    }}
    as |t|
  >
    <t.List @label='Settings'>
      <t.Tab @value='account'>Account</t.Tab>
      <t.Tab @value='security'>Security</t.Tab>
    </t.List>
  </Tabs>
</template>
```

## Accessibility

`t.List` renders `role="tablist"` with `aria-orientation`, each `t.Tab` is a
`role="tab"` (`aria-selected`, `aria-controls` pointing at its panel), and
each `t.Panel` is a `role="tabpanel"` (`aria-labelledby` pointing back at its
tab, `tabindex="0"`) that only exists in the DOM while selected.

`t.List` needs an accessible name from `@label`, or pass `aria-labelledby` on
`t.List` directly.

| Key                        | Behaviour                                                                                            |
| -------------------------- | ---------------------------------------------------------------------------------------------------- |
| `Tab`                      | Moves focus into or out of the tab list. Only the selected tab is a tab stop.                        |
| `ArrowRight` / `ArrowDown` | Moves focus to the next enabled tab, wrapping at the end.                                            |
| `ArrowLeft` / `ArrowUp`    | Moves focus to the previous enabled tab, wrapping at the start.                                      |
| `Home` / `End`             | Moves focus to the first / last enabled tab.                                                         |
| `Enter` / `Space`          | Selects the focused tab. Only needed in manual activation — automatic activation selects on arrival. |

Horizontal orientation uses left/right, vertical orientation uses up/down.
Disabled tabs are skipped entirely.

## API

<Signature @component="Tabs" />
<Signature @component="TabsTab" />
<Signature @component="TabsPanel" />
