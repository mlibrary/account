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
    it "contains 'Fines'" do
      stub_alma_get_request(url: "users/tutor/fees", query: {limit: 100, offset: 0}, 
        body: File.read("spec/fixtures/jbister_fines.json"))
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
    before(:each) do
      stub_alma_get_request(url: "users/tutor/loans", query: {expand: 'renewable'})
    end
    it "handles good request" do
      stub_alma_post_request(url: "users/tutor/loans/1234", query: {op: 'renew'} )
      post "/renew-loan", {'loan_id' => '1234'}
      expect(URI(last_response.headers["Location"]).path).to eq("/shelf/loans")
      follow_redirect!
      expect(last_response.body).to include("Loan Successfully Renewed")
    end
    it "handles bad request" do
      stub_alma_post_request(url: "users/tutor/loans/1234", query: {op: 'renew'}, status: 500 )
      post "/renew-loan", {'loan_id' => '1234'}
      expect(URI(last_response.headers["Location"]).path).to eq("/shelf/loans")
      follow_redirect!
      expect(last_response.body).to include("Error")
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
end
