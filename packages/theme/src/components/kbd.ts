import { tv } from '../tw';
import type { VariantProps } from 'tailwind-variants';

const kbd = tv({
  slots: {
    // The wrapper draws nothing: it only lines the caps up. `font-label`, not
    // `font-code` -- the modifier glyphs (⌘ ⇧ ⌥ ⌃) render poorly in most
    // monospace faces, and a keycap is a UI affordance rather than sample code.
    base: [
      'inline-flex items-center align-middle',
      'font-label',
      'select-none',
      'whitespace-nowrap'
    ],
    // Each cap. `min-w` is set per size to match its height, so a lone `K` stays
    // square instead of collapsing to the width of the letter.
    key: [
      'inline-flex items-center justify-center',
      'shrink-0',
      'leading-none',
      '[&_svg]:size-3'
    ],
    separator: ['shrink-0', 'text-neutral', 'px-0.5']
  },
  variants: {
    size: {
      sm: {
        base: 'gap-0.5 text-label-2xs',
        key: 'h-5 min-w-5 px-1 rounded text-label-2xs'
      },
      md: {
        base: 'gap-1 text-label-xs',
        key: 'h-6 min-w-6 px-1.5 rounded-md text-label-xs'
      },
      lg: {
        base: 'gap-1 text-label-sm',
        key: 'h-7 min-w-7 px-2 rounded-md text-label-sm'
      }
    },
    // Colours live in the compound variants below, paired with `intent`.
    appearance: {
      default: { key: 'border border-transparent' },
      outlined: { key: 'border bg-transparent' },
      faded: { key: 'border' },
      // Follows whatever colour it is sitting on. This is what lets a keycap
      // ride an active, filled Listbox row without the row's theme having to
      // repaint it for every intent.
      inherit: {
        key: 'border border-current/20 bg-transparent text-current'
      },
      // No box at all. For dense rows where a keycap would be visual noise and
      // the shortcut should read as quiet trailing text.
      plain: {
        key: 'border-0 bg-transparent px-0 min-w-0 text-current tracking-wide'
      }
    },
    intent: {
      default: {},
      primary: {},
      secondary: {},
      tertiary: {},
      success: {},
      warning: {},
      danger: {}
    },
    /**
     * `merged` puts every glyph inside one cap (`⌘K`); `split` gives each key
     * its own (`⌘` `K`).
     */
    isMerged: {
      true: { base: 'gap-0' }
    }
  },
  compoundVariants: [
    // appearance: default -- a filled cap. `-muted` is light enough to read as
    // a key on a page and each level carries its own `on-` contrast colour.
    {
      appearance: 'default',
      intent: 'default',
      class: { key: 'bg-neutral-muted text-on-neutral-muted' }
    },
    {
      appearance: 'default',
      intent: 'primary',
      class: { key: 'bg-primary-muted text-on-primary-muted' }
    },
    {
      appearance: 'default',
      intent: 'secondary',
      class: { key: 'bg-secondary-muted text-on-secondary-muted' }
    },
    {
      appearance: 'default',
      intent: 'tertiary',
      class: { key: 'bg-tertiary-muted text-on-tertiary-muted' }
    },
    {
      appearance: 'default',
      intent: 'success',
      class: { key: 'bg-success-muted text-on-success-muted' }
    },
    {
      appearance: 'default',
      intent: 'warning',
      class: { key: 'bg-warning-muted text-on-warning-muted' }
    },
    {
      appearance: 'default',
      intent: 'danger',
      class: { key: 'bg-danger-muted text-on-danger-muted' }
    },

    // appearance: outlined
    {
      appearance: 'outlined',
      intent: 'default',
      class: { key: 'border-neutral text-neutral-strong' }
    },
    {
      appearance: 'outlined',
      intent: 'primary',
      class: { key: 'border-primary text-primary-strong' }
    },
    {
      appearance: 'outlined',
      intent: 'secondary',
      class: { key: 'border-secondary text-secondary-strong' }
    },
    {
      appearance: 'outlined',
      intent: 'tertiary',
      class: { key: 'border-tertiary text-tertiary-strong' }
    },
    {
      appearance: 'outlined',
      intent: 'success',
      class: { key: 'border-success text-success-strong' }
    },
    {
      appearance: 'outlined',
      intent: 'warning',
      class: { key: 'border-warning text-warning-strong' }
    },
    {
      appearance: 'outlined',
      intent: 'danger',
      class: { key: 'border-danger text-danger-strong' }
    },

    // appearance: faded
    {
      appearance: 'faded',
      intent: 'default',
      class: {
        key: 'bg-neutral-subtle border-neutral-soft text-neutral-strong'
      }
    },
    {
      appearance: 'faded',
      intent: 'primary',
      class: {
        key: 'bg-primary-subtle border-primary-soft text-primary-strong'
      }
    },
    {
      appearance: 'faded',
      intent: 'secondary',
      class: {
        key: 'bg-secondary-subtle border-secondary-soft text-secondary-strong'
      }
    },
    {
      appearance: 'faded',
      intent: 'tertiary',
      class: {
        key: 'bg-tertiary-subtle border-tertiary-soft text-tertiary-strong'
      }
    },
    {
      appearance: 'faded',
      intent: 'success',
      class: {
        key: 'bg-success-subtle border-success-soft text-success-strong'
      }
    },
    {
      appearance: 'faded',
      intent: 'warning',
      class: {
        key: 'bg-warning-subtle border-warning-soft text-warning-strong'
      }
    },
    {
      appearance: 'faded',
      intent: 'danger',
      class: { key: 'bg-danger-subtle border-danger-soft text-danger-strong' }
    }
  ],
  defaultVariants: {
    size: 'md',
    intent: 'default',
    appearance: 'default'
  }
});

export type KbdVariants = VariantProps<typeof kbd>;
export type KbdSlots = keyof ReturnType<typeof kbd>;

export { kbd };
