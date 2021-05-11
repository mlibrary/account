require 'spec_helper'
describe "requests" do
  include Rack::Test::Methods
  before(:each) do
    @session = { uniqname: 'tutor', full_name: "Julian, Tutor" }
    env 'rack.session', @session
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
      connections << { uniqname: 'blah', out: [] }
      connections << { uniqname: 'tutor', out: [] }
      post "/updater/#{query}"
      expect(connections.detect{|x| x[:uniqname] =='tutor'}[:out].first).to eq("data: #{params.to_json}\n\n")
      expect(connections.detect{|x| x[:uniqname] =='blah'}[:out].count).to  eq(0)
    end
  end
  context "post /loan-controls" do
    it "redirects to current-checkouts with appropriate params" do
      post "/loan-controls", {show: '30', sort: 'title-desc'}
      uri = URI.parse(last_response.location)
      params = CGI.parse(uri.query)
      expect(uri.path).to eq("/current-checkouts/u-m-library")
      expect(params["limit"].first).to eq("30")
      expect(params["direction"].first).to eq("DESC")
      expect(params["order_by"].first).to eq('title')
    end
  end
  context "get /" do
    it "contains 'Welcome'" do
      stub_alma_get_request(url: "users/tutor?expand=none&user_id_type=all_unique&view=full")
      get "/"
      expect(last_response.body).to include("Welcome")
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
    before(:each) do
      stub_alma_get_request(url: "users/tutor/loans", query: {expand: 'renewable', limit: 15, order_by: "due_date"})
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
  context "post /current-checkouts/u-m-library" do
    before(:each) do
      @alma_loans = JSON.parse(File.read('./spec/fixtures/loans.json')) 
      @alma_loans["item_loan"][0]["renewable"] = false
      stub_alma_get_request( url: 'users/tutor/loans', body: @alma_loans.to_json, query: {expand: 'renewable', limit: 100, offset: 0} )
      stub_alma_get_request( url: 'users/tutor/loans', body: @alma_loans.to_json, query: {expand: 'renewable'} )
      stub_alma_post_request( url: 'users/tutor/loans/1332733700000521', query: {op: 'renew'} ) 
      stub_alma_post_request( url: 'users/tutor/loans/1332734190000521', query: {op: 'renew'} ) 
      stub_updater({step: '1', count: '0', renewed: '0', uniqname: 'tutor'})
      stub_updater({step: '2', count: '1', renewed: '1', uniqname: 'tutor'})
      stub_updater({step: '2', count: '2', renewed: '2', uniqname: 'tutor'})
      stub_updater({step: '3', count: '2', renewed: '2', uniqname: 'tutor'})
    end
    it "shows appropriate " do
      stub_updater({step: '2', count: '1', renewed: '0', uniqname: 'tutor'})
      stub_updater({step: '2', count: '2', renewed: '1', uniqname: 'tutor'})
      stub_updater({step: '3', count: '2', renewed: '1', uniqname: 'tutor'})
      post "/current-checkouts/u-m-library" 
      session = last_request.env["rack.session"]
      expect(session["message"].renewed).to eq(1)
      expect(session["message"].not_renewed).to eq(1)
    end
    it "has correct counts for none renewable" do
      @alma_loans["item_loan"][1]["renewable"] = false
      stub_alma_get_request( url: 'users/tutor/loans', body: @alma_loans.to_json, query: {expand: 'renewable', limit: 100, offset: 0} )
      stub_alma_get_request( url: 'users/tutor/loans', body: @alma_loans.to_json, query: {expand: 'renewable'} )

      stub_updater({step: '2', count: '1', renewed: '0', uniqname: 'tutor'})
      stub_updater({step: '2', count: '2', renewed: '0', uniqname: 'tutor'})
      stub_updater({step: '3', count: '2', renewed: '0', uniqname: 'tutor'})
      post "/current-checkouts/u-m-library" 
      session = last_request.env["rack.session"]
      expect(session["message"].renewed).to eq(0)
      expect(session["message"].not_renewed).to eq(2)
    end
    it "shows error flash for major Alma Error" do
      stub_alma_get_request( url: 'users/tutor/loans', body: File.read('./spec/fixtures/alma_error.json'), query: {expand: 'renewable', limit: 100, offset: 0}, status: 400 )
      post "/current-checkouts/u-m-library"
      session = last_request.env["rack.session"]
      expect(session["flash"][:error]).to include("Error")
    end
  end
  
  context "get /current-checkouts/interlibrary-loan" do
    it "contains 'Interlibrary Loan'" do
      stub_illiad_get_request(url: "Transaction/UserRequests/testhelp", 
        body: File.read("spec/fixtures/illiad_requests.json"))
      get "/current-checkouts/interlibrary-loan" 
      expect(last_response.body).to include("Interlibrary Loan")
    end
  end
  context "get /current-checkouts/document-delivery-or-scans" do
    it "contains 'Document Delivery / Scans'" do
      stub_illiad_get_request(url: "Transaction/UserRequests/testhelp", 
        body: File.read("spec/fixtures/illiad_requests.json"))
      get "/current-checkouts/document-delivery-or-scans" 
      expect(last_response.body).to include("Document Delivery / Scans")
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
    it "contains 'U-M Library'" do
      stub_alma_get_request(url: "users/tutor/requests", body: File.read("./spec/fixtures/requests.json"), query: {limit: 100, offset: 0}  )
      get "/pending-requests/u-m-library"
      expect(last_response.body).to include("U-M Library")
    end
  end
  context "get /pending-requests/interlibrary-loan" do
    it "contains 'From Other Institutions (Interlibrary Loan)'" do
      stub_illiad_get_request(url: "Transaction/UserRequests/testhelp", 
        body: File.read("spec/fixtures/illiad_requests.json"))
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
    it "exists" do
      get "/past-activity/u-m-library" 
      expect(last_response.status).to eq(200)
    end
  end
  context "get /past-activity/interlibrary-loan" do
    it "contains 'Interlibrary Loan'" do
      stub_illiad_get_request(url: "Transaction/UserRequests/testhelp", 
        body: File.read("spec/fixtures/illiad_requests.json"))
      get "/past-activity/interlibrary-loan" 
      expect(last_response.body).to include("Interlibrary Loan")
    end
  end
  context "get /past-activity/special-collections" do
    it "exists" do
      get "/past-activity/special-collections" 
      expect(last_response.status).to eq(200)
    end
  end
  context "get /fines-and-fees" do
    it "contains 'Fines'" do
      stub_alma_get_request(url: "users/tutor/fees", query: {limit: 100, offset: 0}, 
        body: File.read("spec/fixtures/jbister_fines.json"))
      get "/fines-and-fees"
      expect(last_response.body).to include("Fines")
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
      get "/settings"
      expect(last_response.body).to include("Settings")
    end
  end
  #ToDO 
  #context "post /renew-loan" do
    #before(:each) do
      #stub_alma_get_request(url: "users/tutor/loans", query: {expand: 'renewable'})
    #end
    #it "handles good request" do
      #stub_alma_post_request(url: "users/tutor/loans/1234", query: {op: 'renew'} )
      #post "/renew-loan", {'loan_id' => '1234'}
      #expect(URI(last_response.headers["Location"]).path).to eq("/current-checkouts/loans")
      #follow_redirect!
      #expect(last_response.body).to include("Loan Successfully Renewed")
    #end
    #it "handles bad request" do
      #stub_alma_post_request(url: "users/tutor/loans/1234", query: {op: 'renew'}, status: 500 )
      #post "/renew-loan", {'loan_id' => '1234'}
      #expect(URI(last_response.headers["Location"]).path).to eq("/current-checkouts/loans")
      #follow_redirect!
      #expect(last_response.body).to include("Error")
    #end
  #end
  context "post /pending-requests/u-m-library/cancel-request" do
    before(:each) do
      @req = stub_alma_get_request( url: 'users/tutor/requests', body: File.read("./spec/fixtures/requests.json") )
    end
    it "handles good cancel request" do
      stub_alma_delete_request( url: 'users/tutor/requests/1234', status: 204, body: '{}', query: {reason: 'CancelledAtPatronRequest'} )
      post "/pending-requests/u-m-library/cancel-request", {'request_id' => '1234'}
      expect(last_response.status).to eq(200)
    end
  end
  context "post /sms" do
    before(:each) do
      @patron_json = File.read("./spec/fixtures/mrio_user_alma.json")
      stub_alma_get_request(url: "users/tutor?expand=none&user_id_type=all_unique&view=full", body: @patron_json)
    end
    it "handles good phone number update" do
      phone_number = '(734) 555-5555'
      new_phone_patron = JSON.parse(@patron_json)
      new_phone_patron["contact_info"]["phone"][1]["phone_number"] = phone_number

      stub_alma_put_request(url: "users/mrio", input: new_phone_patron.to_json, output: new_phone_patron.to_json)

      post "/sms", {'phone-number' => phone_number}
      follow_redirect!
      expect(last_response.body).to include("SMS Successfully Updated")
    end
    it "handles bad phone number update" do

      post "/sms", {'phone-number' => 'aaa'}
      follow_redirect!
      expect(last_response.body).to include("is invalid")
    end
    it "handles phone number removal" do
      new_phone_patron = JSON.parse(@patron_json)
      new_phone_patron["contact_info"]["phone"].delete_at(1)
      stub_alma_put_request(url: "users/mrio", input: new_phone_patron.to_json, output: new_phone_patron.to_json)
      post "/sms", {'phone-number' => ''}
      follow_redirect!
      expect(last_response.body).to include("SMS Successfully Removed")
    end
  end
  context "post /fines-and-fees/pay" do
    it "puts fine information in session and redirects to nelnet with amountDue" do
      stub_alma_get_request( url: 'users/tutor/fees', body: File.read("./spec/fixtures/jbister_fines.json"), query: {limit: 100, offset: 0}  )
      post "/fines-and-fees/pay", {'fines' => {"0" => '690390050000521'}}
      query = Addressable::URI.parse(last_response.location).query_values
      expect(last_request.env['rack.session'].key?(query["orderNumber"])).to eq(true)
      expect(query["amountDue"]).to eq("277")
    end
  end
  context "post /fines-and-fees/receipt" do
    before(:each) do
      @params = {
        "transactionType"=>"1", 
        "transactionStatus"=>"1", 
        "transactionId"=>"382481568",
        "transactionTotalAmount"=>"2250",
        "transactionDate"=>"202001211341",
        "transactionAcountType"=>"VISA",
        "transactionResultCode"=>"267849",
        "transactionResultMessage"=>"Approved and completed",
        "orderNumber"=>"Afam.1608566536797",
        "orderType"=>"UMLibraryCirc",
        "orderDescription"=>"U-M Library Circulation Fines",
        "payerFullName"=>"Aardvark Jones",
        "actualPayerFullName"=>"Aardvark Jones",
        "accountHolderName"=>"Aardvark Jones",
        "streetOne"=>"555 S STATE ST",
        "streetTwo"=>"",
        "city"=>"Ann Arbor",
        "state"=>"MI",
        "zip"=>"48105",
        "country"=>"UNITED STATES",
        "email"=>"aardvark@umich.edu",
        "timestamp"=>"1579628471900",
        "hash"=>"9baaee6c2a0ee08c63bbbcc0435360b0d5ecef1de876b68d59956c0752fed836"
      }
      @item = {
        "id"=>"1384289260006381",
        "balance"=>"5.00",
        "title"=>"Short history of Georgia.",
        "barcode"=>"95677",
        "library"=>"Main Library",
        "type"=>"Overdue fine",
        "creation_time"=>"2020-12-09T17:13:29.959Z"
      }
    end
    it "for valid params, retrieves items from session, updates Alma, sets success flash, prints receipt" do
      with_modified_env NELNET_SECRET_KEY: 'secret', JWT_SECRET: 'secret' do
        stub_alma_post_request( url: 'users/tutor/fees/1384289260006381', query: {op: "pay", method: 'ONLINE', amount: '5.00'}  )
        token = JWT.encode [@item], ENV.fetch('JWT_SECRET'), 'HS256'

        env 'rack.session', 'Afam.1608566536797' => token, uniqname: 'tutor'
        get "/fines-and-fees/receipt", @params 
        expect(last_response.body).to include("Fines successfully paid")
      end
    end
    it "for invalid params,  sets fail flash" do
      with_modified_env NELNET_SECRET_KEY: 'incorect_secret', JWT_SECRET: 'secret' do

        get "/fines-and-fees/receipt", @params 
        expect(last_response.body).to include("Could not Validate")
      end
    end
    def with_modified_env(options, &block)
      ClimateControl.modify(options, &block)
    end
  end
end
