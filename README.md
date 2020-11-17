<img width="978" alt="github-readme" src="https://user-images.githubusercontent.com/230476/99427114-dacf1f80-28b9-11eb-929f-c3aaa70dadd2.png">
<p align="center">
  <a href="https://github.com/josemarluedke/frontile/actions?query=workflow%3ACI"><img src="https://github.com/josemarluedke/frontile/workflows/CI/badge.svg" alt="Build Status"></a>
  <a href="https://github.com/josemarluedke/frontile/blob/master/LICENSE.md"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="GitHub license"></a>
</p>

**Under active development.**

Frontile aims to provide the legos (components, helpers, modifiers, and styles)
necessary for building consistent and powerful Ember.js apps while following best
practices from the community and providing both low-level and high-level components for your application.

- Built with accessibility in mind into every component;
- Built as logically separated packages, so you can choose the pieces you're going to use;
- Written in TypeScript;
- All components are Glimmer components;
- Styles are just TailwindCSS plugins, and fully responsive;


## Documentation

Visit [frontile.dev](https://frontile.dev/) to read the docs
and see live demos.

**Docs are early development and will have a big re-write/re-organization in near future.**


## What is available?

There are a few packages available to use already; you can use them in your
applications today if you are in a supported Ember version. The project is
still pre-version 1.0.0, so breaking changes can still occur.

- [@frontile/core](./packages/core): Core package providing essential a11y components.
- [@frontile/forms](./packages/forms): Components for working with forms.
- [@frontile/changeset-form](./packages/forms): Integration between the Forms package and [Changeset](https://github.com/poteto/ember-changeset).
- [@frontile/notifications](./packages/notifications): Package that provides toast-like notifications.
- [@frontile/overlays](./packages/overlays): Components to render content over the UI, like Modal Dialogs.
- [@frontile/buttons](./packages/buttons): Components for working with buttons.

## Styles with Tailwind

All the styles we provide are through [TailwindCSS](https://tailwindcss.com/)
plugins. It is perfect if your app has Tailwind; however, some apps don't have or
don't necessarily want to write styles using it. For these, there are two alternatives:

- Write all the styles yourself targeting our classes, which follows
[BEM naming](http://getbem.com/naming/) conventions.
- Only add Tailwind for our styles. This approach is yet to be proven, but in theory,
you should be able to set up Tailwind and only allow it to include Frontile styles.

By providing Tailwind plugins, you can customize pretty much all styles, even
removing what is not what you need. All plugins have the option to pass a
configuration so that you can set up all the colors, spacings, etc, as your
application needs. It also allows for creating themes or dark modes using CSS Variables.

TL; DR; You don't need TailwindCSS if you don't want it, but it's best if you do use it.

## Compatibility

* Ember.js v3.16 or above
* Ember CLI v2.13 or above
* Node.js v10 or above

## License

This project is licensed under the [MIT License](LICENSE.md).
