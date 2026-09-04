import { tv } from '../tw';
import type { VariantProps } from 'tailwind-variants';

const command = tv({
  slots: {
    base: [
      'flex flex-col',
      'w-full',
      'overflow-hidden',
      'text-on-surface-modal'
    ],
    inputWrapper: [
      'flex items-center gap-2',
      'px-3',
      'border-b border-surface-overlay-mild',
      'shrink-0'
    ],
    inputIcon: ['w-4 h-4 shrink-0', 'text-neutral'],
    input: [
      'w-full',
      'bg-transparent',
      'py-3',
      'font-body text-body-sm',
      'outline-hidden',
      'placeholder:text-neutral',
      'disabled:cursor-not-allowed disabled:opacity-disabled'
    ],
    // The list keeps a minimum height on purpose: without it the panel
    // collapses and re-expands on every keystroke as results narrow, which
    // reads as jitter rather than as responsiveness.
    list: ['overflow-y-auto', 'overscroll-contain', 'p-1'],
    empty: ['py-8', 'text-center', 'font-body text-body-sm', 'text-neutral'],
    loading: [
      'flex items-center justify-center gap-2',
      'py-8',
      'font-body text-body-sm',
      'text-neutral'
    ],
    footer: [
      'flex items-center gap-2',
      'px-3 py-2',
      'shrink-0',
      'border-t border-surface-overlay-mild',
      'font-label text-label-2xs',
      'text-neutral'
    ]
  },
  variants: {
    size: {
      sm: { list: 'max-h-64 min-h-32' },
      md: { list: 'max-h-80 min-h-48' },
      lg: { list: 'max-h-96 min-h-64' }
    },
    /**
     * Lets a palette rendered inline (rather than in a dialog) carry the same
     * surface as the dialog panel does.
     */
    isBordered: {
      true: {
        base: [
          'bg-surface-modal',
          'border border-surface-overlay-mild',
          'rounded-2xl'
        ]
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
    base: 'mx-auto mt-[12vh] w-full max-w-xl px-4',
    panel: [
      'flex flex-col',
      'w-full',
      'overflow-hidden',
      'bg-surface-modal',
      'text-on-surface-modal',
      'border border-surface-overlay-mild',
      'rounded-2xl',
      'shadow-2xl',
      'outline-hidden'
    ]
  }
});

export type CommandVariants = VariantProps<typeof command>;
export type CommandSlots = keyof ReturnType<typeof command>;
export type CommandDialogSlots = keyof ReturnType<typeof commandDialog>;

export { command, commandDialog };
