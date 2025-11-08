import { helper } from '@ember/component/helper';
import { htmlSafe } from '@ember/template';
import type { SafeString } from '@ember/template';
import lowlight from 'lowlight';

interface HighlightCodeSignature {
  Args: {
    Positional: [code: string, language?: string];
  };
  Return: SafeString;
}

// Map gjs/gts to their base languages
const languageMap: Record<string, string> = {
  gjs: 'javascript',
  gts: 'typescript',
};

// Simple HAST to HTML converter for lowlight results
function hastToHtml(node: any): string {
  // Handle lowlight result format which has a 'value' array at the root
  if (node.value && Array.isArray(node.value)) {
    return node.value.map(hastToHtml).join('');
  }

  // Handle text nodes
  if (node.type === 'text') {
    return escapeHtml(node.value);
  }

  // Handle element nodes
  if (node.type === 'element') {
    const className = node.properties?.className
      ? ` class="${node.properties.className.join(' ')}"`
      : '';
    const children = node.children?.map(hastToHtml).join('') || '';
    return `<${node.tagName}${className}>${children}</${node.tagName}>`;
  }

  // Handle root nodes
  if (node.type === 'root' && node.children) {
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
      return htmlSafe(`<code class="hljs language-${language}">NO CODE PROVIDED</code>`);
    }

    // Map gjs/gts to their base languages
    const actualLanguage = languageMap[language] || language;

    console.log('Highlighting code:', {
      codeLength: code.length,
      codeSample: code.substring(0, 50),
      language: actualLanguage
    });

    const result = lowlight.highlight(actualLanguage, code);
    console.log('Lowlight result:', JSON.stringify(result, null, 2).substring(0, 500));

    const html = hastToHtml(result);
    console.log('HTML output length:', html.length, 'Sample:', html.substring(0, 100));

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
