// Flat config from eslint-config-expo (the config `npx expo lint` generates).
const { defineConfig } = require('eslint/config');
const expoConfig = require('eslint-config-expo/flat');

module.exports = defineConfig([
  expoConfig,
  {
    ignores: ['dist/*', 'private-data/*', 'node_modules/*', '.expo/*'],
  },
  {
    rules: {
      // "@toeic/dataset" is a virtual module resolved by metro.config.js / jest.config.js
      'import/no-unresolved': ['error', { ignore: ['^@toeic/dataset$'] }],
    },
  },
]);
