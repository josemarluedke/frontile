import { defineConfig } from 'vite';
import { extensions, classicEmberSupport, ember } from '@embroider/vite';
import { babel } from '@rollup/plugin-babel';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  plugins: [
    classicEmberSupport(),
    ember(),
    tailwindcss(),
    babel({
      babelHelpers: 'runtime',
      extensions
    })
  ]
});
