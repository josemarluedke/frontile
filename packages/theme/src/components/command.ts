import { tv } from '../tw';
import type { VariantProps } from 'tailwind-variants';

const command = tv({
  slots: {
    // Padded, with the input inset as its own field: the palette reads as one
    // surface holding a search box and its results, not as a form control
    // with a list glued underneath.
    base: [
      'flex flex-col',
      'w-full min-w-0',
      'p-2',
      'overflow-hidden',
      'text-on-surface-modal'
    ],
    inputWrapper: [
      'flex items-center gap-2',
      'h-9 shrink-0',
      'px-3',
      'rounded-md',
      'border border-neutral-soft',
      'bg-neutral-subtle/60',
      'transition-colors',
      'has-[input:focus-visible]:border-neutral-mild'
    ],
    inputIcon: ['size-4 shrink-0', 'text-neutral'],
    input: [
      'h-full w-full',
      'bg-transparent',
      'font-body text-body-sm',
      'outline-hidden',
      'placeholder:text-neutral',
      'disabled:cursor-not-allowed disabled:opacity-disabled'
    ],
    // The `size` variant gives the list a minimum height on purpose: without
    // one the panel collapses and re-expands on every keystroke as results
    // narrow, which reads as jitter.
    //
    // The palette wants denser, plainer rows than a Dropdown menu does. The
    // descendant utilities below apply that without forking `listboxItem`.
    // They must stay as literal strings: Tailwind finds classes by scanning
    // source text, so a class assembled with interpolation is never generated.
    // No `overscroll-contain`: the list is a scroll container even when its
    // items fit, and containing overscroll there swallows wheel events over an
    // inline palette so the page behind it cannot scroll. The dialog does not
    // need it either -- body scroll is locked while it is open.
    list: [
      // Vertical rhythm: 8px above the first heading, 4px between rows, a
      // padded group above each divider, and room before the footer.
      'mt-2',
      'overflow-y-auto overflow-x-hidden',
      'scroll-py-1',
      'px-0 pt-0 pb-1',
      'gap-1',
      '[&_[data-component=listbox-group]]:pb-1',
      '[&_[data-component=listbox-group]_ul]:gap-1',
      // rows
      '[&_[data-component=listbox-item]]:min-h-9',
      '[&_[data-component=listbox-item]]:rounded-md',
      '[&_[data-component=listbox-item]]:px-3',
      '[&_[data-component=listbox-item]]:py-0',
      // Active row: a solid fill, no outline. `neutral-subtle` is too close to
      // the panel surface in dark mode to read as a highlight, leaving only a
      // hairline box; `neutral-muted` is one step up and visible in both schemes.
      '[&_[data-component=listbox-item][data-active=true]]:bg-neutral-muted',
      '[&_[data-component=listbox-item][data-active=true]]:text-neutral-bolder',
      // row text
      '[&_[data-test-id=listbox-item-label]]:text-body-sm',
      '[&_[data-test-id=listbox-item-label]]:font-medium',
      // shortcuts read as plain muted text, not as keycaps -- the footer owns keycaps
      '[&_[data-test-id=listbox-item-shortcut]]:border-transparent',
      '[&_[data-test-id=listbox-item-shortcut]]:px-0',
      '[&_[data-test-id=listbox-item-shortcut]]:tracking-widest',
      // the shared item style boxes the shortcut on the active row; keep it flat here
      '[&_[data-component=listbox-item][data-active=true]_[data-test-id=listbox-item-shortcut]]:border-transparent',
      '[&_[data-component=listbox-item][data-active=true]_[data-test-id=listbox-item-shortcut]]:text-neutral',
      // leading icons are sized and muted unless the consumer says otherwise
      '[&_[data-component=listbox-item]_svg:not([class*=size-])]:size-4',
      '[&_[data-component=listbox-item]_svg]:shrink-0',
      '[&_[data-component=listbox-item]_svg:not([class*=text-])]:text-neutral',
      // group headings
      '[&_[data-test-id=listbox-group-title]]:px-3',
      '[&_[data-test-id=listbox-group-title]]:pt-1.5',
      '[&_[data-test-id=listbox-group-title]]:pb-1.5'
    ],
    empty: ['py-6', 'text-center', 'font-body text-body-sm', 'text-neutral'],
    loading: [
      'flex items-center justify-center gap-2',
      'py-6',
      'font-body text-body-sm',
      'text-neutral'
    ],
    // Bleeds to the panel edges, so it reads as the palette's chrome rather
    // than as a row.
    footer: [
      'flex items-center gap-3',
      'h-10 shrink-0',
      '-mx-2 -mb-2 mt-2 px-4',
      'border-t border-neutral-soft',
      'bg-neutral-subtle/60',
      'font-body text-body-2xs font-medium',
      'text-neutral',
      'select-none'
    ],
    footerHint: 'flex items-center gap-1.5',
    kbd: [
      'pointer-events-none select-none',
      'flex h-5 min-w-5 items-center justify-center gap-1',
      'rounded border border-neutral-soft',
      'bg-surface-modal',
      'px-1',
      'font-body text-[0.7rem] font-medium',
      'text-neutral',
      '[&_svg]:size-3'
    ]
  },
  variants: {
    size: {
      sm: { list: 'max-h-64 min-h-32' },
      md: { list: 'max-h-80 min-h-48' },
      lg: { list: 'max-h-96 min-h-64' }
    },
    /**
     * Draws the palette's own surface, for use outside a dialog. A shrink-wrap
     * layout would otherwise size it to its widest row, so it also carries a
     * sensible minimum width.
     */
    isBordered: {
      true: {
        base: [
          // A percentage here would resolve against a shrink-wrapped parent's
          // indefinite width and vanish; the rem floor is what actually holds.
          'min-w-[28rem] max-w-full',
          'rounded-xl',
          'bg-surface-modal',
          'border border-surface-overlay-mild',
          'shadow-md'
        ],
        footer: 'rounded-b-xl'
      }
    }
  },
  defaultVariants: {
    size: 'md'
  }
});

const commandDialog = tv({
  slots: {
    // Sits the panel below the top edge rather than centering it: a palette is
    // read top-down, and a vertically centered one moves as results change.
    base: 'w-full max-w-lg px-4 mt-[12vh] mb-8 sm:mt-[15vh]',
    panel: [
      'relative flex flex-col',
      'w-full',
      'overflow-hidden',
      'rounded-xl',
      'bg-surface-modal',
      'text-on-surface-modal',
      'border border-surface-overlay-mild',
      // The soft outer ring is what separates the panel from the scrim; a
      // shadow alone reads as flat against a dark backdrop.
      'ring-4 ring-neutral-soft/40',
      'shadow-2xl',
      'outline-hidden'
    ]
  }
});

export type CommandVariants = VariantProps<typeof command>;
export type CommandSlots = keyof ReturnType<typeof command>;
export type CommandDialogSlots = keyof ReturnType<typeof commandDialog>;

export { command, commandDialog };
