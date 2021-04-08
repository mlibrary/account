# My Account

My Account for Alma

## Setting up My Account for development

Clone the repo

```
git clone git@github.com:mlibrary/my_account.git
cd my_account
```

copy .env-example directory to .env

```
cp -r .env-example .env
```

edit .env/development/web with the following environment variables. For development, only ALMA_API_KEY and ILLIAD_API_KEY need to be set with real values.

```ruby
#.env/development/web
ALMA_API_KEY='YOURAPIKEY'
ALMA_API_HOST='https://api-na.hosted.exlibrisgroup.com'
ILLIAD_API_KEY='YOURAPIKEY'
ILLIAD_API_HOST='https://yourilliadhost.com'
NELNET_SECRET_KEY = 'secretkey'
NELNET_PAYMENT_URL = 'http://localhost:4444'
JWT_SECRET = 'myjwtsecret'
PATRON_ACCOUNT_BASE_URL = 'http://localhost:4567'
NELNET_PAYMENT_URL = 'http://localhost:4433'
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

start containers

```
docker-compose up -d
```

In a browser, go to http://localhost:4567 to see the website.

## Adding a javascript file for a specific page
In `webpack.common.js` add a key value pair to entry where the value is the path to the js file, and the key is the path for the page with inner '/' changed to '-'. 

Exmaple: the key for a js file to be used at the following path "/current-checkouts/u-m-library" would be "current-checkouts-u-m-library"

In `my_account.rb`, for the route, locals should include has_js: true.




