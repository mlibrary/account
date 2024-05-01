import globals from "globals";
import pluginJs from "@eslint/js";

export default [
  pluginJs.configs.recommended,
  {
    languageOptions: {
      globals: globals.browser
    }
  },
  {
    rules: {
      "arrow-body-style": ["error", "always"], // Requires {} in arrow function body
      "arrow-parens": ["error", "always"], // Requires () around arrow function arguments
      "brace-style": ["error", "1tbs"], // Requires one true brace style
      "no-empty-function": "error", // Require an empty function to at least have a comment explaining why
      "no-var": "error", // Discourages using `var` and recommends using `let` or `const` instead
      "semi": ["error", "always"] // Requires a semicolon wherever necessary
    }
  }
];
