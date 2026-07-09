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
  <div
    class="p-6
      {{@gradient}}
      rounded-lg border
      {{@borderColor}}
      hover:shadow-md transition-all duration-200"
  >
    <div class="flex items-center mb-3">
      {{yield to="icon"}}
      <h3 class="font-header text-header-md text-neutral-strong">{{@name}}</h3>
      <span
        class="ml-auto font-header text-strong-sm {{@countColor}}"
      >{{@count}}</span>
    </div>
    <p class="font-body text-body-2xs text-neutral-bolder">
      {{@description}}
    </p>
  </div>
</template>;

export default ComponentPackageCard;
