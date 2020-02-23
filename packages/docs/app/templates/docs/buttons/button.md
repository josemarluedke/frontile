# `<Button>`

## All button variations

<Demo::Buttons::ButtonVariations />

## Sizes

Frontile supports a default button size as well as 4 other variations.

Here are the possible sizes and its argument name.

- `@isXSmall` - Extra Small
- `@isSmall` - Small
- `@isLarge` - Large
- `@isXLarge` - Extra Large

<Demo::Buttons::ButtonSizes />

## Renderless

Sometimes a button element is not ideal for a given case, but the same styles are still desired.
Frontile provides the option to disable rendering the element, but instead yield back an object with
the class names it would use.

To enable this behavior, pass `@isRenderless` as true to the `Button` component.

<Demo::Buttons::ButtonRenderless />

## `@type` Argument

Use the `@type` argument to modify the `type` attribute of the button. By default, `button` will be used.

Possible values are:

- `button` - This is the default.
- `submit`
- `reset`
