require 'sinatra'
require 'sinatra/namespace'
require "sinatra/reloader"
require "sinatra/flash"
require 'byebug' 

require_relative "./models/response"
require_relative "./utility"
require_relative "./models/pagination/pagination"
require_relative "./models/pagination/pagination_decorator"
require_relative "./models/alma_client"

require_relative "./models/patron"
require_relative "./models/item"
require_relative "./models/loans"
require_relative "./models/requests"
require_relative "./models/fees"

enable :sessions

# :nocov:
post '/session_switcher' do
  session[:uniqname] = params[:uniqname]
  redirect '/'
end
# :nocov:

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
    #loans = Loans.for(uniqname: session[:uniqname]) 
  
    erb :past_loans, :locals => { past_loans: {} }
  end
  
  get '/document-delivery' do
  
    erb :document_delivery, :locals => { document_delivery: [] }
  end
end

get '/requests' do
  requests = Requests.for(uniqname: session[:uniqname]).holds

  erb :requests, :locals => { requests: requests }
end

get '/contact-information' do 
  #session[:uniqname] = 'tutor' #need to get this from cosign?
  patron = Patron.for(uniqname: session[:uniqname])
  erb :patron, :locals => {patron: patron}
end

post '/renew-loan' do
  byebug
  response = Loan.renew(uniqname: session[:uniqname], loan_id: params["loan_id"])
  if response.code == 200
    flash[:success] = "Loan Successfully Renewed"
  else
    flash[:error] = response.message
  end
  redirect URI(request.referrer).request_uri

end
post '/sms' do
  patron = Patron.for(uniqname: session[:uniqname])
  response = patron.update_sms(params["phone-number"])
  if response.code == 200
    flash[:success] = "SMS Successfully Updated"
  else
    flash[:error] = response.message
  end
  redirect "/contact-information"
end

get '/fines' do
  erb :fines
end
