const { FlatCompat } = require('@eslint/eslintrc');
const eslint = require('@eslint/js');
const globals = require('globals');
const tseslint = require('typescript-eslint');
const perfectionist = require('eslint-plugin-perfectionist');
const json = require('@eslint/json');
const markdown = require('@eslint/markdown');
const css = require('@eslint/css');
const prettierRecommended = require('eslint-plugin-prettier/recommended');

const compat = new FlatCompat({ baseDirectory: __dirname });

module.exports = [
  // JS/TS: recommended + browser globals
  {
    files: ['**/*.{js,mjs,cjs,ts,mts,cts}'],
    ...eslint.configs.recommended,
    languageOptions: { globals: globals.browser }
  },
  { files: ['**/*.js'], languageOptions: { sourceType: 'commonjs' } },

  // JSON variants
  { files: ['**/*.json'], plugins: { json }, language: 'json/json', ...json.configs.recommended },
  { files: ['**/*.jsonc'], plugins: { json }, language: 'json/jsonc', ...json.configs.recommended },
  { files: ['**/*.json5'], plugins: { json }, language: 'json/json5', ...json.configs.recommended },

  // Markdown (GFM)
  { files: ['**/*.md'], plugins: { markdown }, language: 'markdown/gfm', ...markdown.configs.recommended },

  // CSS
  { files: ['**/*.css'], plugins: { css }, language: 'css/css', ...css.configs.recommended },

  // TypeScript + Perfectionist + custom rules
  ...tseslint.config(
    eslint.configs.all,
    ...tseslint.configs.strictTypeChecked,
    ...tseslint.configs.stylisticTypeChecked,
    perfectionist.configs['recommended-natural'],
    {
      languageOptions: {
        parserOptions: {
          projectService: true,
          tsconfigRootDir: __dirname
        }
      },
      rules: {
        '@typescript-eslint/array-type': ['error', { default: 'generic' }],
        '@typescript-eslint/consistent-return': 'off',
        '@typescript-eslint/consistent-type-definitions': ['error', 'type'],
        '@typescript-eslint/explicit-function-return-type': ['error', { allowExpressions: true }],
        '@typescript-eslint/naming-convention': [
          'error',
          { format: ['camelCase'], selector: 'default' },
          { format: [], selector: 'property' },
          { format: ['PascalCase'], selector: 'typeLike' },
          { format: ['camelCase', 'PascalCase'], selector: 'import' },
          { format: ['camelCase', 'UPPER_CASE'], modifiers: ['const', 'global'], selector: 'variable' },
          { format: ['camelCase', 'PascalCase'], selector: 'variable', types: ['function'] },
          { filter: { match: true, regex: '^_' }, format: [], selector: 'parameter' },
          { format: ['camelCase', 'PascalCase'], selector: 'function' }
        ],
        '@typescript-eslint/no-confusing-void-expression': ['error', { ignoreArrowShorthand: true }],
        '@typescript-eslint/no-magic-numbers': 'off',
        '@typescript-eslint/no-unsafe-type-assertion': 'off',
        '@typescript-eslint/no-unused-vars': [
          'error',
          { argsIgnorePattern: '^_', destructuredArrayIgnorePattern: '^_' }
        ],
        '@typescript-eslint/no-use-before-define': 'off',
        '@typescript-eslint/prefer-destructuring': 'off',
        '@typescript-eslint/strict-boolean-expressions': ['error', { allowNullableBoolean: true }],
        'capitalized-comments': 'off',
        'func-style': ['error', 'declaration', { allowArrowFunctions: true }],
        'id-length': ['error', { exceptions: ['x', 'y', 'z', 'w', 'i', 'j', 'k'] }],
        'max-lines-per-function': ['error', 150],
        'max-statements': ['error', 30],
        'no-console': 'error',
        'no-duplicate-imports': 'error',
        'no-inline-comments': 'off',
        'no-ternary': 'off',
        'no-undefined': 'off',
        'no-warning-comments': 'off',
        'one-var': 'off',
        'sort-imports': 'off',
        'sort-keys': 'off'
      }
    },
    // File overrides
    { files: ['**/*.tsx'], rules: { 'max-lines': ['warn', 150] } },
    { files: ['**/*Datas.ts', '**/*.config.{js,ts}'], rules: { 'max-lines': 'off' } },
    { files: ['**/*.{test,spec}.{ts,tsx}'], rules: { '@typescript-eslint/no-magic-numbers': 'off' } }
  ),

  // Next.js
  ...compat.config({
    extends: ['next/core-web-vitals'],
    rules: { '@next/next/no-img-element': 'off' }
  }),

  // Prettier MUST be last
  prettierRecommended
];
