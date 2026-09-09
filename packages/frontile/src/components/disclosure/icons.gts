/**
 * Icon components used in the disclosure components.
 */
import type { TOC } from '@ember/component/template-only';

interface IconSignature {
  Element: SVGElement;
}

export const ChevronDownIcon: TOC<IconSignature> = <template>
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
      d="m19.5 8.25-7.5 7.5-7.5-7.5"
    />
  </svg>
</template>;
