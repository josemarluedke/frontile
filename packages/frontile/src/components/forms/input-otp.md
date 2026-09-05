---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# InputOtp

A one-time-code (OTP/PIN) field. Under the hood it is a single real `<input>` made invisible
over decorative cells, which is why password managers, iOS/Android SMS autofill, paste, undo
and screen readers all work without any of it being reimplemented.

## Import

```js
import { InputOtp } from 'frontile';
```

## Usage

```gts preview
import { InputOtp } from 'frontile';

<template><InputOtp @label='Verification code' /></template>
```

## Groups

Split the cells into visual groups with `@groups`, an array of group sizes that must sum to
`@length`. `@separator` (default `'–'`) sets the character shown between groups; it is
rendered `aria-hidden` because the underlying value never contains it.

```gts preview
import { InputOtp } from 'frontile';
import { array } from '@ember/helper';

<template>
  <InputOtp @label='Card verification' @length={{6}} @groups={{array 3 3}} @separator='-' />
</template>
```

## Uncontrolled with `@onComplete`

The common case: let the component own its value and react only when the code is complete.
`@onComplete` fires once on the transition to a full code, not on every re-render of an
already-complete value.

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
    <div class='flex flex-col gap-2'>
      <InputOtp @label='Verification code' @onComplete={{this.handleComplete}} />
      <p>Submitted: {{this.submittedCode}}</p>
    </div>
  </template>
}
```

## Controlled

Pair `@value` with `@onChange` to own the value yourself.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { InputOtp } from 'frontile';

export default class ControlledOtpExample extends Component {
  @tracked code = '';

  handleChange = (value: string) => {
    this.code = value;
  };

  <template>
    <div class='flex flex-col gap-2'>
      <InputOtp @label='Verification code' @value={{this.code}} @onChange={{this.handleChange}} />
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
    <div class='flex flex-col gap-4'>
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

`@allowedChars` picks a built-in rule (`digits` is the default) that also drives the
on-screen keyboard (`inputmode`) and autocapitalization. Rejection is all-or-nothing: a
pasted value that fails the rule is dropped whole, never silently filtered down to the parts
that pass — pasting `12-456` into a `digits` field does not become `12456`, it is rejected
entirely.

```gts preview
import { InputOtp } from 'frontile';

<template>
  <div class='flex flex-col gap-4'>
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

```gts preview
import Component from '@glimmer/component';
import { InputOtp } from 'frontile';

export default class EvenDigitsExample extends Component {
  evenDigitsPattern = /^[02468]*$/;

  <template>
    <InputOtp @label='Even digits only' @length={{4}} @pattern={{this.evenDigitsPattern}} />
  </template>
}
```

## Masked

`@isMasked` draws a bullet in place of each entered character for PIN-style entry. It is a
rendering choice only — the input stays `type="text"` with `autocomplete="one-time-code"`,
because `type="password"` would disable autofill.

```gts preview
import { InputOtp } from 'frontile';

<template><InputOtp @label='PIN' @length={{4}} @isMasked={{true}} /></template>
```

## Placeholder

`@placeholder` previews the shape of the code in the empty cells, and is exposed on the real
input as `aria-placeholder`. It is all-or-nothing: it disappears from *every* cell the moment
anything at all is entered, rather than lingering in the cells that are still empty. Focus the
field and type a digit to watch it go — the fake caret sits in the active cell alongside it.

```gts preview
import { InputOtp } from 'frontile';

<template>
  <InputOtp @label='Verification code' @length={{6}} @placeholder='000000' />
</template>
```

## Sizes

```gts preview
import { InputOtp } from 'frontile';

<template>
  <div class='flex flex-col gap-4'>
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
  <div class='flex flex-col gap-4'>
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
- Because there is a real text field under the cells, every standard text-field key works
  without being reimplemented: arrow keys, shift-select, select-all, backspace, word-delete,
  undo, and copy/cut/paste.
- Validation messages passed through `@errors` are associated via `aria-describedby` and set
  `aria-invalid`, the same as other form controls.

## SMS autofill

`autocomplete="one-time-code"` is set automatically, which is what lets browsers and mobile
OSes offer the incoming SMS code as a one-tap autofill suggestion. Opting into iOS 14+
domain-bound codes needs a `@example.com #123456` footer in the SMS *message* itself — that
part is entirely a server-side concern of whoever sends the text, not something this
component can influence.

## API

<Signature @component="InputOtp" />
