require 'spec_helper'
require 'json'

describe InterlibraryLoans do
  context "one loan" do
    before(:each) do
      body = [ JSON.parse(File.read('./spec/fixtures/illiad_requests.json'))[0] ].to_json
    filter = "RequestType eq 'Loan' and TransactionStatus eq 'Checked Out to Customer' and ProcessType eq 'Borrowing'"
      stub_illiad_get_request(url: 'Transaction/UserRequests/testhelp', body: body, query: {"$filter" => filter})
    end
    subject do
      InterlibraryLoans.for(uniqname: 'testhelp')
    end
    context "#count" do
      it "returns total request item count" do
        expect(subject.count).to eq(1)
      end
    end
    context "#each" do
      it "iterates over request objects" do
        items = ''
        subject.each do |item|
          items = items + item.class.name
        end
        expect(items).to eq('InterlibraryLoan')
      end
    end
    context "#empty?" do
      it "returns a boolean" do
        expect(subject.empty?).to eq(false)
      end
    end
    context "#item_text" do
      it "returns 'item' if there is only one loan, or 'items' if there is not" do
        expect(subject.item_text).to eq('item')
      end
    end
  end
end
