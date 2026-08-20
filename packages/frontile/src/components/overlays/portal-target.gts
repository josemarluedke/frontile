import type { TOC } from '@ember/component/template-only';

const PortalTarget: TOC<{
  Args: {
    /**
     * Name of this target, matched against a `Portal`'s `@target` argument.
     *
     * When omitted, the target is unnamed: any `Portal` rendered below it that
     * has no `@target` and no parent portal will render here. A named target is
     * only used by portals that ask for it by name.
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
