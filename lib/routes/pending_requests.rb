namespace "/pending-requests" do
  get "/?" do
    redirect_to "/u-m-library" # Redirects to /requests/um-library
  end

  get "/u-m-library/?" do
    raise StandardError, "not_in_alma" unless session[:in_alma]
    requests = Requests.for(uniqname: session[:uniqname])
    local_document_delivery = PendingLocalDocumentDelivery.for(uniqname: session[:uniqname])
    illiad_patron = ILLiadPatron.for(uniqname: session[:uniqname])
    erb :"pending-requests/u-m-library", locals: {holds: requests.holds, bookings: requests.bookings, local_document_delivery: local_document_delivery, illiad_patron: illiad_patron}
  rescue => e
    flash.now[:error] = "<span class='strong'>Error:</span> We were unable to load your requests. Please try again." unless e.message == "not_in_alma"
    erb :empty_state
  end
  post "/u-m-library/cancel-request" do
    response = Request.cancel(uniqname: session[:uniqname], request_id: params["request_id"])
    if response.status == 204
      status 200
      {}.to_json
    else
      error = AlmaError.new(response)
      status error.code
      {message: error.message}.to_json
    end
  rescue
    status 500
    {message: "There was an error"}.to_json
  end

  get "/interlibrary-loan/?" do
    interlibrary_loan_requests = InterlibraryLoanRequests.for(uniqname: session[:uniqname], limit: params["limit"], offset: params["offset"], count: nil)

    erb :"pending-requests/interlibrary-loan", locals: {interlibrary_loan_requests: interlibrary_loan_requests}
  rescue
    flash[:error].now = "<span class='strong'>Error:</span> We were unable to load your interlibrary loan pending requests. Please try again."
    erb :empty_state
  end

  get "/special-collections/?" do
    erb :"pending-requests/special-collections", locals: {special_collections_requests: {}}
  end
end
