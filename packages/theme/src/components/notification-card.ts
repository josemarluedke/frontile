import { tv } from '../tw';
import { focusVisibleRing } from './shared';

const btn = ['transition transition-200', ...focusVisibleRing];

const notificationCard = tv({
  slots: {
    base: 'py-3 px-4 overflow-hidden flex items-center justify-between relative min-h-16 text-sm rounded-sm shadow-sm transition-all transition-200 ease-in-out',
    message: 'grow',
    customActions: 'flex flex-nowrap',
    customActionButton: [
      ...btn,
      'first:ml-4 last:-mr-2 font-semibold py-1 px-2 rounded-sm'
    ],
    closeButton: [...btn, 'inline-block p-2 ml-2 -mr-2 rounded-full']
  },

  variants: {
    appearance: {
      info: {
        base: 'text-white bg-neutral-strong dark:text-surface-solid-11 dark:bg-inverse-subtle',
        closeButton: 'hover:bg-neutral-strong dark:hover:bg-inverse-soft',
        customActionButton: 'hover:bg-neutral-strong dark:hover:bg-inverse-soft'
      },
      success: {
        base: 'bg-success text-success-contrast-1',
        closeButton: 'hover:bg-success-medium',
        customActionButton: 'hover:bg-success-medium'
      },
      warning: {
        base: 'bg-warning text-warning-contrast-1',
        closeButton: 'hover:bg-warning-medium',
        customActionButton: 'hover:bg-warning-medium'
      },
      error: {
        base: 'bg-danger text-danger-contrast-1',
        closeButton: 'hover:bg-danger-medium',
        customActionButton: 'hover:bg-danger-medium'
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
