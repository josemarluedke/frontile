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

const { divider } = useStyles();

const Divider: TOC<{
  Args: {
    orientation?: 'horizontal' | 'vertical';
    as: string;
    class?: string;
  };
  Element: HTMLDivElement;
}> = <template>
  {{#let (element (getTag @orientation @as)) as |Tag|}}
    <Tag
      class={{(divider (hash class=@class))}} role="separator"
    >
    </Tag>
  {{/let}}
</template>

export default Divider;
