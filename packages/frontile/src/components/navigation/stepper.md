---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Stepper

Shows progress through a multi-step flow such as a checkout, an onboarding
wizard, or a form split across pages, and lets people move between the steps.

## Import

```js
import { Stepper } from 'frontile';
```

## Usage

`Stepper` yields a `List` of `Step`s and, optionally, a `Panel` for each one.
Steps are matched to panels by `@value`, never by position, so steps can be
conditional, looped, or wrapped in your own components. Without `@value` the
Stepper tracks the current step itself, starting on `@defaultValue`.

The yielded `next`, `prev`, `hasNext` and `hasPrev` move between steps from
anywhere inside the Stepper, such as a button in a panel.

```gts preview
import { Stepper, Button } from 'frontile';

<template>
  <div class='demo-stack' style='width: 44rem; max-width: none'>
    <Stepper @defaultValue='account' as |S|>
      <S.List @label='Checkout progress'>
        <S.Step @value='account' @title='Account' @description='Your details' />
        <S.Step @value='billing' @title='Billing' @description='Payment' />
        <S.Step @value='review' @title='Review' @description='Confirm' />
      </S.List>

      <S.Panel @value='account'>Create your account.</S.Panel>
      <S.Panel @value='billing'>Add a payment method.</S.Panel>
      <S.Panel @value='review'>Review your order.</S.Panel>

      <div class='flex gap-2'>
        <Button @variant='outline' @onPress={{S.prev}}>Back</Button>
        <Button @color='primary' @onPress={{S.next}}>Continue</Button>
      </div>
    </Stepper>
  </div>
</template>
```

## Orientation

`@orientation='vertical'` stacks the steps in a column and switches the arrow
keys that move between them to up and down. Titles are always visible when
vertical, so it suits long titles, many steps, and narrow screens.

```gts preview
import { Stepper } from 'frontile';

<template>
  <div class='demo-stack'>
    <Stepper @defaultValue='billing' @orientation='vertical' as |S|>
      <S.List @label='Checkout progress'>
        <S.Step @value='account' @title='Account' @description='Your details' />
        <S.Step @value='billing' @title='Billing' @description='Payment' />
        <S.Step @value='review' @title='Review' @description='Confirm' />
      </S.List>
    </Stepper>
  </div>
</template>
```

## Colors and sizes

`@color` sets the accent for complete and active steps and the filled
connector between them. It defaults to `primary`. `@size` scales the indicator
and its text.

```gts preview
import { Stepper } from 'frontile';
import { array } from '@ember/helper';

<template>
  <div class='demo-stack'>
    {{#each
      (array
        'neutral' 'primary' 'secondary' 'tertiary' 'success' 'warning' 'danger'
      )
      as |color|
    }}
      <Stepper
        @defaultValue='b'
        @color={{color}}
        @labelPosition='bottom'
        as |S|
      >
        <S.List @label='{{color}} stepper'>
          <S.Step @value='a' @title='One' />
          <S.Step @value='b' @title='Two' />
          <S.Step @value='c' @title='Three' />
        </S.List>
      </Stepper>
    {{/each}}
  </div>
</template>
```

```gts preview
import { Stepper } from 'frontile';
import { array } from '@ember/helper';

<template>
  <div class='demo-stack'>
    {{#each (array 'sm' 'md' 'lg') as |size|}}
      <Stepper
        @defaultValue='b'
        @size={{size}}
        @labelPosition='bottom'
        as |S|
      >
        <S.List @label='{{size}} stepper'>
          <S.Step @value='a' @title='One' />
          <S.Step @value='b' @title='Two' />
          <S.Step @value='c' @title='Three' />
        </S.List>
      </Stepper>
    {{/each}}
  </div>
</template>
```

## Label position

`@labelPosition='end'` (the default) puts each title and description beside its
indicator. `@labelPosition='bottom'` centers them underneath, which fits
longer titles and narrower containers. Vertical Steppers ignore it.

```gts preview
import { Stepper } from 'frontile';

<template>
  <div class='demo-stack'>
    <Stepper @defaultValue='billing' @labelPosition='bottom' as |S|>
      <S.List @label='Checkout progress'>
        <S.Step @value='account' @title='Account' @description='Your details' />
        <S.Step @value='billing' @title='Billing' @description='Payment' />
        <S.Step @value='review' @title='Review' @description='Confirm' />
      </S.List>
    </Stepper>
  </div>
</template>
```

## Icons

`@icon` takes an icon component, shown in the indicator while the step is
active or upcoming. Complete steps show a check, and invalid and loading steps
show their own marks. Passing a block named `indicator` replaces the
indicator's content entirely.

```gts preview
import { Stepper } from 'frontile';
import { UserIcon, SettingsIcon, CheckIcon } from 'site/components/icons';

<template>
  <div class='demo-stack'>
    <Stepper @defaultValue='profile' @labelPosition='bottom' as |S|>
      <S.List @label='Setup progress'>
        <S.Step @value='profile' @title='Profile' @icon={{UserIcon}} />
        <S.Step @value='preferences' @title='Preferences' @icon={{SettingsIcon}} />
        <S.Step @value='done' @title='Done' @icon={{CheckIcon}} />
      </S.List>
    </Stepper>
  </div>
</template>
```

## Loading and invalid steps

`@isLoading` swaps the indicator for a spinner while something is in flight,
and `@isInvalid` marks a step that needs attention. An invalid step is always
danger-colored, whatever `@color` is. Neither changes which step is selected.

```gts preview
import { Stepper } from 'frontile';

<template>
  <div class='demo-stack'>
    <Stepper @defaultValue='review' @labelPosition='bottom' as |S|>
      <S.List @label='Checkout progress'>
        <S.Step @value='account' @title='Account' />
        <S.Step @value='billing' @title='Billing' @isInvalid={{true}} />
        <S.Step @value='review' @title='Review' @isLoading={{true}} />
        <S.Step @value='confirm' @title='Confirm' />
      </S.List>
    </Stepper>
  </div>
</template>
```

## Completed steps

A step counts as complete when it comes before the selected step. When
completion is a business rule rather than position, pass `@isComplete` on the
step and it takes precedence. The active step is always active.

```gts preview
import { Stepper } from 'frontile';

<template>
  <div class='demo-stack'>
    <Stepper @defaultValue='b' @labelPosition='bottom' as |S|>
      <S.List @label='Onboarding'>
        <S.Step @value='a' @title='Verify email' @isComplete={{false}} />
        <S.Step @value='b' @title='Add team' />
        <S.Step @value='c' @title='Invite' @isComplete={{true}} />
      </S.List>
    </Stepper>
  </div>
</template>
```

## Disabling steps

`@isDisabled` on a step stops people selecting it: clicks are ignored, arrow
keys skip it, and it is announced as disabled. Each step's rule is yours, so
any flow can be expressed. This one lets people go back to any step they have
already reached, but not skip ahead.

`next` and `prev` skip disabled steps, so a button that moves to a step that is
still disabled calls `goTo`, or sets `@value` itself as below. `goTo` can reach
a disabled step because `@isDisabled` governs what people do, not what your
code does.

```gts preview collapsible
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Stepper, Button } from 'frontile';

const STEPS = ['account', 'billing', 'review'];

export default class StepperBackOnlyExample extends Component {
  @tracked step = 'account';
  @tracked furthest = 0;

  isAhead = (value: string): boolean => STEPS.indexOf(value) > this.furthest;

  setStep = (value: string): void => {
    this.step = value;
    this.furthest = Math.max(this.furthest, STEPS.indexOf(value));
  };

  continue = (): void => {
    const next = STEPS[STEPS.indexOf(this.step) + 1];
    if (next) {
      this.setStep(next);
    }
  };

  <template>
    <div class='demo-stack'>
      <Stepper
        @value={{this.step}}
        @onChange={{this.setStep}}
        @labelPosition='bottom'
        as |S|
      >
        <S.List @label='Checkout progress'>
          <S.Step
            @value='account'
            @title='Account'
            @isDisabled={{this.isAhead 'account'}}
          />
          <S.Step
            @value='billing'
            @title='Billing'
            @isDisabled={{this.isAhead 'billing'}}
          />
          <S.Step
            @value='review'
            @title='Review'
            @isDisabled={{this.isAhead 'review'}}
          />
        </S.List>

        <Button @color='primary' @onPress={{this.continue}}>Continue</Button>
      </Stepper>
    </div>
  </template>
}
```

## Controlled and uncontrolled

The mode is decided by whether `@value` is passed, not by what it holds. Omit
it and `Stepper` keeps the current step itself, with `@onChange` still firing
so you can observe it. Pass it, even as `undefined`, and the selection only
follows what you pass: `@onChange` becomes a request, and your handler decides
whether the step actually changes.

That makes a controlled Stepper the place to validate before moving on.

Whether a step is available is always your call: the Stepper cannot know what
"terms accepted" means. Pass the condition to `@isDisabled` so the step looks
and behaves unavailable (styled, skipped by arrow keys, ignored on click), and
keep the `@onChange` check as the guard for anything that moves the step
without going through the step itself.

```gts preview collapsible
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { Stepper } from 'frontile';

export default class StepperValidatedExample extends Component {
  @tracked step = 'account';
  @tracked accepted = false;

  get planLocked(): boolean {
    return !this.accepted;
  }

  setStep = (value: string): void => {
    if (this.step === 'account' && value !== 'account' && !this.accepted) {
      return;
    }
    this.step = value;
  };

  toggleAccepted = (): void => {
    this.accepted = !this.accepted;
  };

  <template>
    <div class='demo-stack'>
      <Stepper
        @value={{this.step}}
        @onChange={{this.setStep}}
        @labelPosition='bottom'
        as |S|
      >
        <S.List @label='Sign up'>
          <S.Step @value='account' @title='Account' />
          <S.Step @value='plan' @title='Plan' @isDisabled={{this.planLocked}} />
        </S.List>

        <S.Panel @value='account'>
          <label class='flex items-center gap-2'>
            <input type='checkbox' checked={{this.accepted}} {{on 'change' this.toggleAccepted}} />
            Accept the terms to continue
          </label>
        </S.Panel>
        <S.Panel @value='plan'>Pick a plan.</S.Panel>
      </Stepper>
    </div>
  </template>
}
```

## Starting over

The Stepper only owns the current step, and only when uncontrolled. Resetting
a flow means going back to the first step with `goTo` (or setting `@value`)
and clearing your own form state and flags.

```gts preview
import { fn } from '@ember/helper';
import { Stepper, Button } from 'frontile';

<template>
  <div class='demo-stack'>
    <Stepper @defaultValue='review' @labelPosition='bottom' as |S|>
      <S.List @label='Checkout progress'>
        <S.Step @value='account' @title='Account' />
        <S.Step @value='billing' @title='Billing' />
        <S.Step @value='review' @title='Review' />
      </S.List>

      <Button @variant='outline' @onPress={{fn S.goTo 'account'}}>Start over</Button>
    </Stepper>
  </div>
</template>
```

## Keeping panel content

Only the selected step's panel is rendered, so a form inside another step's
panel is torn down when you move away and starts empty when you return. Move
the form's state into a parent, or set `@keepMounted` on the `Panel` to keep
its content in the DOM, hidden, while another step is selected.

A kept-mounted panel keeps running its own effects while hidden, and an
autofocus inside it fires when it first renders, not when its step is selected.

```gts preview
import { Stepper } from 'frontile';

<template>
  <div class='demo-stack'>
    <Stepper @defaultValue='account' @labelPosition='bottom' as |S|>
      <S.List @label='Sign up'>
        <S.Step @value='account' @title='Account' />
        <S.Step @value='plan' @title='Plan' />
      </S.List>

      <S.Panel @value='account' @keepMounted={{true}}>
        <label class='flex flex-col gap-1'>
          Name
          <input class='rounded border border-neutral-soft p-2' />
        </label>
      </S.Panel>
      <S.Panel @value='plan'>Pick a plan.</S.Panel>
    </Stepper>
  </div>
</template>
```

## Splitting panels into components

A panel's content can live in its own component. Type its argument with
`StepperApi` and pass the yielded object, or just the helper you need.

```gts
import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import type { StepperApi } from 'frontile';

interface Signature {
  Args: { stepper: StepperApi<string> };
}

export default class BillingStep extends Component<Signature> {
  <template>
    <button type='button' {{on 'click' @stepper.next}}>Continue</button>
  </template>
}
```

```gts
<S.Panel @value='billing'>
  <BillingStep @stepper={{S}} />
</S.Panel>
```

## Using with routes

A controlled Stepper works with the router: pass the route name as `@value`
and move with your own transition in `@onChange`. The URL stays the source of
truth, so back, forward and deep links work. Leave out the panels and render
the route's outlet instead.

```gts
<Stepper
  @value={{this.router.currentRouteName}}
  @onChange={{this.goToStep}}
  as |S|
>
  <S.List @label='Checkout progress'>
    <S.Step @value='checkout.account' @title='Account' />
    <S.Step @value='checkout.billing' @title='Billing' />
    <S.Step @value='checkout.review' @title='Review' />
  </S.List>
</Stepper>

{{outlet}}
```

## Responsive

A horizontal Stepper measures its own width, not the screen's, so it adapts
inside modals and sidebars as well as pages. Give it a parent with a definite
width, such as a block element or a full-width flex item: a parent that
shrinks to fit its content leaves it no width to measure.

When the row does not fit, `@collapse` decides what happens. It defaults to
`'menu'`: the row is replaced by a button showing the current step ("Step 2 of
4" and its title). Pressing it opens the steps as a floating list, laid out
like a vertical Stepper, over the content below. Choosing a step selects it
and closes the list.

| `@labelPosition` | Full row shows from |
| ---------------- | ------------------- |
| `bottom`         | 28rem (448px)       |
| `end`            | 42rem (672px)       |

Drag the handle at the right edge of the box to resize it.

```gts preview
import { Stepper } from 'frontile';

<template>
  <div
    class='w-full overflow-hidden rounded border border-neutral-soft p-4'
    style='resize: horizontal; width: 100%; min-width: 14rem; max-width: 100%'
  >
    <Stepper @defaultValue='billing' @labelPosition='bottom' as |S|>
      <S.List @label='Checkout progress'>
        <S.Step @value='account' @title='Account' />
        <S.Step @value='billing' @title='Billing' />
        <S.Step @value='review' @title='Review' />
        <S.Step @value='confirm' @title='Confirm' />
      </S.List>
    </Stepper>
  </div>
</template>
```

The list is a native popover, so it renders in the top layer: an ancestor's
`overflow: hidden`, like the box above, does not clip it. Escape and clicking
away close it, and focus returns to the button. The steps stay in the DOM while
the list is closed, so `next` and `prev` work throughout.

### Summary line instead of a menu

Set `@collapse='summary'` to keep the row at narrow widths instead. Only the
indicators and connectors show, with the "Step 2 of 4" line and the active
step's title beneath them. Every title stays available to screen readers.
Wider than the threshold, the titles appear and the line goes.

```gts preview
import { Stepper } from 'frontile';

<template>
  <div
    class='w-full overflow-hidden rounded border border-neutral-soft p-4'
    style='resize: horizontal; width: 100%; min-width: 14rem; max-width: 100%'
  >
    <Stepper
      @defaultValue='billing'
      @labelPosition='bottom'
      @collapse='summary'
      as |S|
    >
      <S.List @label='Checkout progress'>
        <S.Step @value='account' @title='Account' />
        <S.Step @value='billing' @title='Billing' />
        <S.Step @value='review' @title='Review' />
        <S.Step @value='confirm' @title='Confirm' />
      </S.List>
    </Stepper>
  </div>
</template>
```

Narrow screens fit roughly six or seven steps as indicators alone; beyond
that, prefer the menu or a vertical Stepper. Set `@collapse={{false}}` to
never collapse. Vertical Steppers never collapse.

### Changing the thresholds

The two widths are theme tokens. Redefine them in your stylesheet's `@theme`
block to move them for the whole app. They are named for Stepper so that
redefining Tailwind's own `--container-*` sizes does not affect them.

```css
@theme {
  --container-fr-stepper-bottom: 24rem;
  --container-fr-stepper-end: 36rem;
}
```

For a single Stepper, set `@collapse={{false}}` and write your own rules on
the slots.

## Accessibility

`Stepper` renders an ordered list (`List`) of items, each holding a button.
The selected step has `aria-current="step"`. It is not a tab list: steps do
not need a panel, and moving between them does not have to change content.

`Stepper.List` needs an accessible name from `@label`, or pass
`aria-labelledby` on it directly. Each `Panel` is a `role="region"` labelled by
its step. Loading steps set `aria-busy`, and invalid steps are announced as
"Invalid" in addition to being colored.

When collapsed to a menu, the button is a disclosure (`aria-expanded`,
`aria-controls`) whose text names the current step; the list inside is the same
list of buttons, so `aria-current` and the keys below apply unchanged, with the
up and down arrows. While the menu is closed the list is hidden from assistive
technology entirely, so the button's text is how the current step is
announced, and `Tab` reaches the button rather than the steps. With `@collapse='summary'`, titles are visually hidden but
still read aloud, and the "Step N of M" line is hidden from assistive
technology so the current step is not announced twice.

| Key                        | Behaviour                                                         |
| -------------------------- | ----------------------------------------------------------------- |
| `Tab`                      | Moves focus into or out of the steps. Only one step is a tab stop. |
| `ArrowRight` / `ArrowDown` | Moves focus to the next enabled step, wrapping at the end.        |
| `ArrowLeft` / `ArrowUp`    | Moves focus to the previous enabled step, wrapping at the start.  |
| `Home` / `End`             | Moves focus to the first / last enabled step.                     |
| `Enter` / `Space`          | Selects the focused step.                                         |

Arrow keys move focus without selecting, so passing a step never triggers
validation or navigation. Horizontal orientation uses left and right, vertical
uses up and down. Disabled steps are skipped.

Each step's clickable area is at least 44px square at every size.

The text the Stepper adds is English by default. Pass `@invalidLabel` on a step
to change what screen readers announce for an invalid step, and
`@summaryLabel` on the Stepper, a function taking the position and total, to
change the "Step 2 of 4" line.

## API

<Signature @component="Stepper" />
<Signature @component="StepperList" />
<Signature @component="StepperStep" />
<Signature @component="StepperPanel" />
