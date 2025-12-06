---
order: 4
category: theme
---

# Theme Inverse

The `theme-inverse` utility allows you to create sections with inverted theme colors within the same page. When in light mode, `theme-inverse` applies dark theme colors, and vice versa. This is perfect for creating visual contrast, hero sections, or feature highlights.

## Basic Usage

```gts preview
import { Button, Chip } from 'frontile';

<template>
  <div class='space-y-8 p-8'>
    {{! Normal theme section }}
    <div class='p-6 bg-surface-overlay-subtle rounded-lg'>
      <h3 class='text-lg font-bold text-neutral-strong mb-4'>Regular Theme</h3>
      <p class='text-neutral-medium mb-4'>This section uses the current theme
        colors.</p>
      <div class='flex gap-2'>
        <Button @intent='primary'>Primary Button</Button>
        <Button @intent='default'>Default Button</Button>
      </div>
    </div>

    {{! Inverted theme section }}
    <div class='theme-inverse p-6 bg-background rounded-lg'>
      <div class='p-6 bg-surface-overlay-subtle rounded-lg'>
        <h3 class='text-lg font-bold text-neutral-strong mb-4'>Inverted Theme</h3>
        <p class='text-neutral-medium mb-4'>This section uses the opposite theme
          colors automatically.</p>
        <div class='flex gap-2'>
          <Button @intent='primary'>Primary Button</Button>
          <Button @intent='default'>Default Button</Button>
        </div>
      </div>
    </div>
  </div>
</template>
```

## Component Examples

All Frontile components work seamlessly with `theme-inverse`:

```gts preview
import { Button, Chip, Input, Field, ProgressBar } from 'frontile';

<template>
  <div class='space-y-6'>
    {{! Cards with chips }}
    <div class='theme-inverse p-6 bg-background rounded-lg'>
      <h4 class='text-neutral-strong font-semibold mb-3'>Project Status</h4>
      <div class='flex flex-wrap gap-2 mb-4'>
        <Chip @intent='success'>Active</Chip>
        <Chip @intent='warning'>In Review</Chip>
        <Chip @intent='default'>Draft</Chip>
      </div>
      <ProgressBar @progress={{65}} @intent='primary' />
    </div>

    {{! Form section }}
    <div class='theme-inverse p-6 bg-background rounded-lg'>
      <h4 class='text-neutral-strong font-semibold mb-4'>Contact Form</h4>
      <div class='space-y-4'>
        <Field @name='email' as |field|>
          <field.Input
            @label='Email'
            @type='email'
            @placeholder='you@example.com'
          />
        </Field>
        <Field @name='message' as |field|>
          <field.Textarea
            @label='Message'
            @placeholder='Your message...'
            @rows={{3}}
          />
        </Field>
        <Button @intent='primary'>Send Message</Button>
      </div>
    </div>
  </div>
</template>
```

## Important: Modals and Drawers

**By default**, Modal and Drawer components render at the top level of the DOM (using portals), which means they inherit the theme from the `<html>` or `<body>` element, not from `theme-inverse` sections:

```gts preview
import { Modal, Button, toggleState } from 'frontile';

const state = toggleState(false);

<template>
  <div class='theme-inverse p-6 bg-background rounded-lg'>
    <p class='text-neutral-medium mb-4'>This section uses inverted theme, but
      the modal will use the root theme (not inverted).</p>
    <Button @onPress={{state.toggle}}>Open Modal (Root Theme)</Button>

    {{! Modal renders at top level - gets root theme, NOT theme-inverse }}
    <Modal @isOpen={{state.current}} @onClose={{state.toggle}} as |modal|>
      <modal.Header>Modal uses root theme</modal.Header>
      <modal.Body>
        <p>This modal inherits from html/body, not the theme-inverse parent.</p>
        <p class='mt-2'>Notice it uses the opposite colors from the button that
          opened it.</p>
      </modal.Body>
    </Modal>
  </div>
</template>
```

**To use inverted theme in modals/drawers**, render them in place:

```gts preview
import { Modal, Button, toggleState } from 'frontile';

const state = toggleState(false);

<template>
  <div class='theme-inverse p-6 bg-background rounded-lg'>
    <p class='text-neutral-medium mb-4'>This section uses inverted theme, and
      the modal will inherit it.</p>
    <Button @onPress={{state.toggle}}>Open Modal (Inverted Theme)</Button>

    {{! Modal renders in place - inherits theme-inverse from parent }}
    <Modal
      @isOpen={{state.current}}
      @onClose={{state.toggle}}
      @renderInPlace={{true}}
      as |modal|
    >
      <modal.Header>Modal uses inverted theme</modal.Header>
      <modal.Body>
        <p>This modal inherits the theme-inverse from its parent.</p>
        <p class='mt-2'>Notice it matches the theme colors of the section that
          opened it.</p>
      </modal.Body>
    </Modal>
  </div>
</template>
```

## How It Works

- `theme-inverse` only works with base themes (light and dark)
- When in light mode, `.light .theme-inverse` applies all dark theme colors
- When in dark mode, `.dark .theme-inverse` applies all light theme colors
- Custom themes do not support theme inversion
- All CSS variables are automatically swapped, so components work without modification

## Using Dark/Light Variants

The `dark:` and `light:` variants work correctly inside `theme-inverse` contexts:

```hbs
{{! This works as expected inside theme-inverse }}
<div class='theme-inverse p-6 bg-background'>
  <div class='bg-white dark:bg-gray-900'>
    {{! In light mode: shows gray-900 (inverted) }}
    {{! In dark mode: shows white (inverted) }}
    Content
  </div>
</div>
```

The variants automatically understand theme-inverse contexts:

- `dark:` classes apply in actual dark mode AND in `.light .theme-inverse` contexts
- `light:` classes apply in actual light mode AND in `.dark .theme-inverse` contexts

## Best Practices

### Always Set a Base Background

Surface overlay colors are semi-transparent and need a base background:

```hbs
{{! Good - has base background }}
<div class='theme-inverse bg-background'>
  <div class='bg-surface-overlay-subtle'>
    Content
  </div>
</div>

{{! Bad - overlay has no base }}
<div class='theme-inverse'>
  <div class='bg-surface-overlay-subtle'>
    Content (invisible!)
  </div>
</div>
```

### Use Semantic Colors

Theme-inverse works automatically with semantic colors:

```hbs
{{! These automatically invert }}
<div class='theme-inverse p-6 bg-background'>
  <h3 class='text-neutral-strong'>Heading</h3>
  <p class='text-neutral-medium'>Body text</p>
  <button class='bg-brand-medium text-brand-contrast-1'>Action</button>
</div>
```
