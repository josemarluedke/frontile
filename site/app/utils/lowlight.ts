// lowlight's `all` export registers every one of highlight.js's ~190 grammars —
// over a megabyte of source in whatever bundle imports it. The only runtime
// consumer is the homepage's code panel (docs pages are highlighted at build
// time by rehype-highlight), so handing `createLowlight` just the languages the
// site actually renders keeps that weight out of the bundle every visitor
// downloads.
import { createLowlight } from 'lowlight';
import { glimmer, glimmerJavascript } from 'highlightjs-glimmer';
import bash from 'highlight.js/lib/languages/bash';
import css from 'highlight.js/lib/languages/css';
import javascript from 'highlight.js/lib/languages/javascript';
import json from 'highlight.js/lib/languages/json';
import shell from 'highlight.js/lib/languages/shell';
import typescript from 'highlight.js/lib/languages/typescript';
import xml from 'highlight.js/lib/languages/xml';
import type { HLJSApi, LanguageFn } from 'highlight.js';

// highlightjs-glimmer's own types declare `glimmer` but not `glimmerJavascript`.
declare module 'highlightjs-glimmer' {
  export function glimmerJavascript(
    hljs: HLJSApi,
    jsLanguageName?: string
  ): ReturnType<LanguageFn>;
}

// gts is gjs with TypeScript inside; the grammar takes the sublanguage to
// delegate to as its second argument. Same wrapper as docfy.config.mjs uses,
// so the homepage panel and the docs pages tokenize Glimmer identically.
function glimmerTypescript(hljs: HLJSApi) {
  return {
    ...glimmerJavascript(hljs, 'typescript'),
    name: 'glimmer-typescript',
    aliases: ['glimmer-ts', 'gts'],
  };
}

// Order matters: the glimmer-* grammars resolve their sublanguage at
// registration time, so javascript and typescript have to land first.
const lowlight = createLowlight({
  bash,
  css,
  javascript,
  json,
  shell,
  typescript,
  xml,
  glimmer,
  'glimmer-javascript': glimmerJavascript,
  'glimmer-typescript': glimmerTypescript,
});

// highlight.js registers each grammar's own aliases (js, ts, sh, html, hbs,
// gjs, gts …); `handlebars` is the only name the site uses that no grammar
// claims for itself.
lowlight.registerAlias({ glimmer: ['handlebars'] });

export default lowlight;
