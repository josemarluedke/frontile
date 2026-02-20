import { babel } from '@rollup/plugin-babel';
import copy from 'rollup-plugin-copy';
import { Addon } from '@embroider/addon-dev/rollup';
import { nodeResolve } from '@rollup/plugin-node-resolve';

const extensions = ['.js', '.gjs', '.ts', '.gts'];

const addon = new Addon({
  srcDir: 'src',
  destDir: 'dist',
});

export default {
  output: addon.output(),

  plugins: [
    addon.publicEntrypoints([
      'components/**/*.js',
      'index.js',
      'template-registry.js'
    ]),

    addon.appReexports([
      'components/**/*.js',
    ]),

    addon.dependencies(),

    nodeResolve({ extensions }),

    babel({
      extensions,
      babelHelpers: 'bundled',
    }),

    addon.hbs(),
    addon.gjs(),
    addon.declarations('declarations'),
    addon.keepAssets(['**/*.css']),
    addon.clean(),

    copy({
      targets: [
        { src: '../README.md', dest: '.' },
        { src: '../LICENSE.md', dest: '.' },
      ],
    }),
  ],
};
