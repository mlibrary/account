# My Account

Account.lib 
https://account.lib.umich.edu

## Setting up patron_account for development

Clone the repo

```
git clone git@github.com:mlibrary/patron_account.git
cd patron_account
```

copy .env-example to .env

```
cp .env-example .env
```

edit .env with the following environment variables. 

```ruby
#.env/development/web
ALMA_API_KEY='YOURAPIKEY'
ALMA_API_HOST='https://api-na.hosted.exlibrisgroup.com'
ILLIAD_API_KEY='YOURAPIKEY'
ILLIAD_API_HOST='https://yourilliadhost.com'
WEBLOGIN_SECRET = 'YOURWEBLOGINSECRET'
```

build web container

```
docker-compose build web
```

bundle install
```
docker-compose run --rm web bundle install
```

npm install
```
docker-compose run --rm web npm install
```

build styles

```
docker-compose run --rm web npm run build-css
```

watch then build styles (optional)

```
docker-compose run --rm web npm run watch-css
```

start containers

```
docker-compose up -d
```

In a browser, go to http://localhost:4567 to see the website.

## Turning Weblogin on or off
In `docker-compose.yml` in the 'web' service there's an environment variable "WEBLOGIN_ON". If it is "true" weblogin will be turned on in development mode. 
If it is "false" weblogin will be turned off. Having weblogin off will turn on the developer tools form on each page, and you will be able to toggle 
through the mlibrary.acct.testing friend accounts. These will have circulation data in the Alma sandbox. 


## Adding a javascript file for a specific page
In `webpack.common.js` add a key value pair to entry where the value is the path to the js file, and the key is the path for the page with inner '/' changed to '-'. 

Exmaple: the key for a js file to be used at the following path "/current-checkouts/u-m-library" would be "current-checkouts-u-m-library"

In `my_account.rb`, for the route, locals should include has_js: true.

## Testing with the actual Nelnet testing site
To try using the actual Nelnet testing site for testing fines and fees, you need to get the correct environment variables. There's extra documentation with example credit cards and input that will trigger different responses. Check the My Account confluenc page for more info.

## Kubernetes configuration
The Kubernetes configuration lives in [patron-account-kube](https://github.com/mlibrary/patron-account-kube)
