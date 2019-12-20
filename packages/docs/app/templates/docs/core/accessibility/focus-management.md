# Focus management

The outline styles (that blue line around the outside of a focused element)
are an essential part of accessibility for users using keyboard to navigate
around, it indicates which element is in focus at a given time. Users can
choose to "click" them by just pressing the `Enter` key in the keyboard, instead of
using the mouse.

These styles are less important for users using the mouse, usually having
them enabled can be annoying.

Frontile includes a [library](https://github.com/WICG/focus-visible) based
in the proposed CSS `:focus-visible` pseudo-selector. It adds a `focus-visible` class
to the focused element, but it only adds the class when `Tab`, `Shift + Tab`, or an
arrow key is used to focus an element. If the mouse is used to focus, the class
will not be added (with the exception of input and textarea elements).

<DocsDemo as |demo|>
  {{#demo.example name="focus-visible-demo.hbs"}}
    <FormInput placeholder="Test me for focus" />
    <a
      class="px-4 py-2 mt-4 inline-block border bg-teal-600 rounded text-white hover:bg-teal-700"
      href="javascript:void(0)"
    >
      Test me for focus
    </a>
  {{/demo.example}}
  {{demo.snippet name="focus-visible-demo.hbs"}}
</DocsDemo>
