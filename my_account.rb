require 'sinatra'
require 'sinatra/namespace'
require "sinatra/reloader"
require "sinatra/flash"
require "alma_rest_client"
require 'jwt'
require 'byebug' 

require_relative "./models/navigation"
require_relative "./models/response"
require_relative "./utility"
require_relative "./models/pagination/pagination"
require_relative "./models/pagination/pagination_decorator"
require_relative "./models/illiad_client"
require_relative "./models/nelnet"
require_relative "./models/fine_payer"

require_relative "./models/patron"
require_relative "./models/items"
require_relative "./models/item"
require_relative "./models/loans"
require_relative "./models/document_delivery"
require_relative "./models/requests"
require_relative "./models/interlibrary_loan_requests"
require_relative "./models/fines"
require_relative "./models/receipt"


helpers StyledFlash

enable :sessions

# :nocov:
post '/session_switcher' do
  session[:uniqname] = params[:uniqname]
  redirect '/'
end
post '/loan-controls' do
  query = {limit: params["show"]}
  case params["sort"]
  when "due-asc"
    query["order_by"] =  "due_date"
    query["direction"] = "ASC"
  when "due-desc"
    query["order_by"] =  "due_date"
    query["direction"] = "DESC"
  when "title-asc"
    query["order_by"] =  "title"
    query["direction"] = "ASC"
  when "title-desc"
    query["order_by"] =  "title"
    query["direction"] = "DESC"
  end

  redirect "/current-checkouts/checkouts?#{URI.encode_www_form(query)}"
end
get '/receipt_test' do
  items = [{ "id"=>"1384289260006381", "balance"=>"5.00", "title"=>"Short history of Georgia.", "barcode"=>"95677", "library"=>"Main Library", "type"=>"Overdue fine", "creation_time"=>"2020-12-09T17:13:29.959Z" }]
  nelnet_params =  { "transactionType"=>"1", "transactionStatus"=>"1", "transactionId"=>"382481568", "transactionTotalAmount"=>"2250", "transactionDate"=>"202001211341", "transactionAcountType"=>"VISA", "transactionResultCode"=>"267849", "transactionResultMessage"=>"Approved and completed", "orderNumber"=>"Afam.1608566536797", "orderType"=>"UMLibraryCirc", "orderDescription"=>"U-M Library Circulation Fines", "payerFullName"=>"Aardvark Jones", "actualPayerFullName"=>"Aardvark Jones", "accountHolderName"=>"Aardvark Jones", "streetOne"=>"555 S STATE ST", "streetTwo"=>"", "city"=>"Ann Arbor", "state"=>"MI", "zip"=>"48105", "country"=>"UNITED STATES", "email"=>"aardvark@umich.edu", "timestamp"=>"1579628471900", "hash"=>"33c52c83a5edd6755a5981368028b55238a01a918570b0552836db3250b2ed6c" }

  if params["invalid"] == 'true'
    receipt = InvalidReceipt.new('Could not Validate Transaction')
    flash.now[:error] = receipt.message
  else
    receipt = Receipt.new( items: items, nelnet_params: nelnet_params)
    flash.now[:success] = "Fines successfully paid"
  end
  erb :receipt, :locals => {receipt: receipt, items: receipt.items, payment: receipt.payment}
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

  erb :home, :locals => { patron: patron, test_users: test_users, navigation: Navigation.new}
end

namespace '/current-checkouts' do
  get ''  do
    redirect_to '/checkouts' # Redirects to /shelf/loans
  end

  get '/'  do
    redirect_to '/checkouts' # Redirects to /shelf/loans
  end

  get '/checkouts' do
    loans = Loans.for(uniqname: session[:uniqname], offset: params["offset"], limit: params["limit"], order_by: params["order_by"], direction: params["direction"])
    session.delete(:items)
    erb :shelf, :locals => { loans: loans, message: nil }
  end
  
  post '/checkouts' do
    response = Loans.renew_all(uniqname: session[:uniqname])
    if response.code != 200 
      flash.now[:error] = "<strong>Error:</strong> #{response.message}"
    end
    if response.class.name == 'RenewResponse' 
      items = response.items 
      message = response
    else
      items = []
      message = nil
    end
    loans = Loans.for(uniqname: session[:uniqname], renewed_items: items)
    
    erb :shelf, :locals => { loans: loans, message: message }
  end
  
  get '/interlibrary-loan' do
    document_delivery = DocumentDelivery.for(uniqname: 'testhelp')

    erb :document_delivery, :locals => { document_delivery: document_delivery }
  end
  get '/document-delivery-or-scans' do
    #loans = Loans.for(uniqname: session[:uniqname]) 
  
    erb :past_loans, :locals => { past_loans: {} }
  end
end

namespace '/pending-requests' do
  get ''  do
    redirect_to '/u-m-library' # Redirects to /requests/um-library
  end

  get '/'  do
    redirect_to '/u-m-library' # Redirects to /requests/um-library
  end

  get '/u-m-library' do
    requests = Requests.for(uniqname: session[:uniqname]).holds

    erb :requests, :locals => { requests: requests }
  end

  get '/interlibrary-loan' do
    interlibrary_loan_requests = InterlibraryLoanRequests.for(uniqname: 'testhelp')

    erb :interlibrary_loan_requests, :locals => { interlibrary_loan_requests: interlibrary_loan_requests }
  end
  get '/special-collections' do
    erb :past_loans, :locals => { past_loans: {} }
  end
end

get '/settings' do 
  #session[:uniqname] = 'tutor' #need to get this from cosign?
  patron = Patron.for(uniqname: session[:uniqname])
  erb :patron, :locals => {patron: patron}
end
#TODO set up renew loan to handle renew in place with top part message???
#post '/renew-loan' do
  #response = Loan.renew(uniqname: session[:uniqname], loan_id: params["loan_id"])
  #if response.code == 200
    #flash[:success] = "<strong>Success:</strong> Loan Successfully Renewed"
  #else
    #flash[:error] = "<strong>Error:</strong> #{response.message}"
  #end
  #redirect "shelf/loans"
#end

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
  redirect "/settings"
end

namespace '/fines-and-fees' do
  get '' do
    fines = Fines.for(uniqname: session[:uniqname])
    erb :fines, :locals => { fines: fines }
  end

  
# :nocov:
  get '/' do
    redirect_to ''
  end
# :nocov:

  post '/pay' do
    payer = FinePayer.new(uniqname: session[:uniqname], fine_ids: params["fines"].values)
    session[payer.orderNumber] = payer.token
    redirect payer.url
  end

  get '/receipt' do
    token = session[params["orderNumber"]]
    items = []
    if token 
      items = JWT.decode(token, ENV.fetch('JWT_SECRET'), true, {algorithm: 'HS256'}).first 
    end

    receipt = Receipt.for(uniqname: session[:uniqname], items: items, nelnet_params: params)
    if receipt.valid?
      flash.now[:success] = "Fines successfully paid"
    else
      flash.now[:error] = receipt.message 
    end
    erb :receipt, :locals => {receipt: receipt, items: receipt.items, payment: receipt.payment}
  end

end
