import type { TOC } from '@ember/component/template-only';

const IconChevronUpDown: TOC<{
  Element: SVGElement;
}> = <template>
  <svg
    xmlns="http://www.w3.org/2000/svg"
    fill="none"
    viewBox="0 0 24 24"
    stroke-width="1.5"
    stroke="currentColor"
    aria-hidden="true"
    ...attributes
  >
    <path
      stroke-linecap="round"
      stroke-linejoin="round"
      d="M8.25 15 12 18.75 15.75 15m-7.5-6L12 5.25 15.75 9"
    />
  </svg>
</template>;

const IconCalendar: TOC<{
  Element: SVGElement;
}> = <template>
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="1.5"
    aria-hidden="true"
    ...attributes
  >
    <path
      stroke-linecap="round"
      stroke-linejoin="round"
      d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0V11.25A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5"
    />
  </svg>
</template>;

export { IconChevronUpDown, IconCalendar };

<template>
  @frontile/froms Icons component is empty, use template imports.
</template>
