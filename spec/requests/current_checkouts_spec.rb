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
    env "HTTP_X_AUTH_REQUEST_USER", "tutor"
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
