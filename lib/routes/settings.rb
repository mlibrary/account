namespace "/settings" do
  get "/?" do
    patron = Patron.for(uniqname: session[:uniqname])
    erb :"settings/index", locals: {patron: patron, has_js: true}
  end
  post "/history" do
    response = Patron.set_retain_history(uniqname: session[:uniqname], retain_history: params[:retain_history])
    raise StandardError if response.code != 200
    session[:confirmed_history_setting] = true
    flash[:success] = "<span class='strong'>Success:</span> History Setting Successfully Changed"
    redirect "/settings"
  rescue
    flash[:error] = "Unable to update your checkout history setting. Please try again."
    redirect "/settings"
  end
end

post "/sms" do
  patron = Patron.for(uniqname: session[:uniqname])
  response = patron.update_sms(params["text-notifications"] == "on" ? params["sms-number"] : "")
  if response.code == 200
    flash[:success] = if params["text-notifications"] == "on"
      "<span class='strong'>Success:</span> Your SMS number was successfully updated"
    else
      "<span class='strong'>Success:</span> Your SMS number was successfully removed"
    end
  else
    flash[:error] = "<span class='strong'>Error:</span> #{response.message}"
  end
  redirect "/settings"
rescue
  flash[:error] = "<span class='strong'>Error:</span> We were unable to update your SMS number."
  redirect "/settings"
end
