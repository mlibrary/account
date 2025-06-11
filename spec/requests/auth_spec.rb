require "spec_helper"
describe "authentication requests" do
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
  context "not yet logged in" do
    it "sets the session to the uniqname in the header" do
      env "rack.session", {}
      stub_alma_get_request(url: "users/tutor?expand=none&user_id_type=all_unique&view=full", status: 400)
      stub_circ_history_get_request(url: "users/tutor")
      stub_illiad_get_request(url: "Users/tutor", status: 404)
      get "/"
      session = last_request.env["rack.session"]
      expect(session[:uniqname]).to eq("tutor")
      expect(session[:in_illiad]).to eq(false)
      expect(session[:expires_at]).to be >= Time.now.utc
    end
  end
  context "session has different patron" do
    it "sets the patron to the one in header" do
      @session[:uniqname] = "nottutor"
      env "rack.session", @session
      stub_alma_get_request(url: "users/tutor?expand=none&user_id_type=all_unique&view=full", status: 400)
      stub_circ_history_get_request(url: "users/tutor")
      stub_illiad_get_request(url: "Users/tutor", status: 404)
      get "/"
      session = last_request.env["rack.session"]
      expect(session[:uniqname]).to eq("tutor")
      expect(session[:in_illiad]).to eq(false)
      expect(session[:expires_at]).to be >= Time.now.utc
    end
  end
  context "session has expired" do
    it "it calls for patron info" do
      @session[:expires_at] = Time.now - 1.hour
      env "rack.session", @session
      stub_alma_get_request(url: "users/tutor?expand=none&user_id_type=all_unique&view=full", status: 400)
      stub_circ_history_get_request(url: "users/tutor")
      stub_illiad_get_request(url: "Users/tutor", status: 404)
      get "/"
      session = last_request.env["rack.session"]
      expect(session[:uniqname]).to eq("tutor")
      expect(session[:in_illiad]).to eq(false)
      expect(session[:expires_at]).to be >= Time.now.utc
    end
  end
  context "same patron in header as in session and session not expired" do
    it "does not call any patron related apis" do
      alma_stub = stub_alma_get_request(url: "users/tutor?expand=none&user_id_type=all_unique&view=full", status: 400)
      get "/"
      session = last_request.env["rack.session"]
      expect(session[:uniqname]).to eq("tutor")
      expect(session[:in_illiad]).to eq(true)
      expect(alma_stub).not_to have_been_requested
      expect(session[:expires_at]).to eq(@session[:expires_at])
    end
  end

  context "get '/auth/openid_connect/callback'" do
    let(:omniauth_auth) {
      {
        info: {nickname: "nottutor"},
        credentials: {expires_in: 86399}
      }
    }
    context "successfull circ_history request" do
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
    context "unsucessful circ_history request" do
      before(:each) do
        stub_alma_get_request(url: "users/nottutor?expand=none&user_id_type=all_unique&view=full", status: 400)
        stub_illiad_get_request(url: "Users/nottutor", status: 404)
        OmniAuth.config.add_mock(:openid_connect, omniauth_auth)
      end
      it "returns false in_circ_history" do
        stub_circ_history_get_request(url: "users/nottutor", status: 500)
        get "/auth/openid_connect/callback"
        session = last_request.env["rack.session"]
        expect(session[:in_circ_history]).to eq(false)
      end
      it "handles timeout and returns false in_circ_history" do
        stub_circ_history_get_request(url: "users/nottutor", no_return: true).to_timeout
        get "/auth/openid_connect/callback"
        session = last_request.env["rack.session"]
        expect(session[:in_circ_history]).to eq(false)
      end
    end
    context "illiad timeout request" do
      it "returns false in illiad" do
        stub_alma_get_request(url: "users/nottutor?expand=none&user_id_type=all_unique&view=full", status: 400)
        stub_circ_history_get_request(url: "users/nottutor")
        stub_illiad_get_request(url: "Users/nottutor", no_return: true).to_timeout
        OmniAuth.config.add_mock(:openid_connect, omniauth_auth)
        get "/auth/openid_connect/callback"
        session = last_request.env["rack.session"]
        expect(session[:in_illiad]).to eq(false)
      end
    end
  end
end
