import type { TOC } from '@ember/component/template-only';

export interface Signature {
  Args: {
    title: string;
    description?: string;
  };
  Blocks: {
    default: [];
  };
}

const ComponentDemoCard: TOC<Signature> = <template>
  <div
    class="p-8 bg-white dark:bg-black/20 rounded-xl shadow-lg border border-default-200"
  >
    <h3 class="text-xl font-bold text-default-900 mb-6">{{@title}}</h3>
    {{#if @description}}
      <p class="text-default-600 mb-6">{{@description}}</p>
    {{/if}}
    <div>
      {{yield}}
    </div>
  </div>
</template>;

export default ComponentDemoCard;
