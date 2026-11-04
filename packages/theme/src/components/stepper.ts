import { tv } from '../tw';
import { focusVisibleRing } from './shared';
import type { VariantProps } from '../tw';

/**
 * Every state class keys off a `data-*` attribute the Step writes onto its
 * `<li>` (`data-part="item"`, the `group/item` anchor): `data-state`
 * (`complete | active | upcoming`), `data-invalid`, `data-loading`,
 * `data-disabled`. `data-invalid` and friends are written as the strings
 * "true"/"false", so they are tested with `=true`.
 *
 * Class strings are spelled out per color rather than built in a loop:
 * Tailwind generates nothing from an interpolated class name.
 */
const stepper = tv({
  slots: {
    // The named container the responsive label rules (added alongside the
    // layout work) measure against.
    base: '@container/stepper flex w-full',

    list: 'm-0 flex w-full list-none p-0',

    item: 'group/item relative flex',

    step: [
      ...focusVisibleRing,
      'inline-flex items-center gap-2',
      // Hit area: at least 44px whatever the circle size, so the visual
      // size and the touch target are independent.
      'min-h-11 min-w-11 justify-center rounded-md',
      'cursor-pointer text-left',
      'transition-colors duration-200 motion-reduce:transition-none',
      'group-data-[disabled=true]/item:cursor-not-allowed',
      'group-data-[disabled=true]/item:opacity-disabled'
    ],

    indicator: [
      'inline-flex shrink-0 items-center justify-center rounded-full',
      'border-2 font-medium tabular-nums',
      'transition-colors duration-200 motion-reduce:transition-none',
      // Upcoming is the resting state; the other states override it.
      'border-neutral-mild text-neutral-firm',
      // Invalid is always danger, whatever `color` is, and outranks the
      // active and complete treatments. Those are `group-data-[state=...]`
      // classes of equal specificity emitted later, so only `!` guarantees
      // the win -- without it a step that is both complete and invalid shows
      // the accent color.
      'group-data-[invalid=true]/item:border-danger!',
      'group-data-[invalid=true]/item:bg-danger-subtle!',
      'group-data-[invalid=true]/item:text-danger!'
    ],

    connector: [
      'shrink-0 bg-neutral-mild',
      'transition-colors duration-200 motion-reduce:transition-none',
      // The last step has nothing to connect to.
      'group-last/item:hidden'
    ],

    label: 'flex min-w-0 flex-col',

    title: [
      'font-medium text-neutral-strong',
      'group-data-[state=upcoming]/item:text-neutral-firm',
      'group-data-[invalid=true]/item:text-danger'
    ],

    description: 'text-neutral-firm',

    summary: 'text-neutral-firm',

    panel: [...focusVisibleRing, 'outline-none']
  },

  variants: {
    color: {
      neutral: {
        indicator: [
          'group-data-[state=complete]/item:border-neutral-strong group-data-[state=complete]/item:bg-neutral-strong group-data-[state=complete]/item:text-background',
          'group-data-[state=active]/item:border-neutral-strong group-data-[state=active]/item:text-neutral-strong'
        ],
        connector: 'group-data-[state=complete]/item:bg-neutral-strong'
      },
      primary: {
        indicator: [
          'group-data-[state=complete]/item:border-primary group-data-[state=complete]/item:bg-primary group-data-[state=complete]/item:text-on-primary',
          'group-data-[state=active]/item:border-primary group-data-[state=active]/item:text-primary'
        ],
        connector: 'group-data-[state=complete]/item:bg-primary'
      },
      secondary: {
        indicator: [
          'group-data-[state=complete]/item:border-secondary group-data-[state=complete]/item:bg-secondary group-data-[state=complete]/item:text-on-secondary',
          'group-data-[state=active]/item:border-secondary group-data-[state=active]/item:text-secondary'
        ],
        connector: 'group-data-[state=complete]/item:bg-secondary'
      },
      tertiary: {
        indicator: [
          'group-data-[state=complete]/item:border-tertiary group-data-[state=complete]/item:bg-tertiary group-data-[state=complete]/item:text-on-tertiary',
          'group-data-[state=active]/item:border-tertiary group-data-[state=active]/item:text-tertiary'
        ],
        connector: 'group-data-[state=complete]/item:bg-tertiary'
      },
      success: {
        indicator: [
          'group-data-[state=complete]/item:border-success group-data-[state=complete]/item:bg-success group-data-[state=complete]/item:text-on-success',
          'group-data-[state=active]/item:border-success group-data-[state=active]/item:text-success'
        ],
        connector: 'group-data-[state=complete]/item:bg-success'
      },
      warning: {
        indicator: [
          'group-data-[state=complete]/item:border-warning group-data-[state=complete]/item:bg-warning group-data-[state=complete]/item:text-on-warning',
          'group-data-[state=active]/item:border-warning group-data-[state=active]/item:text-warning'
        ],
        connector: 'group-data-[state=complete]/item:bg-warning'
      },
      danger: {
        indicator: [
          'group-data-[state=complete]/item:border-danger group-data-[state=complete]/item:bg-danger group-data-[state=complete]/item:text-on-danger',
          'group-data-[state=active]/item:border-danger group-data-[state=active]/item:text-danger'
        ],
        connector: 'group-data-[state=complete]/item:bg-danger'
      }
    },

    size: {
      sm: {
        // Padding that brings indicator plus padding to 44px, so the hit
        // area is 44px whatever the circle size and the circle sits 22px
        // in from the button's edge in every layout.
        step: 'p-2.5',
        indicator: 'size-6 text-label-sm',
        title: 'text-label-sm',
        description: 'text-caption-sm',
        summary: 'text-label-sm',
        panel: 'py-2'
      },
      md: {
        // Padding that brings indicator plus padding to 44px, so the hit
        // area is 44px whatever the circle size and the circle sits 22px
        // in from the button's edge in every layout.
        step: 'p-2',
        indicator: 'size-7 text-label-md',
        title: 'text-label-md',
        description: 'text-caption-md',
        summary: 'text-label-md',
        panel: 'py-3'
      },
      lg: {
        // Padding that brings indicator plus padding to 44px, so the hit
        // area is 44px whatever the circle size and the circle sits 22px
        // in from the button's edge in every layout.
        step: 'p-1',
        indicator: 'size-9 text-label-lg',
        title: 'text-label-lg',
        description: 'text-body-sm',
        summary: 'text-label-lg',
        panel: 'py-4'
      }
    },

    orientation: {
      horizontal: {
        base: 'flex-col gap-3',
        list: 'flex-row items-start',
        item: 'flex-1 items-center last:flex-none',
        connector: 'mx-1 h-0.5 min-w-4 flex-1'
      },
      vertical: {
        base: 'flex-col gap-3',
        list: 'flex-col',
        item: 'flex-col items-start',
        connector: 'ml-[21px] h-4 w-0.5'
      }
    },

    // Where the label sits relative to the circle. `end` is beside it;
    // `bottom` centers it underneath. Vertical orientation ignores this.
    labelPosition: {
      end: {},
      bottom: {}
    },

    // When true (the default), horizontal labels collapse at narrow container
    // widths and a summary line takes over. The rules are compound variants
    // below, since they depend on orientation and labelPosition.
    collapseLabels: {
      true: {},
      false: {}
    }
  },

  compoundVariants: [
    // -- label below the circle (horizontal only; vertical ignores it) --
    // Items are equal-width columns, and the connector is drawn from this
    // item's circle to the next one's, so it needs `relative` on the item and
    // an offset that clears the circle (radius plus a 4px gap, per size).
    {
      orientation: 'horizontal',
      labelPosition: 'bottom',
      class: {
        item: 'relative flex-1 flex-col items-center last:flex-1',
        step: 'flex-col',
        label: 'items-center text-center',
        connector: 'absolute top-[21px] mx-0 min-w-0 flex-none'
      }
    },
    {
      orientation: 'horizontal',
      labelPosition: 'bottom',
      size: 'sm',
      class: { connector: 'left-[calc(50%+1rem)] right-[calc(-50%+1rem)]' }
    },
    {
      orientation: 'horizontal',
      labelPosition: 'bottom',
      size: 'md',
      class: {
        connector: 'left-[calc(50%+1.125rem)] right-[calc(-50%+1.125rem)]'
      }
    },
    {
      orientation: 'horizontal',
      labelPosition: 'bottom',
      size: 'lg',
      class: {
        connector: 'left-[calc(50%+1.375rem)] right-[calc(-50%+1.375rem)]'
      }
    },

    // -- responsive label collapse (horizontal only) --
    // Narrow: the label is visually hidden (`sr-only` keeps it in the
    // accessibility tree) and the summary shows. Wider than the threshold the
    // label returns and the summary goes.
    //
    // The thresholds are Frontile-namespaced container tokens, not `@md` /
    // `@2xl`: those read `--container-*`, which apps commonly redefine (and
    // which `max-w-*` shares), so they would move the breakpoints -- possibly
    // inverting the two modes. `var()` is not allowed in a container query
    // condition, so a theme token is the only way to make them tunable.
    {
      orientation: 'horizontal',
      collapseLabels: true,
      labelPosition: 'bottom',
      class: {
        label: 'sr-only @fr-stepper-bottom/stepper:not-sr-only',
        summary: '@fr-stepper-bottom/stepper:hidden'
      }
    },
    {
      orientation: 'horizontal',
      collapseLabels: true,
      labelPosition: 'end',
      class: {
        label: 'sr-only @fr-stepper-end/stepper:not-sr-only',
        summary: '@fr-stepper-end/stepper:hidden'
      }
    }
  ],

  defaultVariants: {
    color: 'primary',
    size: 'md',
    orientation: 'horizontal',
    labelPosition: 'end',
    collapseLabels: true
  }
});

export { stepper };
export type StepperSlots = keyof ReturnType<typeof stepper>;
export type StepperVariants = VariantProps<typeof stepper>;
