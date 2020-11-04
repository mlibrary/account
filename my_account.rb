require 'sinatra'
require "sinatra/reloader" if development?
require 'byebug' if development?

require_relative "./utility"
require_relative "./models/response"
require_relative "./models/alma_client"
require_relative "./models/alma_error"

require_relative "./models/patron"
require_relative "./models/item"
require_relative "./models/loans"
require_relative "./models/requests"
require_relative "./models/fees"

enable :sessions

get '/' do
  #loans = Prototypes::Loans.new
  #session[:uniqname] = 'mrio' #need to get this from cosign?
  #patron = Patron.for(uniqname: session[:uniqname])
  #erb :home, :locals => {loans: loans, patron: patron} 
end

get '/shelf' do
  session[:uniqname] = 'scholar' #graduate student; small number of books
  #session[:uniqname] = 'tutor' #faculty; lots of books
  #session[:uniqname] = 'etude' #new student; no books
  loans = Loans.for(uniqname: session[:uniqname]) 

  erb :shelf, :locals => { loans: loans, past_loans: loans }
end

get '/requests' do
  erb :requests
end

get '/profile' do 
  #session[:uniqname] = 'tutor' #need to get this from cosign?
  patron = Patron.for(uniqname: session[:uniqname])
  erb :patron, :locals => {patron: patron}
end

get '/fines' do
  erb :fines
end
