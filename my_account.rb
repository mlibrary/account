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
  loans = Prototypes::Loans.new
  session[:uniqname] = 'mrio' #need to get this from cosign?
  patron = Patron.for(uniqname: session[:uniqname])
  erb :home, :locals => {loans: loans, patron: patron} 
end

get '/shelf' do
  loans = [
    {
      title: "Go green: How to build an earth-friendly community",
      author: "Nancy H. Taylor",
      due: "December 12, 2020",
      to: "https://search.lib.umich.edu/catalog/record/[id]"
    },
    {
      title: "The betrayal : the 1919 World Series and the birth of modern baseball",
      author: "Charles Fountain",
      due: "November 27, 2020",
      to: "https://search.lib.umich.edu/catalog/record/[id]"
    }
  ]

  past_loans = [
    {
      title: "Go green: How to build an earth-friendly community",
      author: "Nancy H. Taylor",
      due: "December 12, 2020",
      to: "https://search.lib.umich.edu/catalog/record/[id]"
    },
    {
      title: "The betrayal : the 1919 World Series and the birth of modern baseball",
      author: "Charles Fountain",
      due: "November 27, 2020",
      to: "https://search.lib.umich.edu/catalog/record/[id]"
    }
  ]

  erb :shelf, :locals => { loans: loans, past_loans: past_loans }
end

get '/requests' do
  erb :requests
end

get '/profile' do 
  session[:uniqname] = 'tutor' #need to get this from cosign?
  patron = Patron.for(uniqname: session[:uniqname])
  erb :patron, :locals => {patron: patron}
end

get '/fines' do
  erb :fines
end
