import { on } from '@ember/modifier';
import type { TOC } from '@ember/component/template-only';

export interface DrawerDragHandleSignature {
  Args: {
    /**
     * Called when the handle is activated by click, Enter or Space. The drag
     * gesture is attached separately by the Drawer; this is the keyboard and
     * assistive-technology route to the same outcome.
     */
    onPress?: () => void;

    /**
     * Accessible name for the handle.
     *
     * @defaultValue 'Close drawer'
     */
    label?: string;

    class?: string;

    /**
     * @internal
     */
    barClass?: string;
  };
  Element: HTMLButtonElement;
}

const handlePress = (onPress?: () => void) => {
  return () => onPress?.();
};

const DrawerDragHandle: TOC<DrawerDragHandleSignature> = <template>
  <button
    type="button"
    aria-label={{if @label @label "Close drawer"}}
    data-drawer-drag-handle
    class={{@class}}
    {{on "click" (handlePress @onPress)}}
    ...attributes
  >
    <span class={{@barClass}}></span>
  </button>
</template>;

export { DrawerDragHandle };
export default DrawerDragHandle;
