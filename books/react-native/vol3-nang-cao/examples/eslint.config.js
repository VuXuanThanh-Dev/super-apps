// https://docs.expo.dev/guides/using-eslint/
const { defineConfig } = require('eslint/config');
const expoConfig = require('eslint-config-expo/flat');

module.exports = defineConfig([
  expoConfig,
  {
    ignores: ['dist/*', '.export-web/*', '.export-ios/*', '.expo/*', 'node_modules/*'],
  },
  {
    // File thiết lập Jest dùng biến toàn cục `jest`.
    files: ['jest.setup.js'],
    languageOptions: { globals: { jest: 'readonly' } },
  },
]);
