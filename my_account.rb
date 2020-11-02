require 'sinatra'
require "sinatra/reloader" if development?
require 'byebug' if development?

require_relative "./models/response"
require_relative "./models/alma_client"
require_relative "./models/alma_error"

require_relative "./models/patron"
require_relative "./models/item"
require_relative "./models/loans"
require_relative "./models/requests"

enable :sessions

get '/' do
  #loans = Loans.for(uniqname: 'etude') #student with nothing
  loans = Loans.for(uniqname: 'tutor') #faculty with too much
  erb :shelf, :locals => {loans: loans} 
end

get '/notifications' do
  erb :notifications
end

get '/fines' do
  erb :fines
end

#demos info from Alma
get '/profile' do 
  session[:uniqname] = 'tutor' #need to get this from cosign?
  patron = Patron.for(uniqname: session[:uniqname])
  erb :patron, :locals => {patron: patron}
end
