import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { element } from 'ember-element-helper';
import type { TOC } from '@ember/component/template-only';

function getTag(
  orientation: string | undefined,
  as?: string | undefined
): string {
  if (as) {
    return as;
  }

  if (orientation === 'vertical') {
    return 'div';
  }
  return 'hr';
}

// The separator role is horizontal by default, so only the vertical case needs
// stating. `<hr>` carries its orientation implicitly and needs neither.
function isVertical(orientation: string | undefined): boolean {
  return orientation === 'vertical';
}

const { divider } = useStyles();

const Divider: TOC<{
  Args: {
    /**
     * Which way the divider runs. A horizontal divider renders an `<hr>`; a
     * vertical one renders a `<div>`, since `<hr>` cannot express that.
     *
     * @defaultValue 'horizontal'
     */
    orientation?: 'horizontal' | 'vertical';

    /**
     * The tag to render instead of the one the orientation would choose — for
     * example `li` when the divider sits between list items.
     */
    as?: string;

    /**
     * Custom class name, it will override the default ones using Tailwind Merge
     * library.
     */
    class?: string;
  };
  Element: Element;
}> = <template>
  {{#let (element (getTag @orientation @as)) as |Tag|}}
    <Tag
      class={{divider (hash class=@class orientation=@orientation)}}
      role="separator"
      aria-orientation={{if (isVertical @orientation) "vertical"}}
      data-test-id="divider"
      ...attributes
    />
  {{/let}}
</template>;

export { Divider };
export default Divider;
