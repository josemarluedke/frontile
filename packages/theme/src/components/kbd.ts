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
    // `font-label` is repeated here rather than inherited from `base`: the CSS
    // reset styles the `kbd` element itself as monospace, and an element rule
    // beats inheritance, so the cap must name its own font.
    key: [
      'inline-flex items-center justify-center',
      'shrink-0',
      'font-label',
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
    // Colours live in the compound variants below, paired with `color`.
    variant: {
      solid: { key: 'border border-transparent' },
      outline: { key: 'border bg-transparent' },
      subtle: { key: 'border' },
      // Follows whatever colour it is sitting on. This is what lets a keycap
      // ride an active, filled Listbox row without the row's theme having to
      // repaint it for every color.
      inherit: {
        key: 'border border-current/20 bg-transparent text-current'
      },
      // No box at all. For dense rows where a keycap would be visual noise and
      // the shortcut should read as quiet trailing text.
      plain: {
        key: 'border-0 bg-transparent px-0 min-w-0 text-current tracking-wide'
      }
    },
    color: {
      neutral: {},
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
    // variant: solid -- a filled cap. `-muted` is light enough to read as
    // a key on a page and each level carries its own `on-` contrast colour.
    {
      variant: 'solid',
      color: 'neutral',
      class: { key: 'bg-neutral-muted text-on-neutral-muted' }
    },
    {
      variant: 'solid',
      color: 'primary',
      class: { key: 'bg-primary-muted text-on-primary-muted' }
    },
    {
      variant: 'solid',
      color: 'secondary',
      class: { key: 'bg-secondary-muted text-on-secondary-muted' }
    },
    {
      variant: 'solid',
      color: 'tertiary',
      class: { key: 'bg-tertiary-muted text-on-tertiary-muted' }
    },
    {
      variant: 'solid',
      color: 'success',
      class: { key: 'bg-success-muted text-on-success-muted' }
    },
    {
      variant: 'solid',
      color: 'warning',
      class: { key: 'bg-warning-muted text-on-warning-muted' }
    },
    {
      variant: 'solid',
      color: 'danger',
      class: { key: 'bg-danger-muted text-on-danger-muted' }
    },

    // variant: outline
    {
      variant: 'outline',
      color: 'neutral',
      class: { key: 'border-neutral text-neutral-strong' }
    },
    {
      variant: 'outline',
      color: 'primary',
      class: { key: 'border-primary text-primary-strong' }
    },
    {
      variant: 'outline',
      color: 'secondary',
      class: { key: 'border-secondary text-secondary-strong' }
    },
    {
      variant: 'outline',
      color: 'tertiary',
      class: { key: 'border-tertiary text-tertiary-strong' }
    },
    {
      variant: 'outline',
      color: 'success',
      class: { key: 'border-success text-success-strong' }
    },
    {
      variant: 'outline',
      color: 'warning',
      class: { key: 'border-warning text-warning-strong' }
    },
    {
      variant: 'outline',
      color: 'danger',
      class: { key: 'border-danger text-danger-strong' }
    },

    // variant: subtle
    {
      variant: 'subtle',
      color: 'neutral',
      class: {
        key: 'bg-neutral-subtle border-neutral-soft text-neutral-strong'
      }
    },
    {
      variant: 'subtle',
      color: 'primary',
      class: {
        key: 'bg-primary-subtle border-primary-soft text-primary-strong'
      }
    },
    {
      variant: 'subtle',
      color: 'secondary',
      class: {
        key: 'bg-secondary-subtle border-secondary-soft text-secondary-strong'
      }
    },
    {
      variant: 'subtle',
      color: 'tertiary',
      class: {
        key: 'bg-tertiary-subtle border-tertiary-soft text-tertiary-strong'
      }
    },
    {
      variant: 'subtle',
      color: 'success',
      class: {
        key: 'bg-success-subtle border-success-soft text-success-strong'
      }
    },
    {
      variant: 'subtle',
      color: 'warning',
      class: {
        key: 'bg-warning-subtle border-warning-soft text-warning-strong'
      }
    },
    {
      variant: 'subtle',
      color: 'danger',
      class: { key: 'bg-danger-subtle border-danger-soft text-danger-strong' }
    }
  ],
  defaultVariants: {
    size: 'md',
    color: 'neutral',
    variant: 'solid'
  }
});

export type KbdVariants = VariantProps<typeof kbd>;
export type KbdSlots = keyof ReturnType<typeof kbd>;

export { kbd };
