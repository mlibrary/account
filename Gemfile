source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'sinatra'
gem 'thin'
gem 'httparty'
gem 'sinatra-flash'
gem 'telephone_number'
gem 'jwt'
gem 'addressable'
gem 'omniauth'
gem 'omniauth_openid_connect'
gem 'redcarpet'

#In order to get rspec to work for ruby 3.1. Maybe later see if it's still necessary
gem 'net-smtp', require: false

gem 'alma_rest_client',
  git: 'https://github.com/mlibrary/alma_rest_client', 
  tag: '1.3.0'

group :development, :test do
  gem 'pry'
  gem 'pry-byebug'
  gem 'rack-test'
  gem 'rspec'
  gem 'sinatra-contrib'
  gem 'webmock'
  gem 'simplecov'
  gem 'climate_control'
end

