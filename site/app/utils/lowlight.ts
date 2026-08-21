// lowlight's default entry point registers every one of highlight.js's ~190
// grammars — 1.3 MB of source in whatever bundle imports it. The only runtime
// consumer is the homepage's code panel (docs pages are highlighted at build
// time by rehype-highlight), so registering just the languages the site
// actually renders keeps that weight out of the bundle every visitor
// downloads.
// @ts-expect-error: lowlight 1.x ships no types
import lowlightCore from 'lowlight/lib/core.js';
// @ts-expect-error: highlight.js 10.x ships no types for lib/languages/*
import bash from 'highlight.js/lib/languages/bash';
// @ts-expect-error: see above
import css from 'highlight.js/lib/languages/css';
// @ts-expect-error: see above
import handlebars from 'highlight.js/lib/languages/handlebars';
// @ts-expect-error: see above
import javascript from 'highlight.js/lib/languages/javascript';
// @ts-expect-error: see above
import json from 'highlight.js/lib/languages/json';
// @ts-expect-error: see above
import shell from 'highlight.js/lib/languages/shell';
// @ts-expect-error: see above
import typescript from 'highlight.js/lib/languages/typescript';
// @ts-expect-error: see above
import xml from 'highlight.js/lib/languages/xml';

interface Lowlight {
  highlight(language: string, value: string): unknown;
  registerLanguage(name: string, syntax: unknown): void;
  registerAlias(alias: string, name: string): void;
}

const low = lowlightCore as Lowlight;

low.registerLanguage('bash', bash);
low.registerLanguage('css', css);
// handlebars delegates to xml for the HTML around the mustaches.
low.registerLanguage('xml', xml);
low.registerLanguage('handlebars', handlebars);
low.registerLanguage('javascript', javascript);
low.registerLanguage('json', json);
low.registerLanguage('shell', shell);
low.registerLanguage('typescript', typescript);

low.registerAlias('html', 'xml');
low.registerAlias('hbs', 'handlebars');
low.registerAlias('js', 'javascript');
low.registerAlias('ts', 'typescript');
low.registerAlias('sh', 'shell');

export default low;
