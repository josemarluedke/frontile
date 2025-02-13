<img width="978" alt="github-readme" src="https://user-images.githubusercontent.com/230476/99427114-dacf1f80-28b9-11eb-929f-c3aaa70dadd2.png">
<p align="center">
  <a href="https://github.com/josemarluedke/frontile/actions?query=workflow%3ACI"><img src="https://github.com/josemarluedke/frontile/workflows/CI/badge.svg" alt="Build Status"></a>
  <a href="https://github.com/josemarluedke/frontile/blob/main/LICENSE.md"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="GitHub license"></a>
</p>

**Under active development.**

A modern, accessible, and extensible component library for Ember.js, built with Tailwind Variants for highly customizable styling.

## 🚀 Features

- _Fully Customizable_ – Uses Tailwind CSS with Tailwind Variants for styling.
- _Accessible Components_ – Follows best practices for a11y.
- _Composable & Extensible_ – Designed to be customized and extended to fit any design system.
- _Built for Ember_ – Seamless integration with Ember Octane & Glimmer components.
- _TypeScript & Glint Support_ – Fully typed templates with Glint for a better developer experience.
- _Dark & Light Mode Support_ – Theme-aware components that automatically adapt.

## 📖 Documentation

Visit [frontile.dev](https://frontile.dev/) to read the docs and see live demos.

### Usage

```gjs
import Component from '@glimmer/component';
import { Button } from '@frontile/buttons';

export default class Example extends Component {
  onClick = () => {
    alert('Button clicked!');
  };

  <template>
    <Button @intent='primary' @size='lg' @onClick={{this.onClick}}>
      Click Me
    </Button>
  </template>
}
```

```gjs
import Component from '@glimmer/component';
import { Select } from '@frontile/forms';

const options = [
  { key: 'apple', label: 'Apple' },
  { key: 'banana', label: 'Banana' },
  { key: 'cherry', label: 'Cherry' }
];

export default class Example extends Component {
  selectedKeys = [];

  onSelectionChange = (keys) => {
    this.selectedKeys = keys;
  };

  <template>
    <Select
      @items={{options}}
      @selectedKeys={{this.selectedKeys}}
      @onSelectionChange={{this.onSelectionChange}}
      @isFilterable={{true}}
    />
  </template>
}
```

## 🎨 Styling

### Tailwind CSS

Frontile is built on Tailwind CSS, a utility-first CSS framework that allows you to quickly style components without writing custom styles.

By default, Frontile components come with sensible defaults using Tailwind classes, but you can override styles using Tailwind’s utility classes.

```gjs
<Button @class="bg-blue-500 text-white hover:bg-blue-600">
  Custom Styled Button
</Button>
```

### Tailwind Variants

For more structured and reusable styling, Frontile uses [Tailwind Variants](https://www.tailwind-variants.org/).
This approach makes it easier to manage component styling, support variants, and apply conditional styles.

```ts
import { registerCustomStyles, tv } from '@frontile/theme';

registerCustomStyles({
  button: tv({
    base: 'rounded px-4 py-2 font-semibold transition-all',
    variants: {
      intent: {
        primary: 'bg-blue-500 text-white hover:bg-blue-600',
        secondary: 'bg-gray-500 text-white hover:bg-gray-600'
      },
      size: {
        sm: 'text-sm py-1 px-2',
        lg: 'text-lg py-3 px-6'
      }
    },
    defaultVariants: {
      intent: 'primary',
      size: 'lg'
    }
  })
});
```

Frontile components internally use Tailwind Variants, but you can override them by passing `@classes`. Class conflicts are handled automatically by Tailwind Variants.

```gjs
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

## 💡 Contributing

1. Fork the repository.
2. Create a feature branch (git checkout -b my-feature).
3. Commit your changes (git commit -m 'feat: Add new feature').
4. Push to the branch (git push origin my-feature).
5. Open a Pull Request.

## 🛠️ Development

Clone the repository:

```sh
git clone https://github.com/josemarluedke/frontile.git
cd frontile
pnpm install
```

Run the test suite:

```sh
pnpm test
```

Run the test app:

```sh
pnpm start
```

Build all packages:

```sh
pnpm build
```

## 📜 License

This project is licensed under the [MIT License](LICENSE.md).
