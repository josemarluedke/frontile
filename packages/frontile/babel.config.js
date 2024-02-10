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
  plugins: []
};
