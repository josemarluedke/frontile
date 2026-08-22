import { helper } from '@ember/component/helper';
import { htmlSafe } from '@ember/template';
import type { SafeString } from '@ember/template';
import lowlight from 'site/utils/lowlight';
import type { Root, RootContent } from 'hast';

interface HighlightCodeSignature {
  Args: {
    Positional: [code: string, language?: string];
  };
  Return: SafeString;
}

// Simple HAST to HTML converter for lowlight results
function hastToHtml(node: RootContent | Root): string {
  if (node.type === 'text') {
    return escapeHtml(node.value);
  }

  if (node.type === 'element') {
    const classNames = node.properties?.['className'];
    const className = Array.isArray(classNames)
      ? ` class="${classNames.join(' ')}"`
      : '';
    const children = node.children.map(hastToHtml).join('');
    return `<${node.tagName}${className}>${children}</${node.tagName}>`;
  }

  if (node.type === 'root') {
    return node.children.map(hastToHtml).join('');
  }

  return '';
}

function escapeHtml(text: string): string {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function highlightCode([code, language = 'javascript']: [
  string,
  string?,
]): SafeString {
  try {
    // Debug: Check if code is empty
    if (!code) {
      console.warn('highlightCode: code is empty or undefined');
      return htmlSafe(
        `<code class="hljs language-${language}">NO CODE PROVIDED</code>`
      );
    }

    // gjs/gts/hbs are aliases of the glimmer grammars; see site/utils/lowlight.
    const html = hastToHtml(lowlight.highlight(language, code));

    return htmlSafe(`<code class="hljs language-${language}">${html}</code>`);
  } catch (error) {
    // If language is not supported, return plain code
    console.error(
      `Language "${language}" not supported for syntax highlighting`,
      error
    );
    return htmlSafe(`<code>${escapeHtml(code || 'ERROR')}</code>`);
  }
}

export default helper<HighlightCodeSignature>(highlightCode);
