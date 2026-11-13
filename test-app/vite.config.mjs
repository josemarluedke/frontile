import { defineConfig } from 'vite';
import { extensions, classicEmberSupport, ember } from '@embroider/vite';
import { babel } from '@rollup/plugin-babel';
import tailwindcss from '@tailwindcss/vite';
import Icons from 'unplugin-icons/vite';

export default defineConfig({
  plugins: [
    classicEmberSupport(),
    ember(),
    tailwindcss(),
    Icons({ compiler: 'ember' }),
    babel({
      babelHelpers: 'runtime',
      extensions
    })
  ]
});
