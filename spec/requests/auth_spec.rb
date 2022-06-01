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
end
