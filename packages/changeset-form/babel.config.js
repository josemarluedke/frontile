module.exports = {
  presets: [
    [
      '@babel/preset-typescript',
      {
        onlyRemoveTypeImports: true,
        ignoreExtensions: true,
        allExtensions: true
      }
    ]
  ],
  plugins: [
    'ember-concurrency/async-arrow-task-transform',
    '@embroider/addon-dev/template-colocation-plugin',
    [
      'babel-plugin-ember-template-compilation',
      {
        targetFormat: 'hbs'
      }
    ],
    ['@babel/plugin-proposal-decorators', { legacy: true }],
    '@babel/plugin-proposal-class-properties',
    '@babel/plugin-transform-class-static-block'
  ]
};
