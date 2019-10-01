module.exports = {
    extends: ['airbnb-base', 'plugin:vue/recommended', 'prettier', 'prettier/vue'],
    env: {
        browser: true,
        commonjs: true,
        es6: true,
        node: true,
        mocha: true
    },
    parserOptions: {
        parser: 'babel-eslint',
        sourceType: 'module'
    },
    plugins: ['prettier', 'vue'],
    rules: {
        'import/no-unresolved': 'off',
        'vue/no-v-html': 'off',
        'no-console': 'off',
        'no-unused-vars': ['error', { args: 'none' }],
        'prefer-const': 'error',
        'prettier/prettier': 'error'
        // I'd love to turn on camelcase, but it's a big shift with tons of current errors.
        // camelcase: [
        //     "error",
        //     {
        //         properties: "always"
        //     }
        // ]
    },
    globals: {
        // chai tests
        assert: true,
        expect: true
    }
};
