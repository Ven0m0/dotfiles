[const { FlatCompat } = require("@eslint/eslintrc");
const eslint = require("@eslint/js");
const globals = require("globals");
const tseslint = require("typescript-eslint");
const perfectionist = require("eslint-plugin-perfectionist");
const json = require("@eslint/json");
const markdown = require("@eslint/markdown");
const css = require("@eslint/css");

// Keep Prettier last so it can disable conflicting rules and report formatting issues
const prettierRecommended = require("eslint-plugin-prettier/recommended");

const compat = new FlatCompat({
  baseDirectory: __dirname,
});

module.exports = [
  // JS/TS files: enable @eslint/js recommended and browser globals
  { files: ["**/*.{js,mjs,cjs,ts,mts,cts}"], plugins: { js: eslint }, extends: ["js/recommended"], languageOptions: { globals: globals.browser } },
  // Plain .js files use CommonJS by default
  { files: ["**/*.js"], languageOptions: { sourceType: "commonjs" } },

  // JSON (json, jsonc, json5)
  { files: ["**/*.json"], plugins: { json }, language: "json/json", extends: ["json/recommended"] },
  { files: ["**/*.jsonc"], plugins: { json }, language: "json/jsonc", extends: ["json/recommended"] },
  { files: ["**/*.json5"], plugins: { json }, language: "json/json5", extends: ["json/recommended"] },

  // Markdown (GFM)
  { files: ["**/*.md"], plugins: { markdown }, language: "markdown/gfm", extends: ["markdown/recommended"] },

  // CSS
  { files: ["**/*.css"], plugins: { css }, language: "css/css", extends: ["css/recommended"] },

  // TypeScript + shared rules, Perfectionist sorting, and custom rules
  ...tseslint.config(
    eslint.configs.all,
    tseslint.configs.all,
    perfectionist.configs["recommended-natural"],
    {
      languageOptions: {
        parserOptions: {
          projectService: true,
          tsconfigRootDir: __dirname,
        },
      },
      rules: {
        "@typescript-eslint/array-type": [
          "error",
          {
            default: "generic",
          },
        ],
        "@typescript-eslint/consistent-return": "off",
        "@typescript-eslint/consistent-type-definitions": ["error", "type"],
        "@typescript-eslint/explicit-function-return-type": [
          "error",
          {
            allowExpressions: true,
          },
        ],
        "@typescript-eslint/naming-convention": [
          "error",
          {
            format: ["camelCase"],
            selector: "default",
          },
          {
            format: [],
            selector: "property",
          },
          {
            format: ["PascalCase"],
            selector: "typeLike",
          },
          {
            format: ["camelCase", "PascalCase"],
            selector: "import",
          },
          {
            format: ["camelCase", "UPPER_CASE"],
            modifiers: ["const", "global"],
            selector: "variable",
          },
          {
            format: ["camelCase", "PascalCase"],
            selector: "variable",
            types: ["function"],
          },
          {
            filter: {
              match: true,
              regex: "^_",
            },
            format: [],
            selector: "parameter",
          },
          {
            format: ["camelCase", "PascalCase"],
            selector: "function",
          },
        ],
        "@typescript-eslint/no-confusing-void-expression": [
          "error",
          {
            ignoreArrowShorthand: true,
          },
        ],
        "@typescript-eslint/no-magic-numbers": [
          "off",
          { ignore: [0, 1, 2, -1] },
        ],
        "@typescript-eslint/no-unsafe-type-assertion": "off",
        "@typescript-eslint/no-unused-vars": [
          "error",
          {
            argsIgnorePattern: "^_",
            destructuredArrayIgnorePattern: "^_",
          },
        ],
        "@typescript-eslint/no-use-before-define": "off",
        "@typescript-eslint/strict-boolean-expressions": [
          "error",
          {
            allowNullableBoolean: true,
          },
        ],
        "func-style": [
          "error",
          "declaration",
          {
            allowArrowFunctions: true,
          },
        ],
        "id-length": [
          "error",
          {
            exceptions: ["x", "y", "z", "w"],
          },
        ],
        "max-lines-per-function": ["error", 150],
        "no-console": "on",
        "no-duplicate-imports": "on",
        "no-ternary": "off",
        "no-undefined": "off",
        "no-warning-comments": "off",
        "one-var": "off",
        "sort-imports": "off",
        "sort-keys": "off",
      },
    },
    // File-specific overrides
    { files: ["**/*.tsx"], rules: { "max-lines": ["warn", 150] } },
    { files: ["**/*Datas.ts"], rules: { "max-lines": "off" } },
  ),

  // Next.js core web vitals (via FlatCompat)
  ...compat.config({
    extends: ["next/core-web-vitals"],
    rules: {
      "@next/next/no-img-element": "off",
    },
  }),

  // Prettier plugin recommended (MUST be last)
  prettierRecommended,
];
