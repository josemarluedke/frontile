import { tv, type VariantProps } from '../tw';

const obscurer = `before:bg-linear-to-b before:to-surface-solid-1 before:from-surface-solid-1/75 before:absolute before:left-0 before:w-full before:h-4 before:-top-4 before:content-['_']`;

const overlay = tv({
  base: 'will-change-transform overflow-auto',
  variants: {
    enableFlexContent: {
      true: 'flex items-center fixed inset-0 flex-col'
    },
    inPlace: {
      true: 'absolute'
    }
  }
});

const backdrop = tv({
  base: 'fixed inset-0 select-none',
  variants: {
    type: {
      none: '',
      transparent: '',
      blur: 'bg-surface-overlay-inverse-strong backdrop-blur-sm',
      faded: 'bg-surface-overlay-inverse-strong'
    },
    inPlace: {
      true: 'absolute'
    }
  }
});

const modal = tv({
  slots: {
    base: 'flex flex-col shrink-0 relative text-surface-solid-11 bg-surface-solid-1 rounded-sm my-24 w-full outline-hidden overflow-hidden',
    closeButton: 'absolute top-2 right-2',
    header: 'font-bold text-xl p-4 rounded-tl rounded-tr',
    body: 'p-4 grow overflow-y-auto',
    footer: `${obscurer} flex justify-end items-center relative border-t border-neutral-subtle bg-surface-overlay-subtle p-4`
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
    base: 'flex flex-col absolute text-surface-solid-11 bg-surface-solid-1 w-full h-full shadow-sm outline-hidden',
    closeButton: 'absolute top-2 right-2',
    header: 'font-bold text-xl p-4 rounded-tl rounded-tr',
    body: 'p-4 grow overflow-y-auto',
    footer: `${obscurer} flex justify-end items-center relative border-t border-neutral-subtle bg-surface-overlay-subtle p-4`
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
  },
  scale: {
    enter: {
      opacity: '0',
      transform: 'scale(0.95)'
    },
    enterActive: {
      transitionProperty: 'transform, opacity',
      transitionDuration: '200ms',
      transitionTimingFunction: 'cubic-bezier(0, 0, 0.2, 1)'
    },
    enterTo: {
      opacity: '1',
      transform: 'translate(scaleX(1) scaleY(1))'
    },
    leave: {
      opacity: '1',
      transform: 'translate(scaleX(1) scaleY(1))'
    },
    leaveActive: {
      transitionProperty: 'transform, opacity',
      transitionDuration: '100ms',
      transitionTimingFunction: 'cubic-bezier(0.4, 0, 1, 1)'
    },
    leaveTo: {
      opacity: '0',
      transform: 'scale(0.95)'
    }
  }
};

export type OverlayVariants = VariantProps<typeof overlay>;
export type OverlaySlots = keyof ReturnType<typeof overlay>;
export type DrawerVariants = VariantProps<typeof drawer>;
export type DrawerSlots = keyof ReturnType<typeof drawer>;
export type ModalVariants = VariantProps<typeof modal>;
export type ModalSlots = keyof ReturnType<typeof modal>;
export type BackdropVariants = VariantProps<typeof backdrop>;
export type BackdropSlots = keyof ReturnType<typeof backdrop>;

export { overlay, drawer, modal, overlayTransitions, backdrop };
