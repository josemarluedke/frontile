import type { TOC } from '@ember/component/template-only';

export interface Signature {
  Args: {
    icon: string;
    iconColor: string;
    iconBg: string;
    title: string;
    description: string;
  };
  Blocks: {
    icon: [];
  };
}

const FeatureCard: TOC<Signature> = <template>
  <div
    class="p-8 bg-neutral-subtle rounded-xl shadow-lg border border-neutral-subtle hover:shadow-xl transition-shadow duration-200"
  >
    <div
      class="w-12 h-12
        {{@iconBg}}
        rounded-lg flex items-center justify-center mb-4"
    >
      {{yield to="icon"}}
    </div>
    <h3 class="text-xl font-bold text-neutral-strong mb-3">{{@title}}</h3>
    <p class="text-neutral-medium leading-relaxed">
      {{@description}}
    </p>
  </div>
</template>;

export default FeatureCard;
