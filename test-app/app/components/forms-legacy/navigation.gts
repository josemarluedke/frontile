import { LinkTo } from '@ember/routing';
import type { TOC } from '@ember/component/template-only';

const Navigation: TOC<{ Element: HTMLDivElement }> = <template>
  <div class="flex flex-col mb-6 -mt-4" ...attributes>
    <div class="flex overflow-x-auto whitespace-nowrap">
      <LinkTo
        @route="forms-legacy.index"
        @activeClass="border-brand-medium"
        class="px-2 py-2 border-b-4 border-transparent"
      >
        Forms
      </LinkTo>
      <LinkTo
        @route="forms-legacy.style-variants"
        @activeClass="border-brand-medium"
        class="px-2 py-2 border-b-4 border-transparent"
      >
        Style Variants
      </LinkTo>
    </div>
  </div>
</template>;

export default Navigation;
