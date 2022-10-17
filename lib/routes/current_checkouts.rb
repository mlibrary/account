namespace "/current-checkouts" do
  get "/?" do
    redirect_to "/u-m-library"
  end

  # get "/" do
  # redirect_to "/u-m-library"
  # end

  get "/u-m-library/?" do
    raise StandardError, "not_in_alma" unless session[:in_alma]
    loan_controls = TableControls::LoansForm.new(limit: params["limit"], order_by: params["order_by"], direction: params["direction"])
    loans = Loans.for(uniqname: session[:uniqname], offset: params["offset"], limit: params["limit"], order_by: params["order_by"], direction: params["direction"])
    message = session.delete(:message)
    erb :"current-checkouts/u-m-library", locals: {loans: loans, message: message, loan_controls: loan_controls, has_js: true}
  rescue => e
    if e.message == "not_in_alma"
      erb :empty_state
    else
      flash.now[:error] = "<span class='strong'>Error:</span> We were unable to load your loans. Please try again." unless e.message == "not_in_alma"
      erb :error
    end
  end

  post "/u-m-library" do
    response = Loans.renew_all(uniqname: session[:uniqname])
    if response.code != 200
      flash[:error] = "<span class='strong'>Error:</span> #{response.message}"
    else
      session[:message] = RenewResponsePresenter.for(response.renewed_count)
      204
    end
  end

  get "/interlibrary-loan/?" do
    interlibrary_loans = InterlibraryLoans.for(uniqname: session[:uniqname], limit: params["limit"], offset: params["offset"], count: nil)
    erb :"current-checkouts/interlibrary-loan", locals: {interlibrary_loans: interlibrary_loans}
  rescue
    flash.now[:error] = "<span class='strong'>Error:</span> We were unable to load your interlibrary oans. Please try again."
    erb :error
  end
  get "/scans-and-electronic-items/?" do
    document_delivery = DocumentDelivery.for(uniqname: session[:uniqname], limit: params["limit"], offset: params["offset"], count: nil)

    erb :"current-checkouts/scans-and-electronic-items", locals: {document_delivery: document_delivery}
  rescue
    flash.now[:error] = "<span class='strong'>Error:</span> We were unable to load your scans and electronic items. Please try again."
    erb :empty_state
  end
end
