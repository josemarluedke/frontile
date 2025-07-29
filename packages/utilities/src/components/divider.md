---
label: New
imports:
  - import Signature from 'site/components/signature';
---
# Divider

A Divider is designed to delineate and separate content.

## Import 
```js
import { Divider } from '@frontile/utilities';
```

## Usage

```gts preview
import { Divider } from '@frontile/utilities';

<template>
  <div class="p-2 text-foreground not-prose">
    <p>
      Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam lobortis ullamcorper est, eget malesuada magna vestibulum ac. Quisque nibh est, posuere non purus eu, auctor molestie quam. Mauris ante sapien, accumsan et nibh eget, ultricies aliquam orci. Praesent in lorem sagittis, facilisis quam quis, condimentum risus. Donec sodales elit ut risus hendrerit, a luctus orci pharetra. Pellentesque sit amet ultricies ante. Quisque suscipit dolor et urna viverra rhoncus.
    </p>
    <Divider @class="my-2" />
    <p>
      Vestibulum non justo enim. Etiam sed neque lobortis, suscipit elit id, dapibus erat. Nulla cursus scelerisque elit, id dictum urna iaculis a. Pellentesque fermentum ultrices odio, et gravida urna ultricies quis. Phasellus suscipit, diam quis tincidunt posuere, est diam lacinia lectus, at rutrum elit neque at elit. Donec dictum sed sapien ut interdum. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Mauris iaculis convallis lacus vitae fermentum.
    </p>
  </div>
</template>
```

## API

<Signature @package="utilities" @component="Divider" />
