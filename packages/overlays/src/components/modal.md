---
url: modal
imports:
  - import Signature from 'site/components/signature';
---

# Modal

The Modal component is a centered dialog that appears over the main content. It's built on top of the Overlay component and includes all its accessibility features, plus modal-specific functionality like centered positioning and size variants.

## Import

```js
import { Modal } from '@frontile/overlays';
```

## Key Features

- **Centered Positioning**: Automatically centers content on screen
- **Flexible Sizing**: Multiple size options from xs to full screen
- **Built-in Components**: Header, Body, Footer, and CloseButton
- **Accessible**: Proper ARIA attributes and focus management
- **Customizable**: Control close button visibility and behavior
- **All Overlay Features**: Focus trapping, keyboard support, portal rendering, etc.

## Usage

### Basic Modal

A simple modal with header, body, and footer sections.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Modal } from '@frontile/overlays';
import { Button } from '@frontile/buttons';
import { on } from '@ember/modifier';

export default class BasicModal extends Component {
  @tracked isOpen = false;

  @action toggle() {
    this.isOpen = !this.isOpen;
  }

  <template>
    <div class='flex flex-col gap-4'>
      <Button {{on 'click' this.toggle}}>
        Open Modal
      </Button>

      <Modal @isOpen={{this.isOpen}} @onClose={{this.toggle}} as |m|>
        <m.Header>
          Basic Modal
        </m.Header>
        <m.Body>
          <p class='mb-4'>This is the main content of the modal. Modals are
            great for displaying important information, forms, or confirmation
            dialogs.</p>
          <p>The modal appears centered on the screen with a backdrop that can
            be clicked to close it.</p>
        </m.Body>
        <m.Footer @class='flex gap-2'>
          <Button {{on 'click' this.toggle}}>
            Cancel
          </Button>
          <Button @intent='primary'>
            Confirm
          </Button>
        </m.Footer>
      </Modal>
    </div>
  </template>
}
```

### Different Sizes

Control the modal size with the `@size` argument.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { Modal } from '@frontile/overlays';
import { Button } from '@frontile/buttons';
import { on } from '@ember/modifier';

export default class ModalSizes extends Component {
  @tracked isOpen = false;
  @tracked selectedSize = 'lg';

  sizeOptions = [
    {
      key: 'xs',
      label: 'XS Size',
      title: 'Extra Small Modal',
      description:
        'This is an extra small modal (xs). Perfect for simple confirmations.'
    },
    {
      key: 'sm',
      label: 'SM Size',
      title: 'Small Modal',
      description:
        'This is a small modal (sm). Good for short forms or notifications.'
    },
    {
      key: 'md',
      label: 'MD Size',
      title: 'Medium Modal',
      description: 'This is a medium modal (md). Suitable for moderate content.'
    },
    {
      key: 'lg',
      label: 'LG Size (Default)',
      title: 'Large Modal',
      description:
        'This is a large modal (lg). This is the default size. Great for detailed forms or content.'
    },
    {
      key: 'xl',
      label: 'XL Size',
      title: 'Extra Large Modal',
      description:
        'This is an extra large modal (xl). Perfect for complex forms or detailed content.'
    },
    {
      key: 'full',
      label: 'Full Size',
      title: 'Full Size Modal',
      description:
        'This modal takes up the full screen. Use for complex interfaces or when you need maximum space.'
    }
  ];

  @action openModal(size) {
    this.selectedSize = size;
    this.isOpen = true;
  }

  @action closeModal() {
    this.isOpen = false;
  }

  get currentSizeOption() {
    return this.sizeOptions.find((option) => option.key === this.selectedSize);
  }

  <template>
    <div class='flex flex-col gap-4'>
      <div class='grid grid-cols-3 gap-2'>
        {{#each this.sizeOptions as |option|}}
          <Button {{on 'click' (fn this.openModal option.key)}}>
            {{option.label}}
          </Button>
        {{/each}}
      </div>

      <Modal
        @isOpen={{this.isOpen}}
        @onClose={{this.closeModal}}
        @size={{this.selectedSize}}
        as |m|
      >
        <m.Header>{{this.currentSizeOption.title}}</m.Header>
        <m.Body>
          <p>{{this.currentSizeOption.description}}</p>
        </m.Body>
        <m.Footer>
          <Button {{on 'click' this.closeModal}}>Close</Button>
        </m.Footer>
      </Modal>
    </div>
  </template>
}
```

### Centered vs Standard Positioning

Control vertical centering with the `@isCentered` argument.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Modal } from '@frontile/overlays';
import { Button } from '@frontile/buttons';
import { on } from '@ember/modifier';

export default class ModalPositioning extends Component {
  @tracked standardOpen = false;
  @tracked centeredOpen = false;

  @action toggleStandard() {
    this.standardOpen = !this.standardOpen;
  }

  @action toggleCentered() {
    this.centeredOpen = !this.centeredOpen;
  }

  <template>
    <div class='flex flex-col gap-4'>
      <div class='flex gap-2'>
        <Button {{on 'click' this.toggleStandard}}>
          Standard Position
        </Button>
        <Button {{on 'click' this.toggleCentered}}>
          Centered Position
        </Button>
      </div>

      <Modal
        @isOpen={{this.standardOpen}}
        @onClose={{this.toggleStandard}}
        as |m|
      >
        <m.Header>Standard Positioning</m.Header>
        <m.Body>
          <p>This modal uses standard positioning (not vertically centered). It
            appears towards the top of the screen.</p>
        </m.Body>
        <m.Footer>
          <Button {{on 'click' this.toggleStandard}}>Close</Button>
        </m.Footer>
      </Modal>

      <Modal
        @isOpen={{this.centeredOpen}}
        @onClose={{this.toggleCentered}}
        @isCentered={{true}}
        as |m|
      >
        <m.Header>Centered Positioning</m.Header>
        <m.Body>
          <p>This modal is vertically centered on the screen using @isCentered={{true}}.</p>
        </m.Body>
        <m.Footer>
          <Button {{on 'click' this.toggleCentered}}>Close</Button>
        </m.Footer>
      </Modal>
    </div>
  </template>
}
```

### Different Backdrop Types

Control the appearance of the backdrop behind the modal.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { Modal } from '@frontile/overlays';
import { Button } from '@frontile/buttons';
import { on } from '@ember/modifier';

export default class ModalBackdrops extends Component {
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
      description: 'Backdrop with blur effect behind the modal.'
    },
    {
      key: 'none',
      label: 'No Backdrop',
      title: 'No Backdrop',
      description: 'Modal without any backdrop overlay.'
    }
  ];

  @action openModal(backdrop) {
    this.selectedBackdrop = backdrop;
    this.isOpen = true;
  }

  @action closeModal() {
    this.isOpen = false;
  }

  get currentBackdropOption() {
    return this.backdropOptions.find(
      (option) => option.key === this.selectedBackdrop
    );
  }

  <template>
    <div class='flex flex-col gap-4'>
      <div class='grid grid-cols-2 gap-2'>
        {{#each this.backdropOptions as |option|}}
          <Button {{on 'click' (fn this.openModal option.key)}}>
            {{option.label}}
          </Button>
        {{/each}}
      </div>

      <Modal
        @isOpen={{this.isOpen}}
        @onClose={{this.closeModal}}
        @backdrop={{this.selectedBackdrop}}
        @isCentered={{true}}
        as |m|
      >
        <m.Header>{{this.currentBackdropOption.title}}</m.Header>
        <m.Body>
          <p>{{this.currentBackdropOption.description}}</p>
          <p class='mt-2 text-sm text-default-500'>Notice how the backdrop
            behind this modal changes based on the selected type.</p>
        </m.Body>
        <m.Footer>
          <Button {{on 'click' this.closeModal}}>Close</Button>
        </m.Footer>
      </Modal>
    </div>
  </template>
}
```

### Confirmation Dialog

A practical example showing a confirmation dialog pattern.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Modal } from '@frontile/overlays';
import { Button } from '@frontile/buttons';
import { on } from '@ember/modifier';

export default class ConfirmationDialog extends Component {
  @tracked isOpen = false;
  @tracked isDeleting = false;
  @tracked result = '';

  @action openDialog() {
    this.isOpen = true;
    this.result = '';
  }

  @action cancel() {
    this.isOpen = false;
    this.result = 'Action cancelled';
  }

  @action async confirm() {
    this.isDeleting = true;

    // Simulate async operation
    await new Promise((resolve) => setTimeout(resolve, 2000));

    this.isDeleting = false;
    this.isOpen = false;
    this.result = 'Item deleted successfully';
  }

  get allowClosing() {
    return !this.isDeleting;
  }

  <template>
    <div class='flex flex-col gap-4'>
      <Button @intent='danger' {{on 'click' this.openDialog}}>
        Delete Item
      </Button>

      {{#if this.result}}
        <div class='p-3 rounded border bg-default-50'>
          {{this.result}}
        </div>
      {{/if}}

      <Modal
        @isOpen={{this.isOpen}}
        @onClose={{this.cancel}}
        @size='sm'
        @isCentered={{true}}
        @allowClosing={{this.allowClosing}}
        as |m|
      >
        <m.Header>
          Confirm Deletion
        </m.Header>
        <m.Body>
          <div class='space-y-3'>
            <p>Are you sure you want to delete this item?</p>
            <p class='text-sm text-default-600'>This action cannot be undone.</p>

            {{#if this.isDeleting}}
              <div class='flex items-center space-x-2'>
                <div
                  class='animate-spin rounded-full h-4 w-4 border-b-2 border-red-600'
                ></div>
                <span class='text-sm'>Deleting...</span>
              </div>
            {{/if}}
          </div>
        </m.Body>
        <m.Footer @class='flex gap-2'>
          <Button {{on 'click' this.cancel}} disabled={{this.isDeleting}}>
            Cancel
          </Button>
          <Button
            @intent='danger'
            {{on 'click' this.confirm}}
            disabled={{this.isDeleting}}
          >
            {{#if this.isDeleting}}
              Deleting...
            {{else}}
              Delete
            {{/if}}
          </Button>
        </m.Footer>
      </Modal>
    </div>
  </template>
}
```

### Form Modal

A modal containing a complete form with validation.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Modal } from '@frontile/overlays';
import { Button } from '@frontile/buttons';
import { Input, Textarea, Select } from '@frontile/forms';
import { on } from '@ember/modifier';

export default class FormModal extends Component {
  @tracked isOpen = false;
  @tracked name = '';
  @tracked email = '';
  @tracked category = [];
  @tracked message = '';
  @tracked isSubmitting = false;

  categories = [
    { key: 'support', label: 'Support' },
    { key: 'sales', label: 'Sales' },
    { key: 'feedback', label: 'Feedback' },
    { key: 'other', label: 'Other' }
  ];

  @action toggle() {
    this.isOpen = !this.isOpen;
  }

  @action updateName(value) {
    this.name = value;
  }

  @action updateEmail(value) {
    this.email = value;
  }

  @action updateCategory(keys) {
    this.category = keys;
  }

  @action updateMessage(value) {
    this.message = value;
  }

  @action async handleSubmit(event) {
    event.preventDefault();

    if (!this.name || !this.email || !this.message) {
      return;
    }

    this.isSubmitting = true;

    // Simulate API call
    await new Promise((resolve) => setTimeout(resolve, 2000));

    console.log('Form submitted:', {
      name: this.name,
      email: this.email,
      category: this.category[0],
      message: this.message
    });

    this.isSubmitting = false;
    this.resetForm();
    this.toggle();
  }

  @action resetForm() {
    this.name = '';
    this.email = '';
    this.category = [];
    this.message = '';
  }

  get isValid() {
    return this.name && this.email && this.message;
  }

  get isSubmitDisabled() {
    return !this.isValid || this.isSubmitting;
  }

  get allowClosing() {
    return !this.isSubmitting;
  }

  <template>
    <div class='flex flex-col gap-4'>
      <Button {{on 'click' this.toggle}}>
        Open Contact Form
      </Button>

      <Modal
        @isOpen={{this.isOpen}}
        @onClose={{this.toggle}}
        @size='lg'
        @allowClosing={{this.allowClosing}}
        as |m|
      >
        <m.Header>
          Contact Us
        </m.Header>
        <m.Body>
          <form {{on 'submit' this.handleSubmit}} class='space-y-4'>
            <Input
              @label='Name'
              @value={{this.name}}
              @onInput={{this.updateName}}
              required
              disabled={{this.isSubmitting}}
            />

            <Input
              @label='Email'
              @type='email'
              @value={{this.email}}
              @onInput={{this.updateEmail}}
              required
              disabled={{this.isSubmitting}}
            />

            <Select
              @label='Category'
              @items={{this.categories}}
              @selectedKeys={{this.category}}
              @onSelectionChange={{this.updateCategory}}
              @placeholder='Select a category'
              disabled={{this.isSubmitting}}
            />

            <Textarea
              @label='Message'
              @value={{this.message}}
              @onInput={{this.updateMessage}}
              @rows={{4}}
              required
              disabled={{this.isSubmitting}}
            />
          </form>
        </m.Body>
        <m.Footer @class='flex gap-2'>
          <Button {{on 'click' this.toggle}} disabled={{this.isSubmitting}}>
            Cancel
          </Button>
          <Button
            @intent='primary'
            {{on 'click' this.handleSubmit}}
            disabled={{this.isSubmitDisabled}}
          >
            {{#if this.isSubmitting}}
              Sending...
            {{else}}
              Send Message
            {{/if}}
          </Button>
        </m.Footer>
      </Modal>
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
import { Modal } from '@frontile/overlays';
import { Button } from '@frontile/buttons';
import { on } from '@ember/modifier';

export default class ModalCloseButton extends Component {
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
    <div class='flex flex-col gap-4'>
      <div class='flex gap-2'>
        <Button {{on 'click' this.toggleNormal}}>
          Normal Close Button
        </Button>
        <Button {{on 'click' this.toggleNoCloseButton}}>
          No Close Button
        </Button>
        <Button {{on 'click' this.toggleCustomClose}}>
          Custom Close Button
        </Button>
      </div>

      <Modal @isOpen={{this.normalOpen}} @onClose={{this.toggleNormal}} as |m|>
        <m.Header>Normal Close Button</m.Header>
        <m.Body>
          <p>This modal has the default close button in the top right corner.</p>
        </m.Body>
        <m.Footer>
          <Button {{on 'click' this.toggleNormal}}>Done</Button>
        </m.Footer>
      </Modal>

      <Modal
        @isOpen={{this.noCloseButtonOpen}}
        @onClose={{this.toggleNoCloseButton}}
        @allowCloseButton={{false}}
        as |m|
      >
        <m.Header>No Close Button</m.Header>
        <m.Body>
          <p>This modal has no close button. You can still close it by clicking
            the backdrop or pressing Escape.</p>
        </m.Body>
        <m.Footer>
          <Button {{on 'click' this.toggleNoCloseButton}}>
            Close from Footer
          </Button>
        </m.Footer>
      </Modal>

      <Modal
        @isOpen={{this.customCloseOpen}}
        @onClose={{this.toggleCustomClose}}
        @allowCloseButton={{false}}
        as |m|
      >
        <m.Header>
          <div class='flex justify-between items-center'>
            <span>Custom Close Button</span>
            <m.CloseButton />
          </div>
        </m.Header>
        <m.Body>
          <p>This modal uses a custom close button placed in the header using
            the yielded CloseButton component.</p>
        </m.Body>
        <m.Footer>
          <Button {{on 'click' this.toggleCustomClose}}>Done</Button>
        </m.Footer>
      </Modal>
    </div>
  </template>
}
```

### Nested Modals

Example showing modals that can open other modals.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Modal } from '@frontile/overlays';
import { Button } from '@frontile/buttons';
import { on } from '@ember/modifier';

export default class NestedModals extends Component {
  @tracked firstModalOpen = false;
  @tracked secondModalOpen = false;
  @tracked thirdModalOpen = false;

  @action toggleFirst() {
    this.firstModalOpen = !this.firstModalOpen;
  }

  @action toggleSecond() {
    this.secondModalOpen = !this.secondModalOpen;
  }

  @action toggleThird() {
    this.thirdModalOpen = !this.thirdModalOpen;
  }

  @action closeAll() {
    this.thirdModalOpen = false;
    this.secondModalOpen = false;
    this.firstModalOpen = false;
  }

  <template>
    <div class='flex flex-col gap-4'>
      <Button {{on 'click' this.toggleFirst}}>
        Open First Modal
      </Button>

      <!-- First Modal -->
      <Modal
        @isOpen={{this.firstModalOpen}}
        @onClose={{this.toggleFirst}}
        as |m|
      >
        <m.Header>First Modal</m.Header>
        <m.Body>
          <p class='mb-4'>This is the first modal. You can open another modal
            from here.</p>
          <p class='text-sm text-default-600'>Notice how the backdrop becomes
            darker with each modal layer.</p>

          <!-- Second Modal -->
          <Modal
            @isOpen={{this.secondModalOpen}}
            @onClose={{this.toggleSecond}}
            @size='md'
            as |m|
          >
            <m.Header>Second Modal</m.Header>
            <m.Body>
              <p class='mb-4'>This is the second modal, opened from the first
                one.</p>
              <p class='text-sm text-default-600'>You can continue nesting
                modals as needed.</p>

              <!-- Third Modal -->
              <Modal
                @isOpen={{this.thirdModalOpen}}
                @onClose={{this.toggleThird}}
                @size='sm'
                as |m|
              >
                <m.Header>Third Modal</m.Header>
                <m.Body>
                  <p class='mb-4'>This is the third and final modal in this
                    example.</p>
                  <p class='text-sm text-default-600'>Each modal maintains its
                    own focus trap and can be closed independently.</p>
                </m.Body>
                <m.Footer @class='flex gap-2'>
                  <Button {{on 'click' this.toggleThird}}>
                    Close This
                  </Button>
                  <Button @intent='danger' {{on 'click' this.closeAll}}>
                    Close All
                  </Button>
                </m.Footer>
              </Modal>
            </m.Body>
            <m.Footer @class='flex gap-2'>
              <Button {{on 'click' this.toggleSecond}}>
                Close
              </Button>
              <Button @intent='primary' {{on 'click' this.toggleThird}}>
                Open Third Modal
              </Button>
            </m.Footer>
          </Modal>

        </m.Body>
        <m.Footer @class='flex gap-2'>
          <Button {{on 'click' this.toggleFirst}}>
            Close
          </Button>
          <Button @intent='primary' {{on 'click' this.toggleSecond}}>
            Open Second Modal
          </Button>
        </m.Footer>
      </Modal>

    </div>
  </template>
}
```

## Important Notes

### Yielded Components

The Modal component yields several components for easy composition:

- **`CloseButton`**: A close button with proper styling and onClick handler
- **`Header`**: A header section with proper ID for accessibility
- **`Body`**: The main content area
- **`Footer`**: A footer section for actions or additional content
- **`headerId`**: A unique ID string for the header (used for aria-labelledby)

### Accessibility

The Modal component includes built-in accessibility features:

- **ARIA Attributes**: Proper `role="dialog"` and `aria-labelledby` attributes
- **Focus Management**: Inherits all focus management from Overlay component
- **Keyboard Support**: Escape key to close (can be disabled)
- **Screen Reader Support**: Proper semantic structure

### Size Variants

Available size options:

- **`xs`**: Extra small
- **`sm`**: Small
- **`md`**: Medium
- **`lg`**: Large (default)
- **`xl`**: Extra large
- **`full`**: Full screen

### Positioning

- **Standard**: Modal appears towards the top of the screen
- **Centered**: Use `@isCentered={{true}}` to vertically center the modal

### Controlling Close Behavior

- **`@allowClosing={{false}}`**: Disables all close methods (Escape, backdrop click, close button)
- **`@allowCloseButton={{false}}`**: Hides the default close button
- **`@closeOnOutsideClick={{false}}`**: Disables backdrop click to close
- **`@closeOnEscapeKey={{false}}`**: Disables Escape key to close

### Best Practices

- Use modals sparingly to avoid overwhelming users
- Keep modal content focused and concise
- Provide clear actions in the footer
- Use appropriate sizes for the content
- Consider using drawers for complex forms or navigation

## API

<Signature @package="overlays" @component="Modal" />
