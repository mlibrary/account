namespace "/fines-and-fees" do
  get "" do
    if session[:in_alma]
      begin
        fines = Fines.for(uniqname: session[:uniqname])
        erb :"fines-and-fees/index", locals: {fines: fines}
      rescue
        flash[:error] = "<span class='strong'>Error:</span> We were unable to load your fines. Please try again."
        erb :empty_state
      end
    else
      erb :empty_state
    end
  end

  # :nocov:
  get "/" do
    redirect_to ""
  end
  # :nocov:

  post "/pay" do
    fines = Fines.for(uniqname: session[:uniqname])
    total_sum = fines.total_sum.to_f
    amount = params["pay_in_full"] == "true" ? total_sum : params["partial_amount"].to_f
    if amount <= total_sum
      nelnet = Nelnet.new(amount_due: amount.to_currency)
      session["order_number"] = nelnet.orderNumber
      redirect nelnet.url
    else
      flash[:error] = "You don't need to overpay!!!"
      redirect "/fines-and-fees"
    end
  end

  get "/receipt" do
    receipt = Receipt.for(uniqname: session[:uniqname], nelnet_params: params, order_number: session[:order_number])
    if receipt.successful?
      flash.now[:success] = "Fines successfully paid"
    else
      flash.now[:error] = receipt.message
    end
    erb :"fines-and-fees/receipt", locals: {receipt: receipt}
  end
end
