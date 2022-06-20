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
  context "get /favorites" do
    it "goes to olde favorites" do
      get "/favorites"
      expect(last_response.status).to eq(302)
      expect(last_response.location).to eq("https://apps.lib.umich.edu/my-account/favorites")
    end
  end
  context "not_found" do
    it "shows page not found for not found" do
      get "/does_not_exist"
      expect(last_response.body).to include("Page not found")
    end
  end
end
