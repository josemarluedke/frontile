import { tv } from '../tw';

const notificationsContainer = tv({
  slots: {
    base: ['fixed z-1000 w-full max-w-lg px-4 py-4 pointer-events-none'],
    stack: [
      'relative w-full pointer-events-none',
      'data-[expanded=true]:pointer-events-auto',
      'transition-[height] duration-400 ease-[cubic-bezier(0.21,1.02,0.73,1)]',
      'motion-reduce:transition-none'
    ]
  },
  variants: {
    placement: {
      'top-left': { base: 'top-0 left-0' },
      'top-center': { base: 'top-0 left-2/4 translate-x-[-50%]' },
      'top-right': { base: 'top-0 right-0' },
      'bottom-left': { base: 'bottom-0 left-0' },
      'bottom-center': { base: 'bottom-0 left-2/4 translate-x-[-50%]' },
      'bottom-right': { base: 'bottom-0 right-0' }
    }
  },
  defaultVariants: {
    placement: 'bottom-right'
  }
});

export { notificationsContainer };
