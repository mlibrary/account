# Account

https://account.lib.umich.edu

This is the code repository for the University of Michigan Library Account application.

## Setting up account for development

Clone the repo

```bash
git clone git@github.com:mlibrary/account.git
cd account
```

run the `init.sh` script. 
```bash
./init.sh
```

edit .env with the appropriate environment variables 

start containers

```bash
docker compose up -d
```

watch then build styles or scripts (optional)

```bash
# styles
docker compose run --rm web npm run watch-css
# scripts
docker compose run --rm web npm run watch-js
```

In a browser, go to http://localhost:4567 to see the website.

## Authentication
The app needs to have the environment variable `APP_ENV=development` in order
to run the site in local development. This will enable the session_switcher
endpoint, and developer tools form which let you choose a user. The
mlibrary.acct.testing friend accounts are available to work with.

In production authentication is handled with [OAuth2
Proxy](https://oauth2-proxy.github.io/oauth2-proxy/), which is configured to
pass a header with the uniqname of the user.


## Adding a javascript file for a specific page
In `lib/routes/`, find the route for the page you wish to add a `.js` file. For
the `erb`, make sure the `locals` includes `has_js:true`.

When creating a `.js` file, they must all be in the `./js` directory. Naming
the file matches the slug version of the page's URL path, where the first `/`
is removed and all following `/` are replaced with `-`. For example: creating a
JavaScript file for
`https://account.lib.umich.edu/current-checkouts/u-m-library` would require the
file `./js/current-checkouts-u-m-library.js`.

## Testing with the actual Nelnet testing site
To try using the actual Nelnet testing site for testing fines and fees, you
need to get the correct environment variables. There's extra documentation with
example credit cards and input that will trigger different responses. Check the
My Account confluenc page for more info.
