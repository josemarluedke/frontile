---
order: 1
category: get-started
---

# Introduction

Frontile is a modern, accessible, and extensible component library for Ember.js applications. Built with [Tailwind CSS](https://tailwindcss.com/) and [Tailwind Variants](https://www.tailwind-variants.org/), Frontile provides the building blocks you need to create consistent, beautiful, and accessible user interfaces while following best practices from the Ember.js community.

## Why Frontile?

Frontile aims to provide the legos (components, helpers, modifiers, and styles) necessary for building consistent and powerful Ember.js apps while following best practices from the community. Whether you're building a simple application or a complex design system, Frontile offers both low-level primitives and high-level components to meet your needs.

### Key Features

- **🎯 Built for Ember** – Seamless integration with Ember Octane & Glimmer components
- **♿ Accessibility First** – Built with accessibility in mind into every component, following WAI-ARIA guidelines
- **🎨 Fully Customizable** – Uses Tailwind CSS with Tailwind Variants for highly customizable styling
- **🔧 TypeScript & Glint Support** – Fully typed templates with Glint for a better developer experience
- **🌙 Theme Support** – Dark & light mode support with theme-aware components that automatically adapt
- **📱 Responsive Design** – All styles are fully responsive using TailwindCSS utilities
- **🔄 Composable & Extensible** – Designed to be customized and extended to fit any design system

## Quick Start

Get started with Frontile in just a few steps:

### Installation

```sh
pnpm install frontile @frontile/theme
```

### Basic Setup

Add Frontile's theme configuration to your `app/styles/app.css` for Tailwind CSS v4:

```css
@import 'tailwindcss' source('../../');
@plugin "@frontile/theme/plugin/default";
@import "@frontile/theme";

/* Tailwind skips node_modules when scanning for classes, so Frontile's own
   templates have to be pointed at or their classes get purged. */
@source '../../node_modules/frontile';
@source '../../node_modules/@frontile';
```

Paths are relative to the CSS file. Under Vite the entry stylesheet is usually
`app/app.css`, one level shallower, so the sources become
`'../node_modules/...'`.

The `dark` variant comes from `@import "@frontile/theme"` — you do not need to
declare `@custom-variant dark` yourself, and the version the theme ships also
handles `theme-inverse`.

### Your First Component

```gts
import Component from '@glimmer/component';
import { Button } from 'frontile';

export default class Example extends Component {
  onPress = () => {
    alert('Welcome to Frontile!');
  };

  <template>
    <Button @intent='primary' @size='lg' @onPress={{this.onPress}}>
      Get Started
    </Button>
  </template>
}
```

### Legacy Packages

> **Note:** The following packages are deprecated and will be removed before v1 release:
>
> - `@frontile/changeset-form` - Use `frontile` forms instead
> - `@frontile/forms-legacy` - Migrate to the new `frontile` forms

## Architecture Philosophy

Frontile follows a component composition pattern that prioritizes:

- **Flexibility** – Components are designed to be composed together in various ways
- **Consistency** – Unified design language across all components
- **Accessibility** – WCAG compliance built into every component
- **Performance** – Optimized for Ember's rendering system
- **Developer Experience** – Clear APIs with comprehensive TypeScript support

## Browser Support

Frontile supports all modern browsers and follows Ember.js compatibility guidelines:

- **Ember.js** v3.16 or above
- **Node.js** v18 or above
- **Modern Browsers** – Chrome, Firefox, Safari, Edge

## Development Status

Frontile is currently in active development and approaching v1.0. While the API is stabilizing, breaking changes may still occur. We recommend using Frontile in production with appropriate version pinning.

## Getting Help

- 📖 **Documentation** – Visit [frontile.dev](https://frontile.dev/) for comprehensive guides and examples
- 🐛 **Issues** – Report bugs or request features on [GitHub](https://github.com/josemarluedke/frontile/issues)
- 💬 **Community** – Join discussions on the Ember.js Discord server

## Acknowledgments

Frontile draws inspiration from the excellent work of many frontend component libraries and design systems. We're grateful to these projects for paving the way and establishing patterns that make building accessible, beautiful user interfaces possible:

- **[HeroUI](https://www.heroui.com/)** – Modern React UI library with excellent accessibility and theming
- **[IntentUI](https://intentui.com/)** – Design system focused on developer experience and component composition
- **[Mantine](https://mantine.dev/)** – Full-featured React components library with comprehensive theming
- **[Chakra UI](https://chakra-ui.com/)** – Modular and accessible component library for React
- **[Ember Primitives](https://ember-primitives.pages.dev/)** – Low-level UI primitives for Ember applications

These projects have significantly influenced Frontile's approach to component design, accessibility, theming, and developer experience. We encourage you to explore these libraries as they represent some of the best practices in modern frontend development.

---

Ready to get started? Check out our [Installation Guide](./installation.md) to begin building with Frontile.
