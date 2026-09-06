/**
 * The component inventory, taken from the routes Docfy actually generates
 * (site/public/docfy-urls.json). Legacy packages are deliberately excluded:
 * `forms-legacy` and `changeset-form` are deprecated and slated for removal
 * before v1, so counting them would overstate what Frontile currently offers.
 *
 * If a component gains or loses a docs page, update this list. It is the only
 * place the homepage and the /docs/components/overview page name components,
 * so nothing else has to be kept in step.
 */

export interface InventoryItem {
  name: string;
  path: string;
  /** What the component does, in one sentence. Shown on /docs/components/overview. */
  description: string;
}

export interface InventoryCategory {
  name: string;
  /** What this group is for, in the product's own terms. */
  summary: string;
  items: InventoryItem[];
}

export const inventory: InventoryCategory[] = [
  {
    name: 'Forms',
    summary:
      'Labelling, validation, and state handled by the control itself, not by the page.',
    items: [
      {
        name: 'Form',
        path: '/docs/components/forms/form',
        description:
          "Wraps a native <form>, serializes its fields, and hands you the result on submit.",
      },
      {
        name: 'Field',
        path: '/docs/components/forms/field',
        description:
          'Binds a label, input, and validation messages together as one accessible unit.',
      },
      {
        name: 'FormControl',
        path: '/docs/components/forms/form-control',
        description:
          'Composes label, description, and error text around any custom control.',
      },
      {
        name: 'Input',
        path: '/docs/components/forms/input',
        description:
          'A single-line text field with built-in label, validation, and sizing.',
      },
      {
        name: 'Textarea',
        path: '/docs/components/forms/textarea',
        description: 'A multi-line text field for longer, free-form content.',
      },
      {
        name: 'Select',
        path: '/docs/components/forms/select',
        description:
          'A searchable dropdown supporting single and multiple selection, with chips for multiple.',
      },
      {
        name: 'NativeSelect',
        path: '/docs/components/forms/native-select',
        description:
          "A select built on the browser's own <select>, styled to match the rest of the form components.",
      },
      {
        name: 'Autocomplete',
        path: '/docs/components/forms/autocomplete',
        description: 'A type-ahead combobox that filters its options as you type.',
      },
      {
        name: 'Checkbox',
        path: '/docs/components/forms/checkbox',
        description: 'A single toggle for binary or tri-state choices.',
      },
      {
        name: 'CheckboxGroup',
        path: '/docs/components/forms/checkbox-group',
        description:
          'Lets users select multiple options from a set of choices, with shared validation.',
      },
      {
        name: 'Radio',
        path: '/docs/components/forms/radio',
        description: 'A single option within a mutually exclusive set.',
      },
      {
        name: 'RadioGroup',
        path: '/docs/components/forms/radio-group',
        description: 'Manages a set of radio options and their shared selection.',
      },
      {
        name: 'Switch',
        path: '/docs/components/forms/switch',
        description: 'An on/off toggle styled as a physical switch.',
      },
    ],
  },
  {
    name: 'Utilities',
    summary: 'Small primitives the rest of the library is built out of.',
    items: [
      {
        name: 'Avatar',
        path: '/docs/components/utilities/avatar',
        description: 'Displays a person or entity as an image, initials, or icon.',
      },
      {
        name: 'Collapsible',
        path: '/docs/components/utilities/collapsible',
        description:
          'Shows and hides content with an animated, accessible disclosure.',
      },
      {
        name: 'Divider',
        path: '/docs/components/utilities/divider',
        description: 'A visual or semantic separator between sections of content.',
      },
      {
        name: 'Skeleton',
        path: '/docs/components/utilities/skeleton',
        description: 'A placeholder shape that stands in for content while it loads.',
      },
      {
        name: 'Spinner',
        path: '/docs/components/utilities/spinner',
        description: 'An indeterminate loading indicator.',
      },
      {
        name: 'Toggle',
        path: '/docs/components/utilities/toggle',
        description:
          "toggleState, a lightweight helper for managing boolean state with a toggle() setter.",
      },
      {
        name: 'Press',
        path: '/docs/components/utilities/press',
        description:
          'A modifier that normalizes press interactions across mouse, touch, keyboard, and screen readers.',
      },
      {
        name: 'Ref',
        path: '/docs/components/utilities/ref',
        description: 'A utility for capturing a reactive reference to a DOM element.',
      },
      {
        name: 'RovingFocus',
        path: '/docs/components/utilities/roving-focus',
        description:
          'A modifier that gives a group of controls single-tab-stop, arrow-key keyboard navigation.',
      },
      {
        name: 'SelectionIndicator',
        path: '/docs/components/utilities/selection-indicator',
        description:
          'A modifier that tracks the selected item in a group and publishes its geometry as CSS custom properties.',
      },
      {
        name: 'VisuallyHidden',
        path: '/docs/components/utilities/visually-hidden',
        description:
          'Hides content visually while keeping it available to screen readers.',
      },
    ],
  },
  {
    name: 'Buttons',
    summary: 'One press primitive, five shapes of it.',
    items: [
      {
        name: 'Button',
        path: '/docs/components/buttons/button',
        description: 'The base pressable action, with intents, appearances, and sizes.',
      },
      {
        name: 'ButtonGroup',
        path: '/docs/components/buttons/button-group',
        description: 'Groups related buttons, including toggling segmented sets.',
      },
      {
        name: 'ToggleButton',
        path: '/docs/components/buttons/toggle-button',
        description: 'A button that holds a pressed/unpressed state.',
      },
      {
        name: 'SegmentedControl',
        path: '/docs/components/buttons/segmented-control',
        description:
          'A row of mutually exclusive options with an indicator that slides between them.',
      },
      {
        name: 'CloseButton',
        path: '/docs/components/buttons/close-button',
        description:
          'A dedicated icon button for dismissing dialogs, tags, and banners.',
      },
      {
        name: 'Chip',
        path: '/docs/components/buttons/chip',
        description: 'A compact label for statuses, filters, and removable tags.',
      },
    ],
  },
  {
    name: 'Overlays',
    summary:
      'Focus trapping, scroll locking, and portalling, shared by every layer.',
    items: [
      {
        name: 'Modal',
        path: '/docs/components/overlays/modal',
        description: 'A focus-trapped dialog layered above the page.',
      },
      {
        name: 'Drawer',
        path: '/docs/components/overlays/drawer',
        description: 'A panel that slides in from an edge of the screen.',
      },
      {
        name: 'Popover',
        path: '/docs/components/overlays/popover',
        description: 'Floating content anchored to a trigger element.',
      },
      {
        name: 'Overlay',
        path: '/docs/components/overlays/overlay',
        description: 'The foundation Modal, Drawer, and Popover are all built on.',
      },
      {
        name: 'Portal',
        path: '/docs/components/overlays/portal',
        description:
          'Renders content into a different part of the DOM tree, escaping clipped or stacked parents.',
      },
    ],
  },
  {
    name: 'Collections',
    summary:
      'Typed, keyboard-navigable lists and tables that infer against your data.',
    items: [
      {
        name: 'Table',
        path: '/docs/components/collections/table',
        description: 'A sortable, selectable table backed by typed column definitions.',
      },
      {
        name: 'SimpleTable',
        path: '/docs/components/collections/simple-table',
        description:
          "A foundational table for manual composition, without Table's sorting and selection.",
      },
      {
        name: 'Listbox',
        path: '/docs/components/collections/listbox',
        description: 'A keyboard-navigable list of selectable options.',
      },
      {
        name: 'Dropdown',
        path: '/docs/components/collections/dropdown',
        description:
          'Combines a trigger button with a floating panel of actions or options.',
      },
    ],
  },
  {
    name: 'Feedback',
    summary: 'Progress and notifications, with the live regions wired up.',
    items: [
      {
        name: 'ProgressBar',
        path: '/docs/components/status/progress-bar',
        description:
          'Communicates the progress of a determinate or indeterminate task.',
      },
      {
        name: 'Notifications',
        path: '/docs/components/notifications/notifications',
        description: 'Toasts with live regions, placement, and auto-dismiss.',
      },
    ],
  },
];

export const componentCount: number = inventory.reduce(
  (total, category) => total + category.items.length,
  0
);
