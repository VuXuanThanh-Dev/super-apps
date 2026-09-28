// Tests ALWAYS use the public sample dataset, so they pass with private-data/ empty.
// (The optional test src/data/__tests__/privateDataset.test.ts checks the full
// dataset only when private-data/dataset.json exists.)
module.exports = {
  preset: 'jest-expo',
  moduleNameMapper: {
    '^@toeic/dataset$': '<rootDir>/src/data/sample/dataset.json',
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  testPathIgnorePatterns: ['/node_modules/', '/private-data/'],
  modulePathIgnorePatterns: ['<rootDir>/private-data/'],
  setupFiles: ['<rootDir>/jest.setup.js'],
  collectCoverageFrom: ['src/**/*.{ts,tsx}', '!src/app/**'],
};
