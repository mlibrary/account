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
      it "handles network timeout error" do
        stub_circ_history_get_request(url: "users/tutor/loans", query: {direction: "DESC"}, no_return: true).to_timeout
        get "/past-activity/u-m-library"
        expect(last_response.body).to include("Error")
      end
    end
    context "not in circ history user" do
      it "show do not have circ history" do
        @session[:in_circ_history] = false
        env "rack.session", @session
        get "/past-activity/u-m-library"
        expect(last_response.body).to include("You don't have")
        expect(last_response.body).not_to include("Error")
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
    it "redirects to past activity page with an error message when non 200 status" do
      stub_circ_history_get_request(url: "users/tutor/loans/download.csv", status: 500)
      get "/past-activity/u-m-library/download.csv"
      session = last_request.env["rack.session"]
      expect(session["flash"][:error]).to include("Error")
    end
    it "redirects to past activity page with an error message when network timeout" do
      stub_circ_history_get_request(url: "users/tutor/loans/download.csv", no_return: true).to_timeout
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
    it "handles network error" do
      stub_illiad_get_request(url: "Transaction/UserRequests/tutor",
        query: hash_excluding({just_pass: "for_real"}), no_return: true).to_timeout
      get "/past-activity/interlibrary-loan"
      expect(last_response.body).to include("Error")
    end
  end
  context "get /past-activity/scans-and-electronic-items" do
    it "contains 'Scans and Electronic Items'" do
      stub_illiad_get_request(url: "Transaction/UserRequests/tutor",
        body: File.read("spec/fixtures/illiad_requests.json"), query: hash_excluding({just_pass: "for_real"}))
      get "/past-activity/scans-and-electronic-items"
      expect(last_response.body).to include("Scans and Electronic Items")
    end
    it "handles network error" do
      stub_illiad_get_request(url: "Transaction/UserRequests/tutor",
        query: hash_excluding({just_pass: "for_real"}), no_return: true).to_timeout
      get "/past-activity/scans-and-electronic-items"
      expect(last_response.body).to include("Error")
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
end
