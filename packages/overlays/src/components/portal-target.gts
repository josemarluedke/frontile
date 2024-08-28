import type { TOC } from '@ember/component/template-only';

const PortalTarget: TOC<{
  Args: {
    /**
     * Target name
     */
    for?: string;
  };
  Blocks: {
    default: [];
  };
  Element: HTMLElement;
}> = <template>
  <div ...attributes data-portal-target="true" data-portal-for={{@for}}>
    {{yield}}
  </div>
</template>;

export { PortalTarget };
export default PortalTarget;
