# Overview
Monthly dependency update to help maintain Account.

## NPM
These dependencies have been updated to their latest versions:
- `eslint`
- `eslint-config-standard`
- `eslint-plugin-import`
- `eslint-plugin-node`
- `eslint-plugin-promise`
- `eslint-webpack-plugin`
- `sass`
- `webpack`
- `webpack-cli`
- `webpack-merge`

## Testing
- Install the updated packages (`docker-compose run --rm web npm install`).
- Make an SCSS change, and build the styles (`docker-compose run --rm web npm run build-css`).
- Make a JS change, and build the scripts (`docker-compose run --rm web npm run build-js`).
- Start [the site](http://localhost:4567) to see if your change was made, and everything still works (`docker-compose up`).
- Make sure the PR is consistent in these browsers:
  - [x] Chrome
  - [x] Firefox
  - [x] Safari
  - [x] Edge