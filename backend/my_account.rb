require 'sinatra'
require "sinatra/reloader" if development?

require_relative "./models/patron"
require_relative "./models/alma_client"

get '/' do
  "Hello World"
end

get '/users/:uniqname' do |uniqname|
  content_type :json
  Patron.new(uniqname: uniqname).to_h.to_json
end
  

