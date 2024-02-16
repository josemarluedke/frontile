import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import DocfyLink from '@docfy/ember/components/docfy-link';
import type { NestedPageMetadata } from '@docfy/core/lib/types';
import { Chip } from '@frontile/buttons';

interface Signature {
  Args: {
    onSidebarClick: (event: MouseEvent) => void;
    node: NestedPageMetadata;
  };
  Element: HTMLDivElement;
}

export default class DocfySidebarNavContent extends Component<Signature> {
  <template>
    <div ...attributes>
      {{! template-lint-disable no-invalid-interactive }}
      <ul class="space-y-2" {{on "click" @onSidebarClick}}>
        {{! template-lint-enable no-invalid-interactive }}
        {{#each @node.pages as |page|}}
          <li>
            <DocfyLink
              @to={{page.url}}
              class="transition pl-2 py-1 hover:text-primary-800 text-sm block rounded hover:bg-primary-100 outline-none focus-visible:ring ring-inset"
              @activeClass="text-primary-800"
            >
              {{page.title}}
            </DocfyLink>
          </li>
        {{/each}}

        {{#each @node.children as |child|}}
          <li>
            <div class="pt-2 pl-2 pb-2 text-xs text-primary-700">
              {{child.label}}
            </div>

            <ul class="space-y-2">
              {{#each child.pages as |page|}}
                <li class="truncate">
                  <DocfyLink
                    @to={{page.url}}
                    class="transition pl-6 py-1 hover:text-primary-800 text-sm block rounded hover:bg-primary-100 outline-none focus-visible:ring ring-inset"
                    @activeClass="text-primary-800 d bg-primary-100 0"
                  >
                    {{page.title}}
                    {{#if page.frontmatter.label}}
                      <Chip
                        @size="sm"
                        @appearance="outlined"
                        @intent="primary"
                        @class="ml-1"
                      >
                        {{page.frontmatter.label}}
                      </Chip>
                    {{/if}}
                  </DocfyLink>
                </li>
              {{/each}}

              {{#each child.children as |subChild|}}
                <li>
                  <div class="pl-6 pt-2 pb-2 text-xs text-primary-700">
                    {{subChild.label}}
                  </div>

                  <ul class="space-y-2">
                    {{#each subChild.pages as |page|}}
                      <li class="truncate">
                        <DocfyLink
                          @to={{page.url}}
                          class="transition pl-10 py-1 hover:text-primary-800 text-sm block rounded hover:bg-primary-100 outline-none focus-visible:ring ring-inset"
                          @activeClass="text-primary-800 bg-primary-100 "
                        >
                          {{page.title}}
                        </DocfyLink>
                      </li>
                    {{/each}}
                  </ul>
                </li>
              {{/each}}
            </ul>
          </li>
        {{/each}}
      </ul>
    </div>
  </template>
}
