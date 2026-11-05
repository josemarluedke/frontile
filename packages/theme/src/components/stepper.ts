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
      'cursor-pointer text-start',
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

    // The check mark inside a complete indicator. It animates only while the
    // Step has `data-just-completed` -- set for the moment after a step
    // *becomes* complete -- so steps that load already complete stay still.
    check: [
      'shrink-0',
      'group-data-[just-completed=true]/item:animate-stepper-check-pop',
      'group-data-[just-completed=true]/item:[&_path]:animate-stepper-check-draw',
      // `1 2`: a dash as long as the path (normalized to 1) and a gap longer
      // than it, so the undrawn state shows nothing, not even a round cap.
      'group-data-[just-completed=true]/item:[&_path]:[stroke-dasharray:1_2]',
      'motion-reduce:animate-none motion-reduce:[&_path]:animate-none'
    ],

    // The track is neutral; an `::after` fill in the step's color grows along
    // it when the step completes, and shrinks back if the user returns. The
    // fill's axis and origin come from `orientation`, below.
    connector: [
      'relative shrink-0 overflow-hidden bg-neutral-mild',
      'after:absolute after:inset-0 after:content-[""]',
      'after:transition-transform after:duration-300 after:ease-out',
      'motion-reduce:after:transition-none',
      // The last step has nothing to connect to.
      'group-last/item:hidden'
    ],

    // Collapsed (menu) mode only. The trigger shows the current step and opens
    // the list, which becomes a floating panel; see `collapsed` below.
    trigger: [
      ...focusVisibleRing,
      'flex min-h-11 w-full cursor-pointer items-center justify-between gap-3',
      'rounded-xl border border-neutral-subtle bg-surface-input px-3 py-2 text-start',
      'transition-colors duration-200 motion-reduce:transition-none',
      '[&_svg]:transition-transform motion-reduce:[&_svg]:transition-none',
      '[&[aria-expanded=true]_svg]:rotate-180'
    ],

    // A zero-size sentinel the root reads to learn which side of the
    // threshold it is on. The threshold stays in CSS, where the label rules
    // already read it, so the two can never disagree.
    probe: 'hidden',

    // The trigger's two lines of text, and its chevron.
    triggerLabel: 'flex min-w-0 flex-col',
    chevron: 'size-4 shrink-0 text-neutral-firm',

    // "Step N of M" and the active step's title, in the trigger and in the
    // standalone summary line.
    summaryText: 'block',
    summaryTitle: 'block font-medium text-neutral-strong',

    // The invalid step's exclamation mark, the loading spinner, and the text
    // only screen readers get for an invalid step.
    mark: 'shrink-0',
    spinner: 'fill-current text-neutral-mild',
    invalidText: 'sr-only',

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
        connector: 'group-data-[state=complete]/item:after:bg-neutral-strong'
      },
      primary: {
        indicator: [
          'group-data-[state=complete]/item:border-primary group-data-[state=complete]/item:bg-primary group-data-[state=complete]/item:text-on-primary',
          'group-data-[state=active]/item:border-primary group-data-[state=active]/item:text-primary'
        ],
        connector: 'group-data-[state=complete]/item:after:bg-primary'
      },
      secondary: {
        indicator: [
          'group-data-[state=complete]/item:border-secondary group-data-[state=complete]/item:bg-secondary group-data-[state=complete]/item:text-on-secondary',
          'group-data-[state=active]/item:border-secondary group-data-[state=active]/item:text-secondary'
        ],
        connector: 'group-data-[state=complete]/item:after:bg-secondary'
      },
      tertiary: {
        indicator: [
          'group-data-[state=complete]/item:border-tertiary group-data-[state=complete]/item:bg-tertiary group-data-[state=complete]/item:text-on-tertiary',
          'group-data-[state=active]/item:border-tertiary group-data-[state=active]/item:text-tertiary'
        ],
        connector: 'group-data-[state=complete]/item:after:bg-tertiary'
      },
      success: {
        indicator: [
          'group-data-[state=complete]/item:border-success group-data-[state=complete]/item:bg-success group-data-[state=complete]/item:text-on-success',
          'group-data-[state=active]/item:border-success group-data-[state=active]/item:text-success'
        ],
        connector: 'group-data-[state=complete]/item:after:bg-success'
      },
      warning: {
        indicator: [
          'group-data-[state=complete]/item:border-warning group-data-[state=complete]/item:bg-warning group-data-[state=complete]/item:text-on-warning',
          'group-data-[state=active]/item:border-warning group-data-[state=active]/item:text-warning'
        ],
        connector: 'group-data-[state=complete]/item:after:bg-warning'
      },
      danger: {
        indicator: [
          'group-data-[state=complete]/item:border-danger group-data-[state=complete]/item:bg-danger group-data-[state=complete]/item:text-on-danger',
          'group-data-[state=active]/item:border-danger group-data-[state=active]/item:text-danger'
        ],
        connector: 'group-data-[state=complete]/item:after:bg-danger'
      }
    },

    // `step` is the padding that brings indicator plus padding to 44px, so the
    // hit area is 44px whatever the circle size and the circle sits 22px in
    // from the button's edge in every layout. `item` carries how far a
    // bottom-label connector sits from the item's center: the circle's radius
    // plus a 4px gap.
    size: {
      sm: {
        step: 'p-2.5',
        item: '[--stepper-offset:1rem]',
        // `[&_svg]` outranks an icon's own size class, so the circle, not the
        // icon, decides the glyph size (about half the circle, 4-6px padding).
        indicator: 'size-6 text-label-sm [&_svg]:size-3',
        title: 'text-label-sm',
        description: 'text-caption-sm',
        summary: 'text-label-sm',
        panel: 'py-2'
      },
      md: {
        step: 'p-2',
        item: '[--stepper-offset:1.125rem]',
        indicator: 'size-7 text-label-md [&_svg]:size-4',
        title: 'text-label-md',
        description: 'text-caption-md',
        summary: 'text-label-md',
        panel: 'py-3'
      },
      lg: {
        step: 'p-1',
        item: '[--stepper-offset:1.375rem]',
        indicator: 'size-9 text-label-lg [&_svg]:size-5',
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
        connector: [
          'mx-1 h-0.5 min-w-4 flex-1',
          // Grows from the start edge, which is the right in RTL.
          'after:origin-left after:scale-x-0 rtl:after:origin-right',
          'group-data-[state=complete]/item:after:scale-x-100'
        ]
      },
      vertical: {
        base: 'flex-col gap-3',
        list: 'flex-col',
        item: 'flex-col items-start',
        connector: [
          'ms-[21px] h-4 w-0.5',
          'after:origin-top after:scale-y-0',
          'group-data-[state=complete]/item:after:scale-y-100'
        ]
      }
    },

    // Where the label sits relative to the circle. `end` is beside it;
    // `bottom` centers it underneath. Vertical orientation ignores this.
    labelPosition: {
      end: {},
      bottom: {}
    },

    // What a horizontal Stepper does when it is too narrow for its titles.
    // `menu` swaps the row for a trigger and a floating list; `summary` hides
    // the titles and shows a "Step N of M" line; `none` leaves it alone. The
    // label rules depend on orientation and labelPosition, so they are
    // compound variants below.
    collapse: {
      menu: {},
      summary: {},
      none: {}
    },

    // True while a `menu` Stepper is actually collapsed. The component sets it
    // (it measures the root), and passes `orientation: 'vertical'` alongside,
    // so the list reuses the vertical layout inside the panel.
    collapsed: {
      true: {
        list: [
          'inset-auto m-0 w-auto min-w-64 max-w-[calc(100vw-1rem)] overflow-auto p-2 text-inherit',
          'max-h-[min(24rem,70vh)] rounded-xl border border-neutral-muted bg-surface-input shadow-elevation-3',
          // `display` on the list would beat the UA rule that hides a closed
          // popover, so the closed state is restated here.
          '[&:not(:popover-open)]:hidden'
        ],
        item: 'items-stretch',
        step: 'w-full justify-start'
      }
    }
  },

  compoundVariants: [
    // -- label below the circle (horizontal only; vertical ignores it) --
    // Items are equal-width columns, and the connector is drawn from this
    // item's circle to the next one's, so it needs `relative` on the item and
    // an offset that clears the circle (radius plus a 4px gap, per size).
    // Logical properties (`start`/`end`, `ms`) so the layout mirrors in RTL.
    {
      orientation: 'horizontal',
      labelPosition: 'bottom',
      class: {
        item: 'relative flex-1 flex-col items-center last:flex-1',
        step: 'flex-col',
        label: 'items-center text-center',
        connector: [
          'absolute top-[21px] mx-0 min-w-0 flex-none',
          'start-[calc(50%+var(--stepper-offset))] end-[calc(-50%+var(--stepper-offset))]'
        ]
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
      collapse: 'summary',
      labelPosition: 'bottom',
      class: {
        label: 'sr-only @fr-stepper-bottom/stepper:not-sr-only',
        summary: '@fr-stepper-bottom/stepper:hidden'
      }
    },
    {
      orientation: 'horizontal',
      collapse: 'summary',
      labelPosition: 'end',
      class: {
        label: 'sr-only @fr-stepper-end/stepper:not-sr-only',
        summary: '@fr-stepper-end/stepper:hidden'
      }
    },

    // The probe is `display: block` from the same threshold at which titles
    // would appear, i.e. when the full row fits.
    {
      orientation: 'horizontal',
      collapse: 'menu',
      labelPosition: 'bottom',
      class: { probe: '@fr-stepper-bottom/stepper:block' }
    },
    {
      orientation: 'horizontal',
      collapse: 'menu',
      labelPosition: 'end',
      class: { probe: '@fr-stepper-end/stepper:block' }
    }
  ],

  defaultVariants: {
    color: 'primary',
    size: 'md',
    orientation: 'horizontal',
    labelPosition: 'end',
    collapse: 'menu'
  }
});

export { stepper };
export type StepperSlots = keyof ReturnType<typeof stepper>;
export type StepperVariants = VariantProps<typeof stepper>;
