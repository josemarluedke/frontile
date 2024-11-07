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

// This is empty for now as we don't have any configuration
const twMergeConfig = {};
const twMergeBase = extendTailwindMerge({ extend: twMergeConfig });

export function twMerge(defaultClass: ClassValue, overwrites: ClassValue) {
  if (overwrites) {
    return twMergeBase(clsx(defaultClass, overwrites));
  }
  return clsx(defaultClass);
}
