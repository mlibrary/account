const path = require('path');
const ESLintPlugin = require('eslint-webpack-plugin');

module.exports = {
  entry: {
    main: './js/index.js',
    currentCheckouts: './js/current-checkouts.js'
  },
  output: {
    filename: '[name].bundle.js',
    path: path.resolve(__dirname, 'public/bundles')
  },
  plugins: [new ESLintPlugin()]
};
