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
    ],
    // `BottomNav.More`: the copy of its block that is always rendered, out
    // of sight, so its items can report active and badge state while the
    // sheet is closed. `hidden` backs up the `hidden` attribute.
    bottomNavMoreRegistry: 'hidden',
    // The More sheet, merged into the bottom `Drawer`'s base: as tall as its
    // items, up to 80% of the viewport.
    bottomNavMoreSheet: 'h-auto max-h-[80dvh]',
    // The sheet's scrolling body, merged into the `Drawer`'s. The bottom
    // padding is the safe-area inset alone, like the bar's.
    bottomNavMoreBody: [
      'px-2 pt-6',
      'pb-[var(--bottomnav-safe-area,env(safe-area-inset-bottom,0px))]'
    ],
    // The `nav` inside the sheet that holds its items.
    bottomNavMoreNav: 'flex flex-col gap-0.5 pb-2'
  }
});

export { bottomNav };
export type BottomNavSlots = keyof ReturnType<typeof bottomNav>;
export type BottomNavVariants = VariantProps<typeof bottomNav>;
