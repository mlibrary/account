require "spec_helper"
describe "current-checkouts requests" do
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
        expect(last_response.body).to include("You don't have")
        expect(last_response.body).to include("Error")
      end
    end
    context "not in alma user" do
      it "has empty checkouts" do
        not_in_alma
        get "/current-checkouts/u-m-library"
        expect(last_response.body).to include("You don't have")
        session = last_request.env["rack.session"]
        expect(session["flash"][:error]).to be_nil
      end
    end
  end
  context "get /current-checkouts/u-m-library/all" do
    it "returns json with user's checkouts" do
      stub_alma_get_request(url: "users/tutor/loans", body: File.read("./spec/fixtures/loans.json"), query: {expand: "renewable", limit: 100, offset: 0})
      get "/current-checkouts/u-m-library/all"
      expect(last_response.body).to eq(
        [
          {loan_id: "1332733700000521", renewable: true},
          {loan_id: "1332734190000521", renewable: true}
        ].to_json
      )
      expect(last_response.headers["Content-Type"]).to eq("application/json")
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

  # this has to do with the stream for renew all
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
  context "get /current-checkouts/interlibrary-loan" do
    it "contains 'Interlibrary Loan'" do
      stub_illiad_get_request(url: "Transaction/UserRequests/tutor",
        body: File.read("spec/fixtures/illiad_requests.json"), query: hash_excluding({just_pass: "for_real"}))
      get "/current-checkouts/interlibrary-loan"
      expect(last_response.body).to include("Interlibrary Loan")
    end
    it "handles a network error" do
      stub_illiad_get_request(url: "Transaction/UserRequests/tutor", query: hash_excluding({just_pass: "for_real"}), no_return: true).to_timeout
      get "/current-checkouts/interlibrary-loan"
      expect(last_response.body).to include("Interlibrary Loan")
      expect(last_response.body).to include("Error")
    end
  end
  context "get /current-checkouts/scans-and-electronic-items" do
    it "contains 'Scans and Electronic Items'" do
      stub_illiad_get_request(url: "Transaction/UserRequests/tutor",
        body: File.read("spec/fixtures/illiad_requests.json"), query: hash_excluding({just_pass: "for_real"}))
      get "/current-checkouts/scans-and-electronic-items"
      expect(last_response.body).to include("Scans and Electronic Items")
    end
    it "handles a network error" do
      stub_illiad_get_request(url: "Transaction/UserRequests/tutor",
        query: hash_excluding({just_pass: "for_real"}), no_return: true).to_timeout
      get "/current-checkouts/scans-and-electronic-items"
      expect(last_response.body).to include("Scans and Electronic Items")
      expect(last_response.body).to include("Error")
    end
    it "handles a non 200 response" do
      stub_illiad_get_request(url: "Transaction/UserRequests/tutor",
        query: hash_excluding({just_pass: "for_real"}), status: 500)
      get "/current-checkouts/scans-and-electronic-items"
      expect(last_response.body).to include("Scans and Electronic Items")
      expect(last_response.body).to include("Error")
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
end
