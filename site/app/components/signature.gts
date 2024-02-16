import Component from '@glimmer/component';
import data, { type ComponentDoc } from './signature-data';

interface SignatureSignature {
  Args: {
    /**
     * The component name
     */
    component: string;
    /**
     * package name
     */
    package: string;

    /**
     * module, usually the folder name or the file name
     */
    module: string;
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
      return component.name == this.args.component;
    })[0];
  }

  <template>
    <div class="prose dark:prose-light mt-8 overflow-x-scroll" ...attributes>
      <table class="text-sm">
        <thead>
          <tr>
            <th>
              Arg
            </th>
            <th>
              Type
            </th>
            <th>
              Description
            </th>
            <th>
              Required
            </th>
            <th>
              Default
            </th>
          </tr>
        </thead>

        <tbody>
          {{#each this.component.Args as |arg|}}
            {{#unless (shouldIgnoreTag arg.tags)}}
              <tr>
                <td>
                  <code class="hljs-light-theme code-transparent">
                    <span class="hljs-name">
                      {{arg.identifier}}
                    </span>
                  </code>
                </td>
                <td>
                  <code class="hljs-light-theme code-transparent">
                    {{! template-lint-disable  }}
                    {{{arg.type.type}}}
                    {{! template-lint-enable }}
                  </code>
                </td>
                <td>
                  {{arg.description}}
                </td>
                <td>
                  {{#if arg.isRequired}}
                    Yes
                  {{else}}
                    -
                  {{/if}}
                </td>
                <td>
                  {{#if arg.defaultValue}}
                    <code class="hljs-light-theme code-transparent">
                      {{! template-lint-disable  }}
                      {{{arg.defaultValue}}}
                      {{! template-lint-enable }}
                    </code>
                  {{else}}
                    -
                  {{/if}}
                </td>
              </tr>
            {{/unless}}
          {{/each}}
        </tbody>
      </table>
    </div>
  </template>
}
