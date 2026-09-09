---
label: Updated
url: drawer
imports:
  - import Signature from 'site/components/signature';
---

# Drawer

The Drawer component is a slide-out panel that appears from any edge of the screen. It's built on top of the Overlay component and includes all its accessibility features, plus drawer-specific functionality like multiple placement options and sizes.

## Import

```js
import { Drawer } from 'frontile';
```

## Anatomy

Drawer yields the pieces you assemble it from:

| Yielded       | Purpose                                                         |
| ------------- | --------------------------------------------------------------- |
| `Header`      | Heading region; applies the id that `aria-labelledby` points at |
| `Body`        | Main content area                                               |
| `Footer`      | Action row                                                      |
| `CloseButton` | Styled close button wired to `@onClose`                         |
| `headerId`    | The id `Header` uses, for labelling your own heading instead    |

The default close button (shown unless `@allowClosing`/`@allowCloseButton` is `false`) is
rendered inside `<d.Header>` when one is present, vertically centered against it regardless of
whether the header is title-only or has a description too. Only a drawer with no `Header` at
all falls back to the standalone, absolutely-positioned close button in the top right corner.

## Usage

### Basic Drawer

A simple drawer that slides in from the right side.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Drawer } from 'frontile';
import { Button } from 'frontile';

export default class BasicDrawer extends Component {
  @tracked isOpen = false;

  @action toggle() {
    this.isOpen = !this.isOpen;
  }

  <template>
    <div class='demo-stack demo-stack--wide items-center'>
      <Button @onPress={{this.toggle}}>
        Open Drawer
      </Button>

      <Drawer @isOpen={{this.isOpen}} @onClose={{this.toggle}} as |d|>
        <d.Header>
          Basic Drawer
        </d.Header>
        <d.Body>
          <p class='mb-4'>This is the main content of the drawer. You can put
            any content here including forms, lists, or other components.</p>
          <p>The drawer slides in from the right side by default and includes a
            close button in the top right corner.</p>
        </d.Body>
        <d.Footer @class='flex gap-2'>
          <Button @onPress={{this.toggle}}>
            Cancel
          </Button>
          <Button @intent='primary'>
            Save
          </Button>
        </d.Footer>
      </Drawer>
    </div>
  </template>
}
```

### Appearance

`@appearance` controls how the header, body and footer relate to each other. `default` gives
the drawer a black header band, a body on its own surface and a solid footer — this is the
banded treatment. `ghost` keeps every region on the same surface as the modal — the flat look
Drawer used before v0.18, kept for consumers who don't want the restyle.

The header API is identical in both appearances: `@title`/`@description` and a block yielding
`h.Icon`, `h.Title` and `h.Description` work the same way regardless of which appearance is
selected.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { Drawer } from 'frontile';
import { Button } from 'frontile';

export default class DrawerAppearances extends Component {
  @tracked isOpen = false;
  @tracked selectedAppearance = 'default';

  appearances = ['default', 'ghost'];

  @action openDrawer(appearance) {
    this.selectedAppearance = appearance;
    this.isOpen = true;
  }

  @action closeDrawer() {
    this.isOpen = false;
  }

  <template>
    <div class='flex gap-2'>
      {{#each this.appearances as |appearance|}}
        <Button @onPress={{fn this.openDrawer appearance}}>
          {{appearance}}
        </Button>
      {{/each}}
    </div>

    <Drawer
      @isOpen={{this.isOpen}}
      @onClose={{this.closeDrawer}}
      @appearance={{this.selectedAppearance}}
      as |d|
    >
      <d.Header
        @title='{{this.selectedAppearance}} appearance'
        @description='Switch appearances with the buttons above.'
      />
      <d.Body>
        <p>This is the body content, on its own surface in `default` and flat in
          `ghost`.</p>
      </d.Body>
      <d.Footer @class='flex gap-2'>
        <Button @onPress={{this.closeDrawer}}>Close</Button>
      </d.Footer>
    </Drawer>
  </template>
}
```

The same switch works with the block form of `<d.Header>`, including an icon:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { Drawer } from 'frontile';
import { Button } from 'frontile';
import { SettingsIcon } from 'site/components/icons';

export default class DrawerAppearancesIcon extends Component {
  @tracked isOpen = false;
  @tracked selectedAppearance = 'default';

  appearances = ['default', 'ghost'];

  @action openDrawer(appearance) {
    this.selectedAppearance = appearance;
    this.isOpen = true;
  }

  @action closeDrawer() {
    this.isOpen = false;
  }

  <template>
    <div class='flex gap-2'>
      {{#each this.appearances as |appearance|}}
        <Button @onPress={{fn this.openDrawer appearance}}>
          {{appearance}}
          with icon
        </Button>
      {{/each}}
    </div>

    <Drawer
      @isOpen={{this.isOpen}}
      @onClose={{this.closeDrawer}}
      @appearance={{this.selectedAppearance}}
      as |d|
    >
      <d.Header
        @title='{{this.selectedAppearance}} with an icon'
        @description='The icon and text placement come from the block form.'
        as |h|
      >
        <h.Icon><SettingsIcon /></h.Icon>
        <h.Title />
        <h.Description />
      </d.Header>
      <d.Body>
        <p>Icon, title and description are placed by the block, unaffected by
          which appearance is active.</p>
      </d.Body>
    </Drawer>
  </template>
}
```

### Header

`<d.Header>` accepts `@title` and `@description` directly, or a block yielding `h.Icon`,
`h.Title` and `h.Description` for when you need to place them yourself — a blockless
`<h.Title />` or `<h.Description />` falls back to `@title` / `@description`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Drawer } from 'frontile';
import { Button } from 'frontile';

export default class DrawerHeaderArgs extends Component {
  @tracked isOpen = false;

  @action toggle() {
    this.isOpen = !this.isOpen;
  }

  <template>
    <Button @onPress={{this.toggle}}>
      Open Drawer
    </Button>

    <Drawer @isOpen={{this.isOpen}} @onClose={{this.toggle}} as |d|>
      <d.Header
        @title='Account settings'
        @description='Update your name, email and password.'
      />
      <d.Body>
        <p>The title and description above came from `@title` and
          `@description`, with no block needed.</p>
      </d.Body>
    </Drawer>
  </template>
}
```

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Drawer } from 'frontile';
import { Button } from 'frontile';
import { SettingsIcon } from 'site/components/icons';

export default class DrawerHeaderBlock extends Component {
  @tracked isOpen = false;

  @action toggle() {
    this.isOpen = !this.isOpen;
  }

  <template>
    <Button @onPress={{this.toggle}}>
      Open Drawer
    </Button>

    <Drawer @isOpen={{this.isOpen}} @onClose={{this.toggle}} as |d|>
      <d.Header
        @title='Account settings'
        @description='Update your name, email and password.'
        as |h|
      >
        <h.Icon><SettingsIcon /></h.Icon>
        <h.Title />
        <h.Description />
      </d.Header>
      <d.Body>
        <p>The title and description here are still the same `@title` and
          `@description`, only placed alongside an icon by the block.</p>
      </d.Body>
    </Drawer>
  </template>
}
```

### Placement

Drawers can slide in from any edge of the screen.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { Drawer } from 'frontile';
import { Button } from 'frontile';

export default class DrawerPlacements extends Component {
  @tracked isOpen = false;
  @tracked selectedPlacement = 'right';

  placements = [
    {
      key: 'top',
      label: 'Top Drawer',
      title: 'Top Drawer',
      description: 'This drawer slides down from the top of the screen.'
    },
    {
      key: 'bottom',
      label: 'Bottom Drawer',
      title: 'Bottom Drawer',
      description: 'This drawer slides up from the bottom of the screen.'
    },
    {
      key: 'left',
      label: 'Left Drawer',
      title: 'Left Drawer',
      description: 'This drawer slides in from the left side of the screen.'
    },
    {
      key: 'right',
      label: 'Right Drawer',
      title: 'Right Drawer',
      description: 'This drawer slides in from the right side of the screen.'
    }
  ];

  @action openDrawer(placement) {
    this.selectedPlacement = placement;
    this.isOpen = true;
  }

  @action closeDrawer() {
    this.isOpen = false;
  }

  get currentPlacement() {
    return this.placements.find(
      (placement) => placement.key === this.selectedPlacement
    );
  }

  <template>
    <div class='demo-stack demo-stack--wide items-center'>
      <div class='grid grid-cols-2 gap-2'>
        {{#each this.placements as |placement|}}
          <Button @onPress={{fn this.openDrawer placement.key}}>
            {{placement.label}}
          </Button>
        {{/each}}
      </div>

      <Drawer
        @isOpen={{this.isOpen}}
        @onClose={{this.closeDrawer}}
        @placement={{this.selectedPlacement}}
        as |d|
      >
        <d.Header>{{this.currentPlacement.title}}</d.Header>
        <d.Body>
          <p>{{this.currentPlacement.description}}</p>
        </d.Body>
      </Drawer>
    </div>
  </template>
}
```

### Size

Control the drawer size with the `@size` argument.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { Drawer } from 'frontile';
import { Button } from 'frontile';
import { on } from '@ember/modifier';

export default class DrawerSizes extends Component {
  @tracked isOpen = false;
  @tracked selectedSize = 'md';

  sizeOptions = [
    {
      key: 'xs',
      label: 'XS Size',
      title: 'Extra Small Drawer',
      description: 'This is an extra small drawer (xs).'
    },
    {
      key: 'sm',
      label: 'SM Size',
      title: 'Small Drawer',
      description: 'This is a small drawer (sm).'
    },
    {
      key: 'md',
      label: 'MD Size (Default)',
      title: 'Medium Drawer',
      description: 'This is a medium drawer (md). This is the default size.'
    },
    {
      key: 'lg',
      label: 'LG Size',
      title: 'Large Drawer',
      description: 'This is a large drawer (lg).'
    },
    {
      key: 'xl',
      label: 'XL Size',
      title: 'Extra Large Drawer',
      description: 'This is an extra large drawer (xl).'
    },
    {
      key: 'full',
      label: 'Full Size',
      title: 'Full Size Drawer',
      description: 'This drawer takes up the full width/height of the screen.'
    }
  ];

  @action openDrawer(size) {
    this.selectedSize = size;
    this.isOpen = true;
  }

  @action closeDrawer() {
    this.isOpen = false;
  }

  get currentSizeOption() {
    return this.sizeOptions.find((option) => option.key === this.selectedSize);
  }

  <template>
    <div class='demo-stack demo-stack--wide items-center'>
      <div class='grid grid-cols-3 gap-2'>
        {{#each this.sizeOptions as |option|}}
          <Button @onPress={{fn this.openDrawer option.key}}>
            {{option.label}}
          </Button>
        {{/each}}
      </div>

      <Drawer
        @isOpen={{this.isOpen}}
        @onClose={{this.closeDrawer}}
        @size={{this.selectedSize}}
        as |d|
      >
        <d.Header>{{this.currentSizeOption.title}}</d.Header>
        <d.Body>
          <p>{{this.currentSizeOption.description}}</p>
        </d.Body>
      </Drawer>
    </div>
  </template>
}
```

### Drag to close

`@allowDragToClose` is on by default for `top`/`bottom` and off by default for `left`/`right`.
Passing `true` opts any placement in; passing `false` turns it off for any placement. It has no
effect when `@allowClosing={{false}}` — a non-dismissible drawer stays non-dismissible either
way. Side placements default to off because a horizontal drag starting at a screen edge is
easy to miss; pass `@allowDragToClose={{true}}` to enable it there too.
The handle is a real button (labelled "Close drawer"), so keyboard and assistive-technology
users can close the drawer by activating it, without performing a gesture at all — and it
closes on click as well as on drag for everyone else.

A press on the body itself (not just the handle) can also dismiss the drawer, once the body's
own scroll position is already at the edge the drag pulls away from — so a drag toward the
handle's side dismisses, while scrolling through a longer body still scrolls normally instead
of being hijacked. This distinction is decided a few pixels into the gesture, not at the very
first touch, so tapping or starting to scroll never has a false start.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { Drawer } from 'frontile';
import { Button } from 'frontile';

export default class DrawerDragBottom extends Component {
  @tracked isOpen = false;
  @tracked selectedAppearance = 'default';

  appearances = ['default', 'ghost'];

  @action openDrawer(appearance) {
    this.selectedAppearance = appearance;
    this.isOpen = true;
  }

  @action closeDrawer() {
    this.isOpen = false;
  }

  <template>
    <div class='flex gap-2'>
      {{#each this.appearances as |appearance|}}
        <Button @onPress={{fn this.openDrawer appearance}}>
          Open Bottom Drawer ({{appearance}})
        </Button>
      {{/each}}
    </div>

    <Drawer
      @isOpen={{this.isOpen}}
      @onClose={{this.closeDrawer}}
      @placement='bottom'
      @appearance={{this.selectedAppearance}}
      as |d|
    >
      <d.Header @title='Drag me down' @description='Or use the close button.' />
      <d.Body>
        <p>Drag the handle at the top of this drawer down to dismiss it, or
          release early to have it spring back. The handle bar looks the same in
          `default` and `ghost`.</p>
      </d.Body>
    </Drawer>
  </template>
}
```

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Drawer } from 'frontile';
import { Button } from 'frontile';

export default class DrawerDragRight extends Component {
  @tracked isOpen = false;

  @action toggle() {
    this.isOpen = !this.isOpen;
  }

  <template>
    <Button @onPress={{this.toggle}}>
      Open Right Drawer
    </Button>

    <Drawer
      @isOpen={{this.isOpen}}
      @onClose={{this.toggle}}
      @placement='right'
      @allowDragToClose={{true}}
      as |d|
    >
      <d.Header
        @title='Opted in'
        @description='Right drawers need @allowDragToClose to get the handle.'
      />
      <d.Body>
        <p>Drag the handle on the left edge toward the left to dismiss.</p>
      </d.Body>
    </Drawer>
  </template>
}
```

### Different Backdrop Types

Control the appearance of the backdrop behind the drawer.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { Drawer } from 'frontile';
import { Button } from 'frontile';

export default class DrawerBackdrops extends Component {
  @tracked isOpen = false;
  @tracked selectedBackdrop = 'faded';

  backdropOptions = [
    {
      key: 'faded',
      label: 'Faded Backdrop',
      title: 'Faded Backdrop',
      description: 'Standard semi-transparent backdrop (default).'
    },
    {
      key: 'blur',
      label: 'Blurred Backdrop',
      title: 'Blurred Backdrop',
      description: 'Backdrop with blur effect behind the drawer.'
    },
    {
      key: 'none',
      label: 'No Backdrop',
      title: 'No Backdrop',
      description: 'Drawer without any backdrop overlay.'
    }
  ];

  @action openDrawer(backdrop) {
    this.selectedBackdrop = backdrop;
    this.isOpen = true;
  }

  @action closeDrawer() {
    this.isOpen = false;
  }

  get currentBackdropOption() {
    return this.backdropOptions.find(
      (option) => option.key === this.selectedBackdrop
    );
  }

  <template>
    <div class='demo-stack demo-stack--wide items-center'>
      <div class='grid grid-cols-2 gap-2'>
        {{#each this.backdropOptions as |option|}}
          <Button @onPress={{fn this.openDrawer option.key}}>
            {{option.label}}
          </Button>
        {{/each}}
      </div>

      <Drawer
        @isOpen={{this.isOpen}}
        @onClose={{this.closeDrawer}}
        @backdrop={{this.selectedBackdrop}}
        @placement='right'
        @size='md'
        as |d|
      >
        <d.Header>{{this.currentBackdropOption.title}}</d.Header>
        <d.Body>
          <p>{{this.currentBackdropOption.description}}</p>
          <p class='mt-2 text-sm text-neutral-soft'>Notice how the backdrop
            behind this drawer changes based on the selected type.</p>
        </d.Body>
        <d.Footer>
          <Button @onPress={{this.closeDrawer}}>Close</Button>
        </d.Footer>
      </Drawer>
    </div>
  </template>
}
```

### Close Button Control

Control the visibility and behavior of the close button.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Drawer } from 'frontile';
import { Button } from 'frontile';

export default class DrawerCloseButton extends Component {
  @tracked normalOpen = false;
  @tracked noCloseButtonOpen = false;
  @tracked customCloseOpen = false;

  @action toggleNormal() {
    this.normalOpen = !this.normalOpen;
  }

  @action toggleNoCloseButton() {
    this.noCloseButtonOpen = !this.noCloseButtonOpen;
  }

  @action toggleCustomClose() {
    this.customCloseOpen = !this.customCloseOpen;
  }

  <template>
    <div class='demo-stack demo-stack--wide items-center'>
      <div class='flex gap-2'>
        <Button @onPress={{this.toggleNormal}}>
          Normal Close Button
        </Button>
        <Button @onPress={{this.toggleNoCloseButton}}>
          No Close Button
        </Button>
        <Button @onPress={{this.toggleCustomClose}}>
          Custom Close Button
        </Button>
      </div>

      <Drawer @isOpen={{this.normalOpen}} @onClose={{this.toggleNormal}} as |d|>
        <d.Header>Normal Close Button</d.Header>
        <d.Body>
          <p>This drawer has the default close button in the top right corner.</p>
        </d.Body>
      </Drawer>

      <Drawer
        @isOpen={{this.noCloseButtonOpen}}
        @onClose={{this.toggleNoCloseButton}}
        @allowCloseButton={{false}}
        as |d|
      >
        <d.Header>No Close Button</d.Header>
        <d.Body>
          <p>This drawer has no close button. You can still close it by clicking
            the backdrop or pressing Escape.</p>
        </d.Body>
        <d.Footer>
          <Button @onPress={{this.toggleNoCloseButton}}>
            Close from Footer
          </Button>
        </d.Footer>
      </Drawer>

      <Drawer
        @isOpen={{this.customCloseOpen}}
        @onClose={{this.toggleCustomClose}}
        @allowCloseButton={{false}}
        as |d|
      >
        <d.Header>
          Custom Close Button
          <d.CloseButton />
        </d.Header>
        <d.Body>
          <p>This drawer uses a custom close button placed in the header using
            the yielded CloseButton component.</p>
        </d.Body>
      </Drawer>
    </div>
  </template>
}
```

### Non-Dismissible Drawer

A drawer that cannot be closed by normal means.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Drawer } from 'frontile';
import { Button } from 'frontile';
import { ProgressBar } from 'frontile';

export default class NonDismissibleDrawer extends Component {
  @tracked isOpen = false;
  @tracked progress = 0;
  @tracked isProcessing = false;

  @action toggle() {
    this.isOpen = !this.isOpen;
  }

  @action startProcess() {
    this.isProcessing = true;
    this.progress = 0;

    const interval = setInterval(() => {
      this.progress += 10;
      if (this.progress >= 100) {
        clearInterval(interval);
        this.isProcessing = false;
      }
    }, 500);
  }

  @action forceClose() {
    this.isProcessing = false;
    this.progress = 0;
    this.toggle();
  }

  get allowClosing() {
    return !this.isProcessing;
  }

  <template>
    <div class='demo-stack demo-stack--wide items-center'>
      <Button @onPress={{this.toggle}}>
        Open Processing Drawer
      </Button>

      <Drawer
        @isOpen={{this.isOpen}}
        @onClose={{this.toggle}}
        @allowClosing={{this.allowClosing}}
        as |d|
      >
        <d.Header>
          Processing Data
        </d.Header>
        <d.Body>
          <div class='space-y-4'>
            <p>This drawer cannot be closed while processing is in progress.</p>

            {{#if this.isProcessing}}
              <ProgressBar
                @progress={{this.progress}}
                @label='Progress: {{this.progress}}%'
                @intent='success'
              />
            {{else}}
              <p class='text-success'>Ready to process data.</p>
            {{/if}}
          </div>
        </d.Body>
        <d.Footer @class='flex gap-2'>
          {{#if this.isProcessing}}
            <Button disabled={{true}}>
              Processing...
            </Button>
            <Button @intent='danger' @onPress={{this.forceClose}}>
              Force Close
            </Button>
          {{else}}
            <Button @onPress={{this.toggle}}>
              Cancel
            </Button>
            <Button @intent='primary' @onPress={{this.startProcess}}>
              Start Processing
            </Button>
          {{/if}}
        </d.Footer>
      </Drawer>
    </div>
  </template>
}
```

## Patterns

### Form in Drawer

A practical example showing a form inside a drawer.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Drawer } from 'frontile';
import { Button } from 'frontile';
import { Input, Textarea } from 'frontile';
import { on } from '@ember/modifier';

export default class DrawerForm extends Component {
  @tracked isOpen = false;
  @tracked name = '';
  @tracked email = '';
  @tracked message = '';

  @action toggle() {
    this.isOpen = !this.isOpen;
  }

  @action handleSubmit(event) {
    event.preventDefault();
    // Handle form submission
    console.log('Form submitted:', {
      name: this.name,
      email: this.email,
      message: this.message
    });
    this.toggle();
  }

  @action updateName(value) {
    this.name = value;
  }

  @action updateEmail(value) {
    this.email = value;
  }

  @action updateMessage(value) {
    this.message = value;
  }

  <template>
    <div class='demo-stack demo-stack--wide items-center'>
      <Button @onPress={{this.toggle}}>
        Open Contact Form
      </Button>

      <Drawer
        @isOpen={{this.isOpen}}
        @onClose={{this.toggle}}
        @size='lg'
        as |d|
      >
        <d.Header>
          Contact Us
        </d.Header>
        <d.Body>
          <form {{on 'submit' this.handleSubmit}} class='space-y-4'>
            <Input
              @label='Name'
              @value={{this.name}}
              @onInput={{this.updateName}}
              required
            />
            <Input
              @label='Email'
              @type='email'
              @value={{this.email}}
              @onInput={{this.updateEmail}}
              required
            />
            <Textarea
              @label='Message'
              @value={{this.message}}
              @onInput={{this.updateMessage}}
              @rows={{5}}
              required
            />
          </form>
        </d.Body>
        <d.Footer @class='flex gap-2'>
          <Button @onPress={{this.toggle}}>
            Cancel
          </Button>
          <Button @intent='primary' @onPress={{this.handleSubmit}}>
            Send Message
          </Button>
        </d.Footer>
      </Drawer>
    </div>
  </template>
}
```

### Navigation Drawer

A drawer used for navigation with a list of links.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { Drawer } from 'frontile';
import { Button } from 'frontile';
import { on } from '@ember/modifier';
import { Divider } from 'frontile';

export default class NavigationDrawer extends Component {
  @tracked isOpen = false;

  @action toggle() {
    this.isOpen = !this.isOpen;
  }

  @action navigateTo(page) {
    console.log('Navigate to:', page);
    this.toggle();
  }

  <template>
    <div class='demo-stack demo-stack--wide items-center'>
      <Button @onPress={{this.toggle}}>
        Open Navigation
      </Button>

      <Drawer
        @isOpen={{this.isOpen}}
        @onClose={{this.toggle}}
        @placement='left'
        @size='sm'
        as |d|
      >
        <d.Header>
          App Navigation
        </d.Header>
        <d.Body>
          <nav class='space-y-2'>
            <button
              {{on 'click' (fn this.navigateTo 'dashboard')}}
              class='w-full text-left px-3 py-2 rounded hover:bg-neutral-subtle transition-colors'
            >
              🏠 Dashboard
            </button>
            <button
              {{on 'click' (fn this.navigateTo 'profile')}}
              class='w-full text-left px-3 py-2 rounded hover:bg-neutral-subtle transition-colors'
            >
              👤 Profile
            </button>
            <button
              {{on 'click' (fn this.navigateTo 'settings')}}
              class='w-full text-left px-3 py-2 rounded hover:bg-neutral-subtle transition-colors'
            >
              ⚙️ Settings
            </button>
            <button
              {{on 'click' (fn this.navigateTo 'help')}}
              class='w-full text-left px-3 py-2 rounded hover:bg-neutral-subtle transition-colors'
            >
              ❓ Help
            </button>
            <Divider />
            <button
              {{on 'click' (fn this.navigateTo 'logout')}}
              class='w-full text-left px-3 py-2 rounded hover:bg-danger-subtle text-danger transition-colors'
            >
              🚪 Logout
            </button>
          </nav>
        </d.Body>
      </Drawer>
    </div>
  </template>
}
```

## Accessibility

The drawer renders as `role="dialog"` with `tabindex="0"` and `aria-modal="true"`, labelled
by `aria-labelledby` pointing at the id yielded as `headerId` — which `<d.Header>` applies.
`aria-labelledby` is only rendered while a `Header` is actually on the page, so a drawer
without one has no dangling reference — but it also has **no accessible name**. Give it one:
render a `Header`, or pass your own label through attributes.

```gts
<Drawer @isOpen={{this.isOpen}} @onClose={{this.close}} aria-label="Filters" as |d|>
  <d.Body>Filter controls</d.Body>
</Drawer>
```

If you label the drawer with a heading of your own rather than `<d.Header>`, pass
`aria-labelledby` yourself — putting the yielded `headerId` on a heading does not label the
dialog by itself, because nothing points at it:

```gts
<Drawer @isOpen={{this.isOpen}} @onClose={{this.close}} aria-labelledby={{this.titleId}} as |d|>
  <h2 id={{this.titleId}}>My Title</h2>
  <d.Body>My Content</d.Body>
</Drawer>
```

In development, a drawer that ends up with no accessible name at all — no `Header`, no
`aria-label` and no `aria-labelledby` — logs a warning with the id
`frontile.drawer.missing-accessible-name`. It is compiled out of production builds.

`aria-modal="true"` is dropped when `@disableFocusTrap={{true}}`: with the trap off the page
behind really is reachable, and claiming otherwise would mislead screen reader users. Note
that the drawer still auto-focuses itself in this case, unless `@preventAutoFocus={{true}}`
is also passed — see [Overlay](./overlay.md#accessibility).

Behavior inherited from [Overlay](./overlay.md):

| Behavior       | Detail                                                 |
| -------------- | ------------------------------------------------------ |
| Focus on open  | Moves into the drawer, and a focus trap keeps it there |
| Focus on close | Returns to whatever was focused before opening         |
| `Escape`       | Closes, unless `@closeOnEscapeKey={{false}}`           |
| Backdrop click | Closes, unless `@closeOnOutsideClick={{false}}`        |
| Body scroll    | Blocked while open (reference counted for nesting)     |

The drawer needs at least one focusable element inside it, or the focus trap has nowhere to
put focus. `@allowClosing={{false}}` disables Escape, backdrop click and the close button at
once, leaving a keyboard user no way out — the Non-Dismissible example above pairs it with
explicit footer actions for that reason.

Note that `@placement` is purely visual: a drawer sliding in from the left is announced no
differently from one on the right, and nothing about the placement reaches assistive
technology. Frontile also does not set `aria-describedby`.

## API

<Signature @component="Drawer" />
