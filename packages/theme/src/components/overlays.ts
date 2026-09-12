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
    base: 'flex flex-col absolute rounded-2xl outline-hidden overflow-clip border border-neutral-muted shadow-elevation-5',
    closeButton: 'absolute top-3 right-3',
    // The close button rendered *inside* the header (see `drawer.gts`) is
    // absolutely positioned rather than placed as a grid item. Making it a
    // grid item was tried and reverted: as a spanning item it forces the
    // header's row track count up, so a header with only a title grew a
    // phantom second row and the band became far taller than its content.
    // Out of flow, it centres against whatever height the header's own
    // content produces -- title-only or title + description alike -- and
    // contributes nothing to that height. The header reserves space for it
    // with right padding instead, since an out-of-flow element cannot push
    // the text out of its own way.
    //
    // `right-5` rather than `right-8` is optical alignment, not a mistake.
    // The button's hit area is its icon plus 12px of padding on each side --
    // padding that exists for the hover and focus rings, and that is
    // invisible at rest. Pinning the button's *box* to the header's 32px
    // padding would leave the visible glyph sitting 12px further in than the
    // body text below it. Offsetting by that padding (32 - 12 = 20px) lines
    // the glyph's edge up with the content instead of the box's.
    headerCloseButton: 'absolute top-1/2 right-5 -translate-y-1/2 shrink-0',
    // The header is a flex row of two regions, not a grid: the grid lives one
    // level down in `headerContent`. Consumer actions have to be able to sit
    // beside the close button and be centred against a header that may be one
    // or two text rows tall, and a grid item that spans both rows forces the
    // row track count up -- which is what previously made a title-only header
    // grow a phantom second row. As a flex sibling there are no row tracks to
    // inflate.
    header: 'relative flex items-center gap-4',
    // `min-w-0` lets a long title shrink (and truncate, if the consumer asks
    // for it) instead of shoving the actions past the edge -- a flex item's
    // default `min-width: auto` refuses to shrink below its content.
    headerContent: [
      'grid grid-cols-[auto_1fr] items-center grow min-w-0',
      // The icon only spans two rows when there are two rows of text to span.
      // A spanning grid item's height is distributed across every track it
      // covers, so a 40px icon spanning rows in a header with only a title
      // pushed half its height into a phantom second row: the title (and the
      // close button, centred against the band) ended up ~10px above the
      // band's centre with dead space underneath. Keyed off the description
      // element's own presence with `:has()` -- the same trick `pagination.ts`
      // and `table.ts` use -- so it follows the rendered structure rather than
      // a variant the header has to compute and thread through, and it holds
      // for `@description` and a yielded `<h.Description />` alike.
      '[&:has([data-drawer-header-description])_[data-drawer-header-icon]]:row-span-2',
      '[&:has([data-drawer-header-description])_[data-drawer-header-icon]]:self-start'
    ],
    // Actions are in flow, deliberately, unlike the close button. The close
    // button is chrome this component owns and should not dictate the band's
    // height; whatever a consumer puts here is content, so a taller control
    // legitimately makes the band taller.
    headerActions: 'flex items-center gap-2 shrink-0',
    // `touch-pan-y` (not `touch-none`) tells the browser it may still handle
    // vertical panning natively -- matching `overflow-y-auto` above -- while
    // continuing to deliver pointer events to `dragToDismiss` for the first
    // few pixels of a touch drag. That's what lets the modifier decide
    // (before the browser commits to a native scroll) whether a body press
    // is a scroll or a dismiss drag; `touch-none` would suppress the native
    // scroll it's supposed to fall back to, and the default `touch-auto`
    // would let the browser claim the gesture for panning *and* pinch-zoom,
    // which fires `pointercancel` more eagerly than plain vertical panning.
    body: 'grow overflow-y-auto touch-pan-y',
    footer: 'flex justify-end items-center relative gap-4',
    // Sized from the design: a 40px icon box with a 16px gap to the text.
    //
    // With a title and a description the icon tops out with the title rather
    // than centring across both text rows, matching the design's
    // `align-items: flex-start`; that pairing lives on `headerContent`, which
    // can see whether a description exists. Title-only, it centres.
    //
    // The gap between the icon column and the text column lives here rather
    // than as `gap-x-*` on the header grid. A column gap applies between the
    // two tracks whether or not the icon track has anything in it, so a
    // header with no icon still had its title indented past the body text
    // below it. As a margin it only exists when an icon does.
    icon: 'col-start-1 self-center mr-4 size-10 shrink-0 flex items-center justify-center',
    title: 'col-start-2 font-header',
    description: 'col-start-2',
    dragHandle:
      'absolute z-10 flex items-center justify-center touch-none cursor-grab active:cursor-grabbing focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary',
    dragHandleBar: 'rounded-pill'
  },
  variants: {
    variant: {
      sectioned: {
        base: 'bg-surface-drawer text-on-surface-drawer',
        body: 'bg-surface-drawer px-8 py-6',
        header: 'bg-black text-white px-8 py-6',
        footer:
          'bg-surface-app text-on-surface-app border-t border-neutral-muted px-8 py-6',
        // The close button's own `transparent` variant hovers to
        // `surface-overlay-subtle` (black at 3% opacity), which is invisible
        // against this band's `bg-black` (itself black in both schemes, by
        // design). A fixed white tint reads against black in both light and
        // dark, matching the `text-white` / `text-white/70` treatment already
        // used here -- unlike `surface-lift-*`, which is white in light mode
        // but black in dark mode and would vanish on this band in dark.
        closeButton: 'text-white hover:bg-white/10',
        headerCloseButton: 'text-white hover:bg-white/10',
        icon: 'text-white',
        title: 'text-header-md text-white',
        description: 'text-body-sm text-white/80',
        // The handle can sit over the black header band (bottom placement)
        // or the surface-app footer (top placement) -- white in light mode,
        // black in dark mode. `bg-neutral` (gray-500 light / gray-400 dark)
        // is the one level that reads against both, plus the surface-drawer
        // body a side-placement handle runs down. See the "compound variant
        // vs. single semantic level" note on the `flat` bar below -- same
        // reasoning applies here.
        dragHandleBar: 'bg-neutral'
      },
      flat: {
        base: 'bg-surface-modal text-on-surface-modal',
        body: 'px-8 py-6',
        // Same grid layout as `sectioned` (left-aligned, icon column) but
        // flat's own colours -- no `bg-black`/`text-white` here, this stays
        // on `surface-modal`.
        header: 'font-header px-8 py-6',
        footer: `${obscurer} border-t border-surface-overlay-mild bg-surface-modal px-8 py-6`,
        title: 'text-header-lg',
        description: 'text-sm text-neutral',
        // `bg-neutral-soft` (gray-200 light / gray-700 dark) reads too faint
        // against `surface-modal` (white light / gray-950 dark) -- verified
        // in the browser. `bg-neutral` (gray-500 / gray-400) gives clear
        // contrast against surface-modal in both placements/schemes, and
        // matches the level used for the `sectioned` variant above, which
        // a matrix of variant x placement compound variants would not
        // buy us anything over -- every surface the handle can land on
        // (black header, surface-app, surface-drawer, surface-modal)
        // contrasts against this one level.
        dragHandleBar: 'bg-neutral'
      }
    },
    // The close button is absolutely positioned, so it cannot reserve its own
    // space -- the header pads a lane for it instead. That lane is only worth
    // paying for when the button is actually rendered; with
    // `@allowCloseButton={{false}}` it would be dead whitespace.
    hasCloseButton: {
      true: { header: 'pr-24' }
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
      top: 'top-2 right-2 left-2 h-full',
      bottom: 'bottom-2 right-2 left-2 h-full',
      left: 'top-2 bottom-2 left-2 w-full',
      right: 'top-2 bottom-2 right-2 w-full'
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

// One policy, spelled once: reduced motion drops the travel and keeps the
// fade. `addTransitions` derives `-leave-to` from `enter` and `-enter-to` from
// `leave`, so a state block covers two of the four generated classes.
//
// A slide is *only* travel, so it has no fade to keep -- `slideHidden` and
// `slideShown` supply one rather than leaving the drawer to appear with no
// transition at all. The `-active` blocks stay written per transition, because
// each has to override its own timing in its own spelling.
const reducedMotion = {
  dropTransform: {
    '@media (prefers-reduced-motion: reduce)': {
      transform: 'none'
    }
  },
  slideHidden: {
    '@media (prefers-reduced-motion: reduce)': {
      transform: 'none',
      opacity: '0'
    }
  },
  slideShown: {
    '@media (prefers-reduced-motion: reduce)': {
      opacity: '1'
    }
  }
};

const slideTransition = {
  enterActive: {
    transition: 'transform 0.2s cubic-bezier(0.37, 0, 0.63, 1)',
    '@media (prefers-reduced-motion: reduce)': {
      transition: 'opacity 0.2s linear'
    }
  },

  leaveActive: {
    transition: 'transform 0.2s cubic-bezier(0.37, 0, 0.63, 1)',
    '@media (prefers-reduced-motion: reduce)': {
      transition: 'opacity 0.2s linear'
    }
  }
};

/**
 * The arrow shared by `Popover.Content` and `Tooltip`.
 *
 * A rotated square rather than a border triangle, so it can carry the
 * content's own border. `bg-inherit` is the point: the arrow takes whatever
 * background the content has, so intents and custom classes never have to be
 * restated here. Its offset along the content's edge comes from the
 * floating-ui `arrow` middleware and is written as inline `left`/`top`; the
 * static side is pinned by the component from the resolved placement.
 */
const overlayArrow = tv({
  base: 'absolute w-2 h-2 rotate-45 bg-inherit border border-neutral-subtle pointer-events-none'
});

const overlayTransitions = {
  /**
   * Deliberately has no `prefers-reduced-motion` branch: a cross-fade is not
   * motion. Reduced motion asks for movement to be removed, not for state
   * changes to become instant, so the other transitions below drop their
   * travel and keep exactly this fade.
   */
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
      transform: 'scale(0.8)',
      ...reducedMotion.dropTransform
    },
    enterActive: {
      transition: 'all 0.2s ease-in-out',
      '@media (prefers-reduced-motion: reduce)': {
        transition: 'opacity 0.2s ease-in-out'
      }
    },
    leave: {
      opacity: '1',
      transform: 'scale(1)'
    },
    leaveActive: {
      transition: 'all 0.2s ease-in-out',
      '@media (prefers-reduced-motion: reduce)': {
        transition: 'opacity 0.2s ease-in-out'
      }
    }
  },
  slideFromLeft: {
    enter: {
      transform: 'translateX(-100%)',
      ...reducedMotion.slideHidden
    },
    leave: {
      transform: 'translateX(0%)',
      ...reducedMotion.slideShown
    },
    ...slideTransition
  },
  slideFromRight: {
    enter: {
      transform: 'translateX(100%)',
      ...reducedMotion.slideHidden
    },
    leave: {
      transform: 'translateX(0%)',
      ...reducedMotion.slideShown
    },
    ...slideTransition
  },

  slideFromTop: {
    enter: {
      transform: 'translateY(-100%)',
      ...reducedMotion.slideHidden
    },
    leave: {
      transform: 'translateY(0%)',
      ...reducedMotion.slideShown
    },
    ...slideTransition
  },
  slideFromBottom: {
    enter: {
      transform: 'translateY(100%)',
      ...reducedMotion.slideHidden
    },
    leave: {
      transform: 'translateY(0%)',
      ...reducedMotion.slideShown
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
  /**
   * Tooltip: a short scale-and-approach. Deliberately faster than `scale` --
   * a tooltip fires on every mouse pass, so a 200ms reveal reads as lag. The
   * translate is toward the anchor and the origin is set from the resolved
   * placement (see the `tooltip` component's `data-placement` classes), so it
   * grows out of the trigger rather than appearing in space.
   */
  tooltip: {
    enter: {
      opacity: '0',
      transform: 'scale(0.95) translateY(3px)',
      // Reduced motion keeps the fade and drops the travel, rather than
      // removing the transition -- the tooltip should still read as appearing.
      '@media (prefers-reduced-motion: reduce)': {
        transform: 'none'
      }
    },
    enterActive: {
      transitionProperty: 'transform, opacity',
      transitionDuration: '120ms',
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
      transitionDuration: '80ms',
      transitionTimingFunction: 'cubic-bezier(0.4, 0, 1, 1)',
      '@media (prefers-reduced-motion: reduce)': {
        transitionProperty: 'opacity'
      }
    },
    leaveTo: {
      opacity: '0',
      transform: 'scale(0.95) translateY(3px)',
      '@media (prefers-reduced-motion: reduce)': {
        transform: 'none'
      }
    }
  },
  scale: {
    enter: {
      opacity: '0',
      transform: 'scale(0.95)',
      ...reducedMotion.dropTransform
    },
    enterActive: {
      transitionProperty: 'transform, opacity',
      transitionDuration: '200ms',
      transitionTimingFunction: 'cubic-bezier(0, 0, 0.2, 1)',
      '@media (prefers-reduced-motion: reduce)': {
        transitionProperty: 'opacity'
      }
    },
    enterTo: {
      opacity: '1',
      transform: 'scale(1)'
    },
    leave: {
      opacity: '1',
      transform: 'scale(1)'
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
      transform: 'scale(0.95)',
      ...reducedMotion.dropTransform
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
export type OverlayArrowVariants = VariantProps<typeof overlayArrow>;

export { overlay, drawer, modal, overlayTransitions, backdrop, overlayArrow };
