import tailwindcss from '@tailwindcss/vite';
import { defineConfig } from 'vite';
import { extensions, classicEmberSupport, ember } from '@embroider/vite';
import { babel } from '@rollup/plugin-babel';
import docfy from '@docfy/ember-vite';

// One config for both builds. The client bundle and the Node bundle that
// *generates* the prerendered HTML have to be compiled by the same Ember/babel
// transform stack — if they drift, the markup the server serializes no longer
// matches what the client rehydrates, and both builds still succeed. So the
// shared plugins are declared once and only the genuinely divergent bits sit
// behind `isSsrBuild`.
export default defineConfig(({ isSsrBuild }) => ({
  plugins: [
    docfy(
      /** @type {import('@docfy/ember-vite').DocfyViteOptions} */
      {
        root: process.cwd(),
        hmr: !isSsrBuild,
        // Emitting the Markdown mirrors and llms.txt is the client build's job;
        // doing it twice would just rewrite the same files.
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

    // No stylesheet is served from the Node bundle.
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
          // Bundle everything, so the Node entry has no bare-specifier
          // resolution to do against Ember's virtual modules.
          noExternal: true,
        },
      }
    : {}),
}));
