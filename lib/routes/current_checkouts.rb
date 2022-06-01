namespace "/current-checkouts" do
  get "" do
    redirect_to "/u-m-library"
  end

  get "/" do
    redirect_to "/u-m-library"
  end

  get "/u-m-library" do
    if session[:in_alma]
      loan_controls = TableControls::LoansForm.new(limit: params["limit"], order_by: params["order_by"], direction: params["direction"])
      begin
        loans = Loans.for(uniqname: session[:uniqname], offset: params["offset"], limit: params["limit"], order_by: params["order_by"], direction: params["direction"])
        message = session.delete(:message)
        erb :"current-checkouts/u-m-library", locals: {loans: loans, message: message, loan_controls: loan_controls, has_js: true}
      rescue
        flash[:error] = "<span class='strong'>Error:</span> We were unable to load your loans. Please try again."
        erb :empty_state
      end
    else
      erb :empty_state
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

  get "/interlibrary-loan" do
    interlibrary_loans = InterlibraryLoans.for(uniqname: session[:uniqname], limit: params["limit"], offset: params["offset"], count: nil)

    erb :"current-checkouts/interlibrary-loan", locals: {interlibrary_loans: interlibrary_loans}
  end
  get "/scans-and-electronic-items" do
    document_delivery = DocumentDelivery.for(uniqname: session[:uniqname], limit: params["limit"], offset: params["offset"], count: nil)

    erb :"current-checkouts/scans-and-electronic-items", locals: {document_delivery: document_delivery}
  end
end
