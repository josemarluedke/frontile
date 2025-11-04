---
imports:
  - import Signature from 'site/components/signature';
---

# VisuallyHidden

Hides content visually while keeping it accessible to screen readers. Essential for providing context to assistive technology users without cluttering the visual design.

## Import

```js
import { VisuallyHidden } from 'frontile';
```

## Key Features

- **Screen Reader Accessible**: Content remains available to assistive technologies
- **Visually Hidden**: Content is completely hidden from visual rendering
- **Semantic HTML**: Maintains proper document structure
- **Simple Implementation**: Uses the `sr-only` utility class

## Usage

### Icon Buttons with Labels

The most common use case is providing accessible labels for icon-only buttons.

```gts preview
import { VisuallyHidden } from 'frontile';
import { Button } from 'frontile';
import { ViewIcon, EditIcon, DeleteIcon } from 'site/components/icons';

<template>
  <div class='flex gap-2'>
    <Button @appearance='outlined' @size='sm'>
      <VisuallyHidden>View Details</VisuallyHidden>
      <ViewIcon />
    </Button>

    <Button @appearance='outlined' @size='sm'>
      <VisuallyHidden>Edit Item</VisuallyHidden>
      <EditIcon />
    </Button>

    <Button @appearance='outlined' @size='sm' @intent='danger'>
      <VisuallyHidden>Delete Item</VisuallyHidden>
      <DeleteIcon />
    </Button>
  </div>
</template>
```

## Important Notes

### When to Use

Use VisuallyHidden to:

- Provide text labels for icon-only buttons
- Add context to visual indicators (status icons, badges, colors)
- Enhance form labels without cluttering the interface
- Add screen reader announcements for loading states

### Implementation

The component uses the `sr-only` utility class which applies:

```css
position: absolute;
width: 1px;
height: 1px;
padding: 0;
margin: -1px;
overflow: hidden;
clip: rect(0, 0, 0, 0);
white-space: nowrap;
border-width: 0;
```

This ensures content is completely hidden visually but still accessible to screen readers.

### Common Mistakes

**Don't duplicate visible text:**

```gts
{{! Bad: Redundant }}
<button>
  <VisuallyHidden>Save changes</VisuallyHidden>
  Save changes
</button>

{{! Good: Only for non-visible content }}
<button>
  <VisuallyHidden>Save</VisuallyHidden>
  <SaveIcon />
</button>
```

**Provide specific context:**

```gts
{{! Bad: Too generic }}
<button>
  <VisuallyHidden>Delete</VisuallyHidden>
  <DeleteIcon />
</button>

{{! Good: Specific context }}
<button>
  <VisuallyHidden>Delete contact John Doe</VisuallyHidden>
  <DeleteIcon />
</button>
```

### Alternative: aria-label

For simple cases, `aria-label` may be more appropriate:

```gts
{{! Using VisuallyHidden }}
<button>
  <VisuallyHidden>Close dialog</VisuallyHidden>
  <CloseIcon />
</button>

{{! Using aria-label }}
<button aria-label="Close dialog">
  <CloseIcon />
</button>
```

Both approaches work. VisuallyHidden is useful when you need more complex content or want consistency with visible text patterns.

## API

<Signature @package="utilities" @component="VisuallyHidden" />
