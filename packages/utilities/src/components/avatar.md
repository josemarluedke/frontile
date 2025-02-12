---
label: New
---

# Avatar

The Avatar component is used to represent a user by displaying either their initials or an image. It supports customization of size and shape.

## Import

```js
import { Avatar } from '@frontile/utilities';
```

## Usage

### Basic

By default, the Avatar component will display initials derived from the `@name`, `@firstName`, and `@lastName` arguments.

```gts preview
import { Avatar } from '@frontile/utilities';

<template>
  <div class='flex items-center space-x-4 py-2'>
    <Avatar @name='Jon Snow' />
    <Avatar @firstName='Arya' @lastName='Stark' />
  </div>
</template>
```

### With an Image

If an `@src` is provided, the avatar will display the image instead of initials.

```gts preview
import { Avatar } from '@frontile/utilities';

<template>
  <Avatar @src='https://i.pravatar.cc/150?img=5' @alt='Jon Snow' />
</template>
```

### Different Sizes

The `@size` property allows you to customize the avatar's size.

```gts preview
import { Avatar } from '@frontile/utilities';

<template>
  <div class='flex items-center space-x-4 py-2'>
    <Avatar @name='Jon Snow' @size='xs' />
    <Avatar @name='Jon Snow' @size='sm' />
    <Avatar @name='Jon Snow' @size='md' />
    <Avatar @name='Jon Snow' @size='lg' />
    <Avatar @name='Jon Snow' @size='xl' />
  </div>

  <div class='flex items-center space-x-4 py-2'>
    <Avatar @size='xs' @src='https://i.pravatar.cc/150?img=1' />
    <Avatar @size='sm' @src='https://i.pravatar.cc/150?img=2' />
    <Avatar @size='md' @src='https://i.pravatar.cc/150?img=3' />
    <Avatar @size='lg' @src='https://i.pravatar.cc/150?img=4' />
    <Avatar @size='xl' @src='https://i.pravatar.cc/150?img=5' />
  </div>
</template>
```

### Shapes

The `@shape` property changes the avatar shape.

```gts preview
import { Avatar } from '@frontile/utilities';

<template>
  <div class='flex items-center space-x-4 py-2'>
    <Avatar @name='Jon Snow' @shape='circle' />
    <Avatar @name='Jon Snow' @shape='square' />
  </div>
</template>
```

### Accessibility

To provide better accessibility, the `@alt` attribute should be used when displaying an image.

```gts preview
import { Avatar } from '@frontile/utilities';

<template>
  <Avatar @src='https://i.pravatar.cc/150?img=5' @alt='User profile picture' />
</template>
```

If no `@alt` is provided, screen readers will read the initials.

### Custom Styling

You can pass custom `@classes` to override styling:

```gts preview
import { Avatar } from '@frontile/utilities';
import { hash } from '@ember/helper';

<template>
  <Avatar
    @name='Jon Snow'
    @classes={{hash
      base='bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500 text-white'
    }}
  />
</template>
```

## API

<Signature @package="utilities" @component="Avatar" />
