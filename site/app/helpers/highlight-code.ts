import { helper } from '@ember/component/helper';
import { htmlSafe } from '@ember/template';
import type { SafeString } from '@ember/template';
// @ts-ignore: missing types
import lowlight from 'lowlight';

interface HighlightCodeSignature {
  Args: {
    Positional: [code: string, language?: string];
  };
  Return: SafeString;
}

// HAST node types for lowlight
interface HastText {
  type: 'text';
  value: string;
}

interface HastElement {
  type: 'element';
  tagName: string;
  properties?: {
    className?: string[];
  };
  children?: HastNode[];
}

interface HastRoot {
  type: 'root';
  children: HastNode[];
}

interface HastLowlightResult {
  value: HastNode[];
}

type HastNode = HastText | HastElement | HastRoot | HastLowlightResult;

// Map gjs/gts to their base languages
const languageMap: Record<string, string> = {
  gjs: 'javascript',
  gts: 'typescript',
};

// Simple HAST to HTML converter for lowlight results
function hastToHtml(node: HastNode): string {
  // Handle lowlight result format which has a 'value' array at the root
  if ('value' in node && Array.isArray(node.value)) {
    return node.value.map(hastToHtml).join('');
  }

  // Handle text nodes
  if ('type' in node && node.type === 'text') {
    return escapeHtml(node.value);
  }

  // Handle element nodes
  if ('type' in node && node.type === 'element') {
    const className = node.properties?.className
      ? ` class="${node.properties.className.join(' ')}"`
      : '';
    const children = node.children?.map(hastToHtml).join('') || '';
    return `<${node.tagName}${className}>${children}</${node.tagName}>`;
  }

  // Handle root nodes
  if ('type' in node && node.type === 'root') {
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

    // Map gjs/gts to their base languages
    const actualLanguage = languageMap[language] || language;
    const result = lowlight.highlight(actualLanguage, code);
    const html = hastToHtml(result);

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
