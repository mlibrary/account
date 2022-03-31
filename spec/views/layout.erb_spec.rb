require "spec_helper"
describe "flash messages" do
  include Rack::Test::Methods
  it "displays appropriate flash message" do
    env "rack.session", {flash: {success: "it was successful"}, authenticated: true, expires_at: Time.now + 1.day, uniqname: "tutor"}
    get "/"
    expect(last_response.body).to include("it was successful")
  end
end
