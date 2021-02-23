# Overlay

The Overlay component is the base for building interactions like Modal and Drawer.
It contains all the core features necessary for a great experience.

- Auto-Focusing
- Focus Trapping
- Render in-Place or in-Portal.
- Press `Esc` to dismiss
- Click on the backdrop to dismiss
- Animations

> Important: You must have a focusable element inside of the Overlay.

## Note on Overlays and other portal elements

`FormSelect` uses Power Select under the hood and has `@renderInPlace={{false}}` set by default, which will insert the content of the drop-down outside of the `Overlay` (or `Drawer` or `Modal`) and because of that focus-trap will prevent accessing focusable elements ([search input](https://ember-power-select.com/docs/the-search)) in said Power Select. To solve this you have following options:

- `<Overlay @disableFocusTrap={{true}} />` (not recommended)
- `<FormSelect @renderInPlace={{true}} />` (recommended)

## API

<ArgsTable @of="Overlay" />
