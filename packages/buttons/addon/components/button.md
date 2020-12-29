---
category: components
---

# Button

The Button component can be used to trigger an action, such as submitting a form, opening a modal, and more.

## Usage

```hbs preview-template
<Button>Button</Button>
```

## Button Appearances

```hbs preview-template
<div>
  <Button>Default</Button>
  <Button @appearance="outlined">Outlined</Button>
  <Button @appearance="minimal">minimal</Button>
</div>
<div class="mt-4">
  <Button disabled>Default</Button>
  <Button @appearance="outlined" disabled>Outlined</Button>
  <Button @appearance="minimal" disabled>minimal</Button>
</div>

```

## Button Intents

```hbs preview-template
<div>
  <Button @intent="primary">Button</Button>
  <Button @intent="success">Button</Button>
  <Button @intent="warning">Button</Button>
  <Button @intent="danger">Button</Button>
</div>
<div class="mt-4">
  <Button @intent="primary" disabled>Button</Button>
  <Button @intent="success" disabled>Button</Button>
  <Button @intent="warning" disabled>Button</Button>
  <Button @intent="danger" disabled>Button</Button>
</div>
```
## Button Sizes

```hbs preview-template
<Button @isXSmall={{true}}>Button</Button>
<Button @isSmall={{true}}>Button</Button>
<Button>Button</Button>
<Button @isLarge={{true}}>Button</Button>
<Button @isXLarge={{true}}>Button</Button>
```

## Renderless Button

Sometimes a button element is not ideal for a given case, but the same styles are still desired.
Frontile provides the option to disable rendering the `button` element, but instead it yields back an object with
the class names it would use.

```hbs preview-template
<Button @isRenderless={{true}} as |btn|>
  <a href="javascript:void(0)" class={{btn.classNames}}>My Link</a>
</Button>
```

## Composition

You can compose appearance with intents and more to create the button that best fits your needs.

```hbs preview-template
<Button @appearance="outlined" @intent="primary">Button</Button>
<Button @appearance="minimal" @intent="warning">Button</Button>
<Button @isXSmall={{true}} @intent="danger">Button</Button>
```

You can also use TailwindCSS classes to customize even further.

```hbs preview-template
<Button
  @appearance="outlined"
  @intent="primary"
  class="px-20 py-2 italic"
>
  Button
</Button>
```

## API

<ArgsTable @of="Button" />
