require 'sinatra'
require 'sinatra/namespace'
require "sinatra/reloader"
require 'byebug' 

require_relative "./utility"
require_relative "./models/pagination/pagination"
require_relative "./models/pagination/pagination_decorator"
require_relative "./models/response"
require_relative "./models/alma_client"
require_relative "./models/alma_error"

require_relative "./models/patron"
require_relative "./models/item"
require_relative "./models/loans"
require_relative "./models/requests"
require_relative "./models/fees"

enable :sessions

post '/session_switcher' do
  session[:uniqname] = params[:uniqname]
  redirect '/'
end

get '/' do
  session[:uniqname] = 'tutor' if !session[:uniqname]

  test_users = [
    {
      label: 'Graduate student (few)',
      value: 'scholar'
    },
    {
      label: "Faculty (many)",
      value: 'tutor'
    },
    {
      label: "New student (none)",
      value: 'etude'
    }
  ]

  patron = Patron.for(uniqname: session[:uniqname])

  erb :home, :locals => { patron: patron, test_users: test_users }
end

namespace '/shelf' do
  get ''  do
    redirect_to '/loans' # Redirects to /shelf/loans
  end

  get '/'  do
    redirect_to '/loans' # Redirects to /shelf/loans
  end

  get '/loans' do
    loans = Loans.for(uniqname: session[:uniqname], offset: params["offset"], limit: params["limit"]) 
  
    erb :shelf, :locals => { loans: loans }
  end
  
  get '/past-loans' do
    loans = Loans.for(uniqname: session[:uniqname]) 
  
    erb :past_loans, :locals => { past_loans: loans }
  end
  
  get '/document-delivery' do
    loans = Loans.for(uniqname: session[:uniqname]) 
  
    erb :document_delivery, :locals => { document_delivery: [] }
  end
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
