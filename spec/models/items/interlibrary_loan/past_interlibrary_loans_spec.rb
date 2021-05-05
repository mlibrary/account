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
  end
end
