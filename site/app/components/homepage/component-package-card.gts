import type { TOC } from '@ember/component/template-only';

export interface Signature {
  Args: {
    name: string;
    count: number;
    description: string;
    gradient: string;
    borderColor: string;
    countColor: string;
  };
  Blocks: {
    icon: [];
  };
}

const ComponentPackageCard: TOC<Signature> = <template>
  <div class="p-6 {{@gradient}} rounded-lg border {{@borderColor}}">
    <div class="flex items-center mb-3">
      {{yield to="icon"}}
      <h3 class="font-bold text-default-900">{{@name}}</h3>
      <span
        class="ml-auto text-sm font-semibold {{@countColor}}"
      >{{@count}}</span>
    </div>
    <p class="text-sm text-default-700">
      {{@description}}
    </p>
  </div>
</template>;

export default ComponentPackageCard;
