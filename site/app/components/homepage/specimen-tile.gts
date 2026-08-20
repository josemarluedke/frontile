import type { TOC } from '@ember/component/template-only';
import { DocfyLink } from '@docfy/ember';

export interface Signature {
  Args: {
    name: string;
    path: string;
    /** What this component does, in one clause. */
    note: string;
    /** Give a component that needs room two columns and two rows. */
    isWide?: boolean;
  };
  Blocks: {
    /** A rendered specimen of the component. Inert — the overlay link is the target. */
    default: [];
  };
}

/**
 * One cell of the specimen wall: a live component above its name, with the
 * whole card acting as a single link to its documentation.
 *
 * The link is an overlay (`position: absolute; inset: 0`) rather than a wrapper.
 * That matters: the specimens include real Buttons, Switches, Checkboxes and
 * inputs, and putting those inside an `<a>` is invalid HTML — an anchor may not
 * contain interactive content — regardless of `inert`. The overlay keeps the
 * markup valid, keeps the entire card clickable, and leaves exactly one tab
 * stop per tile.
 *
 * The specimen itself is `inert` and `aria-hidden`, so its controls cannot take
 * focus or clicks and are not announced twice; the operable demos live in their
 * own sections and in the docs.
 */
const SpecimenTile: TOC<Signature> = <template>
  <div class="specimen-tile {{if @isWide 'specimen-tile--wide'}}">
    <DocfyLink
      @to={{@path}}
      class="specimen-tile__link"
      aria-label="{{@name}} documentation"
    ><span class="sr-only">{{@name}} documentation</span></DocfyLink>

    <span class="specimen-tile__stage" aria-hidden="true" inert>
      {{yield}}
    </span>

    <span class="specimen-tile__meta">
      <span
        class="font-header text-header-sm text-neutral-strong"
      >{{@name}}</span>
      <span
        class="font-caption text-caption-sm text-neutral-firm"
      >{{@note}}</span>
    </span>
  </div>
</template>;

export default SpecimenTile;
