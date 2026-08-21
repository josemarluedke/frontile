// Builds the Ember app for the Node/SSR environment, consumed by ssr/prerender.mjs.
import { defineConfig } from 'vite';
import { extensions, classicEmberSupport, ember } from '@embroider/vite';
import { babel } from '@rollup/plugin-babel';
import docfy from '@docfy/ember-vite';

export default defineConfig({
  plugins: [
    docfy({ root: process.cwd(), hmr: false }),
    classicEmberSupport(),
    ember(),
    babel({ babelHelpers: 'runtime', extensions }),
  ],
  build: {
    ssr: 'app/ssr-entry.ts',
    outDir: 'dist-ssr',
    emptyOutDir: true,
    copyPublicDir: false,
    minify: false,
    target: 'node22',
  },
  ssr: {
    // Bundle everything so the Node entry has no bare-specifier resolution
    // problems against Ember's virtual modules.
    noExternal: true,
  },
});
