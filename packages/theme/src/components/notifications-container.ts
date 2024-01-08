import { tv } from 'tailwind-variants';

const notificationsContainer = tv({
  base: [
    'w-full',
    'max-h-full',
    'overflow-hidden',
    'px-4',
    'fixed',
    'max-w-lg',
    'z-[1000]'
  ],
  variants: {
    placement: {
      'top-left': 'top-0 left-0',
      'top-center': 'top-0 left-2/4 translate-x-[-50%]',
      'top-right': 'top-0  right-0',
      'bottom-left': 'bottom-0 left-0',
      'bottom-center': 'bottom-0 left-2/4 translate-x-[-50%]',
      'bottom-right': 'bottom-0 right-0 '
    }
  },
  defaultVariants: {
    placement: 'bottom-right'
  }
});

export { notificationsContainer };
