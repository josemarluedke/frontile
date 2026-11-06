import { tv } from '../tw';
import type { VariantProps } from '../tw';

/** The bar's height above the safe-area inset. */
export const bottomNavRowHeight = '3.75rem';

/**
 * The bottom inset the bar pads for. `--bottomnav-safe-area` overrides it,
 * so tests and apps can set their own; otherwise it is the device inset,
 * which is `0px` unless the page opts in with `viewport-fit=cover`.
 */
export const bottomNavSafeArea =
  'var(--bottomnav-safe-area, env(safe-area-inset-bottom, 0px))';

/** The bar's full height: the row plus the safe-area inset. */
export const bottomNavHeight = `calc(${bottomNavRowHeight} + ${bottomNavSafeArea})`;

/**
 * The mobile bottom tab bar. Slot names equal the kebab-cased `data-part`
 * each component renders.
 *
 * Standalone, the bar is fixed to the bottom of the viewport. There is no
 * z-index here on purpose; `AppLayout` positions it and layers it.
 */
const bottomNav = tv({
  slots: {
    // Class names are literal strings so Tailwind can see them.
    bottomNav: [
      'fixed inset-x-0 bottom-0 box-border flex items-center justify-around',
      'border-t border-neutral-subtle bg-surface-app',
      'min-h-[calc(3.75rem+var(--bottomnav-safe-area,env(safe-area-inset-bottom,0px)))]',
      'pb-[var(--bottomnav-safe-area,env(safe-area-inset-bottom,0px))]'
    ]
  }
});

export { bottomNav };
export type BottomNavSlots = keyof ReturnType<typeof bottomNav>;
export type BottomNavVariants = VariantProps<typeof bottomNav>;
