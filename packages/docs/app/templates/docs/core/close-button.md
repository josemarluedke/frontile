# `<CloseButton>`

This component provides the commonly used Close Button with an icon.

It is also used under other components in Frontile, for example `Modal` and `Drawer`

<DocsDemo as |demo|>
  {{#demo.example name="close-button-demo.hbs"}}
    <div class="flex items-center space-x-2">
      <CloseButton @size="xs" />
      <CloseButton @size="sm" />
      <CloseButton @size="md" />
      <CloseButton @size="lg" />
      <CloseButton @size="xl" />
    </div>
  {{/demo.example}}
  {{demo.snippet name="close-button-demo.hbs"}}
</DocsDemo>
