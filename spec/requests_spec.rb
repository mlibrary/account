require "spec_helper"
describe "requests" do
  include Rack::Test::Methods
  before(:each) do
    @session = {
      uniqname: "tutor",
      in_alma: true,
      in_circ_history: true,
      in_illiad: true,
      can_book: false,
      confirmed_history_setting: false,
      authenticated: true,
      expires_at: Time.now + 1.day

    }
    env "rack.session", @session
  end
  let(:not_in_alma) do
    @session[:in_alma] = false
    env "rack.session", @session
  end

  context "not yet logged in" do
    it "sets the path in the session before sending off to omniauth" do
      @session[:authenticated] = false
      env "rack.session", @session
      get "/settings"
      expect(last_request.env["rack.session"][:path_before_login]).to eq("/settings")
      expect(URI.parse(last_response.location).path).to eq("/login")
    end
  end

  context "get '/auth/openid_connect/callback'" do
    let(:omniauth_auth) {
      {
        info: {nickname: "nottutor"},
        credentials: {expires_in: 86399}
      }
    }
    before(:each) do
      stub_alma_get_request(url: "users/nottutor?expand=none&user_id_type=all_unique&view=full", status: 400)
      stub_circ_history_get_request(url: "users/nottutor")
      stub_illiad_get_request(url: "Users/nottutor", status: 404)
      OmniAuth.config.add_mock(:openid_connect, omniauth_auth)
    end
    it "sets session to appropriate values and redirects to home" do
      get "/auth/openid_connect/callback"
      session = last_request.env["rack.session"]
      expect(session[:authenticated]).to eq(true)
      expect(session[:uniqname]).to eq("nottutor")
      expect(session[:in_illiad]).to eq(false)
      expect(session[:expires_at]).to be <= (Time.now.utc + 1.hour)
      expect(URI.parse(last_response.location).path).to eq("/")
    end
    it "redirects to location stored in the session" do
      @session[:path_before_login] = "/settings"
      env "rack.session", @session
      get "/auth/openid_connect/callback"
      expect(last_request.env["rack.session"][:path_before_login]).to be_nil
      expect(URI.parse(last_response.location).path).to eq("/settings")
    end
  end

  context "post /updater/" do
    it "returns 403 if message doesn't authenticate" do
      post "/updater/", {msg: "one", uniqname: "tutor", hash: "notcorrect"}
      expect(last_response.status).to eq(403)
    end
    it "returns 204 and posts data to connections for uniqname if hash is correct" do
      params = {step: "1", count: "1"}
      query = Authenticator.params_with_signature(params: {**params, uniqname: "tutor"})
      connections = Sinatra::Application.settings.connections
      connections << {uniqname: "blah", out: []}
      connections << {uniqname: "tutor", out: []}
      post "/updater/#{query}"
      expect(connections.detect { |x| x[:uniqname] == "tutor" }[:out].first).to eq("data: #{params.to_json}\n\n")
      expect(connections.detect { |x| x[:uniqname] == "blah" }[:out].count).to eq(0)
    end
  end
  context "post /table-controls" do
    # it "redirects to current-checkouts with appropriate params" do
    # #header "Referer", 'http://localhost:4567/referer'

    # post "/table-controls", {show: '30', sort: 'title-desc'}, {'rack.session' => @session }
    # uri = URI.parse(last_response.location)
    # params = CGI.parse(uri.query)
    # expect(uri.path).to eq("/referer")
    # expect(params["limit"].first).to eq("30")
    # expect(params["direction"].first).to eq("DESC")
    # expect(params["order_by"].first).to eq('title')
    # end
  end
  context "get /" do
    it "contains 'Account Overview'" do
      stub_alma_get_request(url: "users/tutor?expand=none&user_id_type=all_unique&view=full")
      get "/"
      expect(last_response.body).to include("Account Overview")
    end
  end
  context "get /current-checkouts" do
    it "redirects to '/current-checkouts/u-m-library'" do
      get "/current-checkouts"
      expect(last_response.status).to eq(302)
      expect(URI(last_response.headers["Location"]).path).to eq("/current-checkouts/u-m-library")
    end
  end
  context "get /current-checkouts/" do
    it "redirects to '/current-checkouts/u-m-library'" do
      get "/current-checkouts/"
      expect(last_response.status).to eq(302)
      expect(URI(last_response.headers["Location"]).path).to eq("/current-checkouts/u-m-library")
    end
  end
  context "get /current-checkouts/u-m-library" do
    context "in alma user" do
      before(:each) do
        stub_alma_get_request(url: "users/tutor/loans", query: {expand: "renewable", limit: 15, order_by: "due_date"})
      end
      it "contains 'U-M Library'" do
        get "/current-checkouts/u-m-library"
        expect(last_response.body).to include("U-M Library")
      end
      it "has checkouts js" do
        get "/current-checkouts/u-m-library"
        expect(last_response.body).to include("current-checkouts-u-m-library.bundle.js")
      end
    end
    context "in alma user but alma has a network problem" do
      it "loads the empty state and has an error flash" do
        stub_alma_get_request(url: "users/tutor/loans", query: {expand: "renewable", limit: 15, order_by: "due_date"}, status: 500)
        get "/current-checkouts/u-m-library"
        session = last_request.env["rack.session"]
        expect(session["flash"][:error]).to include("Error")
        expect(last_response.body).to include("You don't have")
      end
    end
    context "not in alma user" do
      it "has empty checkouts" do
        not_in_alma
        get "/current-checkouts/u-m-library"
        expect(last_response.body).to include("You don't have")
      end
    end
  end
  context "post /current-checkouts/u-m-library" do
    before(:each) do
      @alma_loans = JSON.parse(File.read("./spec/fixtures/loans.json"))
      @alma_loans["item_loan"][0]["renewable"] = false
      stub_alma_get_request(url: "users/tutor/loans", body: @alma_loans.to_json, query: {expand: "renewable", limit: 100, offset: 0})
      stub_alma_get_request(url: "users/tutor/loans", body: @alma_loans.to_json, query: {expand: "renewable"})
      stub_alma_post_request(url: "users/tutor/loans/1332733700000521", query: {op: "renew"})
      stub_alma_post_request(url: "users/tutor/loans/1332734190000521", query: {op: "renew"})
      stub_updater({step: "1", count: "0", renewed: "0", uniqname: "tutor"})
      stub_updater({step: "2", count: "1", renewed: "1", uniqname: "tutor"})
      stub_updater({step: "2", count: "2", renewed: "2", uniqname: "tutor"})
      stub_updater({step: "3", count: "2", renewed: "2", uniqname: "tutor"})
    end
    it "shows appropriate " do
      stub_updater({step: "2", count: "1", renewed: "0", uniqname: "tutor"})
      stub_updater({step: "3", count: "1", renewed: "1", uniqname: "tutor"})
      post "/current-checkouts/u-m-library"
      session = last_request.env["rack.session"]
      expect(session["message"].renewed).to eq(1)
    end
    it "has correct counts for none renewable" do
      @alma_loans["item_loan"][1]["renewable"] = false
      stub_alma_get_request(url: "users/tutor/loans", body: @alma_loans.to_json, query: {expand: "renewable", limit: 100, offset: 0})
      stub_alma_get_request(url: "users/tutor/loans", body: @alma_loans.to_json, query: {expand: "renewable"})

      stub_updater({step: "2", count: "0", renewed: "0", uniqname: "tutor"})
      stub_updater({step: "3", count: "0", renewed: "0", uniqname: "tutor"})
      post "/current-checkouts/u-m-library"
      session = last_request.env["rack.session"]
      expect(session["message"].renewed).to eq(0)
    end
    it "shows error flash for major Alma Error" do
      stub_alma_get_request(url: "users/tutor/loans", body: File.read("./spec/fixtures/alma_error.json"), query: {expand: "renewable", limit: 100, offset: 0}, status: 400)
      post "/current-checkouts/u-m-library"
      session = last_request.env["rack.session"]
      expect(session["flash"][:error]).to include("Error")
    end
  end

  context "get /current-checkouts/interlibrary-loan" do
    it "contains 'Interlibrary Loan'" do
      stub_illiad_get_request(url: "Transaction/UserRequests/tutor",
        body: File.read("spec/fixtures/illiad_requests.json"), query: hash_excluding({just_pass: "for_real"}))
      get "/current-checkouts/interlibrary-loan"
      expect(last_response.body).to include("Interlibrary Loan")
    end
  end
  context "get /current-checkouts/scans-and-electronic-items" do
    it "contains 'Scans and Electronic Items'" do
      stub_illiad_get_request(url: "Transaction/UserRequests/tutor",
        body: File.read("spec/fixtures/illiad_requests.json"), query: hash_excluding({just_pass: "for_real"}))
      get "/current-checkouts/scans-and-electronic-items"
      expect(last_response.body).to include("Scans and Electronic Items")
    end
  end
  context "get /pending-requests" do
    it "redirects to '/pending-requests/u-m-library'" do
      get "/pending-requests"
      expect(last_response.status).to eq(302)
      expect(URI(last_response.headers["Location"]).path).to eq("/pending-requests/u-m-library")
    end
  end
  context "get /pending-requests/" do
    it "redirects to '/pending-requests/u-m-library'" do
      get "/pending-requests/"
      expect(last_response.status).to eq(302)
      expect(URI(last_response.headers["Location"]).path).to eq("/pending-requests/u-m-library")
    end
  end
  context "get /pending-requests/u-m-library" do
    context "in alma" do
      it "contains 'U-M Library'" do
        stub_alma_get_request(url: "users/tutor/requests", body: File.read("./spec/fixtures/requests.json"), query: {limit: 100, offset: 0})
        stub_illiad_get_request(url: "Users/tutor", status: 404)
        stub_illiad_get_request(url: "Transaction/UserRequests/tutor",
          body: "[]", query: hash_excluding({just_pass: "for_real"}))
        get "/pending-requests/u-m-library"
        expect(last_response.body).to include("U-M Library")
      end
      it "loads empty state when theres an error with an alma request" do
        stub_alma_get_request(url: "users/tutor/requests", status: 500, query: {limit: 100, offset: 0})
        get "/pending-requests/u-m-library"
        session = last_request.env["rack.session"]
        expect(session["flash"][:error]).to include("Error")
        expect(last_response.body).to include("You don't have")
      end
    end
    context "not in alma" do
      it "shows empty sate pending requests" do
        not_in_alma
        get "/pending-requests/u-m-library"
        expect(last_response.body).to include("You don't have")
      end
    end
  end
  context "get /pending-requests/interlibrary-loan" do
    it "contains 'From Other Institutions (Interlibrary Loan)'" do
      stub_illiad_get_request(url: "Transaction/UserRequests/tutor",
        body: File.read("spec/fixtures/illiad_requests.json"), query: hash_excluding({just_pass: "for_real"}))
      get "/pending-requests/interlibrary-loan"
      expect(last_response.body).to include("Interlibrary Loan")
    end
  end
  context "get /pending-requests/special-collections" do
    it "exists" do
      get "/pending-requests/special-collections"
      expect(last_response.status).to eq(200)
    end
  end
  context "get /past-activity" do
    it "redirects to '/past-activity/u-m-library'" do
      get "/past-activity"
      expect(last_response.status).to eq(302)
      expect(URI(last_response.headers["Location"]).path).to eq("/past-activity/u-m-library")
    end
  end
  context "get /past-activity/" do
    it "redirects to '/past-activity/u-m-library'" do
      get "/past-activity/"
      expect(last_response.status).to eq(302)
      expect(URI(last_response.headers["Location"]).path).to eq("/past-activity/u-m-library")
    end
  end
  context "get /past-activity/u-m-library" do
    context "in circ history user" do
      it "exists" do
        stub_circ_history_get_request(url: "users/tutor/loans", output: File.read("spec/fixtures/circ_history_loans.json"), query: {direction: "DESC"})
        get "/past-activity/u-m-library"
        expect(last_response.status).to eq(200)
      end
    end
    context "not in circ history user" do
      it "show do not have circ history" do
        @session[:in_circ_history] = false
        env "rack.session", @session
        get "/past-activity/u-m-library"
        expect(last_response.body).to include("You don't have")
      end
    end
  end
  context "get /past-activity/u-m-library/download.csv" do
    it "successfully returns an attachment" do
      stub_request(:get, "#{ENV["CIRCULATION_HISTORY_URL"]}/v1/users/tutor/loans/download.csv").with(
        headers: {
          :accept => "application/json",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "User-Agent" => "Ruby"
        }
      ).to_return(body: "sample csv", status: 200, headers: {
        content_type: "application/csv",
        "content-disposition": "attachment; filename=\"my_circ_history.csv\""
      })
      get "/past-activity/u-m-library/download.csv"
      expect(last_response.headers["Content-Type"]).to eq("application/csv")
      expect(last_response.headers["Content-Disposition"]).to include("my_circ_history.csv")
    end
    it "redirects to past activity page with an error message" do
      stub_circ_history_get_request(url: "users/tutor/loans/download.csv", status: 500)
      get "/past-activity/u-m-library/download.csv"
      session = last_request.env["rack.session"]
      expect(session["flash"][:error]).to include("Error")
    end
  end
  context "get /past-activity/interlibrary-loan" do
    it "contains 'Interlibrary Loan'" do
      stub_illiad_get_request(url: "Transaction/UserRequests/tutor",
        body: File.read("spec/fixtures/illiad_requests.json"), query: hash_excluding({just_pass: "for_real"}))
      get "/past-activity/interlibrary-loan"
      expect(last_response.body).to include("Interlibrary Loan")
    end
  end
  context "get /past-activity/scans-and-electronic-items" do
    it "contains 'Scans and Electronic Items'" do
      stub_illiad_get_request(url: "Transaction/UserRequests/tutor",
        body: File.read("spec/fixtures/illiad_requests.json"), query: hash_excluding({just_pass: "for_real"}))
      get "/past-activity/scans-and-electronic-items"
      expect(last_response.body).to include("Scans and Electronic Items")
    end
  end
  context "get /past-activity/special-collections" do
    it "exists" do
      get "/past-activity/special-collections"
      expect(last_response.status).to eq(200)
    end
  end
  context "get /fines-and-fees" do
    context "in alma user" do
      it "contains 'Fines'" do
        stub_alma_get_request(url: "users/tutor/fees", query: {limit: 100, offset: 0},
          body: File.read("spec/fixtures/jbister_fines.json"))
        get "/fines-and-fees"
        expect(last_response.body).to include("Fines")
      end
      it "shows error and empty state if there's an failed alma request" do
        stub_alma_get_request(url: "users/tutor/fees", status: 500, query: {limit: 100, offset: 0})
        get "/fines-and-fees"
        session = last_request.env["rack.session"]
        expect(session["flash"][:error]).to include("Error")
        expect(last_response.body).to include("You don't have")
      end
    end
    context "not in alma user" do
      it "show do not have fines and fees" do
        not_in_alma
        get "/fines-and-fees"
        expect(last_response.body).to include("You don't have")
      end
    end
  end
  context "get /favorites" do
    it "goes to olde favorites" do
      get "/favorites"
      expect(last_response.status).to eq(302)
      expect(last_response.location).to eq("https://apps.lib.umich.edu/my-account/favorites")
    end
  end
  context "get /settings" do
    it "contains 'Settings'" do
      stub_alma_get_request(url: "users/tutor?expand=none&user_id_type=all_unique&view=full")
      stub_circ_history_get_request(url: "users/tutor")
      stub_illiad_get_request(url: "Users/tutor", status: 404)
      get "/settings"
      expect(last_response.body).to include("Settings")
    end
  end
  context "post /settings/history" do
    before(:each) do
      @patron_json = File.read("./spec/fixtures/mrio_user_alma.json")
      stub_alma_get_request(url: "users/tutor?expand=none&user_id_type=all_unique&view=full", body: @patron_json)
      stub_circ_history_get_request(url: "users/tutor")
      stub_circ_history_put_request(url: "users/tutor", query: {retain_history: true})
      stub_illiad_get_request(url: "Users/tutor", status: 404)
    end
    it "handles retain history" do
      @session[:confirmed_history_setting] = false
      env "rack.session", @session
      post "/settings/history", {"retain_history" => "true"}
      follow_redirect!
      expect(last_response.body).to include("History Setting Successfully Changed")
      expect(last_request.env["rack.session"][:confirmed_history_setting]).to eq(true)
    end
  end
  # ToDO
  # context "post /renew-loan" do
  # before(:each) do
  # stub_alma_get_request(url: "users/tutor/loans", query: {expand: 'renewable'})
  # end
  # it "handles good request" do
  # stub_alma_post_request(url: "users/tutor/loans/1234", query: {op: 'renew'} )
  # post "/renew-loan", {'loan_id' => '1234'}
  # expect(URI(last_response.headers["Location"]).path).to eq("/current-checkouts/loans")
  # follow_redirect!
  # expect(last_response.body).to include("Loan Successfully Renewed")
  # end
  # it "handles bad request" do
  # stub_alma_post_request(url: "users/tutor/loans/1234", query: {op: 'renew'}, status: 500 )
  # post "/renew-loan", {'loan_id' => '1234'}
  # expect(URI(last_response.headers["Location"]).path).to eq("/current-checkouts/loans")
  # follow_redirect!
  # expect(last_response.body).to include("Error")
  # end
  # end
  context "post /pending-requests/u-m-library/cancel-request" do
    before(:each) do
      @req = stub_alma_get_request(url: "users/tutor/requests", body: File.read("./spec/fixtures/requests.json"))
    end
    it "handles good cancel request" do
      stub_alma_delete_request(url: "users/tutor/requests/1234", status: 204, body: "{}", query: {reason: "CancelledAtPatronRequest"})
      post "/pending-requests/u-m-library/cancel-request", {"request_id" => "1234"}
      expect(last_response.status).to eq(200)
    end
  end
  context "post /sms" do
    before(:each) do
      @patron_json = File.read("./spec/fixtures/mrio_user_alma.json")
      stub_alma_get_request(url: "users/tutor?expand=none&user_id_type=all_unique&view=full", body: @patron_json)
      stub_circ_history_get_request(url: "users/tutor")
      stub_illiad_get_request(url: "Users/tutor", status: 404)
    end
    it "handles good phone number update" do
      sms_number = "(734) 555-5555"
      new_phone_patron = JSON.parse(@patron_json)
      new_phone_patron["contact_info"]["phone"][1]["phone_number"] = sms_number

      stub_alma_put_request(url: "users/mrio", input: new_phone_patron.to_json, output: new_phone_patron.to_json)

      post "/sms", {"text-notifications" => "on", "sms-number" => sms_number}
      follow_redirect!
      expect(last_response.body).to include("SMS Successfully Updated")
    end
    it "handles bad phone number update" do
      post "/sms", {"text-notifications" => "on", "sms-number" => "aaa"}
      follow_redirect!
      expect(last_response.body).to include("is invalid")
    end
    it "handles phone number removal" do
      new_phone_patron = JSON.parse(@patron_json)
      new_phone_patron["contact_info"]["phone"].delete_at(1)
      stub_alma_put_request(url: "users/mrio", input: new_phone_patron.to_json, output: new_phone_patron.to_json)
      post "/sms", {"text-notifications" => "off", "sms-number" => ""}
      follow_redirect!
      expect(last_response.body).to include("SMS Successfully Removed")
    end
  end
  context "post /fines-and-fees/pay" do
    before(:each) do
      stub_alma_get_request(url: "users/tutor/fees", body: File.read("./spec/fixtures/jbister_fines.json"), query: {limit: 100, offset: 0})
    end
    it "for pay in full redirects to nelnet with total amountDue" do
      post "/fines-and-fees/pay", {"pay_in_full" => "true", "partial_amount" => "0.00"}
      query = Addressable::URI.parse(last_response.location).query_values
      expect(query["amountDue"]).to eq("2500")
    end
    it "for pay in part redirects to nelnet with partial amountDue" do
      post "/fines-and-fees/pay", {"pay_in_full" => "false", "partial_amount" => "2.77"}
      query = Addressable::URI.parse(last_response.location).query_values
      expect(query["amountDue"]).to eq("277")
    end
    it "redirects back to fines and fees with error if user tries to overpay" do
      post "/fines-and-fees/pay", {"pay_in_full" => "false", "partial_amount" => "100"}
      expect(last_response.status).to eq(302)
      expect(URI(last_response.headers["Location"]).path).to eq("/fines-and-fees")
    end
  end
  context "get /fines-and-fees/receipt" do
    before(:each) do
      @params = {
        "transactionType" => "1",
        "transactionStatus" => "1",
        "transactionId" => "382481568",
        "transactionTotalAmount" => "2250",
        "transactionDate" => "202001211341",
        "transactionAcountType" => "VISA",
        "transactionResultCode" => "267849",
        "transactionResultMessage" => "Approved and completed",
        "orderNumber" => "Afam.1608566536797",
        "orderType" => "UMLibraryCirc",
        "orderDescription" => "U-M Library Circulation Fines",
        "payerFullName" => "Aardvark Jones",
        "actualPayerFullName" => "Aardvark Jones",
        "accountHolderName" => "Aardvark Jones",
        "streetOne" => "555 S STATE ST",
        "streetTwo" => "",
        "city" => "Ann Arbor",
        "state" => "MI",
        "zip" => "48105",
        "country" => "UNITED STATES",
        "email" => "aardvark@umich.edu",
        "timestamp" => "1579628471900",
        "hash" => "9baaee6c2a0ee08c63bbbcc0435360b0d5ecef1de876b68d59956c0752fed836"
      }
      @item = {
        "id" => "1384289260006381",
        "balance" => "5.00",
        "title" => "Short history of Georgia.",
        "barcode" => "95677",
        "library" => "Main Library",
        "type" => "Overdue fine",
        "creation_time" => "2020-12-09T17:13:29.959Z"
      }
    end
    it "for valid params, updates Alma, sets success flash, prints receipt" do
      with_modified_env NELNET_SECRET_KEY: "secret" do
        stub_alma_get_request(url: "users/tutor/fees", query: {limit: 100, offset: 0},
          body: File.read("spec/fixtures/jbister_fines.json"))
        @session[:order_number] = "382481568"
        env "rack.session", @session
        stub_alma_post_request(url: "users/tutor/fees/all", query: {op: "pay", amount: "22.50", method: "ONLINE", external_transaction_id: "382481568"}, body: File.read("spec/fixtures/fines_pay_amount.json"))

        get "/fines-and-fees/receipt", @params
        expect(last_response.body).to include("Fines successfully paid")
      end
    end
    it "for invalid params,  sets fail flash" do
      with_modified_env NELNET_SECRET_KEY: "incorect_secret" do
        stub = stub_alma_post_request(url: "users/tutor/fees/all", query: {op: "pay", amount: "22.50", method: "ONLINE", external_transaction_id: "382481568"})

        get "/fines-and-fees/receipt", @params
        expect(last_response.body).to include("Your payment could not be validated")
        expect(stub).not_to have_been_requested
      end
    end
    def with_modified_env(options, &block)
      ClimateControl.modify(options, &block)
    end
  end
end
