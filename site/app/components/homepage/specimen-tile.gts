import type { TOC } from '@ember/component/template-only';
import DocsLink from '../docs-link';

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
 *
 * The hover shadow is tinted rather than black: a neutral drop shadow on a
 * teal-washed ground reads as dirt, and `primary-soft` is translucent teal, so
 * the cast picks up the accent and stays correct in both schemes.
 */
/** Two columns and two rows, for a specimen that needs the room. Named rather
    than inline: `lint:hbs` wants double quotes inside a mustache and Prettier
    wants single, so the literal cannot satisfy both. */
const wideSpan = 'sm:col-span-2 sm:row-span-2';

const SpecimenTile: TOC<Signature> = <template>
  <div
    class="relative flex flex-col overflow-hidden rounded-xl border border-neutral-soft bg-surface-app reveal [animation-range:entry_2%_cover_22%] transition-[border-color,box-shadow,translate,scale] duration-[260ms] ease-settle hover:border-primary-mild hover:-translate-y-[3px] hover:[box-shadow:0_12px_24px_-14px_var(--color-primary-soft),0_2px_6px_-4px_var(--color-surface-overlay-soft)] active:-translate-y-px active:scale-[0.995] active:duration-[90ms] has-[a:focus-visible]:outline-2 has-[a:focus-visible]:outline-primary has-[a:focus-visible]:outline-offset-2 motion-reduce:transition-none motion-reduce:hover:translate-y-0 motion-reduce:active:translate-y-0 motion-reduce:active:scale-100
      {{if @isWide wideSpan}}"
  >
    {{! The name is carried by the link's own text rather than an aria-label:
        with both, the label wins and the span is unreachable markup. }}
    <DocsLink @to={{@path}} class="absolute inset-0 z-1 rounded-[inherit]"><span
        class="sr-only"
      >{{@name}} documentation</span></DocsLink>

    <span
      class="flex flex-auto items-center justify-center overflow-hidden p-5"
      aria-hidden="true"
      inert
    >
      {{yield}}
    </span>

    <span
      class="flex flex-col gap-0.5 border-t border-neutral-soft bg-surface-canvas px-[1.125rem] pt-3.5 pb-4"
    >
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
