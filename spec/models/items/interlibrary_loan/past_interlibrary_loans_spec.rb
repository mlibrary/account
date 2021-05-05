require 'spec_helper'
require 'json'

describe PastInterlibraryLoans do
  context "three loans" do
    before(:each) do
      stub_illiad_get_request(url: 'Transaction/UserRequests/testhelp', body: File.read('./spec/fixtures/illiad_requests.json'))
    end
    subject do
      PastInterlibraryLoans.for(uniqname: 'testhelp')
    end
    context "#count" do
      it "returns total request item count" do
        expect(subject.count).to eq(3)
      end
    end
    context "#each" do
      it "iterates over request objects" do
        items = ''
        subject.each do |item|
          items = items + item.class.name
        end
        expect(items).to eq('PastInterlibraryLoanPastInterlibraryLoanPastInterlibraryLoan')
      end
    end
    context "#empty?" do
      it "returns a boolean" do
        expect(subject.empty?).to eq(false)
      end
    end
    context "#item_text" do
      it "returns 'item' if there is only one loan, or 'items' if there is not" do
        expect(subject.item_text).to eq('items')
      end
    end
  end
end
