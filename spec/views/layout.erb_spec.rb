require "spec_helper"
describe "flash messages" do
  include Rack::Test::Methods
  before(:each) do
    stub_alma_get_request(url: "users/tutor?expand=none&user_id_type=all_unique&view=full", body: '{}')
  end
  it "displays appropriate flash message" do
    #post "/session_switcher", {flash: {success: "it was successful"}}
    env 'rack.session', {flash: {success: "it was successful"}}
    get "/"
    expect(last_response.body).to include('it was successful')

  end
end
