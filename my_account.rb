require 'sinatra'
require 'sinatra/namespace'
require "sinatra/reloader"
require "sinatra/flash"
require 'redcarpet'
require 'omniauth'
require 'omniauth_openid_connect'
require "alma_rest_client"
require 'jwt'
require 'byebug' 


# Monkey patch for omniauth_openid_connect -> openid_connect -> webfinger -> httpclient SSL errors
require_relative "./lib/monkey_httpclient"

require_relative "./lib/entities/entities"
require_relative "./lib/entities/pages"
require_relative "./lib/entities/empty_state"

require_relative "./lib/navigation/navigation"
require_relative "./lib/navigation/page"
require_relative "./lib/navigation/horizontal_nav"
require_relative "./lib/navigation/sidebar"
require_relative "./lib/navigation/user_dropdown"
require_relative "./lib/navigation/title"
require_relative "./lib/navigation/description"

require_relative "./lib/utility"
require_relative "./lib/illiad_client"
require_relative "./lib/circ_history_client"
require_relative "./lib/publisher"
require_relative "./lib/table_controls.rb"
require_relative "./lib/pagination/pagination"
require_relative "./lib/pagination/pagination_decorator"
require_relative "./lib/circulation_history_settings_text"

require_relative "./models/illiad_patron.rb"
require_relative "./models/patron"
require_relative "./models/session_patron"

require_relative "./models/response/response"
require_relative "./models/response/renew_response_presenter"

require_relative "./models/fines/nelnet"
require_relative "./models/fines/fines"
require_relative "./models/fines/receipt"

require_relative "./models/items/items"
require_relative "./models/items/item"

require_relative "./models/items/alma/alma_item"
require_relative "./models/items/alma/loans"
require_relative "./models/items/alma/requests"

require_relative "./models/items/circ_history/circ_history_item"
require_relative "./models/items/interlibrary_loan/interlibrary_loan_item"
require_relative "./models/items/interlibrary_loan/interlibrary_loan_items"
require_relative "./models/items/interlibrary_loan/document_delivery"
require_relative "./models/items/interlibrary_loan/interlibrary_loans"
require_relative "./models/items/interlibrary_loan/interlibrary_loan_requests"
require_relative "./models/items/interlibrary_loan/past_document_delivery"
require_relative "./models/items/interlibrary_loan/past_interlibrary_loans"
require_relative "./models/items/interlibrary_loan/pending_document_delivery"


helpers StyledFlash

enable :sessions
set :session_secret, ENV['RACK_COOKIE_SECRET'] 
set server: 'thin', connections: []
use Rack::Logger

use OmniAuth::Builder do
  provider :openid_connect, {
    issuer: 'https://weblogin.lib.umich.edu',
    discovery: true,
    client_auth_method: 'jwks',
    scope: [:openid, :profile, :email],
    client_options: {
      identifier: ENV['WEBLOGIN_ID'],
      secret: ENV['WEBLOGIN_SECRET'],
      redirect_uri: "#{ENV['PATRON_ACCOUNT_BASE_URL']}/auth/openid_connect/callback"
    }
  }
end

get '/auth/openid_connect/callback' do
  auth = request.env['omniauth.auth']
  info = auth[:info]
  session[:authenticated] = true
  session[:expires_at] = Time.now.utc + 1.hour
  patron = SessionPatron.new(info[:nickname])
  patron.to_h.each{|k,v| session[k] = v}
  redirect session.delete(:path_before_login) || '/' 
end

get '/auth/failure' do
  "You are not authorized"
end

get '/logout' do
  session.clear
  redirect "https://shibboleth.umich.edu/cgi-bin/logout?https://lib.umich.edu/"
end

before  do
  pass if ['auth', 'stream', 'updater', 'session_switcher', 'logout'].include? request.path_info.split('/')[1]
  if dev_login?
    if !session[:uniqname]
      redirect "/session_switcher?uniqname=#{URI.escape('mlibrary.acct.testing1@gmail.com')}"
    end
    pass
  end
  if !session[:authenticated] || Time.now.utc > session[:expires_at]
    session[:path_before_login] = request.path_info
    redirect '/auth/openid_connect'
  end
end

helpers do
  def dev_login?
    ENV['WEBLOGIN_ON'] == "false" && settings.environment == :development
  end
end

get '/stream', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.connections << { uniqname: session[:uniqname], out: out }
    out.callback do
      settings.connections.delete(settings.connections.detect{ |x| x[:out] == out}) 
    end
  end
end
post '/updater/' do
  return 403 unless Authenticator.verify(params: params)
  data = {}
  params.each do |key, value|
    if key != "uniqname" && key != "hash"
      data[key] = value
    end
  end
  data = data.to_json
  settings.connections.each { |x| x[:out] << "data: #{data}\n\n" if x[:uniqname] == params[:uniqname] }
  204 # response without entity body
end
post '/table-controls' do
  urlGenerator = TableControls::URLGenerator.for(show: params["show"], sort: params["sort"], referrer: request.referrer)
  redirect urlGenerator.to_s
end
# :nocov:
get '/session_switcher' do
  patron = SessionPatron.new(params[:uniqname])
  patron.to_h.each{|k,v| session[k] = v}
  redirect back
end
# :nocov:

get '/' do
  erb :'account-overview/index', :locals => { cards: Navigation.cards }
end

namespace '/current-checkouts' do
  get ''  do
    redirect_to '/u-m-library' # Redirects to /shelf/loans
  end

  get '/'  do
    redirect_to '/u-m-library' # Redirects to /shelf/loans
  end

  get '/u-m-library' do
    if session[:in_alma]
      loan_controls = TableControls::LoansForm.new(limit: params["limit"], order_by: params["order_by"], direction: params["direction"])
      loans = Loans.for(uniqname: session[:uniqname], offset: params["offset"], limit: params["limit"], order_by: params["order_by"], direction: params["direction"])
      message = session.delete(:message)
      erb :'current-checkouts/u-m-library', :locals => { loans: loans, message: message, loan_controls: loan_controls, has_js: true}
    else
      erb :empty_state
    end
  end
  
  post '/u-m-library' do
    response = Loans.renew_all(uniqname: session[:uniqname])
    if response.code != 200 
      flash[:error] = "<span class='strong'>Error:</span> #{response.message}"
    else
      session[:message] = RenewResponsePresenter.new(renewed: response.renewed_count, not_renewed: response.not_renewed_count)
      204
    end
  end
  
  get '/interlibrary-loan' do
    interlibrary_loans = InterlibraryLoans.for(uniqname: session[:uniqname], limit: params["limit"], offset: params["offset"], count: nil)

    erb :'current-checkouts/interlibrary-loan', :locals => { interlibrary_loans: interlibrary_loans }
  end
  get '/scans-and-electronic-items' do
    document_delivery = DocumentDelivery.for(uniqname: session[:uniqname], limit: params["limit"], offset: params["offset"], count: nil)

    erb :'current-checkouts/scans-and-electronic-items', :locals => { document_delivery: document_delivery }
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
    if session[:in_alma]
      requests = Requests.for(uniqname: session[:uniqname])
      local_document_delivery = PendingLocalDocumentDelivery.for(uniqname: session[:uniqname]) 
      illiad_patron = ILLiadPatron.for(uniqname: session[:uniqname])
      erb :'pending-requests/u-m-library', :locals => { holds: requests.holds, bookings: requests.bookings, local_document_delivery: local_document_delivery, illiad_patron: illiad_patron }
    else
      erb :empty_state
    end
  end
  post '/u-m-library/cancel-request' do
    response = Request.cancel(uniqname: session[:uniqname], request_id: params["request_id"])
    if response.code == 204
      loan = response.parsed_response
      status 200
      {}.to_json
    else
      error = AlmaError.new(response)
      status error.code
      { message: error.message }.to_json
    end
  end


  get '/interlibrary-loan' do
    interlibrary_loan_requests = InterlibraryLoanRequests.for(uniqname: session[:uniqname], limit: params["limit"], offset: params["offset"], count: nil)

    erb :'pending-requests/interlibrary-loan', :locals => { interlibrary_loan_requests: interlibrary_loan_requests }
  end

  get '/special-collections' do
    erb :'pending-requests/special-collections', :locals => { special_collections_requests: {} }
  end
end

namespace '/past-activity' do
  get ''  do
    redirect_to '/u-m-library' # Redirects to /past-activity/um-library
  end

  get '/'  do
    redirect_to '/u-m-library' # Redirects to /past-activity/um-library
  end

  namespace '/u-m-library' do
    get '' do
      if session[:in_circ_history]
        table_controls = TableControls::PastLoansForm.new(limit: params["limit"], order_by: params["order_by"], direction: params["direction"])
        past_loans = CirculationHistoryItems.for(uniqname: session[:uniqname], offset: params["offset"], limit: params["limit"], order_by: params["order_by"], direction: params["direction"])
        erb :'past-activity/u-m-library', :locals => {past_loans: past_loans, table_controls: table_controls}
      else
        erb :empty_state
      end
    end
    get '/download.csv' do
      resp = CircHistoryClient.new(session[:uniqname]).download_csv
      unless resp.code == 200
        #Error
      else
        #mrio: I'm sorry getting the filename from content-disposition is like this. :(
        filename = resp.headers["content-disposition"]&.split('; ')&.at(1)&.split('"')&.at(1)
        filename = 'my_filename.csv' if filename.nil?
        content_type 'application/csv'
        attachment filename
        resp.body
      end
    end
  end

  get '/interlibrary-loan' do
    past_interlibrary_loans = PastInterlibraryLoans.for(uniqname: session[:uniqname], limit: params["limit"], offset: params["offset"], count: nil)
    #session[:past_interlibrary_loans_count] = past_interlibrary_loans.count if session[:past_interlibrary_loans_count].nil? 

    erb :'past-activity/interlibrary-loan', :locals => { past_interlibrary_loans: past_interlibrary_loans }
  end
  get '/scans-and-electronic-items' do
    past_document_delivery = PastDocumentDelivery.for(uniqname: session[:uniqname], limit: params["limit"], offset: params["offset"], count: nil)
    #session[:past_document_delivery_count] = past_document_delivery.count if session[:past_document_delivery_count].nil? 

    erb :'past-activity/scans-and-electronic-items', :locals => { past_document_delivery: past_document_delivery }
  end
  get '/special-collections' do
    erb :'past-activity/special-collections', :locals => { past_special_collections: {} }
  end
end

get '/favorites' do 
  redirect 'https://apps.lib.umich.edu/my-account/favorites' 
end

namespace '/settings' do 
  get '' do
    patron = Patron.for(uniqname: session[:uniqname])
    erb :'settings/index', :locals => {patron: patron, has_js: true}
  end
  post '/history' do
    response = Patron.set_retain_history(uniqname: session[:uniqname], retain_history: params[:retain_history])
    if response.code == 200
      session[:confirmed_history_setting] = true      
      flash[:success] = "<span class='strong'>Success:</span> History Setting Successfully Changed"
    else
      flash[:error] = "<span class='strong'>Error:</span> #{response.message}"
    end
    redirect "/settings"
  end
end
#TODO set up renew loan to handle renew in place with top part message???
post '/renew-loan' do
  response = Loan.renew(uniqname: session[:uniqname], loan_id: params["loan_id"])
  if response.code == 200
    loan = response.parsed_response
    status 200
    { due_date: DateTime.patron_format(loan["due_date"]), loan_id: loan["loan_id"] }.to_json
  else
    error = AlmaError.new(response)
    status error.code
    { message: error.message }.to_json
  end
end

post '/sms' do
  patron = Patron.for(uniqname: session[:uniqname])
  response = patron.update_sms(params["text-notifications"] == "on" ? params["sms-number"] : "")
  if response.code == 200
    if params["text-notifications"] == "on"
      flash[:success] = "<span class='strong'>Success:</span> SMS Successfully Updated"
    else
      flash[:success] = "<span class='strong'>Success:</span> SMS Successfully Removed"
    end
  else
    flash[:error] = "<span class='strong'>Error:</span> #{response.message}"
  end
  redirect "/settings"
end

namespace '/fines-and-fees' do
  get '' do
    if session[:in_alma]
      fines = Fines.for(uniqname: session[:uniqname])
      erb :'fines-and-fees/index', :locals => { fines: fines }
    else
      erb :empty_state
    end
  end

  
# :nocov:
  get '/' do
    redirect_to ''
  end
# :nocov:

  post '/pay' do
    fines = Fines.for(uniqname: session[:uniqname])
    total_sum = fines.total_sum.to_f
    amount = params["pay_in_full"] == "true" ? total_sum : params["partial_amount"].to_f
    if amount <= total_sum
      nelnet =  Nelnet.new(amountDue: amount.to_currency)
      session["order_number"] = nelnet.orderNumber
      redirect nelnet.url
    else
      flash[:error] = "You don't need to overpay!!!"
      redirect '/fines-and-fees'
    end

  end

  get '/receipt' do
    receipt = Receipt.for(uniqname: session[:uniqname], nelnet_params: params, order_number: session[:order_number])
    if receipt.successful?
      flash.now[:success] = "Fines successfully paid"
    else
      flash.now[:error] = receipt.message 
    end
    erb :'fines-and-fees/receipt', :locals => {receipt: receipt}
  end

end
