import type { TOC } from '@ember/component/template-only';

export interface Signature {
  Args: {
    title: string;
    subtitle?: string;
    iconBg?: string;
  };
  Blocks: {
    icon?: [];
  };
}

const SectionHeader: TOC<Signature> = <template>
  <div class="text-center mb-16">
    {{#if (has-block "icon")}}
      <div
        class="inline-flex items-center justify-center w-16 h-16
          {{@iconBg}}
          rounded-full mb-6"
      >
        {{yield to="icon"}}
      </div>
    {{/if}}
    <h2 class="text-4xl sm:text-5xl font-bold text-default-900 mb-4">
      {{@title}}
    </h2>
    {{#if @subtitle}}
      <p class="text-xl text-default-600 max-w-3xl mx-auto">
        {{@subtitle}}
      </p>
    {{/if}}
  </div>
</template>;

export default SectionHeader;
