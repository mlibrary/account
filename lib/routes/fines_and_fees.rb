namespace "/fines-and-fees" do
  get "/?" do
    raise StandardError, "not_in_alma" unless session[:in_alma]
    fines = Fines.for(uniqname: session[:uniqname])
    erb :"fines-and-fees/index", locals: {fines: fines}
  rescue => e
    flash.now[:error] = "<span class='strong'>Error:</span> We were unable to load your fines. Please try again." unless e.message == "not_in_alma"
    erb :empty_state
  end

  post "/pay" do
    fines = Fines.for(uniqname: session[:uniqname])
    total_sum = fines.total_sum.to_f

    amount = (params["pay_in_full"] == "true") ? total_sum : params["partial_amount"].to_f
    if amount <= total_sum
      nelnet = Nelnet.new(amount_due: amount.to_currency)
      session["order_number"] = nelnet.order_number
      S.logger.info("fine_payment_start", message: "Fine payment started", order_number: nelnet.order_number)
      redirect nelnet.url
    else
      flash[:error] = "You don't need to overpay!!!"
      redirect "/fines-and-fees"
    end
  rescue => e
    S.logger.error("fine_payment_error", message: "Unable to redirect to payment website: #{e.detailed_message}")
    flash[:error] = "<span class='strong'>Error:</span> We were unable to redirect you to the payment website. Please try again"
    redirect "/fines-and-fees"
  end

  get "/receipt/?" do
    receipt = Receipt.for(uniqname: session[:uniqname], nelnet_params: params, order_number: session[:order_number])
    if receipt.successful?
      flash.now[:success] = "Fines successfully paid"
    else
      flash.now[:error] = receipt.message
      S.logger.error(receipt.message)
    end
    erb :"fines-and-fees/receipt", locals: {receipt: receipt}
  rescue
    redirect "/fines-and-fees"
  end
end
