require "spec_helper"
describe "authentication requests" do
  include Rack::Test::Methods
  let(:previous_session) {
    {
      uniqname: "tutor",
      in_alma: true,
      in_circ_history: true,
      in_illiad: true,
      can_book: false,
      confirmed_history_setting: false,
      expires_at: Time.now + 1.day

    }
  }
  let(:alma_patron_stub) do
    stub_alma_get_request(url: "users/tutor?expand=none&user_id_type=all_unique&view=full", status: 400)
  end
  let(:illiad_stub) do
    stub_illiad_get_request(url: "Users/tutor", status: 404)
  end
  let(:checkout_history_stub) do
    stub_circ_history_get_request(url: "users/tutor")
  end
  let(:stub_patron_api_calls) do
    alma_patron_stub
    illiad_stub
    checkout_history_stub
  end
  let(:expect_session_from_fresh_api_calls) do
    session = last_request.env["rack.session"]
    expect(session[:uniqname]).to eq("tutor")
    expect(session[:in_illiad]).to eq(false)
    expect(session[:expires_at]).to be >= Time.now.utc
  end
  before(:each) do
    env "HTTP_X_AUTH_REQUEST_USER", "tutor"
  end
  context "same patron in header as in session and session not expired" do
    it "does not call any patron related apis" do
      env "rack.session", previous_session
      stub_patron_api_calls
      get "/"
      session = last_request.env["rack.session"]
      expect(session[:uniqname]).to eq("tutor")
      expect(session[:in_illiad]).to eq(true)
      expect(alma_patron_stub).not_to have_been_requested
      expect(session[:expires_at]).to eq(previous_session[:expires_at])
    end
  end
  context "not yet logged in" do
    it "sets the session to the uniqname in the header" do
      env "rack.session", {}
      stub_patron_api_calls
      get "/"
      expect_session_from_fresh_api_calls
    end
  end
  context "session has different patron" do
    it "sets the patron to the one in header" do
      previous_session[:uniqname] = "nottutor"
      env "rack.session", previous_session
      stub_patron_api_calls
      get "/"
      expect_session_from_fresh_api_calls
    end
  end
  context "session has expired" do
    it "it calls for patron info" do
      previous_session[:expires_at] = Time.now - 1.hour
      env "rack.session", previous_session
      stub_patron_api_calls
      get "/"
      expect_session_from_fresh_api_calls
    end
  end
  context "empty X_AUTH header not found in alma" do
    it "returns 401 response" do
      env "HTTP_X_AUTH_REQUEST_USER", nil
      get "/"
      stub_alma_get_request(url: "users/?expand=none&user_id_type=all_unique&view=full", status: 400)
      expect(last_response.status).to eq(401)
    end
  end
end
