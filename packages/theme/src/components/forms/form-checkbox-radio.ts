import { tv } from 'tailwind-variants';

const base = tv({
  slots: {
    base: 'flex flex-wrap	flex-row items-center',
    labelContainer: 'leading-tight flex items-start',
    inputContainer: 'flex items-center',
    label: 'font-normal pl-2 pb-0',
    hint: 'pl-2 flex basis-full	before:content-["_"] before:inline-block before:w-[1em] before:h-[1em] shrink-0'
  },
  variants: {
    size: {
      sm: {
        label: 'text-sm'
      },
      md: '',
      lg: ''
    }
  },
  defaultVariants: {
    size: 'md'
  }
});

const formCheckbox = tv({
  extend: base,
  slots: {
    checkbox: ''
  }
});

const formRadio = tv({
  extend: base,
  slots: {
    radio: ''
  }
});

const baseGroup = tv({
  slots: {
    base: '',
    label: 'pb-1 last:pb-0',
    hint: 'pb-1 last:pb-0',
    feedback: 'pt-0 flex-[1_100%]'
  },
  variants: {
    isInline: {
      true: {
        base: 'flex flex-wrap	flex-row items-start',
        label: 'pr-4 pb-0',
        hint: 'pr-4 pb-0',
        feedback: 'pr-4 pb-0'
      }
    }
  }
});

const formCheckboxGroup = tv({
  extend: baseGroup,
  slots: {
    formCheckbox: 'pb-1 last:pb-0'
  },
  variants: {
    isInline: {
      true: {
        formCheckbox: 'pr-4 pb-0'
      }
    }
  }
});

const formRadioGroup = tv({
  extend: baseGroup,
  slots: {
    formRadio: 'pb-1 last:pb-0'
  },
  variants: {
    isInline: {
      true: {
        formRadio: 'pr-4 pb-0'
      }
    }
  }
});

export { formCheckbox, formRadio, formCheckboxGroup, formRadioGroup };
