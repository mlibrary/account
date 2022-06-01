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
end
