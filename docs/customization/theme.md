---
order: 1
category: customization
label: New
---

# Theme

Frontile's theming system is built upon Tailwind CSS, allowing developers to define and switch between themes seamlessly. It offers a set of semantic color classes that adapt based on the active theme, facilitating consistent styling across your application.

## Setup

To integrate Frontile's theming into your project, follow these steps:

### Install the Theme Package

Use Ember CLI to install the `@frontile/theme` package:

```bash
ember install @frontile/theme
```

### Configure Tailwind CSS

Modify your `tailwind.config.js` to include Frontile's theme plugin and safelist:

```javascript
// tailwind.config.js

const { frontile, safelist } = require('@frontile/theme/plugin');

module.exports = {
  content: [
    './app/**/*.{html,js,ts,hbs,gts,gjs}',
    './node_modules/@frontile/theme/dist/**/*.js'
  ],
  safelist: [...safelist],
  darkMode: 'class',
  theme: {
    extend: {}
  },
  plugins: [frontile()]
  // ...
};
```

This configuration ensures that Tailwind processes Frontile's styles and includes necessary classes in the final build.

## What Is Available

Frontile's theming system provides:

- **Default Themes**: Light and dark themes with predefined color schemes.
- **Semantic Colors**: A set of color variables (e.g., `primary`, `secondary`, `success`, `danger`, `default`) that adapt based on the active theme.
- **Customization Options**: Ability to define custom themes and override default settings.

## Usage

To apply Frontile's theming in your components:

### Utilize Semantic Colors

Frontile defines semantic color classes that adjust according to the active theme. For example, using the `text-primary` class will apply the primary color of the current theme to the text.

Each semantic color also has a default color for the theme. For instance, `text-danger` without a number will use the default configured color for danger in the theme. Additionally, these semantic colors have a foreground version, such as `text-primary-foreground`, which is used to provide appropriate contrast against the background.

```hbs
<button class='bg-primary text-primary-foreground'>
  Click Me
</button>
```

In this example, `bg-primary` sets the button's background to the primary color, and `text-primary-foreground` sets the text color to ensure sufficient contrast.

### Switch Between Themes

Frontile supports theme switching via the `darkMode` class. To toggle between light and dark themes, add or remove the `dark` class on a parent element, typically the `<html>` or `<body>` tag.

```html
<html class="dark">
  <!-- Your content -->
</html>
```

Removing the `dark` class will revert to the light theme. The light theme class is called `light` and can be applied in a similar manner.

You can also combine classes for dark/light mode usage, for example:

```html
<div class="dark text-foreground bg-background">
  <!-- Content that adapts to dark mode -->
</div>
```

## Configuration

### Define Custom Themes

You can extend or override the default themes by modifying the `defaultConfig` in your Tailwind configuration. A new theme can also be created by extending another theme. For example, you could create a high contrast version of the dark theme by extending the existing dark theme and adjusting the colors accordingly. This allows you to maintain consistency with the base theme while customizing specific properties to meet your design requirements.

For instance:

```js
// tailwind.config.js

const { frontile } = require('@frontile/theme/plugin');

module.exports = {
  // ...
  plugins: [
    frontile({
      defaultTheme: 'light',
      themes: {
        light: {
          colors: {
            primary: '#3490dc'
            // ...other color overrides
          },
          layout: {
            hoverOpacity: '.8'
            // ...other layout settings
          }
        },
        dark: {
          colors: {
            primary: '#1c3d5a'
            // ...other color overrides
          },
          layout: {
            hoverOpacity: '.7'
            // ...other layout settings
          }
        },
        highContrastDark: {
          extend: 'dark',
          colors: {
            primary: '#ffffff',
            background: '#000000'
            // Adjust colors for higher contrast
          }
        }
        // Define additional custom themes here
      }
    })
  ]
};
```

This example demonstrates how to create a `highContrastDark` theme by extending the `dark` theme and adjusting specific colors to improve contrast.

You can also create entirely new themes by defining a new set of colors and layout properties from scratch. This flexibility allows you to cater to different branding requirements or accessibility needs.

### Inspiration

Frontile's theming system was inspired by NextUI theming, bringing a similar approach to customizable and flexible theme management.

## Semantic Colors

Frontile's semantic theming system provides pre-defined semantic colors:

- **`primary`**
- **`secondary`**
- **`success`**
- **`danger`**
- **`warning`**
- **`info`**
- **`default`**

It is recommended to use these instead of Tailwind CSS's utility classes, such as `bg-gray-400`. For example, in Frontile, you can use `bg-default-400` for consistency.

These colors adapt based on the active theme, ensuring a consistent and accessible design across different themes.

### Background and Foreground Colors

- **`background`**: Used for the main background of components, adapting to light or dark themes.
- **`foreground`**: Typically used for text or elements that need to stand out against the background color.

### Content Colors

- **`content1`**: Primary content color, often used for cards or panels that need to stand out.
- **`content2`**: Secondary content color, used for supporting content in cards or nested panels.
- **`content3`**: Tertiary content color, used for muted or less significant sections within cards.
- **`content4`**: Forth option.

### Utility Colors

- **`overlay`**: Used for overlays, such as modals or dropdown backgrounds, providing appropriate contrast.
- **`focus`**: Used to indicate focus states, such as outlines on focused buttons or inputs.
- **`divider`**: Used for dividers or borders, providing separation between elements.

By leveraging Frontile's theming capabilities, you can create a cohesive and customizable user interface that aligns with your application's design requirements.
