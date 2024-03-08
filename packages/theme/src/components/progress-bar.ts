import { tv } from '../tw';

const progressBar = tv({
  slots: {
    base: ['overflow-hidden w-full bg-content3 dark:bg-content2'],
    label: ['flex justify-between pb-1 gap-2 leading-tight'],
    progress: ['']
  },
  variants: {
    isIndeterminate: {
      true: {
        progress: ['animate-loading origin-left']
      }
    },
    intent: {
      default: {
        progress: 'bg-default-800 dark:bg-default'
      },
      primary: {
        progress: 'bg-primary-500'
      },
      success: {
        progress: 'bg-success-500'
      },
      warning: {
        progress: 'bg-warning-500'
      },
      danger: {
        progress: 'bg-danger-500'
      }
    },
    size: {
      xs: {
        base: 'h-1',
        progress: 'h-1',
        label: 'text-xs'
      },
      sm: {
        base: 'h-2',
        progress: 'h-2',
        label: 'text-sm'
      },
      md: {
        base: 'h-4',
        progress: 'h-4'
      },
      lg: {
        base: 'h-8',
        progress: 'h-8',
        label: 'text-lg'
      }
    },
    radius: {
      none: 'rounded-none',
      sm: 'rounded',
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
