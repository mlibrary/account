require 'spec_helper'
describe AlmaClient, "#get_all(url:, record_key:, limit: 100)" do
  it "gets all of a given get" do
    url = "users/jbister/loans"
    stub_alma_get_request( query: { "limit" => 1, "offset" => 0}, body: File.read("./spec/fixtures/jbister_loans0.json"), url: url) 
    stub_alma_get_request( query: { "limit" => 1, "offset" => 1}, body: File.read("./spec/fixtures/jbister_loans1.json"), url: url) 

    response = described_class.new.get_all(url: "/#{url}", limit: 1, record_key: 'item_loan')
    expect(response.code).to eq(200)
    expect(response.parsed_response["item_loan"].count).to eq(2)
  end
end
