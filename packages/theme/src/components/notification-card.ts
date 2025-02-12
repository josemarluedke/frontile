import { tv } from '../tw';
import { focusVisibleRing } from './shared';

const btn = ['transition transition-200', ...focusVisibleRing];

const notificationCard = tv({
  slots: {
    base: 'py-3 px-4 overflow-hidden flex items-center justify-between relative min-h-16 text-sm rounded shadow transition-all transition-200 ease-in-out',
    message: 'grow',
    customActions: 'flex flex-nowrap',
    customActionButton: [
      ...btn,
      'first:ml-4 last:-mr-2 font-semibold py-1 px-2 rounded'
    ],
    closeButton: [...btn, 'inline-block p-2 ml-2 -mr-2 rounded-full']
  },

  variants: {
    appearance: {
      info: {
        base: 'text-white bg-default-900 dark:text-foreground dark:bg-default-200',
        closeButton: 'hover:bg-default-800 dark:hover:bg-default-300',
        customActionButton: 'hover:bg-default-800 dark:hover:bg-default-300'
      },
      success: {
        base: 'bg-success text-success-foreground',
        closeButton: 'hover:bg-success-600',
        customActionButton: 'hover:bg-success-600'
      },
      warning: {
        base: 'bg-warning text-warning-foreground',
        closeButton: 'hover:bg-warning-600',
        customActionButton: 'hover:bg-warning-600'
      },
      error: {
        base: 'bg-danger text-danger-foreground',
        closeButton: 'hover:bg-danger-600',
        customActionButton: 'hover:bg-danger-600'
      }
    }
  },
  defaultVariants: {
    appearance: 'info'
  }
});

const zoomOut = {
  leaveTo: {
    transform: 'scale(0.80)',
    opacity: '0'
  },
  leave: {
    transform: 'translate3d(0,0,0)'
  }
};

const notificationEnteringFrom = {
  right: {
    transform: 'translate3d(125%, 0, 0)'
  },

  left: {
    transform: 'translate3d(-125%, 0, 0)'
  },

  top: {
    transform: 'translate3d(0, -125%, 0)'
  },

  bottom: {
    transform: 'translate3d(0, 125%, 0)'
  }
};

const notificationTransitions = {
  slideFromTopLeft: {
    ...zoomOut,
    enter: {
      ...notificationEnteringFrom.left
    }
  },
  slideFromTopCenter: {
    ...zoomOut,
    enter: notificationEnteringFrom.top
  },
  slideFromTopRight: {
    ...zoomOut,
    enter: notificationEnteringFrom.right
  },
  slideFromBottomLeft: {
    ...zoomOut,
    enter: notificationEnteringFrom.left
  },
  slideFromBottomCenter: {
    ...zoomOut,
    enter: notificationEnteringFrom.bottom
  },
  slideFromBottomRight: {
    ...zoomOut,
    enter: notificationEnteringFrom.right
  }
};

export { notificationCard, notificationTransitions };
