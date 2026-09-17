import Component from '@glimmer/component';
import { htmlSafe } from '@ember/template';
import data, { type ComponentDoc } from './signature-data';
import { Chip, Popover } from 'frontile';
import type { TOC } from '@ember/component/template-only';
import IconInfo from '~icons/lucide/info';

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

function isDeprecated(tags?: Record<string, unknown>): boolean {
  return Boolean(tags && Object.keys(tags).includes('deprecated'));
}

// A `@deprecated` tag's value carries the migration instruction, and for most
// deprecated arguments it is the *only* documentation they have: when the whole
// JSDoc body is the tag, `description` comes back empty. Rendering just the
// tag's presence would drop the one sentence saying what to use instead.
//
// Unlike descriptions, tag values are raw JSDoc text rather than rendered HTML,
// so this returns a plain string — deliberately not `htmlSafe`.
//
// Mirrors `formatDeprecation` in site/lib/docfy-plugin-signature-markdown.mjs,
// which does the same for the exported Markdown. The two must agree.
function deprecationMessage(tags?: Record<string, unknown>): string {
  const tag = tags?.['deprecated'];

  if (!tag) {
    return '';
  }

  const value =
    typeof tag === 'object' && tag !== null && 'value' in tag
      ? (tag as { value?: unknown }).value
      : tag;

  return typeof value === 'string' ? value : '';
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
          rel="noopener noreferrer"
        >{{! The type carries the generator's syntax-highlighting spans, exactly
             like the argument types below, so it renders as HTML rather than
             being escaped into visible markup. }}{{{this.component.Element.type.type}}}</a>
      </p>
    {{/if}}

    {{#if this.component.description}}
      <div>{{htmlSafe this.component.description}}</div>
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

// Exported so the rendering test can mount the table directly with a fixture,
// rather than going through <Signature> and the real generated data.
export const PropertiesTable: TOC<{
  Element: HTMLDivElement;
  Args: {
    items?: ComponentDoc['Args'];
  };
}> = <template>
  <div
    class="prose max-w-none dark:prose-invert mt-8 overflow-x-scroll"
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
                  {{! The argument's own name is not highlighter output — it is
                      an identifier, styled the way the site styles inline code
                      identifiers everywhere else. }}
                  <span class="text-primary-firm">
                    {{arg.identifier}}
                  </span>
                </code>
                {{#if arg.isRequired}}
                  <span class="text-danger pl-2">
                    *
                  </span>
                {{/if}}
                {{#if (isDeprecated arg.tags)}}
                  <Chip
                    @color="warning"
                    @variant="soft"
                    @size="sm"
                    class="ml-2 align-middle"
                  >
                    Deprecated
                  </Chip>
                {{/if}}
                {{#if arg.isInternal}}
                  <Popover as |pop|>
                    <button
                      class="ml-1 hover:bg-neutral-subtle rounded-full"
                      type="button"
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
                      class="ml-1 hover:bg-neutral-subtle rounded-full"
                      type="button"
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
                {{#if (isDeprecated arg.tags)}}
                  <p class="text-warning-firm">
                    <strong>Deprecated.</strong>
                    {{deprecationMessage arg.tags}}
                  </p>
                {{/if}}
                {{#if arg.description}}
                  {{htmlSafe arg.description}}
                {{/if}}
              </td>
            </tr>
          {{/unless}}
        {{/each}}
      </tbody>
    </table>
  </div>
</template>;

const InfoIcon: TOC<{ Element: SVGSVGElement }> = <template>
  <IconInfo class="w-5 h-5" ...attributes />
</template>;
