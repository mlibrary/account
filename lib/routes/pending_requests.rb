namespace "/pending-requests" do
  get "" do
    redirect_to "/u-m-library" # Redirects to /requests/um-library
  end

  get "/" do
    redirect_to "/u-m-library" # Redirects to /requests/um-library
  end

  get "/u-m-library" do
    if session[:in_alma]
      begin
        requests = Requests.for(uniqname: session[:uniqname])
        local_document_delivery = PendingLocalDocumentDelivery.for(uniqname: session[:uniqname])
        illiad_patron = ILLiadPatron.for(uniqname: session[:uniqname])
        erb :"pending-requests/u-m-library", locals: {holds: requests.holds, bookings: requests.bookings, local_document_delivery: local_document_delivery, illiad_patron: illiad_patron}
      rescue
        flash[:error] = "<span class='strong'>Error:</span> We were unable to load your requests. Please try again."
        erb :empty_state
      end
    else
      erb :empty_state
    end
  end
  post "/u-m-library/cancel-request" do
    response = Request.cancel(uniqname: session[:uniqname], request_id: params["request_id"])
    if response.code == 204
      status 200
      {}.to_json
    else
      error = AlmaError.new(response)
      status error.code
      {message: error.message}.to_json
    end
  end

  get "/interlibrary-loan" do
    interlibrary_loan_requests = InterlibraryLoanRequests.for(uniqname: session[:uniqname], limit: params["limit"], offset: params["offset"], count: nil)

    erb :"pending-requests/interlibrary-loan", locals: {interlibrary_loan_requests: interlibrary_loan_requests}
  end

  get "/special-collections" do
    erb :"pending-requests/special-collections", locals: {special_collections_requests: {}}
  end
end
