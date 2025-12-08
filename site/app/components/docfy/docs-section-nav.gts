import Component from '@glimmer/component';
import { DocfyOutput } from '@docfy/ember';
import DocfyLink from '@docfy/ember/components/docfy-link';
import type { NestedPageMetadata } from '@docfy/core/lib/types';

export default class DocsSectionNav extends Component {
  getFirstPageUrl = (section: NestedPageMetadata): string | null => {
    // If section has direct pages, use the first one
    if (section.pages && section.pages.length > 0) {
      return section.pages[0].url;
    }

    // If section has children, find first page in first child
    if (section.children && section.children.length > 0) {
      return this.getFirstPageUrl(section.children[0]);
    }

    return null;
  };

  <template>
    <DocfyOutput @scope="docs" as |node|>
      <nav class='border-b border-neutral-medium/20 mb-6 pt-6 -mx-4 px-4 lg:mx-0 lg:px-0 lg:mb-8 lg:pt-8'>
        <div class='flex gap-4 lg:gap-8 overflow-x-auto scrollbar-hide pb-px'>
          {{#each node.children as |child|}}
            {{#let (this.getFirstPageUrl child) as |url|}}
              {{#if url}}
                <DocfyLink
                  @to={{url}}
                  class='pb-2.5 lg:pb-3 text-xs lg:text-sm font-medium transition-colors text-neutral-soft hover:text-neutral-strong whitespace-nowrap'
                  @activeClass='text-brand-strong border-b-2 border-brand-strong'
                >
                  {{child.label}}
                </DocfyLink>
              {{/if}}
            {{/let}}
          {{/each}}
        </div>
      </nav>
    </DocfyOutput>
  </template>
}
