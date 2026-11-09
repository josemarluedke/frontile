import type { TOC } from '@ember/component/template-only';
import LayoutRegion from './layout-region';

interface LayoutAsideSignature {
  Args: {
    /**
     * The region the layout's `Aside @region` reads.
     *
     * @defaultValue 'aside'
     */
    region?: string;
  };
  Blocks: { default: [] };
}

/**
 * PROTOTYPE. Fills the layout's route-driven `Aside` from a route template.
 * While no `LayoutAside` is rendered, the aside column and `AsideToggle`
 * disappear.
 */
const LayoutAside: TOC<LayoutAsideSignature> = <template>
  <LayoutRegion @name={{if @region @region "aside"}}>{{yield}}</LayoutRegion>
</template>;

export { LayoutAside, type LayoutAsideSignature };
export default LayoutAside;
