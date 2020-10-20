require 'sinatra'
require "sinatra/reloader" if development?
require 'byebug' if development?

require_relative "./models/response"
require_relative "./models/patron"
require_relative "./models/alma_client"
require_relative "./models/alma_error"

get '/' do
  "Hello World"
end

get '/users/:uniqname' do |uniqname|
  #[200, {"Content-Type"=> "application/json"}, Patron.new(uniqname: uniqname).to_json]
  Patron.for(uniqname:uniqname).response
end
  

