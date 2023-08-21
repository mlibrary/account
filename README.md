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
docker-compose up -d
```

watch then build styles or scripts (optional)

```bash
# styles
docker-compose run --rm web npm run watch-css
# scripts
docker-compose run --rm web npm run watch-js
```

In a browser, go to http://localhost:4567 to see the website.

## Turning Weblogin on or off
In `.env` there's an environment variable "WEBLOGIN_ON". If it is "true" weblogin will be turned on in development mode. 
If it is "false" weblogin will be turned off. Having weblogin off will turn on the developer tools form on each page, and you will be able to toggle 
through the mlibrary.acct.testing friend accounts. These will have circulation data in the Alma sandbox. 


## Adding a javascript file for a specific page
In `lib/routes/`, find the route for the page you wish to add a `.js` file. For the `erb`, make sure the `locals` includes `has_js:true`.

When creating a `.js` file, they must all be in the `./js` directory. Naming the file matches the slug version of the page's URL path, where the first `/` is removed and all following `/` are replaced with `-`. For example: creating a JavaScript file for `https://account.lib.umich.edu/current-checkouts/u-m-library` would require the file `./js/current-checkouts-u-m-library.js`.

## Testing with the actual Nelnet testing site
To try using the actual Nelnet testing site for testing fines and fees, you need to get the correct environment variables. There's extra documentation with example credit cards and input that will trigger different responses. Check the My Account confluenc page for more info.

## Kubernetes configuration
The Kubernetes configuration lives in [patron-account-kube](https://github.com/mlibrary/patron-account-kube)
