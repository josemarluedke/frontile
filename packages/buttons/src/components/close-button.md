---
imports:
  - import Signature from 'site/components/signature';
---
# CloseButton

This component provides the commonly used Close Button with an icon.

It is also used under other components in Frontile, for example `Modal` and `Drawer`

## Import

```js
import { CloseButton} from '@frontile/buttons';
```

```gjs preview
import { CloseButton} from '@frontile/buttons';

<template>
  <div class="flex items-center space-x-2">
    <CloseButton @size="xs" />
    <CloseButton @size="sm" />
    <CloseButton @size="md" />
    <CloseButton @size="lg" />
    <CloseButton @size="xl" />
  </div>
</template>
```

## API

<Signature @package="buttons" @component="CloseButton" />
