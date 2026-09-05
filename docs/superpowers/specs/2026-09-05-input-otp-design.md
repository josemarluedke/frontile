# InputOtp — Design

Date: 2026-09-05
Status: Approved, ready for implementation planning

## Summary

A one-time-code / PIN entry component for Frontile's `forms` category. Renders as a
row of discrete cells, but is a **single real `<input>`** underneath — which is what
makes password managers, iOS/Android SMS autofill, paste, native undo, and screen
readers all work.

Named `InputOtp`. Source at `packages/frontile/src/components/forms/input-otp.gts`,
theme entry `inputOtp` in `packages/theme/src/components/forms/forms.ts`.

## Motivation

Frontile has no OTP/PIN control. Hand-rolled versions almost always reach for N
`<input maxlength=1>` elements, which breaks SMS autofill (the platform has nowhere
to put a 6-character value), truncates 1Password fills into the first box, and
announces six unlabeled fields to screen readers.

## Architecture

One real `<input>`, absolutely positioned over the whole widget, made invisible by
transparent **colors**. The cells are inert presentational elements driven by a
*selection mirror*.

```
<div data-otp-container translate="no">      position: relative; pointer-events: none
  [cell][cell][cell]  –  [cell][cell][cell]  aria-hidden decoration
  <div class="absolute inset-0">
    <input>                                  pointer-events: all
  </div>                                     color/caret-color/background transparent
</div>
```

Pointer-events are inverted — container `none`, input `all` — so a click anywhere in
the widget lands on the input and resolves to the nearest character position.

### Why not N inputs

| Concern | Single overlaid input | N inputs |
|---|---|---|
| SMS one-time-code autofill | Whole code arrives in one `change` | Broken on iOS and Android |
| Password managers | One fillable credential field | Truncates into the first box |
| Paste (incl. partial) | Native | Hand-written split/distribute |
| Keyboard | Everything a text input does | Reimplement all of it |
| Screen readers | One control, one tab stop | Six unlabeled fields |
| Form semantics | One `name`, one `FormData` entry | Recombine N entries |
| Caret/selection | Hard — needs the selection mirror | Trivial |

The only thing the N-input approach wins is caret handling, and that cost is
contained to one ~40-line algorithm.

### Rejected

- **N separate inputs** — above.
- **contenteditable** — no autofill, no `inputmode`, worse a11y.
- **Porting shadcn-ember's `input-otp.gts`** — it is the obvious Ember precedent and
  it is materially broken: `handleInput` takes `inputValue[0]` and discards the rest,
  so a 6-character SMS autofill silently loses 5 characters; the input is
  `size-0 opacity-0`, which kills the iOS long-press Paste menu; and its cells are
  `<button>` elements, producing `length + 1` tab stops and N announced controls.

## Public API

```gts
<InputOtp
  @label='Verification code'
  @length={{6}}
  @groups={{array 3 3}}
  @onComplete={{this.verify}}
/>
```

Extends `FormControlSharedArgs` unchanged: `@label`, `@description`, `@isRequired`,
`@errors`, `@isInvalid`, `@isDisabled`.

| Arg | Type | Default | Notes |
|---|---|---|---|
| `@length` | `number` | `6` | Cell count; drives `maxlength` |
| `@groups` | `number[]` | — | `[3,3]` → two groups with a separator between. Omitted → one group, no separator |
| `@separator` | `string` | `'–'` | Rendered `aria-hidden` |
| `@value` | `string` | — | Controlled value |
| `@onChange` | `(value: string, event?: Event) => void` | — | |
| `@onInput` | `(value: string, event?: Event) => void` | — | |
| `@onBlur` | `() => void` | — | |
| `@onComplete` | `(value: string) => void` | — | Fires on the transition to full |
| `@name` | `string` | — | One `FormData` entry |
| `@size` | `'sm' \| 'md' \| 'lg'` | `'md'` | |
| `@allowedChars` | `'digits' \| 'alphanumeric' \| 'letters'` | `'digits'` | Derives `pattern`, `inputmode`, `autocapitalize` |
| `@pattern` | `RegExp` | — | Escape hatch; overrides `@allowedChars` |
| `@placeholder` | `string` | — | Per-cell characters; also `aria-placeholder` |
| `@isMasked` | `boolean` | `false` | Renders `•` per filled cell |
| `@classes` | `SlotsToClasses<InputOtpSlots>` | — | |

`Element` is `HTMLInputElement`, so `...attributes` lands on the real input —
`autofocus`, `aria-label`, `data-test-id` work directly.

### API decisions

**`@allowedChars` is primary, `@pattern` is the escape hatch.** The native `pattern`
attribute is tested against *every intermediate value*, so `^\d{6}$` makes the field
completely untypeable — the first keystroke fails and nothing can be entered. Presets
make that unreachable and also derive `inputmode` correctly (`numeric` for digits,
`text` otherwise; never `tel`, which offers `*`, `#` and pause characters the pattern
rejects). `@pattern` is documented with the partial-match rule: `^\d+$`, not `^\d{6}$`.

Preset sources: `digits` → `^\d+$`; `letters` → `^[a-zA-Z]+$`;
`alphanumeric` → `^[a-zA-Z0-9]+$`.

**`@groups` validation.** When `@groups` is omitted the cells render as a single group
with no separator. When supplied, its entries must sum to `@length`; a mismatch raises a
development-time `assert` (stripped in production builds). In production a mismatched
value renders `@length` cells total, filling groups in order and truncating or appending
a final group as needed, so a bad value degrades rather than dropping cells.

Pattern rejection is **all-or-nothing** — a value failing the pattern is rejected
entirely, not filtered. A pasted `123-456` is dropped rather than silently becoming
`123456`.

**`@isMasked` is a cell-render decision only.** The real input's text is already
transparent, so no `-webkit-text-security` and no `type="password"` (which would
disable autofill).

**No `@autoSubmit`.** `@onComplete` plus `form.submit()` is one line in userland;
baking it in adds behavior that can't be opted out of mid-flow.

## Value ownership

Identical contract to `Input`:

```
isControlled  = typeof onChange === 'function' || typeof onInput === 'function'

uncontrolledValue   we own it
elementValue        what the DOM actually holds
currentValue        = isControlled ? (args.value ?? elementValue) : uncontrolledValue
```

`currentValue` is what the cells render from, always.

This matters more here than for `Input`. `Input` renders its own text, so a controlled
parent that never feeds `@value` back still looks correct — the element draws itself.
Our cells are decoration rendered from a JS string, so reading only `@value` would show
six empty boxes while the user types. `<Form>` is exactly that parent: `Field` binds
`value=this.fieldValue` and `onInput`/`onChange` handlers that only trigger validation,
while `Form` reads the real value off the DOM via `FormData`.

**`@onComplete` does not make the component controlled.** It is a notification, not
ownership. Only `@onChange`/`@onInput` flip the switch.

Three supported patterns:

```gts
<InputOtp @label='Code' @onComplete={{this.verify}} />                     {{! uncontrolled }}
<InputOtp @label='Code' @value={{this.code}} @onChange={{this.setCode}} /> {{! controlled }}
<form.Field @name='code' as |field|><field.InputOtp /></form.Field>        {{! Form-owned }}
```

`InputOtp` is added to `Field`'s yielded hash with the same bound args as `Input`
(`name`, `errors`, `value`, `onChange`, `onInput`, `onBlur`, `isDisabled`), so
`field.InputOtp` needs no special casing.

`@onComplete` fires on the *transition* from shorter-than-full to exactly full:
`value !== previous && previous.length < length && value.length === length`.
Re-rendering with the same full value does not refire; editing and refilling does.

## The selection mirror

The one genuinely hard piece. A collapsed text caret sits *between* characters and so
belongs to no cell; it is widened to a 1-character range so exactly one cell reads as
active and typing overwrites.

A `document`-level `selectionchange` listener registered with `{ capture: true }`,
plus a remembered previous `[start, end, direction]`:

- Caret at `0` → select `[0, 1]` forward.
- Caret at `length` → select `[length-1, length]` backward.
- **Append exemption:** when the caret is at the end of a not-yet-full value, leave it
  collapsed. Without this, the 4th keystroke replaces the 3rd character.
- **Direction inference:** the selection API does not report which side of a boundary
  the user meant, so direction is derived by comparing against the previous selection.
  A backward move shifts the range by `-1`, *unless* we were previously in append mode
  — otherwise ArrowLeft appears to skip a cell.

**Deletion fires no `selectionchange` in any browser.** The change handler compares
lengths and dispatches a synthetic one when the value shrank. Known accepted cost: it
also fires on select-all-then-paste-shorter, which is harmless.

Derived per cell:

```
isActive = isFocused && start !== null && end !== null &&
           ((start === end && index === start) || (index >= start && index < end))
char        = currentValue[index] ?? null
placeholder = currentValue.length === 0 ? (placeholder?.[index] ?? null) : null
hasFakeCaret = isActive && char === null
```

Multiple cells are active simultaneously during a shift-arrow range selection — this is
correct, not a bug.

On focus, a full code selects the last cell rather than parking the caret past the end:
`setSelectionRange(min(value.length, length - 1), value.length)`. Paste restores the
same way.

Under SSR/prerender, `isFocused` is false and the mirror is null, so no cell is active
in the initial HTML by design. Branch on classes, never on markup structure.

## Theme

New `inputOtp` entry in `packages/theme/src/components/forms/forms.ts`.

Slots: `base`, `container`, `input`, `group`, `cell`, `cellChar`, `caret`, `separator`.

The `cell` slot spreads the existing `fieldShell` array verbatim (`bg-surface-input`,
`border`, `border-neutral-soft`, `rounded-xl`), so invalid, disabled and focus
treatments match every other Frontile field without duplication.

Variants: `size` (`sm`/`md`/`lg`), `isActive`, `isInvalid`, `isDisabled`.

The active cell needs `relative z-10` so its focus ring is not clipped by a neighbour.
The caret blink goes under `motion-safe:`.

Visual language: separate rounded cells with a gap, not a joined segmented bar.

## Accessibility

The entire accessibility story is *we did not take the input apart*.

- Cells are `aria-hidden` and carry **no role, no tabindex, no label**. Giving them
  `role="textbox" aria-label="Digit 1"` creates phantom controls that trap keyboard
  users in a field that is not real. This is the single most common mistake with this
  pattern and it is explicitly avoided.
- Separators are `aria-hidden`. The value contains no dash, so nothing announces one.
- The real input carries `id` (from `FormControl`), `aria-invalid`, `aria-describedby`
  and `aria-placeholder` — standard `FormControl` wiring, unchanged.
- Exactly one tab stop, one announced control, one name, one value.
- The fake caret must never be the only focus affordance — it is invisible under
  `prefers-reduced-motion`. The active cell gets a real ring.

Keyboard support comes free from the real input and is deliberately **not**
reimplemented: arrows, shift-arrow ranges, select-all, backspace, delete,
word-delete, undo, copy/cut/paste including partial paste, Home/End.

## Autofill and password-manager handling

Each of these is a real defect if skipped.

1. **Hide by transparent colors, never `opacity: 0`.** iOS refuses the long-press Paste
   menu on a zero-opacity input. Set `color`, `caret-color`, `background` and
   `::selection` transparent independently. `::selection` needs *both* `background` and
   `color` — setting only `background` leaves text drawn in the highlight foreground.
2. **`autocomplete="one-time-code"`** — any other value disables SMS autofill entirely.
   Plus `spellcheck="false"` and `autocorrect="off"`; keyboards otherwise try to correct
   a six-character "word".
3. **`translate="no"` on the container.** Chrome's translate feature rewrites cell text
   nodes, wrapping them in `<font>`; Glimmer then updates a node that has been
   re-parented.
4. **Chromium `:autofill` styling.** The yellow rectangle needs
   `-webkit-text-fill-color: transparent` (the property that actually controls text
   colour in that state) alongside transparent background/border/box-shadow. The
   `:autofill` state outlives the fill until the next real `input` event.
5. **Invisible-input `font-size` ≥ 16px**, or iOS Safari zooms the page on focus.
   Sized from the cell height with a 16px floor.
6. **Password-manager badge gutter.** Badges are positioned from the *input's* box, not
   the container's, so they land on the last cell. Reserve 40px via
   `width: calc(100% + 40px)` with `clip-path: inset(0 40px 0 0)` — absolutely
   positioned, so no layout shift, and `clip-path` clips hit-testing too. One rule keeps
   an injected badge clickable inside the `pointer-events: none` container.

   **Simplification over the reference implementation:** it ships a vendor-sniffing
   probe (`elementFromPoint` plus `setInterval` polling) whose own documentation admits
   it always returns true, because the topmost element at the probe point is always the
   invisible input. We reserve unconditionally — identical observable behaviour, roughly
   80 fewer lines, no polling.

Domain-bound codes (iOS 14+ matching an SMS footer `@example.com #123456` against the
origin) are a server-side SMS-content concern, documented but not a component feature.

## Testing

`test-app/tests/integration/components/input-otp-test.gts`, written before the
implementation per the repo's TDD guidance.

- Value across all three ownership modes: uncontrolled, controlled, and `<Form>`-owned
  where `@value` is never fed back.
- `@onComplete` fires exactly once on the transition; does not refire on re-render with
  the same full value; refires after edit-and-refill.
- Full-code paste (the autofill path) and partial paste into a half-filled code.
- Pattern rejection is all-or-nothing.
- Selection mirror → `isActive`: arrows, shift-arrow ranges (multiple active cells),
  the append exemption, and the ArrowLeft direction inference.
- Deletion dispatches the synthetic `selectionchange` and the active cell follows.
- `@groups` rendering, separator placement, and the sum assertion.
- `@isMasked`, `@placeholder`, `@size`, `@isDisabled`, `@isInvalid`.
- Cells expose no roles, no labels and no tab stops; the widget has exactly one tab stop.
- Attribute-level assertions for `autocomplete`, `inputmode`, `pattern`, `maxlength`,
  `spellcheck`, `translate`.

iOS and password-manager behaviours are asserted at the attribute/CSS level only —
real autofill cannot be exercised in a headless browser and requires a physical device.

## Deliverables

1. `packages/frontile/src/components/forms/input-otp.gts`
2. `packages/frontile/src/components/forms/input-otp.md` (co-located docs, live demos)
3. `inputOtp` entry + exported `InputOtpVariants` / `InputOtpSlots` types in
   `packages/theme/src/components/forms/forms.ts`
4. Export from `packages/frontile/src/components/forms/index.ts`
5. `InputOtp` added to `Field`'s yielded hash in
   `packages/frontile/src/components/forms/field.gts`
6. `test-app/tests/integration/components/input-otp-test.gts`

## Out of scope

Auto-submit on completion, a paste-from-clipboard button, a resend-timer helper, and a
joined segmented-bar visual variant.
