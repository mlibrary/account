require 'spec_helper'
require 'json'

describe DocumentDelivery do
  let(:query){{"$filter" => "RequestType eq 'Loan' and TransactionStatus ne 'Request Finished'", "$top" => '15'}}
  context "three loans" do
    before(:each) do
      stub_illiad_get_request(url: 'Transaction/UserRequests/testhelp', body: File.read('./spec/fixtures/illiad_requests.json'), query: query)
    end
    subject do
      DocumentDelivery.for(uniqname: 'testhelp', count: 25)
    end
    context "#count" do
      it "returns total request item count" do
        expect(subject.count).to eq(25)
      end
    end
    context "#each" do
      it "iterates over request objects" do
        items = ''
        subject.each do |item|
          items = items + item.class.name
        end
        expect(items).to eq("DocumentDeliveryItem"*5)
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
  context "no count given" do
    before(:each) do
      stub_illiad_get_request(url: 'Transaction/UserRequests/testhelp', body: File.read('./spec/fixtures/illiad_requests.json'), query: {'$filter': query['$filter']})
    end
    subject do
      DocumentDelivery.for(uniqname: 'testhelp', limit: '1', count: nil)
    end
    context "#count" do
      it "returns total number of transactions" do
        expect(subject.count).to eq(5)
      end
    end 
    context "#each" do
      it "returns limit number of Loan objects" do
        items = ''
        subject.each do |item|
          items = items + item.class.name
        end
        expect(items).to eq("DocumentDeliveryItem"*1)
      end
    end
  end
end
