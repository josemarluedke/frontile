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
    }),
    {
      name: 'debug-log-resolve-config',
      configResolved(config) {
        // eslint-disable-next-line no-console
        console.log(
          'DEBUG_VITE_CONFIG',
          JSON.stringify({
            mode: config.mode,
            command: config.command,
            conditions: config.resolve?.conditions,
            resolveMainFields: config.resolve?.mainFields,
            NODE_ENV: process.env.NODE_ENV,
            EMBER_ENV: process.env.EMBER_ENV
          })
        );
      }
    }
  ]
});
