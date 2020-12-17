require 'sinatra'
require 'sinatra/namespace'
require "sinatra/reloader"
require "sinatra/flash"
require 'jwt'
require 'byebug' 

require_relative "./models/response"
require_relative "./utility"
require_relative "./models/pagination/pagination"
require_relative "./models/pagination/pagination_decorator"
require_relative "./models/alma_client"
require_relative "./models/nelnet.rb"

require_relative "./models/patron"
require_relative "./models/item"
require_relative "./models/loans"
require_relative "./models/requests"
require_relative "./models/fines"

helpers StyledFlash

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
  response = Loan.renew(uniqname: session[:uniqname], loan_id: params["loan_id"])
  if response.code == 200
    flash[:success] = "<strong>Success:</strong> Loan Successfully Renewed"
  else
    flash[:error] = "<strong>Error:</strong> #{response.message}"
  end
  redirect "shelf/loans"
end

post '/sms' do
  patron = Patron.for(uniqname: session[:uniqname])
  response = patron.update_sms(params["phone-number"])
  if response.code == 200
    if params["phone-number"] == ''
      flash[:success] = "<strong>Success:</strong> SMS Successfully Removed"
    else
      flash[:success] = "<strong>Success:</strong> SMS Successfully Updated"
    end
  else
    flash[:error] = "<strong>Error:</strong> #{response.message}"
  end
  redirect "/contact-information"
end

namespace '/fines' do
  get '' do
    fines = Fines.for(uniqname: session[:uniqname])
    erb :fines, :locals => { fines: fines }
  end
  get '/' do
    redirect_to ''
  end
  post '/pay' do
    fine_ids = params["fines"].values
    all_fines = Fines.for(uniqname: session[:uniqname])
    selected_fines = all_fines.select(fine_ids)
    amount = selected_fines.reduce(0) {|sum, f| sum + f.balance.to_f}
    nelnet = Nelnet.new(amountDue: amount.to_currency, redirectUrl: "http://localhost:4567/fines/receipt")
    orderNumber = nelnet.orderNumber
    token = JWT.encode selected_fines.map{|x| x.to_h}, ENV.fetch('JWT_SECRET'), 'HS256'
    session[orderNumber] = token
    byebug
    redirect_to ''
  end
  get '/receipt' do
    items = JWT.decode(session[params["orderNumber"]], ENV.fetch('JWT_SECRET'), true, 'HS256')
    receipt = ReceiptPresenter.new(params: params, items: items)
  end
end
