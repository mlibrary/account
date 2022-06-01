require "sinatra"
require "sinatra/namespace"
require "sinatra/reloader" if development?
require "sinatra/flash"
require "redcarpet"
require "omniauth"
require "omniauth_openid_connect"
require "alma_rest_client"
require "jwt"
require "byebug" if development?

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
require_relative "./lib/table_controls"
require_relative "./lib/pagination/pagination"
require_relative "./lib/pagination/pagination_decorator"
require_relative "./lib/circulation_history_settings_text"

require_relative "./models/illiad_patron"
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

require_relative "./lib/routes/auth"
require_relative "./lib/routes/monitoring"
require_relative "./lib/routes/current_checkouts"
require_relative "./lib/routes/pending_requests"
require_relative "./lib/routes/past_activity"
require_relative "./lib/routes/fines_and_fees"

helpers StyledFlash

enable :sessions
set :session_secret, ENV["RACK_COOKIE_SECRET"]
set server: "thin", connections: []
use Rack::Logger

before do
  pass if ["auth", "stream", "updater", "session_switcher", "logout", "login"].include? request.path_info.split("/")[1]
  if dev_login?
    if !session[:uniqname]
      redirect "/session_switcher?uniqname=#{CGI.escape("mlibrary.acct.testing1@gmail.com")}"
    end
    pass
  end
  if !session[:authenticated] || Time.now.utc > session[:expires_at]
    session[:path_before_login] = request.path_info
    redirect "/login"
  end
end

helpers do
  def dev_login?
    ENV["WEBLOGIN_ON"] == "false" && settings.environment == :development
  end
end

get "/stream", provides: "text/event-stream" do
  stream :keep_open do |out|
    settings.connections << {uniqname: session[:uniqname], out: out}
    out.callback do
      settings.connections.delete(settings.connections.detect { |x| x[:out] == out })
    end
  end
end
post "/updater/" do
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
post "/table-controls" do
  url_generator = TableControls::URLGenerator.for(show: params["show"], sort: params["sort"], referrer: request.referrer)
  redirect url_generator.to_s
end
# :nocov:
get "/session_switcher" do
  patron = SessionPatron.new(params[:uniqname])
  patron.to_h.each { |k, v| session[k] = v }
  redirect back
end
# :nocov:

get "/" do
  erb :"account-overview/index", locals: {cards: Navigation.cards}
end

get "/favorites" do
  redirect "https://apps.lib.umich.edu/my-account/favorites"
end

namespace "/settings" do
  get "" do
    patron = Patron.for(uniqname: session[:uniqname])
    erb :"settings/index", locals: {patron: patron, has_js: true}
  end
  post "/history" do
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
# TODO set up renew loan to handle renew in place with top part message???
post "/renew-loan" do
  response = Loan.renew(uniqname: session[:uniqname], loan_id: params["loan_id"])
  if response.code == 200
    loan = response.parsed_response
    status 200
    {due_date: DateTime.patron_format(loan["due_date"]), loan_id: loan["loan_id"]}.to_json
  else
    error = AlmaError.new(response)
    status error.code
    {message: error.message}.to_json
  end
end

post "/sms" do
  patron = Patron.for(uniqname: session[:uniqname])
  response = patron.update_sms(params["text-notifications"] == "on" ? params["sms-number"] : "")
  if response.code == 200
    flash[:success] = if params["text-notifications"] == "on"
      "<span class='strong'>Success:</span> SMS Successfully Updated"
    else
      "<span class='strong'>Success:</span> SMS Successfully Removed"
    end
  else
    flash[:error] = "<span class='strong'>Error:</span> #{response.message}"
  end
  redirect "/settings"
end
