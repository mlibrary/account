require "spec_helper"
describe "fines-and-fees requests" do
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
  context "get /fines-and-fees" do
    context "in alma user" do
      it "contains 'Fines'" do
        stub_alma_get_request(url: "users/tutor/fees", query: {limit: 100, offset: 0},
          body: File.read("spec/fixtures/jbister_fines.json"))
        get "/fines-and-fees"
        expect(last_response.body).to include("Fines")
      end
      it "shows error and empty state if there's an failed alma request" do
        stub_alma_get_request(url: "users/tutor/fees", status: 500, query: {limit: 100, offset: 0})
        get "/fines-and-fees"
        expect(last_response.body).to include("You don't have")
        expect(last_response.body).to include("Error")
      end
      it "shows error and empty state if there's an timeout" do
        stub_alma_get_request(url: "users/tutor/fees", query: {limit: 100, offset: 0}, no_return: true).to_timeout
        get "/fines-and-fees"
        expect(last_response.body).to include("You don't have")
        expect(last_response.body).to include("Error")
      end
    end
    context "not in alma user" do
      it "show do not have fines and fees" do
        not_in_alma
        get "/fines-and-fees"
        expect(last_response.body).to include("You don't have")
      end
    end
  end
  context "post /fines-and-fees/pay" do
    before(:each) do
      @stub = stub_alma_get_request(url: "users/tutor/fees", body: File.read("./spec/fixtures/jbister_fines.json"), query: {limit: 100, offset: 0})
      stub_request(:post, S.slack_url) # Don't care about the slack url for testing purposes
    end
    it "for pay in full redirects to nelnet with total amountDue" do
      post "/fines-and-fees/pay", {"pay_in_full" => "true", "partial_amount" => "0.00"}
      query = Addressable::URI.parse(last_response.location).query_values
      expect(query["amountDue"]).to eq("2500")
    end
    it "for pay in part redirects to nelnet with partial amountDue" do
      post "/fines-and-fees/pay", {"pay_in_full" => "false", "partial_amount" => "2.77"}
      query = Addressable::URI.parse(last_response.location).query_values
      expect(query["amountDue"]).to eq("277")
    end
    it "redirects back to fines and fees with error if user tries to overpay" do
      post "/fines-and-fees/pay", {"pay_in_full" => "false", "partial_amount" => "100"}
      expect(last_response.status).to eq(302)
      expect(URI(last_response.headers["Location"]).path).to eq("/fines-and-fees")
    end
    it "redirects back to fines and fees with an error if there's a network error" do
      remove_request_stub(@stub)
      stub_alma_get_request(url: "users/tutor/fees", query: {limit: 100, offset: 0}, no_return: true).to_timeout
      post "/fines-and-fees/pay", {"pay_in_full" => "false", "partial_amount" => "100"}
      expect(last_response.status).to eq(302)
      expect(URI(last_response.headers["Location"]).path).to eq("/fines-and-fees")
      follow_redirect!
      expect(last_response.body).to include("Error")
    end
  end
  context "get /fines-and-fees/receipt" do
    before(:each) do
      @params = {
        "transactionType" => "1",
        "transactionStatus" => "1",
        "transactionId" => "382481568",
        "transactionTotalAmount" => "2250",
        "transactionDate" => "202001211341",
        "transactionAcountType" => "VISA",
        "transactionResultCode" => "267849",
        "transactionResultMessage" => "Approved and completed",
        "orderNumber" => "Afam.1608566536797",
        "orderType" => "UMLibraryCirc",
        "orderDescription" => "U-M Library Circulation Fines",
        "payerFullName" => "Aardvark Jones",
        "actualPayerFullName" => "Aardvark Jones",
        "accountHolderName" => "Aardvark Jones",
        "streetOne" => "555 S STATE ST",
        "streetTwo" => "",
        "city" => "Ann Arbor",
        "state" => "MI",
        "zip" => "48105",
        "country" => "UNITED STATES",
        "email" => "aardvark@umich.edu",
        "timestamp" => "1579628471900",
        "hash" => "9baaee6c2a0ee08c63bbbcc0435360b0d5ecef1de876b68d59956c0752fed836"
      }
    end
    it "for valid params, updates Alma, sets success flash, prints receipt" do
      with_modified_env NELNET_SECRET_KEY: "secret" do
        stub_alma_get_request(url: "users/tutor/fees", query: {limit: 100, offset: 0},
          body: File.read("spec/fixtures/jbister_fines.json"))
        @session[:order_number] = "382481568"
        env "rack.session", @session
        stub_alma_post_request(url: "users/tutor/fees/all", query: {op: "pay", amount: "22.50", method: "ONLINE", external_transaction_id: "382481568"}, body: File.read("spec/fixtures/fines_pay_amount.json"))

        get "/fines-and-fees/receipt", @params
        expect(last_response.body).to include("Fines successfully paid")
      end
    end
    it "for invalid params,  sets fail flash" do
      with_modified_env NELNET_SECRET_KEY: "incorect_secret" do
        stub = stub_alma_post_request(url: "users/tutor/fees/all", query: {op: "pay", amount: "22.50", method: "ONLINE", external_transaction_id: "382481568"})

        get "/fines-and-fees/receipt", @params
        expect(last_response.body).to include("Your payment could not be validated")
        expect(stub).not_to have_been_requested
      end
    end
    it "retirects to fines and fees if someone goes there directly without any parameters" do
      get "fines-and-fees/receipt"
      expect(last_response.status).to eq(302)
      expect(URI(last_response.headers["Location"]).path).to eq("/fines-and-fees")
    end
    def with_modified_env(options, &block)
      ClimateControl.modify(options, &block)
    end
  end
end
