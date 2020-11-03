require 'sinatra'
require "sinatra/reloader" if development?
require 'byebug' if development?

require_relative "./models/response"
require_relative "./models/patron"
require_relative "./models/alma_client"
require_relative "./models/alma_error"

require_relative "./models/prototypes/loans"

enable :sessions

get '/' do
  loans = Prototypes::Loans.new
  session[:uniqname] = 'mrio' #need to get this from cosign?
  patron = Patron.for(uniqname: session[:uniqname])
  erb :shelf, :locals => {loans: loans, patron: patron} 
end

get '/notifications' do
  erb :notifications
end

get '/fines' do
  erb :fines
end

#demos info from Alma
get '/profile' do 
  session[:uniqname] = 'mrio' #need to get this from cosign?
  patron = Patron.for(uniqname: session[:uniqname])
  erb :patron, :locals => {patron: patron}
end
