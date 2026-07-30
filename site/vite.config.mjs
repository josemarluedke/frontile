import tailwindcss from "@tailwindcss/vite";
import { defineConfig } from 'vite';
import { extensions, classicEmberSupport, ember } from '@embroider/vite';
import { babel } from '@rollup/plugin-babel';
import docfy from '@docfy/ember-vite';

export default defineConfig({
  plugins: [
    docfy(
      /** @type {import('@docfy/ember-vite').DocfyViteOptions} */
      {
        root: process.cwd(),
        hmr: true,
        staticExport: {
          enabled: true,
          projectName: 'Frontile',
          projectDescription:
            'A modern, accessible, and extensible component library for Ember.js applications, built with Tailwind CSS and Tailwind Variants.',
        },
      },
    ),

    tailwindcss(),
    classicEmberSupport(),
    ember(),
    babel({
      babelHelpers: 'runtime',
      extensions,
    }),
  ],
});
