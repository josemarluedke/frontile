import type { TOC } from '@ember/component/template-only';

export interface Signature {
  Args: {
    /** The overlay component this cell opens. */
    name: string;
    /** What to try once it is open, in one clause. */
    note: string;
  };
  Blocks: {
    /** The live trigger. */
    default: [];
  };
}

/**
 * One cell of the overlay bench: a component name, a live trigger, and the
 * thing worth trying once it is open.
 *
 * Grouped by a top rule rather than boxed as a card. Three bordered cards in a
 * row would read as the icon-heading-text feature grid this page refuses, and
 * there is no elevation here to communicate — the cells are siblings on one
 * ground, which is exactly what a rule says and a card does not.
 */
const OverlayDoor: TOC<Signature> = <template>
  <div class="border-t border-neutral-soft pt-4">
    <p
      class="font-label text-label-2xs text-neutral-firm uppercase mb-3"
    >{{@name}}</p>
    {{yield}}
    <p
      class="mt-3 font-caption text-caption-sm text-neutral-firm"
    >{{@note}}</p>
  </div>
</template>;

export default OverlayDoor;
