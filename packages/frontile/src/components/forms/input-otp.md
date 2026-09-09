---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# InputOtp

A one-time-code (OTP/PIN) field. The cells you see are decoration drawn over a single real
`<input>`, so password managers, iOS and Android SMS autofill, paste, undo and screen readers
all behave exactly as they would on an ordinary text field.

## Import

```js
import { InputOtp } from 'frontile';
```

## Usage

```gts preview
import { InputOtp } from 'frontile';

<template>
  <div class='demo-stack'>
    <InputOtp @label='Verification code' />
  </div>
</template>
```

## Groups

Split the cells into visual groups with `@groups`, an array of group sizes. `@separator`
(default `'–'`) sets the character shown between groups; it is rendered `aria-hidden`
because the underlying value never contains it.

The sizes should sum to `@length`. If they do not, the groups are adjusted to fit — you always
get exactly `@length` cells — and a warning is logged in development.

```gts preview
import { InputOtp } from 'frontile';
import { array } from '@ember/helper';

<template>
  <div class='demo-stack'>
    <InputOtp @label='Card verification' @length={{6}} @groups={{array 3 3}} @separator='-' />
  </div>
</template>
```

## Uncontrolled with `@onComplete`

The common case: let the component own its value and react only when the code is complete.
`@onComplete` fires once, when the last character lands.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { InputOtp } from 'frontile';

export default class VerifyCodeExample extends Component {
  @tracked submittedCode = '';

  handleComplete = (value: string) => {
    this.submittedCode = value;
  };

  <template>
    <div class='demo-stack'>
      <InputOtp @label='Verification code' @onComplete={{this.handleComplete}} />
      <p>Submitted: {{this.submittedCode}}</p>
    </div>
  </template>
}
```

## Controlled

Pair `@value` with `@onInput` to own the value yourself. `@onInput` fires on every
keystroke; `@onChange` follows the DOM `change` event, which on a text input fires on
blur, so a parent wired only to `@onChange` hears nothing until the field is left.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { InputOtp } from 'frontile';

export default class ControlledOtpExample extends Component {
  @tracked code = '';

  handleInput = (value: string) => {
    this.code = value;
  };

  <template>
    <div class='demo-stack'>
      <InputOtp @label='Verification code' @value={{this.code}} @onInput={{this.handleInput}} />
      <p>Current value: {{this.code}}</p>
    </div>
  </template>
}
```

## Inside a Form

Used through `<form.Field>`, InputOtp submits as a single string value under one `@name`,
the same as any other field.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from 'frontile';

export default class OtpFormExample extends Component {
  @tracked formData = { code: '' };

  handleFormChange = (result: FormResultData) => {
    this.formData = result.data;
  };

  <template>
    <div class='demo-stack'>
      <Form @data={{this.formData}} @onChange={{this.handleFormChange}} as |form|>
        <form.Field @name='code' as |field|>
          <field.InputOtp @label='Verification code' />
        </form.Field>
      </Form>
      <p>Current value: {{this.formData.code}}</p>
    </div>
  </template>
}
```

## Character rules

`@allowedChars` picks a built-in rule (`digits` is the default), which also sets the on-screen
keyboard (`inputmode`) and autocapitalization.

A value that fails the rule is rejected whole rather than stripped of the offending
characters: pasting `12-456` into a `digits` field leaves the field unchanged, it does not
become `12456`. Length is applied first — anything longer than `@length` is trimmed to its
first `@length` characters, and those are what the rule checks.

```gts preview
import { InputOtp } from 'frontile';

<template>
  <div class='demo-stack'>
    <InputOtp @label='Digits' @allowedChars='digits' @length={{4}} />
    <InputOtp @label='Letters' @allowedChars='letters' @length={{4}} />
    <InputOtp @label='Alphanumeric' @allowedChars='alphanumeric' @length={{4}} />
  </div>
</template>
```

`@pattern` overrides `@allowedChars` with a custom rule.

> **A custom `@pattern` must match partial values.** It is tested against every intermediate
> value as the user types, not just the finished code. Use `/^\d+$/`, never an anchored
> `/^\d{6}$/` — a length-anchored pattern rejects the very first keystroke and makes the
> field impossible to type into.

The rule is also set as the input's native `pattern` attribute, with any regex flags (`i`,
`u`, …) dropped. Since the rule accepts partial input, native validation will also accept an
incomplete code — it does not enforce `@length`. Check for completeness with `@onComplete` or
your form's validation.

```gts preview
import Component from '@glimmer/component';
import { InputOtp } from 'frontile';

export default class EvenDigitsExample extends Component {
  evenDigitsPattern = /^[02468]*$/;

  <template>
    <div class='demo-stack'>
      <InputOtp @label='Even digits only' @length={{4}} @pattern={{this.evenDigitsPattern}} />
    </div>
  </template>
}
```

## Masked

`@isMasked` draws a bullet in place of each entered character, for PIN-style entry. Only the
display changes: autofill and password managers keep working.

```gts preview
import { InputOtp } from 'frontile';

<template>
  <div class='demo-stack'>
    <InputOtp @label='PIN' @length={{4}} @isMasked={{true}} />
  </div>
</template>
```

## Placeholder

`@placeholder` previews the shape of the code in the empty cells, and is exposed on the input
as `aria-placeholder`. It clears from every cell as soon as anything is entered. Type a digit
in the demo below to watch it go.

```gts preview
import { InputOtp } from 'frontile';

<template>
  <div class='demo-stack'>
    <InputOtp @label='Verification code' @length={{6}} @placeholder='000000' />
  </div>
</template>
```

## Sizes

```gts preview
import { InputOtp } from 'frontile';

<template>
  <div class='demo-stack'>
    <InputOtp @label='Small' @size='sm' />
    <InputOtp @label='Medium' @size='md' />
    <InputOtp @label='Large' @size='lg' />
  </div>
</template>
```

## States

```gts preview
import { InputOtp } from 'frontile';

<template>
  <div class='demo-stack'>
    <InputOtp @label='Disabled' @isDisabled={{true}} @value='123' />
    <InputOtp @label='Verification code' @isRequired={{true}} />
    <InputOtp
      @label='Verification code'
      @description="Check your phone for a text message"
    />
    <InputOtp
      @label='Verification code'
      @errors='That code is incorrect or has expired'
    />
  </div>
</template>
```

## Accessibility

- The visible cells are pure decoration: they carry `aria-hidden="true"` and no `role`,
  `tabindex`, or `aria-label` — there is exactly one tab stop, the real input underneath.
- Provide a label with `@label` (associated via `for`/`id`) or an `aria-label` passed through
  `...attributes`.
- Editing works as it does in any text field: shift-select, select-all, backspace,
  word-delete, undo and copy/cut/paste. Arrow keys move from cell to cell.
- Validation messages passed through `@errors` are associated via `aria-describedby` and set
  `aria-invalid`, the same as other form controls.

## SMS autofill

`autocomplete="one-time-code"` is set for you, which is what lets browsers and mobile OSes
offer an incoming SMS code as a one-tap suggestion. Nothing else is required on your side.

To opt into iOS 14+ domain-bound codes, the SMS *message* needs a `@example.com #123456`
footer — that is set by whatever service sends the text.

## API

<Signature @component="InputOtp" />
