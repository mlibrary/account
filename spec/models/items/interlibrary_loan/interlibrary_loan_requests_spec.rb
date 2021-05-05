require 'spec_helper'
require 'json'

describe InterlibraryLoanRequests do
  context "one request" do
    before(:each) do
      requests = JSON.parse(File.read('./spec/fixtures/illiad_requests.json'))
      requests.delete_at(0)
      requests[2]["TransactionStatus"] = "Request Has Been Submitted to ILL"
      requests[3]["TransactionStatus"] = "Awaiting Request Processing"
      stub_illiad_get_request(url: 'Transaction/UserRequests/testhelp', body: requests.to_json)
    end
    subject do
      InterlibraryLoanRequests.for(uniqname: 'testhelp')
    end
    context "#count" do
      it "returns total request item count" do
        expect(subject.count).to eq(2)
      end
    end
    context "#each" do
      it "iterates over request objects" do
        items = ''
        subject.each do |item|
          items = items + item.class.name
        end
        expect(items).to eq('InterlibraryLoanRequestInterlibraryLoanRequest')
      end
    end
    context "#empty?" do
      it "returns a boolean" do
        expect(subject.empty?).to eq(false)
      end
    end
    context "#item_text" do
      it "returns 'item' if there is only one request, or 'items' if there is not" do
        expect(subject.item_text).to eq('items')
      end
    end
  end
end
