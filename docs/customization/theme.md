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

#### Tailwind CSS v3

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

#### Tailwind CSS v4

##### Using Default Theme

For the default theme, add this to your `app/styles/app.css`:

```css
@import 'tailwindcss' source('../../');
@plugin "@frontile/theme/plugin/default";
@source '../../node_modules/@frontile';
@custom-variant dark (&:is(.dark *));
```

##### Customizing Frontile Theme

To customize the frontile theme, create a file in the root of your project named `frontile.js` with the following content:

```js
const { frontile } = require('@frontile/theme/plugin');

module.exports = frontile({
  /* your config */
});
```

Then update your `app/styles/app.css` to use the custom configuration:

```css
@import 'tailwindcss' source('../../');
@plugin "./../../frontile.js";
@source '../../node_modules/@frontile';
```

## What Is Available

Frontile's theming system provides:

- **Default Themes**: Light and dark themes with predefined color schemes.
- **Semantic Colors**: A set of color variables (e.g., `primary`, `success`, `danger`, `default`) that adapt based on the active theme.
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
            primary: {
              50: '#eff6ff',
              100: '#dbeafe',
              200: '#bfdbfe',
              300: '#93c5fd',
              400: '#60a5fa',
              500: '#3b82f6',
              600: '#2563eb',
              700: '#1d4ed8',
              800: '#1e40af',
              900: '#1e3a8a',
              950: '#172554',
              DEFAULT: '#3b82f6',
              foreground: '#ffffff'
            }
            // ...other color overrides
          },
          layout: {
            hoverOpacity: '.8'
            // ...other layout settings
          }
        },
        dark: {
          colors: {
            primary: {
              50: '#172554',
              100: '#1e3a8a',
              200: '#1e40af',
              300: '#1d4ed8',
              400: '#2563eb',
              500: '#3b82f6',
              600: '#60a5fa',
              700: '#93c5fd',
              800: '#bfdbfe',
              900: '#dbeafe',
              950: '#eff6ff',
              DEFAULT: '#60a5fa',
              foreground: '#ffffff'
            }
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
            primary: {
              DEFAULT: '#ffffff',
              foreground: '#000000'
            },
            background: {
              DEFAULT: '#000000'
            }
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

### Understanding Color Scale Structure

Each semantic color in Frontile uses a color scale object with the following properties:

- **Numeric scale (50-950)**: Provides utility classes like `bg-primary-50`, `text-primary-500`, `border-primary-900`, etc.
- **`DEFAULT`**: The color used when no numeric suffix is specified. For example, `bg-primary` will use the `DEFAULT` value.
- **`foreground`**: The color used for text or content that sits on top of the base color, ensuring proper contrast. Used with classes like `text-primary-foreground`.

**Example usage:**

```hbs
{{! Uses the DEFAULT color from primary scale }}
<button class='bg-primary text-primary-foreground'>
  Click Me
</button>

{{! Uses the specific 500 shade from primary scale }}
<div class='bg-primary-500 text-white'>
  Content
</div>

{{! Uses the 50 shade for a lighter background }}
<div class='bg-primary-50 text-primary-900'>
  Light background
</div>
```

When defining custom colors, you can provide either:

- A **full scale object** with all numeric values, `DEFAULT`, and `foreground`
- A **minimal object** with just `DEFAULT` and optionally `foreground` (you won't get numeric utility classes)
- A **simple string** (you'll only get the base class like `bg-primary`, no scale utilities or foreground)

### Inspiration

Frontile's theming system was inspired by HeroUI theming, bringing a similar approach to customizable and flexible theme management.

## Semantic Colors

Frontile's semantic theming system provides pre-defined semantic colors:

- **`primary`**
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
