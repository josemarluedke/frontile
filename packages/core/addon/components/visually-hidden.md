---
category: accessibility
---

# `<VisuallyHidden>`

This component provides text for screen readers that is visually hidden.
Traditionally, developers use `display: none` to hide content on the page.
Unfortunately, this simple and common action can be problematic for users of screen readers.

In the following example, screen readers will announce "Save" and will ignore the icon; the browser displays the icon and ignores the text.

```hbs preview-template
<button class="inline-block p-2 bg-teal-300 border rounded hover:bg-teal-400">
  <VisuallyHidden>Save</VisuallyHidden>
  <svg aria-hidden viewBox="0 0 32 32" class="w-6 h-6">
    <path d="M16 18l8-8h-6v-8h-4v8h-6zM23.273 14.727l-2.242 2.242 8.128 3.031-13.158 4.907-13.158-4.907 8.127-3.031-2.242-2.242-8.727 3.273v8l16 6 16-6v-8z"></path>
  </svg>
</button>
```

Further reading:

- [How-to: Hide content](https://a11yproject.com/posts/how-to-hide-content/).
- [Inspiration](https://ui.reach.tech/visually-hidden).
