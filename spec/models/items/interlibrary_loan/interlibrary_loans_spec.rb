require 'spec_helper'
require 'json'

describe InterlibraryLoans do
  context "one loan" do
    before(:each) do
      stub_illiad_get_request(url: 'Transaction/UserRequests/testhelp', body: File.read('./spec/fixtures/illiad_requests.json'), query: {top: 15})
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
  context "pagination" do
    before(:each) do
      stub_illiad_get_request(url: 'Transaction/UserRequests/testhelp', body: File.read('./spec/fixtures/illiad_requests.json'), query: {"skip" => 1, "top" => 1} )
    end
    subject do
      InterlibraryLoans.for(uniqname: 'testhelp', skip: 1, top: 1)
    end
    context "#count" do
      it "returns total count for loans" do
        expect(subject.count).to eq(1)
      end
    end
    context "#each" do
      it "iterates over toped number of items" do
        loans_contents = ''
        subject.each do |loan|
          loans_contents = loans_contents + loan.class.name
        end
        expect(loans_contents).to eq('InterlibraryLoan')
      end
    end
  end
end
