// The one place the site turns a code string into highlighted HTML outside of
// Docfy's markdown pipeline.
//
// It deliberately goes through `@docfy/plugin-shiki` rather than calling Shiki
// itself: the preset owns the theme pair, the CSS-variable output mode
// (`--shiki-light` / `--shiki-dark`, so light/dark switching needs no
// re-render), the `gjs`/`gts`/`hbs` aliases, and the 15 preloaded grammars.
// Reaching for `shiki` directly here would mean a second, silently divergent
// copy of all of that — the homepage panel and the API tables would drift away
// from the docs pages the first time either side was retuned.
//
// The preset is a rehype plugin, so the input is a synthetic
// `<pre><code class="language-x">` hast tree — exactly the shape a markdown
// fence produces by the time rehype sees it.
import { unified } from 'unified';
import rehypeStringify from 'rehype-stringify';
import shiki from '@docfy/plugin-shiki';

const [shikiRehypePlugin] = shiki();
const processor = unified().use(shikiRehypePlugin).use(rehypeStringify);

function fenceTree(code, language) {
  return {
    type: 'root',
    children: [
      {
        type: 'element',
        tagName: 'pre',
        properties: {},
        children: [
          {
            type: 'element',
            tagName: 'code',
            properties: { className: [`language-${language}`] },
            children: [{ type: 'text', value: code }],
          },
        ],
      },
    ],
  };
}

/** The `<pre class="shiki">` element the preset produced for `code`. */
function highlightToPre(code, language) {
  const result = processor.runSync(fenceTree(code, language));

  // The rehype plugin returns a fresh root, which unified nests under the one
  // it was given; walk down to the first element either way.
  const findPre = (node) =>
    node.type === 'element'
      ? node
      : node.children.map(findPre).find((found) => found);

  return findPre(result);
}

function stringify(children) {
  return processor.stringify({ type: 'root', children }).toString();
}

/**
 * A fragment for somewhere a `<pre>` would be wrong — a table cell, a
 * paragraph. Line wrappers are dropped and the tokens joined with newlines;
 * the `shiki` class has to survive on the wrapper because that is what the
 * site's stylesheet hangs the `--shiki-light`/`--shiki-dark` resolution on.
 */
export function highlightInline(code, language = 'ts') {
  const codeEl = highlightToPre(code, language).children[0];
  const lines = codeEl.children.filter((child) => child.type === 'element');
  const children = lines.flatMap((line, index) =>
    index === 0
      ? line.children
      : [{ type: 'text', value: '\n' }, ...line.children],
  );

  return `<span class="shiki">${stringify(children)}</span>`;
}

/**
 * The `<code>` for a block, for a component that draws its own `<pre>` chrome.
 * Keeps the per-line `<span class="line">` wrappers, so line numbers and
 * highlighted ranges would work here too.
 */
export function highlightBlock(code, language) {
  const pre = highlightToPre(code, language);
  const codeEl = pre.children[0];
  const resolvedLanguage = pre.properties['data-language'] ?? language;

  return `<code class="shiki" data-language="${resolvedLanguage}">${stringify(codeEl.children)}</code>`;
}
