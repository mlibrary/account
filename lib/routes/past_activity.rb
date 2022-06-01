namespace "/past-activity" do
  get "" do
    redirect_to "/u-m-library" # Redirects to /past-activity/um-library
  end

  get "/" do
    redirect_to "/u-m-library" # Redirects to /past-activity/um-library
  end

  namespace "/u-m-library" do
    get "" do
      if session[:in_circ_history]
        table_controls = TableControls::PastLoansForm.new(limit: params["limit"], order_by: params["order_by"], direction: params["direction"])
        past_loans = CirculationHistoryItems.for(uniqname: session[:uniqname], offset: params["offset"], limit: params["limit"], order_by: params["order_by"], direction: params["direction"])
        erb :"past-activity/u-m-library", locals: {past_loans: past_loans, table_controls: table_controls}
      else
        erb :empty_state
      end
    end
    get "/download.csv" do
      resp = CircHistoryClient.new(session[:uniqname]).download_csv
      if resp.code == 200
        # mrio: I'm sorry getting the filename from content-disposition is like this. :(
        filename = resp.headers["content-disposition"]&.split("; ")&.at(1)&.split('"')&.at(1)
        filename = "my_filename.csv" if filename.nil?
        content_type "application/csv"
        attachment filename
        resp.body
      else
        flash[:error] = "<span class='strong'>Error:</span> We were unable to download your checkout history. Please try again."
        redirect "/past-activity/u-m-library" # Redirects to /past-activity/um-library
      end
    end
  end

  get "/interlibrary-loan" do
    past_interlibrary_loans = PastInterlibraryLoans.for(uniqname: session[:uniqname], limit: params["limit"], offset: params["offset"], count: nil)
    # session[:past_interlibrary_loans_count] = past_interlibrary_loans.count if session[:past_interlibrary_loans_count].nil?

    erb :"past-activity/interlibrary-loan", locals: {past_interlibrary_loans: past_interlibrary_loans}
  end
  get "/scans-and-electronic-items" do
    past_document_delivery = PastDocumentDelivery.for(uniqname: session[:uniqname], limit: params["limit"], offset: params["offset"], count: nil)
    # session[:past_document_delivery_count] = past_document_delivery.count if session[:past_document_delivery_count].nil?

    erb :"past-activity/scans-and-electronic-items", locals: {past_document_delivery: past_document_delivery}
  end
  get "/special-collections" do
    erb :"past-activity/special-collections", locals: {past_special_collections: {}}
  end
end
