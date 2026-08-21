import type { TOC } from '@ember/component/template-only';
import { LinkTo } from '@ember/routing';
import { DocfyLink } from '@docfy/ember';
import { Button, type ButtonArgs } from 'frontile';

export interface Signature {
  Args: {
    /** A Docfy path, e.g. "/docs/theming/overview". */
    to?: string;
    /** An Ember route name, e.g. "docs.get-started". */
    route?: string;
    /** An external URL; opens in a new tab. */
    href?: string;
    intent?: ButtonArgs['intent'];
    appearance?: ButtonArgs['appearance'];
    size?: ButtonArgs['size'];
  };
  Blocks: { default: [] };
}

/**
 * A navigation control that looks like a Button but *is* a link.
 *
 * Wrapping `<Button>` in a link renders a `<button>` inside an `<a>`: invalid
 * HTML, two tab stops, and — because the inner button has no `@onPress` —
 * Enter and Space do nothing on the element that has focus. Screen readers
 * announce "link, button".
 *
 * `@isRenderless` is Frontile's escape hatch for exactly this: it yields the
 * computed class names instead of rendering the button element, so the anchor
 * carries the styling and remains the only interactive node.
 */
const LinkButton: TOC<Signature> = <template>
  <Button
    @isRenderless={{true}}
    @intent={{@intent}}
    @appearance={{@appearance}}
    @size={{@size}}
    as |b|
  >
    {{#if @route}}
      <LinkTo @route={{@route}} class={{b.classNames}}>{{yield}}</LinkTo>
    {{else if @to}}
      <DocfyLink @to={{@to}} class={{b.classNames}}>{{yield}}</DocfyLink>
    {{else}}
      <a
        href={{@href}}
        class={{b.classNames}}
        target="_blank"
        rel="noopener noreferrer"
      >{{yield}}</a>
    {{/if}}
  </Button>
</template>;

export default LinkButton;
