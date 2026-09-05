/**
 * The component inventory, taken from the routes Docfy actually generates
 * (site/public/docfy-urls.json). Legacy packages are deliberately excluded:
 * `forms-legacy` and `changeset-form` are deprecated and slated for removal
 * before v1, so counting them would overstate what Frontile currently offers.
 *
 * If a component gains or loses a docs page, update this list. It is the only
 * place the homepage names components, so nothing else has to be kept in step.
 */

export interface InventoryItem {
  name: string;
  path: string;
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
      { name: 'Form', path: '/docs/components/forms/form' },
      { name: 'Field', path: '/docs/components/forms/field' },
      { name: 'FormControl', path: '/docs/components/forms/form-control' },
      { name: 'Input', path: '/docs/components/forms/input' },
      { name: 'Textarea', path: '/docs/components/forms/textarea' },
      { name: 'Select', path: '/docs/components/forms/select' },
      { name: 'NativeSelect', path: '/docs/components/forms/native-select' },
      { name: 'Autocomplete', path: '/docs/components/forms/autocomplete' },
      { name: 'Checkbox', path: '/docs/components/forms/checkbox' },
      { name: 'CheckboxGroup', path: '/docs/components/forms/checkbox-group' },
      { name: 'Radio', path: '/docs/components/forms/radio' },
      { name: 'RadioGroup', path: '/docs/components/forms/radio-group' },
      { name: 'Switch', path: '/docs/components/forms/switch' },
    ],
  },
  {
    name: 'Utilities',
    summary: 'Small primitives the rest of the library is built out of.',
    items: [
      { name: 'Avatar', path: '/docs/components/utilities/avatar' },
      { name: 'Collapsible', path: '/docs/components/utilities/collapsible' },
      { name: 'Divider', path: '/docs/components/utilities/divider' },
      { name: 'Skeleton', path: '/docs/components/utilities/skeleton' },
      { name: 'Spinner', path: '/docs/components/utilities/spinner' },
      { name: 'Toggle', path: '/docs/components/utilities/toggle' },
      { name: 'Press', path: '/docs/components/utilities/press' },
      { name: 'Ref', path: '/docs/components/utilities/ref' },
      {
        name: 'SelectionIndicator',
        path: '/docs/components/utilities/selection-indicator',
      },
      {
        name: 'VisuallyHidden',
        path: '/docs/components/utilities/visually-hidden',
      },
    ],
  },
  {
    name: 'Buttons',
    summary: 'One press primitive, five shapes of it.',
    items: [
      { name: 'Button', path: '/docs/components/buttons/button' },
      { name: 'ButtonGroup', path: '/docs/components/buttons/button-group' },
      { name: 'ToggleButton', path: '/docs/components/buttons/toggle-button' },
      {
        name: 'SegmentedControl',
        path: '/docs/components/buttons/segmented-control',
      },
      { name: 'CloseButton', path: '/docs/components/buttons/close-button' },
      { name: 'Chip', path: '/docs/components/buttons/chip' },
    ],
  },
  {
    name: 'Overlays',
    summary:
      'Focus trapping, scroll locking, and portalling, shared by every layer.',
    items: [
      { name: 'Modal', path: '/docs/components/overlays/modal' },
      { name: 'Drawer', path: '/docs/components/overlays/drawer' },
      { name: 'Popover', path: '/docs/components/overlays/popover' },
      { name: 'Overlay', path: '/docs/components/overlays/overlay' },
      { name: 'Portal', path: '/docs/components/overlays/portal' },
    ],
  },
  {
    name: 'Collections',
    summary:
      'Typed, keyboard-navigable lists and tables that infer against your data.',
    items: [
      { name: 'Table', path: '/docs/components/collections/table' },
      {
        name: 'SimpleTable',
        path: '/docs/components/collections/simple-table',
      },
      { name: 'Listbox', path: '/docs/components/collections/listbox' },
      { name: 'Dropdown', path: '/docs/components/collections/dropdown' },
    ],
  },
  {
    name: 'Feedback',
    summary: 'Progress and notifications, with the live regions wired up.',
    items: [
      { name: 'ProgressBar', path: '/docs/components/status/progress-bar' },
      {
        name: 'Notifications',
        path: '/docs/components/notifications/notifications',
      },
    ],
  },
];

export const componentCount: number = inventory.reduce(
  (total, category) => total + category.items.length,
  0
);
