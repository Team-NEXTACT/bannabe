module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    'ecmaVersion': 2018,
  },
  extends: [
    'eslint:recommended',
    'google',
  ],
  rules: {
    'no-restricted-globals': ['error', 'name', 'length'],
    'prefer-arrow-callback': 'error',
    'quotes': ['error', 'single', { 'allowTemplateLiterals': true }],
    'no-unused-vars': ['warn'],
    'max-len': ['error', { 'code': 120 }],
    'indent': ['error', 2],
    'linebreak-style': 0,
    'comma-dangle': ['error', 'only-multiline'],
    'object-curly-spacing': 0,
    'no-trailing-spaces': 1,
  },
  overrides: [
    {
      files: ['**/*.spec.*'],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};
