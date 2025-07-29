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

class Label extends Component<{ Args: { label: unknown } }> {
  get intent() {
    if (typeof this.args.label !== 'string') {
      return 'default';
    }

    if (this.args.label.toLowerCase() == 'new') {
      return 'primary';
    } else if (this.args.label.toLowerCase() == 'updated') {
      return 'success';
    } else if (this.args.label.toLowerCase() == 'deprecated') {
      return 'danger';
    } else {
      return 'default';
    }
  }

  get label() {
    return typeof this.args.label === 'string' ? this.args.label : '';
  }

  <template>
    <Chip
      @size="sm"
      @appearance="outlined"
      @intent={{this.intent}}
      @class="ml-1"
    >
      {{this.label}}
    </Chip>
  </template>
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
              class="transition pl-2 py-1 hover:text-primary-950 text-sm block rounded hover:bg-primary-50 outline-none focus-visible:ring ring-inset"
              @activeClass="text-foreground"
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
                    class="transition pl-6 py-1 hover:text-primary-950 text-sm block rounded hover:bg-primary-50 outline-none focus-visible:ring ring-inset"
                    @activeClass="text-foreground d bg-primary-50"
                  >
                    {{page.title}}
                    {{#if page.frontmatter.label}}
                      <Label @label={{page.frontmatter.label}} />
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
                          class="transition pl-10 py-1 hover:text-primary-950 text-sm block rounded hover:bg-primary-50 outline-none focus-visible:ring ring-inset"
                          @activeClass="text-foreground bg-primary-50"
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
