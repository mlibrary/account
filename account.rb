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
require "ostruct"

# Monkey patch for omniauth_openid_connect -> openid_connect -> webfinger -> httpclient SSL errors
# require_relative "./lib/monkey_httpclient"

require_relative "lib/services"

require_relative "lib/entities/entities"
require_relative "lib/entities/pages"
require_relative "lib/entities/empty_state"

require_relative "lib/navigation/navigation"
require_relative "lib/navigation/page"
require_relative "lib/navigation/horizontal_nav"
require_relative "lib/navigation/sidebar"
require_relative "lib/navigation/user_dropdown"
require_relative "lib/navigation/title"
require_relative "lib/navigation/description"

require_relative "lib/utility"
require_relative "lib/illiad_client"
require_relative "lib/circ_history_client"
require_relative "lib/table_controls"
require_relative "lib/pagination/pagination"
require_relative "lib/pagination/pagination_decorator"
require_relative "lib/circulation_history_settings_text"

require_relative "models/illiad_patron"
require_relative "models/patron"
require_relative "models/session_patron"

require_relative "models/response/response"
require_relative "models/response/renew_response_presenter"

require_relative "models/fines/nelnet"
require_relative "models/fines/fines"
require_relative "models/fines/receipt"

require_relative "models/items/items"
require_relative "models/items/item"

require_relative "models/items/alma/alma_item"
require_relative "models/items/alma/loans"
require_relative "models/items/alma/requests"

require_relative "models/items/circ_history/circ_history_item"
require_relative "models/items/interlibrary_loan/interlibrary_loan_item"
require_relative "models/items/interlibrary_loan/interlibrary_loan_items"
require_relative "models/items/interlibrary_loan/document_delivery"
require_relative "models/items/interlibrary_loan/interlibrary_loans"
require_relative "models/items/interlibrary_loan/interlibrary_loan_requests"
require_relative "models/items/interlibrary_loan/past_document_delivery"
require_relative "models/items/interlibrary_loan/past_interlibrary_loans"
require_relative "models/items/interlibrary_loan/pending_document_delivery"

require_relative "lib/routes/auth"
require_relative "lib/routes/monitoring"
require_relative "lib/routes/current_checkouts"
require_relative "lib/routes/pending_requests"
require_relative "lib/routes/past_activity"
require_relative "lib/routes/settings"
require_relative "lib/routes/fines_and_fees"

helpers StyledFlash

enable :sessions
set :session_secret, ENV["RACK_COOKIE_SECRET"]
set server: "puma"

use Rack::Logger

def dev_login?
  ENV["WEBLOGIN_ON"] == "false" && settings.environment == :development
end

before do
  pass if ["auth", "session_switcher", "logout", "login", "-"].include? request.path_info.split("/")[1]

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

post "/table-controls" do
  url_generator = TableControls::URLGenerator.for(show: params["show"], sort: params["sort"], referrer: request.referrer)
  redirect url_generator.to_s
end
# :nocov:
if dev_login?
  get "/session_switcher" do
    patron = SessionPatron.new(params[:uniqname])
    patron.to_h.each { |k, v| session[k] = v }
    redirect back
  end
end
# :nocov:

get "/" do
  erb :"account-overview/index", locals: {cards: Navigation.cards}
end

not_found do
  erb :empty_state
end

error do
  flash.now[:error] = "Sorry there was an error - " + env["sinatra.error"].message
  erb :empty_state
end
