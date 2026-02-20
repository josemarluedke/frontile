import type { TOC } from '@ember/component/template-only';

const VisuallyHidden: TOC<{
  Element: HTMLDivElement;
  Blocks: {
    default: [];
  };
}> = <template>
  <div class="sr-only" ...attributes>
    {{yield}}
  </div>
</template>;

export { VisuallyHidden };
export default VisuallyHidden;
