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
    class="p-8 bg-surface-card rounded-xl shadow-lg border border-neutral-subtle hover:border-brand-subtle transition-colors duration-300"
  >
    <h3 class="text-xl font-bold text-neutral-strong mb-6">{{@title}}</h3>
    {{#if @description}}
      <p class="text-neutral-firm mb-6">{{@description}}</p>
    {{/if}}
    <div>
      {{yield}}
    </div>
  </div>
</template>;

export default ComponentDemoCard;
