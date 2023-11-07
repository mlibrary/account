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
        stub_alma_get_request(url: "users/tutor/requests", output: File.read("./spec/fixtures/requests.json"), query: {limit: 100, offset: 0})
        stub_illiad_get_request(url: "Users/tutor", status: 404)
        stub_illiad_get_request(url: "Transaction/UserRequests/tutor",
          body: "[]", query: hash_excluding({just_pass: "for_real"}))
        get "/pending-requests/u-m-library"
        expect(last_response.body).to include("U-M Library")
      end
      it "loads empty state when theres an error with an alma request" do
        stub_alma_get_request(url: "users/tutor/requests", status: 500, query: {limit: 100, offset: 0})
        get "/pending-requests/u-m-library"
        expect(last_response.body).to include("You don't have")
        expect(last_response.body).to include("Error")
      end
    end
    context "not in alma" do
      it "shows empty sate pending requests" do
        not_in_alma
        get "/pending-requests/u-m-library"
        expect(last_response.body).to include("You don't have")
        session = last_request.env["rack.session"]
        expect(session["flash"][:error]).to be_nil
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
  context "post /pending-requests/u-m-library/cancel-request" do
    before(:each) do
      @req = stub_alma_get_request(url: "users/tutor/requests", output: File.read("./spec/fixtures/requests.json"))
    end
    it "handles good cancel request" do
      stub_alma_delete_request(url: "users/tutor/requests/1234", status: 204, output: "{}", query: {reason: "CancelledAtPatronRequest"})
      post "/pending-requests/u-m-library/cancel-request", {"request_id" => "1234"}
      expect(last_response.status).to eq(200)
    end
    it "handles a bad cancel request" do
      stub_alma_delete_request(url: "users/tutor/requests/1234", query: {reason: "CancelledAtPatronRequest"}, no_return: true).to_timeout
      post "/pending-requests/u-m-library/cancel-request", {"request_id" => "1234"}
      expect(last_response.status).to eq(500)
    end
  end
end
