require "spec_helper"
require "json"

describe PastDocumentDelivery do
  let(:query) { {"$filter" => "RequestType eq 'Article' and (TransactionStatus eq 'Request Finished' or startswith(TransactionStatus, 'Cancelled'))", "$top" => "15"} }
  context "three loans" do
    before(:each) do
      stub_illiad_get_request(url: "Transaction/UserRequests/testhelp", body: File.read("./spec/fixtures/illiad_requests.json"), query: query)
    end
    subject do
      PastDocumentDelivery.for(uniqname: "testhelp", count: 25)
    end
    context "#count" do
      it "returns total request item count" do
        expect(subject.count).to eq(25)
      end
    end
    context "#each" do
      it "iterates over request objects" do
        items = ""
        subject.each do |item|
          items += item.class.name
        end
        expect(items).to eq("PastDocumentDeliveryItem" * 5)
      end
    end
    context "#empty?" do
      it "returns a boolean" do
        expect(subject.empty?).to eq(false)
      end
    end
    context "#item_text" do
      it "returns 'item' if there is only one loan, or 'items' if there is not" do
        expect(subject.item_text).to eq("items")
      end
    end
  end
  context "no count given" do
    before(:each) do
      stub_illiad_get_request(url: "Transaction/UserRequests/testhelp", body: File.read("./spec/fixtures/illiad_requests.json"), query: {"$filter": query["$filter"]})
    end
    subject do
      PastDocumentDelivery.for(uniqname: "testhelp", limit: "1", count: nil)
    end
    context "#count" do
      it "returns total number of transactions" do
        expect(subject.count).to eq(5)
      end
    end
    context "#each" do
      it "returns limit number of Loan objects" do
        items = ""
        subject.each do |item|
          items += item.class.name
        end
        expect(items).to eq("PastDocumentDeliveryItem" * 1)
      end
    end
  end
end
