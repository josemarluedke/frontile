import tailwindcss from '@tailwindcss/vite';
import { defineConfig } from 'vite';
import { extensions, classicEmberSupport, ember } from '@embroider/vite';
import { babel } from '@rollup/plugin-babel';
import docfy from '@docfy/ember-vite';

// Two builds from one config:
//
//   vite build                        -> dist/      browser bundle + shell
//   vite build --ssr app/ssr-entry.ts -> dist-ssr/   same app, for Node
//
// The Node build renders the HTML that the browser build rehydrates, so both
// must go through the same Ember/babel transform stack. Declaring the plugins
// once is what guarantees that: a stack that drifted would still build cleanly
// and only show up as a rehydration mismatch at runtime. Only genuinely
// environment-specific settings sit behind `isSsrBuild`.
export default defineConfig(({ isSsrBuild }) => ({
  // Vite does not read `PORT` on its own. Honouring it lets a caller assign a
  // free port instead of hardcoding one, which is what keeps several git
  // worktrees from fighting over the same number. Unset falls back to Vite's
  // own default.
  server: process.env.PORT ? { port: Number(process.env.PORT) } : {},
  plugins: [
    docfy(
      /** @type {import('@docfy/ember-vite').DocfyViteOptions} */
      {
        root: process.cwd(),
        hmr: !isSsrBuild,
        // The Markdown mirrors and llms.txt belong to dist/, which the client
        // build owns.
        ...(isSsrBuild
          ? {}
          : {
              staticExport: {
                enabled: true,
                projectName: 'Frontile',
                projectDescription:
                  'A modern, accessible, and extensible component library for Ember.js applications, built with Tailwind CSS and Tailwind Variants.',
              },
            }),
      },
    ),

    // Nothing serves CSS out of the Node bundle.
    ...(isSsrBuild ? [] : [tailwindcss()]),
    classicEmberSupport(),
    ember(),
    babel({
      babelHelpers: 'runtime',
      extensions,
    }),
  ],

  ...(isSsrBuild
    ? {
        build: {
          outDir: 'dist-ssr',
          emptyOutDir: true,
          copyPublicDir: false,
          minify: false,
          target: 'node22',
        },
        ssr: {
          // Inline every dependency. The entry is loaded by ssr/prerender.mjs as
          // a plain file, so nothing is left to resolve Ember's virtual modules
          // at runtime.
          noExternal: true,
        },
      }
    : {
        build: {
          // ssr/prerender.mjs reads this to work out which lazy route chunks a
          // page needs, so each prerendered page can preload its own.
          manifest: true,
        },
      }),
}));
