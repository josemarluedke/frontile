import { LinkTo } from '@ember/routing';
import type { TOC } from '@ember/component/template-only';

const Navigation: TOC<{ Element: HTMLDivElement }> = <template>
  <div class="flex flex-col mb-6 -mt-4" ...attributes>
    <div class="flex overflow-x-auto whitespace-nowrap">
      <LinkTo
        @route="forms.index"
        @activeClass="border-primary"
        class="px-2 py-2 border-b-4 border-transparent"
      >
        Forms
      </LinkTo>
      <LinkTo
        @route="forms.style-variants"
        @activeClass="border-primary"
        class="px-2 py-2 border-b-4 border-transparent"
      >
        Style Variants
      </LinkTo>
    </div>
  </div>
</template>;

export default Navigation;
