import { tv } from '../tw';

const progressBar = tv({
  slots: {
    base: ['overflow-hidden w-full bg-surface-overlay-soft'],
    label: ['flex justify-between pb-1 gap-2 leading-tight'],
    progress: [''],
    description: ['text-neutral-medium text-xs pb-1']
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
        progress: 'bg-brand-soft'
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
        label: 'text-xs',
        description: 'text-xs'
      },
      sm: {
        base: 'h-2',
        progress: 'h-2',
        label: 'text-sm',
        description: 'text-sm'
      },
      md: {
        base: 'h-4',
        progress: 'h-4'
      },
      lg: {
        base: 'h-8',
        progress: 'h-8',
        label: 'text-lg',
        description: 'text-lg'
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
