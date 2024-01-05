import { tv } from 'tailwind-variants';

const btn = 'transition transition-200 focus-visible:ring';

const notificationCard = tv({
  slots: {
    base: 'text-white py-3 px-4 overflow-hidden flex items-center justify-between relative min-h-16 text-sm rounded shadow transition-all transition-200 ease-in-out',
    message: 'grow',
    customActions: 'flex flex-nowrap',
    customActionButton:
      btn + ' first:ml-4 last:-mr-2 font-semibold py-1 px-2 rounded',
    closeButton: btn + ' inline-block p-2 ml-2 -mr-2 rounded-full'
  },

  variants: {
    appearance: {
      info: {
        base: 'text-white bg-gray-900',
        closeButton: 'hover:bg-gray-800',
        customActionButton: 'hover:bg-gray-800'
      },
      success: {
        base: 'bg-green-700',
        closeButton: 'hover:bg-green-800',
        customActionButton: 'hover:bg-green-800'
      },
      warning: {
        base: 'bg-yellow-600',

        closeButton: 'hover:bg-yellow-700',
        customActionButton: 'hover:bg-yellow-700'
      },
      error: {
        base: 'bg-red-600',
        closeButton: 'hover:bg-red-700',
        customActionButton: 'hover:bg-red-700'
      }
    }
  },
  defaultVariants: {
    appearance: 'info'
  }
});

export { notificationCard };
