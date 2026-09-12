import { tv } from '../tw';
import { focusVisibleRing } from './shared';
import type { VariantProps } from '../tw';

const accordion = tv({
  slots: {
    base: 'flex flex-col',

    // Carries `group/accordion-item` plus `data-open`, which is what lets the
    // indicator rotate without the component pushing a class. The group name
    // is written literally: Tailwind generates nothing from a composed string.
    item: 'group/accordion-item',

    heading: 'flex',

    trigger: [
      ...focusVisibleRing,
      'flex flex-1 items-center text-start',
      'w-full cursor-pointer',
      'transition-colors duration-200 motion-reduce:transition-none',
      'text-neutral-bolder',
      // "Not disabled" is `not-data-[disabled=true]`, not
      // `data-[disabled=false]`: an attribute-value selector cannot match an
      // element that never declares the attribute.
      'not-data-[disabled=true]:hover:text-neutral-strong',
      'data-[disabled=true]:cursor-not-allowed data-[disabled=true]:opacity-disabled'
    ],

    startContent: 'flex shrink-0 items-center',
    titleWrapper: 'flex flex-1 flex-col text-start',
    title: '',
    subtitle: 'text-neutral-firm',

    indicator: [
      'shrink-0',
      'transition-transform duration-200 motion-reduce:transition-none',
      'group-data-[open=true]/accordion-item:rotate-180'
    ],

    // The animated element. It must never carry padding: padding on the
    // animating box means the collapsed height can never reach 0.
    content: 'text-neutral-firm',

    // Where the panel's padding actually lives.
    contentBody: ''
  },

  variants: {
    variant: {
      // No chrome at all.
      ghost: {},
      // Rules between items, none after the last.
      separated: {
        item: 'border-b border-neutral-muted last:border-b-0'
      },
      // A soft fill on the open item. Horizontal padding comes with the
      // surface -- text running to the edge of a tinted box reads as a bug.
      soft: {
        item: 'rounded-lg data-[open=true]:bg-surface-overlay-soft',
        trigger: 'px-3',
        contentBody: 'px-3'
      },
      // One bordered surface around the whole group.
      enclosed: {
        base: 'overflow-hidden rounded-lg border border-neutral-muted',
        item: 'border-b border-neutral-muted last:border-b-0',
        trigger: 'px-4',
        contentBody: 'px-4'
      }
    },

    size: {
      // Typography sits on `trigger`, not on `title`, and that placement is
      // load-bearing: the trigger renders inside a real `<h3>` (or whatever
      // `@headingLevel` says), so a host page's heading styles -- large, bold,
      // tight tracking -- would otherwise be inherited by everything in the
      // header row that does not set its own size: `startContent`, the
      // indicator, and any custom `<:title>` content. The class on the trigger
      // is the baseline that neutralises that; `subtitle` then refines it, and
      // `@classes.title` still wins on the title element itself.
      //
      // `text-label-*` (semibold, default tracking) rather than `text-strong-*`
      // (bold, tight): an accordion header is a label on a row, not a section
      // heading. It matches the panel body's size at every step and lets weight
      // alone do the separating, which is how the reference implementations
      // read.
      sm: {
        trigger: 'gap-2 py-2 text-label-xs',
        subtitle: 'text-body-2xs',
        indicator: 'size-4',
        contentBody: 'pb-2 text-body-sm'
      },
      md: {
        trigger: 'gap-3 py-3 text-label-sm',
        subtitle: 'text-body-xs',
        indicator: 'size-5',
        contentBody: 'pb-3 text-body-md'
      },
      lg: {
        trigger: 'gap-3 py-4 text-label-md',
        subtitle: 'text-body-sm',
        indicator: 'size-6',
        contentBody: 'pb-4 text-body-lg'
      }
    },

    isDisabled: {
      true: {
        base: 'opacity-disabled',
        trigger: 'pointer-events-none'
      }
    }
  },

  defaultVariants: {
    variant: 'separated',
    size: 'md'
  }
});

export { accordion };
export type AccordionSlots = keyof ReturnType<typeof accordion>;
export type AccordionVariants = VariantProps<typeof accordion>;
