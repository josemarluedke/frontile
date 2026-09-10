/**
 * Icon components used by the Pagination component. Heroicons outline, 24px
 * grid, `currentColor` stroke — the same source and settings as the table's.
 */
import type { TOC } from '@ember/component/template-only';

interface IconSignature {
  Element: SVGElement;
}

export const ChevronLeftIcon: TOC<IconSignature> = <template>
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
      d="M15.75 19.5 8.25 12l7.5-7.5"
    />
  </svg>
</template>;

export const ChevronRightIcon: TOC<IconSignature> = <template>
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
      d="m8.25 4.5 7.5 7.5-7.5 7.5"
    />
  </svg>
</template>;

export const ChevronDoubleLeftIcon: TOC<IconSignature> = <template>
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
      d="m18.75 4.5-7.5 7.5 7.5 7.5m-6-15L5.25 12l7.5 7.5"
    />
  </svg>
</template>;

export const ChevronDoubleRightIcon: TOC<IconSignature> = <template>
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
      d="m5.25 4.5 7.5 7.5-7.5 7.5m6-15 7.5 7.5-7.5 7.5"
    />
  </svg>
</template>;
