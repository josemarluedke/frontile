import { tv, type VariantProps } from '../tw';

const obscurer = `before:bg-linear-to-b before:to-surface-modal before:from-surface-modal/75 before:absolute before:left-0 before:w-full before:h-4 before:-top-4 before:content-['_']`;

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
      // The scrim is `overlay-strong` in light and `lift-strong` in dark: the
      // two families are mirrored, so the black 75% step swaps sides. Pairing
      // them keeps the backdrop a dark scrim in both schemes.
      blur: 'bg-surface-overlay-strong dark:bg-surface-lift-strong backdrop-blur-sm',
      faded: 'bg-surface-overlay-strong dark:bg-surface-lift-strong'
    },
    inPlace: {
      true: 'absolute'
    }
  }
});

const modal = tv({
  slots: {
    base: 'flex flex-col shrink-0 relative text-on-surface-modal bg-surface-modal border border-surface-overlay-mild rounded-2xl my-24 w-full outline-hidden overflow-clip',
    closeButton: 'absolute top-3 right-3',
    header: 'font-header text-header-lg px-6 pt-8 pb-2',
    body: 'px-6 py-2 grow overflow-y-auto',
    footer: 'flex justify-end items-center px-6 pt-6 pb-8 gap-4'
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
    base: 'flex flex-col absolute rounded-2xl w-full h-full outline-hidden overflow-clip border border-neutral-muted shadow-elevation-5',
    closeButton: 'absolute top-3 right-3',
    header: '',
    body: 'grow overflow-y-auto',
    footer: 'flex justify-end items-center relative gap-4',
    icon: 'row-span-2 col-start-1 shrink-0 flex items-center justify-center',
    title: 'col-start-2 font-header',
    description: 'col-start-2',
    dragHandle:
      'absolute z-10 flex items-center justify-center touch-none cursor-grab active:cursor-grabbing focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary',
    dragHandleBar: 'rounded-pill'
  },
  variants: {
    appearance: {
      default: {
        base: 'bg-surface-drawer text-on-surface-drawer',
        body: 'bg-surface-drawer px-6 py-4',
        header:
          'grid grid-cols-[auto_1fr] items-center gap-x-3 bg-black text-white px-6 py-4 pr-14',
        footer:
          'bg-surface-app text-on-surface-app border-t border-neutral-muted px-6 py-4',
        closeButton: 'text-white',
        icon: 'text-white',
        title: 'text-header-sm font-semibold text-white',
        description: 'text-sm text-white/70',
        dragHandleBar: 'bg-white/40'
      },
      ghost: {
        base: 'bg-surface-modal text-on-surface-modal',
        body: 'px-8 py-4',
        header: 'font-header text-header-lg text-center px-8 pt-10 pb-2',
        footer: `${obscurer} border-t border-surface-overlay-mild bg-surface-modal p-8`,
        title: 'text-header-lg',
        description: 'text-sm text-neutral',
        dragHandleBar: 'bg-neutral-soft'
      }
    },
    size: {
      xs: '',
      sm: '',
      md: '',
      lg: '',
      xl: '',
      full: ''
    },
    placement: {
      top: 'top-2 right-2 left-2',
      bottom: 'bottom-2 right-2 left-2',
      left: 'top-2 bottom-2 left-2',
      right: 'top-2 bottom-2 right-2'
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
    },

    // Drag handle placement: the bar sits on the edge facing the viewport
    // centre, so the user grabs the side they would pull from.
    {
      placement: 'bottom',
      class: {
        dragHandle: 'top-0 left-0 right-0 h-6',
        dragHandleBar: 'h-1 w-12'
      }
    },
    {
      placement: 'top',
      class: {
        dragHandle: 'bottom-0 left-0 right-0 h-6',
        dragHandleBar: 'h-1 w-12'
      }
    },
    {
      placement: 'right',
      class: {
        dragHandle: 'left-0 top-0 bottom-0 w-6',
        dragHandleBar: 'w-1 h-12'
      }
    },
    {
      placement: 'left',
      class: {
        dragHandle: 'right-0 top-0 bottom-0 w-6',
        dragHandleBar: 'w-1 h-12'
      }
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
  /**
   * Command palette: a short scale-and-rise. Deliberately faster than `scale`
   * -- a palette is opened mid-task and re-opened constantly, so the animation
   * has to read as instant rather than as a reveal.
   */
  command: {
    enter: {
      opacity: '0',
      transform: 'scale(0.96) translateY(4px)',
      // Reduced motion keeps the fade but drops the movement, rather than
      // removing the transition altogether -- the palette should still read as
      // appearing, just without travel.
      '@media (prefers-reduced-motion: reduce)': {
        transform: 'none'
      }
    },
    enterActive: {
      transitionProperty: 'transform, opacity',
      transitionDuration: '150ms',
      transitionTimingFunction: 'cubic-bezier(0.16, 1, 0.3, 1)',
      '@media (prefers-reduced-motion: reduce)': {
        transitionProperty: 'opacity'
      }
    },
    enterTo: {
      opacity: '1',
      transform: 'scale(1) translateY(0)'
    },
    leave: {
      opacity: '1',
      transform: 'scale(1) translateY(0)'
    },
    leaveActive: {
      transitionProperty: 'transform, opacity',
      transitionDuration: '100ms',
      transitionTimingFunction: 'cubic-bezier(0.4, 0, 1, 1)',
      '@media (prefers-reduced-motion: reduce)': {
        transitionProperty: 'opacity'
      }
    },
    leaveTo: {
      opacity: '0',
      transform: 'scale(0.96) translateY(4px)',
      '@media (prefers-reduced-motion: reduce)': {
        transform: 'none'
      }
    }
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
