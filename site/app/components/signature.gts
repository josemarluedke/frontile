import Component from '@glimmer/component';
import data, { type ComponentDoc } from './signature-data';
import { Popover } from 'frontile';
import type { TOC } from '@ember/component/template-only';

interface SignatureSignature {
  Args: {
    /**
     * The component name
     */
    component: string;
    /**
     * package name
     */
    package?: string;

    /**
     * module, usually the folder name or the file name
     */
    module?: string;
  };
  Element: HTMLDivElement;
}

function shouldIgnoreTag(tags?: Record<string, unknown>): boolean {
  if (tags && Object.keys(tags).includes('ignore')) {
    return true;
  }
  return false;
}

export default class Signature extends Component<SignatureSignature> {
  get component(): ComponentDoc | undefined {
    return data.filter((component) => {
      // implement fintering  component by 3 options all at the same time if all params are present (package, module and component). component is required.
      return (
        component.name === this.args.component &&
        (!this.args.package || component.package === this.args.package) &&
        (!this.args.module || component.module === this.args.module)
      );
    })[0];
  }

  <template>
    <h3>
      {{this.component.name}}
    </h3>

    {{#if this.component.Element}}
      <p>
        Element:
        <a
          href={{this.component.Element.url}}
          target="_blank"
        >{{this.component.Element.type.type}}</a>
      </p>
    {{/if}}

    {{#if this.component.description}}
      <p>{{this.component.description}}</p>
    {{/if}}

    <h4>
      Arguments
    </h4>

    <PropertiesTable @items={{this.component.Args}} />

    {{#if this.component.Blocks}}
      <h4 class="mt-4">
        Blocks
      </h4>

      <PropertiesTable @items={{this.component.Blocks}} />
    {{/if}}
  </template>
}

const PropertiesTable: TOC<{
  Element: HTMLDivElement;
  Args: {
    items?: ComponentDoc['Args'];
  };
}> = <template>
  <div
    class="prose max-w-none dark:prose-invert mt-8 overflow-x-scroll hljs-light-theme"
    ...attributes
  >
    <table class="text-sm">
      <thead>
        <tr>
          <th>
            Name
          </th>
          <th>
            Type
          </th>
          <th>
            Default
          </th>
          <th>
            Description
          </th>
        </tr>
      </thead>
      <tbody>
        {{#each @items as |arg|}}
          {{#unless (shouldIgnoreTag arg.tags)}}
            <tr>
              <td class="">
                <code class="code-transparent">
                  <span class="hljs-name">
                    {{arg.identifier}}
                  </span>
                </code>
                {{#if arg.isRequired}}
                  <span class="text-danger pl-2">
                    *
                  </span>
                {{/if}}
                {{#if arg.isInternal}}
                  <Popover as |pop|>
                    <button
                      class="ml-1 hover:bg-default-200 rounded-full"
                      {{pop.trigger "hover"}}
                      {{pop.anchor}}
                    >
                      <InfoIcon />
                    </button>

                    <pop.Content
                      @closeOnOutsideClick={{false}}
                      @size="lg"
                      @class="p-4"
                    >
                      This option is used internally when yielding components
                    </pop.Content>
                  </Popover>
                {{/if}}
              </td>
              <td class="flex items-center">
                <code class="code-transparent">
                  {{! template-lint-disable  }}
                  {{{arg.type.type}}}
                  {{! template-lint-enable }}
                </code>

                {{#if arg.type.raw}}
                  <Popover as |pop|>
                    <button
                      class="ml-1 hover:bg-default-200 rounded-full"
                      {{pop.trigger "hover"}}
                      {{pop.anchor}}
                    >
                      <InfoIcon />
                    </button>

                    <pop.Content
                      @closeOnOutsideClick={{false}}
                      @size="lg"
                      @class="p-4 hljs-light-theme"
                    >
                      <code class="code-transparent">
                        {{! template-lint-disable  }}
                        {{{arg.type.raw}}}
                        {{! template-lint-enable }}
                      </code>
                    </pop.Content>
                  </Popover>
                {{/if}}
              </td>
              <td>
                {{#if arg.defaultValue}}
                  <code class="code-transparent">
                    {{! template-lint-disable  }}
                    {{{arg.defaultValue}}}
                    {{! template-lint-enable }}
                  </code>
                {{else}}
                  -
                {{/if}}
              </td>

              <td>
                {{arg.description}}
              </td>
            </tr>
          {{/unless}}
        {{/each}}
      </tbody>
    </table>
  </div>
</template>;

const InfoIcon = <template>
  <svg
    xmlns="http://www.w3.org/2000/svg"
    fill="none"
    viewBox="0 0 25 25"
    stroke-width="1.5"
    stroke="currentColor"
    class="w-5 h-5"
  >
    <path
      stroke-linecap="round"
      stroke-linejoin="round"
      d="m11.25 11.25.041-.02a.75.75 0 0 1 1.063.852l-.708 2.836a.75.75 0 0 0 1.063.853l.041-.021M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9-3.75h.008v.008H12V8.25Z"
    />
  </svg>
</template>;
