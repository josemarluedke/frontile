import type { TOC } from '@ember/component/template-only';
import highlightCode from 'site/helpers/highlight-code';

export interface Signature {
  Args: {
    code: string;
    language?: string;
  };
}

const CodeBlock: TOC<Signature> = <template>
  <div class="bg-neutral-strong dark:bg-black rounded-lg p-4 sm:p-6">
    <pre class="text-sm font-mono overflow-x-auto">{{highlightCode
        @code
        @language
      }}</pre>
  </div>
</template>;

export default CodeBlock;
