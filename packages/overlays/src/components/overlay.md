---
imports:
  - import Signature from 'site/components/signature';
---

# Overlay

The Overlay component is the foundation for building overlay interactions like Modal, Drawer, Popover, and more. It provides all the essential features needed for accessible and user-friendly overlay experiences.

## Import

```js
import { Overlay } from 'frontile';
```

## Key Features

- **Auto-Focusing**: Automatically focuses the overlay when opened
- **Focus Trapping**: Keeps focus within the overlay while open
- **Portal Rendering**: Renders in a portal by default, with option to render in-place
- **Keyboard Support**: Press `Esc` to dismiss
- **Click Outside**: Click on the backdrop to dismiss
- **Smooth Animations**: Built-in CSS transitions
- **Scroll Management**: Prevents body scroll when overlay is open
- **Focus Restoration**: Restores focus to the previously focused element when closed

> **Important**: You must have at least one focusable element inside the Overlay for proper accessibility.

## Usage

### Basic Overlay

The most basic usage of the Overlay component.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Overlay } from 'frontile';
import { Button } from 'frontile';

export default class BasicOverlay extends Component {
  @tracked isOpen = false;

  @action toggle() {
    this.isOpen = !this.isOpen;
  }

  <template>
    <div class='flex flex-col gap-4'>
      <Button @onPress={{this.toggle}}>
        Open Overlay
      </Button>

      <Overlay @isOpen={{this.isOpen}} @onClose={{this.toggle}}>
        <div class='bg-content1 p-8 rounded-lg shadow-lg max-w-md'>
          <h2 class='text-lg font-semibold mb-4'>Overlay Content</h2>
          <p class='mb-4'>This is the content inside the overlay. You can put
            any content here.</p>
          <div class='flex gap-2'>
            <Button @intent='primary' @onPress={{this.toggle}}>
              Close
            </Button>
            <Button>
              Another Action
            </Button>
          </div>
        </div>
      </Overlay>
    </div>
  </template>
}
```

### Overlay with Different Backdrop Types

Control the appearance of the backdrop behind the overlay.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Overlay } from 'frontile';
import { Button } from 'frontile';

export default class BackdropTypes extends Component {
  @tracked fadedOpen = false;
  @tracked blurredOpen = false;
  @tracked noneOpen = false;

  @action toggleFaded() {
    this.fadedOpen = !this.fadedOpen;
  }

  @action toggleBlurred() {
    this.blurredOpen = !this.blurredOpen;
  }

  @action toggleNone() {
    this.noneOpen = !this.noneOpen;
  }

  <template>
    <div class='flex flex-col gap-4'>
      <div class='flex gap-2'>
        <Button @onPress={{this.toggleFaded}}>
          Faded Backdrop
        </Button>
        <Button @onPress={{this.toggleBlurred}}>
          Blurred Backdrop
        </Button>
        <Button @onPress={{this.toggleNone}}>
          No Backdrop
        </Button>
      </div>

      <Overlay
        @isOpen={{this.fadedOpen}}
        @onClose={{this.toggleFaded}}
        @backdrop='faded'
      >
        <div class='bg-content1 p-6 rounded-lg shadow-lg'>
          <h3 class='font-semibold mb-2'>Faded Backdrop</h3>
          <p class='mb-4'>Standard semi-transparent backdrop</p>
          <Button @onPress={{this.toggleFaded}}>Close</Button>
        </div>
      </Overlay>

      <Overlay
        @isOpen={{this.blurredOpen}}
        @onClose={{this.toggleBlurred}}
        @backdrop='blur'
      >
        <div class='bg-content1 p-6 rounded-lg shadow-lg'>
          <h3 class='font-semibold mb-2'>Blurred Backdrop</h3>
          <p class='mb-4'>Backdrop with blur effect</p>
          <Button @onPress={{this.toggleBlurred}}>Close</Button>
        </div>
      </Overlay>

      <Overlay
        @isOpen={{this.noneOpen}}
        @onClose={{this.toggleNone}}
        @backdrop='none'
      >
        <div class='bg-content1 p-6 rounded-lg shadow-lg border'>
          <h3 class='font-semibold mb-2'>No Backdrop</h3>
          <p class='mb-4'>Overlay without backdrop</p>
          <Button @onPress={{this.toggleNone}}>Close</Button>
        </div>
      </Overlay>
    </div>
  </template>
}
```

### Render In Place

By default, overlays are rendered in a portal. You can render them in-place instead.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Overlay } from 'frontile';
import { Button } from 'frontile';

export default class RenderInPlace extends Component {
  @tracked portalOpen = false;
  @tracked inPlaceOpen = false;

  @action togglePortal() {
    this.portalOpen = !this.portalOpen;
  }

  @action toggleInPlace() {
    this.inPlaceOpen = !this.inPlaceOpen;
  }

  <template>
    <div class='flex flex-col gap-4'>
      <div class='flex gap-2'>
        <Button @onPress={{this.togglePortal}}>
          Portal Overlay (Default)
        </Button>
        <Button @onPress={{this.toggleInPlace}}>
          In-Place Overlay
        </Button>
      </div>

      <div
        class='relative border-2 border-dashed border-default-300 p-4 min-h-48'
      >
        <p class='text-sm text-default-600 mb-4'>This container shows the
          difference between portal and in-place rendering.</p>

        <Overlay
          @isOpen={{this.inPlaceOpen}}
          @onClose={{this.toggleInPlace}}
          @renderInPlace={{true}}
        >
          <div
            class='absolute inset-4 bg-content1 p-4 rounded shadow-lg border'
          >
            <h3 class='font-semibold mb-2'>In-Place Overlay</h3>
            <p class='text-sm mb-4'>This overlay is rendered within its parent
              container.</p>
            <Button @size='sm' @onPress={{this.toggleInPlace}}>Close</Button>
          </div>
        </Overlay>
      </div>

      <Overlay @isOpen={{this.portalOpen}} @onClose={{this.togglePortal}}>
        <div class='bg-content1 p-6 rounded-lg shadow-lg'>
          <h3 class='font-semibold mb-2'>Portal Overlay</h3>
          <p class='mb-4'>This overlay is rendered in a portal (outside the
            normal DOM tree).</p>
          <Button @onPress={{this.togglePortal}}>Close</Button>
        </div>
      </Overlay>
    </div>
  </template>
}
```

### Custom Close Behavior

Control when and how the overlay can be closed.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Overlay } from 'frontile';
import { Button } from 'frontile';

export default class CustomCloseBehavior extends Component {
  @tracked normalOpen = false;
  @tracked noEscapeOpen = false;
  @tracked noOutsideClickOpen = false;
  @tracked confirmCloseOpen = false;

  @action toggleNormal() {
    this.normalOpen = !this.normalOpen;
  }

  @action toggleNoEscape() {
    this.noEscapeOpen = !this.noEscapeOpen;
  }

  @action toggleNoOutsideClick() {
    this.noOutsideClickOpen = !this.noOutsideClickOpen;
  }

  @action toggleConfirmClose() {
    this.confirmCloseOpen = !this.confirmCloseOpen;
  }

  @action handleConfirmClose() {
    if (confirm('Are you sure you want to close this overlay?')) {
      this.confirmCloseOpen = false;
    }
  }

  <template>
    <div class='flex flex-col gap-4'>
      <div class='grid grid-cols-2 gap-2'>
        <Button @onPress={{this.toggleNormal}}>
          Normal Overlay
        </Button>
        <Button @onPress={{this.toggleNoEscape}}>
          No Escape Key
        </Button>
        <Button @onPress={{this.toggleNoOutsideClick}}>
          No Outside Click
        </Button>
        <Button @onPress={{this.toggleConfirmClose}}>
          Confirm Close
        </Button>
      </div>

      <Overlay @isOpen={{this.normalOpen}} @onClose={{this.toggleNormal}}>
        <div class='bg-content1 p-6 rounded-lg shadow-lg'>
          <h3 class='font-semibold mb-2'>Normal Overlay</h3>
          <p class='mb-4'>Can be closed with Escape key, outside click, or
            button.</p>
          <Button @onPress={{this.toggleNormal}}>Close</Button>
        </div>
      </Overlay>

      <Overlay
        @isOpen={{this.noEscapeOpen}}
        @onClose={{this.toggleNoEscape}}
        @closeOnEscapeKey={{false}}
      >
        <div class='bg-content1 p-6 rounded-lg shadow-lg'>
          <h3 class='font-semibold mb-2'>No Escape Key</h3>
          <p class='mb-4'>Cannot be closed with Escape key. Try pressing Escape!</p>
          <Button @onPress={{this.toggleNoEscape}}>Close</Button>
        </div>
      </Overlay>

      <Overlay
        @isOpen={{this.noOutsideClickOpen}}
        @onClose={{this.toggleNoOutsideClick}}
        @closeOnOutsideClick={{false}}
      >
        <div class='bg-content1 p-6 rounded-lg shadow-lg'>
          <h3 class='font-semibold mb-2'>No Outside Click</h3>
          <p class='mb-4'>Cannot be closed by clicking outside. Try clicking the
            backdrop!</p>
          <Button @onPress={{this.toggleNoOutsideClick}}>Close</Button>
        </div>
      </Overlay>

      <Overlay
        @isOpen={{this.confirmCloseOpen}}
        @onClose={{this.handleConfirmClose}}
      >
        <div class='bg-content1 p-6 rounded-lg shadow-lg'>
          <h3 class='font-semibold mb-2'>Confirm Close</h3>
          <p class='mb-4'>Shows confirmation dialog before closing.</p>
          <Button @onPress={{this.handleConfirmClose}}>Close</Button>
        </div>
      </Overlay>
    </div>
  </template>
}
```

### Focus Management

Demonstrate focus trapping and restoration features.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Overlay } from 'frontile';
import { Button } from 'frontile';
import { Input } from 'frontile';

export default class FocusManagement extends Component {
  @tracked focusTrapOpen = false;
  @tracked noFocusTrapOpen = false;

  @action toggleFocusTrap() {
    this.focusTrapOpen = !this.focusTrapOpen;
  }

  @action toggleNoFocusTrap() {
    this.noFocusTrapOpen = !this.noFocusTrapOpen;
  }

  <template>
    <div class='flex flex-col gap-4'>
      <div class='flex gap-2'>
        <Button @onPress={{this.toggleFocusTrap}} data-test-trigger>
          Focus Trap Enabled
        </Button>
        <Button @onPress={{this.toggleNoFocusTrap}}>
          Focus Trap Disabled
        </Button>
      </div>

      <p class='text-sm text-default-600'>
        Open an overlay and use Tab/Shift+Tab to see focus behavior. Focus
        should return to the trigger button when closed.
      </p>

      <Overlay @isOpen={{this.focusTrapOpen}} @onClose={{this.toggleFocusTrap}}>
        <div class='bg-content1 p-6 rounded-lg shadow-lg max-w-md'>
          <h3 class='font-semibold mb-4'>Focus Trap Enabled</h3>
          <p class='mb-4 text-sm'>Focus is trapped within this overlay. Try
            pressing Tab to cycle through focusable elements.</p>

          <div class='space-y-3'>
            <Input @label='First Input' />
            <Input @label='Second Input' />
            <div class='flex gap-2'>
              <Button @intent='primary' @onPress={{this.toggleFocusTrap}}>
                Close
              </Button>
              <Button>
                Another Button
              </Button>
            </div>
          </div>
        </div>
      </Overlay>

      <Overlay
        @isOpen={{this.noFocusTrapOpen}}
        @onClose={{this.toggleNoFocusTrap}}
        @disableFocusTrap={{true}}
      >
        <div class='bg-content1 p-6 rounded-lg shadow-lg max-w-md'>
          <h3 class='font-semibold mb-4'>Focus Trap Disabled</h3>
          <p class='mb-4 text-sm'>Focus is not trapped. You can Tab to elements
            outside the overlay.</p>

          <div class='space-y-3'>
            <Input @label='Input Field' />
            <Button @onPress={{this.toggleNoFocusTrap}}>
              Close
            </Button>
          </div>
        </div>
      </Overlay>
    </div>
  </template>
}
```

### Animations and Transitions

Customize overlay animations and transition duration.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Overlay } from 'frontile';
import { Button } from 'frontile';

export default class AnimationsAndTransitions extends Component {
  @tracked fastOpen = false;
  @tracked slowOpen = false;
  @tracked noAnimationOpen = false;

  @action toggleFast() {
    this.fastOpen = !this.fastOpen;
  }

  @action toggleSlow() {
    this.slowOpen = !this.slowOpen;
  }

  @action toggleNoAnimation() {
    this.noAnimationOpen = !this.noAnimationOpen;
  }

  <template>
    <div class='flex flex-col gap-4'>
      <div class='flex gap-2'>
        <Button @onPress={{this.toggleFast}}>
          Fast Animation (100ms)
        </Button>
        <Button @onPress={{this.toggleSlow}}>
          Slow Animation (800ms)
        </Button>
        <Button @onPress={{this.toggleNoAnimation}}>
          No Animation
        </Button>
      </div>

      <Overlay
        @isOpen={{this.fastOpen}}
        @onClose={{this.toggleFast}}
        @transitionDuration={{100}}
      >
        <div class='bg-content1 p-6 rounded-lg shadow-lg'>
          <h3 class='font-semibold mb-2'>Fast Animation</h3>
          <p class='mb-4'>This overlay opens and closes quickly (100ms).</p>
          <Button @onPress={{this.toggleFast}}>Close</Button>
        </div>
      </Overlay>

      <Overlay
        @isOpen={{this.slowOpen}}
        @onClose={{this.toggleSlow}}
        @transitionDuration={{800}}
      >
        <div class='bg-content1 p-6 rounded-lg shadow-lg'>
          <h3 class='font-semibold mb-2'>Slow Animation</h3>
          <p class='mb-4'>This overlay has a longer transition duration (800ms).</p>
          <Button @onPress={{this.toggleSlow}}>Close</Button>
        </div>
      </Overlay>

      <Overlay
        @isOpen={{this.noAnimationOpen}}
        @onClose={{this.toggleNoAnimation}}
        @disableTransitions={{true}}
      >
        <div class='bg-content1 p-6 rounded-lg shadow-lg'>
          <h3 class='font-semibold mb-2'>No Animation</h3>
          <p class='mb-4'>This overlay appears instantly without transitions.</p>
          <Button @onPress={{this.toggleNoAnimation}}>Close</Button>
        </div>
      </Overlay>
    </div>
  </template>
}
```

### Outside Click vs Overlay Element Click

The Overlay component has two different click-to-close mechanisms that work together:

- **`@closeOnOutsideClick`** (default: `true`): Closes when clicking the backdrop/outside area
- **`@closeOnOverlayElementClick`** (default: `true`): Closes when clicking the overlay element itself

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Overlay } from 'frontile';
import { Button } from 'frontile';

export default class OverlayElementClick extends Component {
  @tracked defaultOpen = false;
  @tracked disabledOpen = false;

  @action toggleDefault() {
    this.defaultOpen = !this.defaultOpen;
  }

  @action toggleDisabled() {
    this.disabledOpen = !this.disabledOpen;
  }

  <template>
    <div class='flex flex-col gap-4'>
      <div class='flex gap-2'>
        <Button @onPress={{this.toggleDefault}}>
          Default Behavior
        </Button>
        <Button @onPress={{this.toggleDisabled}}>
          Overlay Element Click Disabled
        </Button>
      </div>

      <div class='text-sm space-y-2'>
        <p><strong>Default Behavior:</strong>
          Try clicking on the overlay element (the outer container) vs the inner
          content card.</p>
        <p><strong>Disabled:</strong>
          Only the backdrop (outside area) will close the overlay.</p>
      </div>

      <Overlay @isOpen={{this.defaultOpen}} @onClose={{this.toggleDefault}}>
        <div class='bg-content1 p-6 rounded-lg shadow-lg max-w-md'>
          <h3 class='font-semibold mb-2'>Default Behavior</h3>
          <p class='mb-4 text-sm'>
            <code>@closeOnOverlayElementClick={{true}}</code>
            (default)
          </p>
          <p class='mb-4'>Clicking anywhere on the overlay element will close
            it, but clicking this inner content card won't.</p>
          <Button @onPress={{this.toggleDefault}}>Close</Button>
        </div>
      </Overlay>

      <Overlay
        @isOpen={{this.disabledOpen}}
        @onClose={{this.toggleDisabled}}
        @closeOnOverlayElementClick={{false}}
      >
        <div class='bg-content1 p-6 rounded-lg shadow-lg max-w-md'>
          <h3 class='font-semibold mb-2'>Overlay Element Click Disabled</h3>
          <p class='mb-4 text-sm'>
            <code>@closeOnOverlayElementClick={{false}}</code>
          </p>
          <p class='mb-4'>Only clicking the backdrop (outside area) will not
            close this overlay because the overlay content element is on top of
            backdrop.</p>
          <Button @onPress={{this.toggleDisabled}}>Close</Button>
        </div>
      </Overlay>
    </div>
  </template>
}
```

> **Why is `@closeOnOverlayElementClick` `true` by default?**
>
> This option is set to `true` by default to make "outside click" functionality work intuitively. Most overlay content is wrapped with an inner element (like a card or dialog), which prevents accidental closure when clicking on the actual content. The overlay element itself acts as part of the "outside" area, allowing users to click anywhere around the content to dismiss the overlay.

## Important Notes

### Focus Requirements

> **Important**: You must have at least one focusable element inside the Overlay for proper accessibility and focus management.

### Portal Elements and FormSelect

`FormSelect` uses Power Select under the hood and has `@renderInPlace={{false}}` set by default, which will insert the dropdown content outside of the Overlay. This can cause focus-trap to prevent accessing focusable elements (like search input) in the Power Select dropdown.

**Solutions:**

- Use `<FormSelect @renderInPlace={{true}} />` (recommended)
- Use `<Overlay @disableFocusTrap={{true}} />` (not recommended for accessibility)

### Backdrop Types

- **`faded`** (default): Semi-transparent backdrop
- **`blur`**: Backdrop with blur effect
- **`none`**: No backdrop

### Transition Options

- **`transitionDuration`**: Duration in milliseconds (default: 200ms)
- **`disableTransitions`**: Disable all animations (default: false)
- **`transition`**: Custom transition configuration

## Accessibility

The Overlay component follows accessibility best practices:

- **Focus Management**: Automatically focuses the overlay when opened and restores focus when closed
- **Focus Trapping**: Keeps focus within the overlay (can be disabled)
- **Keyboard Support**: Escape key to close (can be disabled)
- **Screen Reader Support**: Proper ARIA roles and attributes
- **Scroll Management**: Prevents body scroll when overlay is open

## API

<Signature @package="overlays" @component="Overlay" />
