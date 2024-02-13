import { Popover } from '@frontile/overlays';
import { Button } from '@frontile/buttons';

<template>
  <Popover as |pop|>
    <Button {{pop.trigger}} {{pop.anchor}}>
      Toggle Popover
    </Button>

    <pop.Content @backdrop="blur" @class="p-4">
      This is some example content for the popover. Check the nested popover by
      clicking the button below.

      <Popover @placement="right" as |pop|>
        <Button {{pop.trigger}} {{pop.anchor}} @class="mt-2">
          Second Popover
        </Button>

        <pop.Content @class="p-4">
          <p>
            More content here, the nested overlay.
          </p>
          <p class="mt-2">
            Clicking outside or pressing Escape will close this Popover, and not
            the root Popover.
          </p>
        </pop.Content>
      </Popover>
    </pop.Content>
  </Popover>
</template>
