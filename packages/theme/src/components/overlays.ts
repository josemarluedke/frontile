import { tv } from 'tailwind-variants';

const obscurer = `before:bg-gradient-to-b before:to-content1 before:from-content1/75 before:absolute before:left-0 before:w-full before:h-4 before:-top-4 before:content-['_']`;

const overlay = tv({
  slots: {
    base: '',
    backdrop: 'fixed inset-0 select-none z-10 bg-overlay/[.45]',
    content:
      'flex items-center fixed inset-0 flex-col z-20 will-change-transform overflow-auto'
  },
  variants: {
    inPlace: {
      true: {
        backdrop: 'absolute',
        content: 'absolute'
      }
    }
  }
});

const modal = tv({
  slots: {
    base: 'flex flex-col shrink-0 relative text-content1-foreground bg-content1 rounded my-24 w-full outline-none overflow-hidden z-0',
    closeButton: 'absolute top-2 right-2 z-10 dark:hover:bg-content2',
    header: 'font-bold text-xl p-4 rounded-tl rounded-tr',
    body: 'p-4 grow overflow-y-auto',
    footer: `${obscurer} flex justify-end items-center relative border-t border-default-200 bg-content2 p-4`
  },
  variants: {
    size: {
      xs: 'modal--xs',
      sm: 'modal--sm',
      md: 'modal--md',
      lg: 'modal--lg',
      xl: 'modal--xl',
      full: 'modal--full'
    },
    isCentered: {
      true: 'my-auto'
    }
  }
});

const drawer = tv({
  slots: {
    base: 'flex flex-col absolute text-content1-foreground bg-content1 w-full h-full z-0 shadow',
    closeButton: 'absolute top-2 right-2 z-10 dark:hover:bg-content2',
    header: 'font-bold text-xl p-4 rounded-tl rounded-tr',
    body: 'p-4 grow overflow-y-auto',
    footer: `${obscurer} flex justify-end items-center relative border-t border-default-200 bg-content2 p-4`
  },
  variants: {
    size: {
      xs: '',
      sm: '',
      md: '',
      lg: '',
      xl: '',
      full: ''
    },
    placement: {
      top: 'top-0 right-0 left-0',
      bottom: 'bottom-0 right-0 left-0',
      left: 'top-0 bottom-0 left-0',
      right: 'top-0 bottom-0 right-0'
    }
  },
  compoundVariants: [
    // vertical
    {
      placement: ['top', 'bottom'],
      size: 'xs',
      class: 'drawer--vertical-xs'
    },
    {
      placement: ['top', 'bottom'],
      size: 'sm',
      class: 'drawer--vertical-sm'
    },
    {
      placement: ['top', 'bottom'],
      size: 'md',
      class: 'drawer--vertical-md'
    },
    {
      placement: ['top', 'bottom'],
      size: 'lg',
      class: 'drawer--vertical-lg'
    },
    {
      placement: ['top', 'bottom'],
      size: 'xl',
      class: 'drawer--vertical-xl'
    },
    {
      placement: ['top', 'bottom'],
      size: 'full',
      class: 'drawer--vertical-full'
    },

    // horizontal
    {
      placement: ['right', 'left'],
      size: 'xs',
      class: 'drawer--horizontal-xs'
    },
    {
      placement: ['right', 'left'],
      size: 'sm',
      class: 'drawer--horizontal-sm'
    },
    {
      placement: ['right', 'left'],
      size: 'md',
      class: 'drawer--horizontal-md'
    },
    {
      placement: ['right', 'left'],
      size: 'lg',
      class: 'drawer--horizontal-lg'
    },
    {
      placement: ['right', 'left'],
      size: 'xl',
      class: 'drawer--horizontal-xl'
    },
    {
      placement: ['right', 'left'],
      size: 'full',
      class: 'drawer--horizontal-full'
    }
  ]
});

const slideTransition = {
  enterActive: {
    transition: 'transform 0.2s cubic-bezier(0.37, 0, 0.63, 1)'
  },

  leaveActive: {
    transition: 'transform 0.2s cubic-bezier(0.37, 0, 0.63, 1)'
  }
};

const overlayTransitions = {
  fade: {
    enter: {
      opacity: '0'
    },
    enterActive: {
      transition: 'opacity 0.2s linear'
    },
    leave: {
      opacity: '1'
    },
    leaveActive: {
      transition: 'opacity 0.2s linear'
    }
  },
  zoom: {
    enter: {
      opacity: '0',
      transform: 'scale(0.8)'
    },
    enterActive: {
      transition: 'all 0.2s ease-in-out'
    },
    leave: {
      opacity: '1',
      transform: 'scale(1)'
    },
    leaveActive: {
      transition: 'all 0.2s ease-in-out'
    }
  },
  slideFromLeft: {
    enter: {
      transform: 'translateX(-100%)'
    },
    leave: {
      transform: 'translateX(0%)'
    },
    ...slideTransition
  },
  slideFromRight: {
    enter: {
      transform: 'translateX(100%)'
    },
    leave: {
      transform: 'translateX(0%)'
    },
    ...slideTransition
  },

  slideFromTop: {
    enter: {
      transform: 'translateY(-100%)'
    },
    leave: {
      transform: 'translateY(0%)'
    },
    ...slideTransition
  },
  slideFromBottom: {
    enter: {
      transform: 'translateY(100%)'
    },
    leave: {
      transform: 'translateY(0%)'
    },
    ...slideTransition
  }
};

export { overlay, drawer, modal, overlayTransitions };
