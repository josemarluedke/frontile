import { tv } from '../tw';

const progressBar = tv({
  slots: {
    base: ['overflow-hidden w-full bg-surface-overlay-soft'],
    label: ['flex justify-between pb-1 gap-2 font-label text-label-sm'],
    progress: [''],
    description: ['text-neutral font-body text-body-micro pb-1']
  },
  variants: {
    isIndeterminate: {
      true: {
        progress: ['animate-loading origin-left']
      }
    },
    intent: {
      default: {
        progress: 'bg-neutral-strong'
      },
      primary: {
        progress: 'bg-primary-soft'
      },
      accent: {
        progress: 'bg-accent-soft'
      },
      success: {
        progress: 'bg-success-soft'
      },
      warning: {
        progress: 'bg-warning-soft'
      },
      danger: {
        progress: 'bg-danger-soft'
      }
    },
    size: {
      xs: {
        base: 'h-1',
        progress: 'h-1',
        label: 'text-label-2xs',
        description: 'text-body-micro'
      },
      sm: {
        base: 'h-2',
        progress: 'h-2',
        label: 'text-label-xs',
        description: 'text-body-2xs'
      },
      md: {
        base: 'h-4',
        progress: 'h-4'
      },
      lg: {
        base: 'h-8',
        progress: 'h-8',
        label: 'text-label-md',
        description: 'text-body-sm'
      }
    },
    radius: {
      none: 'rounded-none',
      sm: 'rounded-sm',
      lg: 'rounded-lg',
      full: 'rounded-full'
    }
  },
  defaultVariants: {
    size: 'md',
    intent: 'default',
    radius: 'sm'
  }
});

export { progressBar };
