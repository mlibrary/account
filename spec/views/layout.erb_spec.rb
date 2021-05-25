require "spec_helper"
describe "flash messages" do
  include Rack::Test::Methods
  before(:each) do
    stub_alma_get_request(url: "users/mlibrary.acct.testing1@gmail.com?expand=none&user_id_type=all_unique&view=full", body: File.read('./spec/fixtures/mrio_user_alma.json'))
    stub_circ_history_get_request(url: "users/mlibrary.acct.testing1@gmail.com", output: File.read('./spec/fixtures/circ_history_user.json'))
  end
  it "displays appropriate flash message" do
    #post "/session_switcher", {flash: {success: "it was successful"}}
    env 'rack.session', {flash: {success: "it was successful"}}
    get "/"
    expect(last_response.body).to include('it was successful')

  end
end
