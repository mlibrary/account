source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "sinatra"
gem "sinatra-contrib"
gem "puma"
gem "httparty"
gem "sinatra-flash"
gem "telephone_number"
gem "jwt"
gem "addressable"
gem "omniauth"
gem "omniauth_openid_connect"
gem "redcarpet"
gem "rackup"
# needed for when we go to ruby 3.3, but we aren't there yet
gem "csv" # included here because httparty uses it and ought to require it

# In order to get rspec to work for ruby 3.1. Maybe later see if it's still necessary
gem "net-smtp", require: false

gem "alma_rest_client",
  git: "https://github.com/mlibrary/alma_rest_client",
  tag: "v2.0.0"

gem "yabeda-puma-plugin"
gem "yabeda-prometheus"

group :development, :test do
  gem "standard"
  gem "pry"
  gem "pry-byebug"
  gem "rack-test"
  gem "rspec"
  gem "webmock"
  gem "simplecov"
  gem "climate_control"
end
