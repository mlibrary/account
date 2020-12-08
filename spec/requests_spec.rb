require 'spec_helper'
describe "requests" do
  include Rack::Test::Methods
  before(:each) do
    env 'rack.session', uniqname: 'tutor'
  end
  context "get /" do
    it "contains 'Welcome'" do
      stub_alma_get_request(url: "users/tutor?expand=none&user_id_type=all_unique&view=full")
      get "/"
      expect(last_response.body).to include("Welcome")
    end
  end
  context "get /shelf" do
    it "redirects to '/shelf/loans'" do
      get "/shelf"
      expect(last_response.status).to eq(302)
      expect(URI(last_response.headers["Location"]).path).to eq("/shelf/loans")
    end
  end
  context "get /shelf/" do
    it "redirects to '/shelf/loans'" do
      get "/shelf/"
      expect(last_response.status).to eq(302)
      expect(URI(last_response.headers["Location"]).path).to eq("/shelf/loans")
    end
  end
  context "get /shelf/loans" do
    it "contains 'Shelf'" do
      stub_alma_get_request(url: "users/tutor/loans", query: {expand: 'renewable'})
      get "/shelf/loans"
      expect(last_response.body).to include("Shelf")
    end
  end
  context "get /shelf/past-loans" do
    it "contains 'Past Loans'" do
      get "/shelf/past-loans" 
      expect(last_response.body).to include("Past loans")
    end
  end
  context "get /shelf/document-delivery" do
    it "contains 'Document Delivery'" do
      get "/shelf/document-delivery" 
      expect(last_response.body).to include("Document delivery")
    end
  end
  context "get /requests" do
    it "contains 'Requests'" do
      stub_alma_get_request(url: "users/tutor/requests")
      get "/requests"
      expect(last_response.body).to include("Requests")
    end
  end
  context "get /fines" do
    it "contains 'Requests'" do
      get "/fines"
      expect(last_response.body).to include("Fines")
    end
  end
  context "get /contact-information" do
    it "contains 'notifications'" do
      stub_alma_get_request(url: "users/tutor?expand=none&user_id_type=all_unique&view=full")
      get "/contact-information"
      expect(last_response.body).to include("notifications")
    end
  end
  context "post /renew loan" do
    it "handles good request" do
      header 'REFERER', 'http://example.com/shelf/loans'
      #env 'rack.session', uniqname: 'tutor'
      #stub_alma_get_request(url: "users/tutor/loans", query: {expand: 'renewable'})
      stub_alma_post_request(url: "users/tutor/loans/1234", query: {op: 'renew'} )
      byebug
      post "/renew-loan", {'loan_id' => '1234'}
    end
    it "handles bad request" do
    end
  end
end
