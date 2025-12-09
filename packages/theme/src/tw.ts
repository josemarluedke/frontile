import { extendTailwindMerge } from 'tailwind-merge';
import type { ClassValue } from 'tailwind-variants';
export { tv } from 'tailwind-variants';
export type { VariantProps } from 'tailwind-variants';

function flat(arr: ClassValue[], target: ClassValue[]): void {
  arr.forEach((el) => {
    if (Array.isArray(el)) {
      flat(el, target);
    } else {
      target.push(el);
    }
  });
}
function flatArray(arr: ClassValue[]): ClassValue[] {
  const flattened: ClassValue[] = [];
  flat(arr, flattened);
  return flattened;
}
const voidEmpty = <T>(value: T): T | undefined => (value ? value : undefined);

const clsx = (...classes: ClassValue[]): string | undefined => {
  return voidEmpty(flatArray(classes).filter(Boolean).join(' '));
};

// Common size units used across all design tokens (icons, typography, etc.)
const COMMON_UNITS = [
  'pico',
  'nano',
  'micro',
  '3xs',
  '2xs',
  'xs',
  'sm',
  'md',
  'lg',
  'xl',
  '2xl',
  '3xl',
  'kilo',
  'mega'
];

const ELEVATION_LEVELS = ['0', '1', '2', '3', '4', '5'];

const twMergeConfig = {
  classGroups: {
    // Icon sizes
    'icon-size': [{ 'size-icon': COMMON_UNITS }],

    // Border widths (directional variants handled automatically)
    'border-w': [{ border: ['thin', 'heavy', 'aggressive'] }],

    // Border radius (extend existing rounded utilities)
    rounded: [{ rounded: ['default', 'pill'] }],

    // Elevation shadows
    shadow: [{ 'shadow-elevation': ELEVATION_LEVELS }],

    // Opacity
    opacity: [{ opacity: ['hover', 'disabled'] }],

    // Typography composite text styles (extend font-size class group)
    // These set font-size + other properties, so they should conflict with text-* utilities
    'font-size': [
      { 'text-marquee': COMMON_UNITS },
      { 'text-header': COMMON_UNITS },
      { 'text-body': COMMON_UNITS },
      { 'text-code': COMMON_UNITS },
      { 'text-caption': COMMON_UNITS },
      { 'text-label': COMMON_UNITS }
    ]
  },
  conflictingClassGroups: {
    'icon-size': ['w', 'h', 'size']
  }
};

const twMergeBase = extendTailwindMerge({
  extend: twMergeConfig as any
});

export function twMerge(defaultClass: ClassValue, overwrites: ClassValue) {
  if (overwrites) {
    return twMergeBase(clsx(defaultClass, overwrites));
  }
  return clsx(defaultClass);
}
