require 'sinatra'
require "sinatra/reloader" if development?
require 'byebug' if development?

require_relative "./models/response"
require_relative "./models/patron"
require_relative "./models/alma_client"
require_relative "./models/alma_error"

enable :sessions

get '/' do
  session[:uniqname] = 'mrio' #need to get this from cosign?
  "Hello World"
end

get '/profile' do 
  session[:uniqname] = 'mrio' #need to get this from cosign?
  patron = Patron.for(uniqname: session[:uniqname])
  erb :patron, :locals => {patron: patron}
end
  

