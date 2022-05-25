require "spec_helper"
require "json"

describe InterlibraryLoans do
  let(:query) { {"$filter" => "RequestType eq 'Loan' and TransactionStatus eq 'Checked Out to Customer' and ProcessType eq 'Borrowing'", "$top" => "15"} }
  context "one loan" do
    before(:each) do
      body = [JSON.parse(File.read("./spec/fixtures/illiad_requests.json"))[0]].to_json
      stub_illiad_get_request(url: "Transaction/UserRequests/testhelp", body: body, query: query)
    end
    subject do
      InterlibraryLoans.for(uniqname: "testhelp", count: 25)
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
        expect(items).to eq("InterlibraryLoan" * 1)
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
      body = [JSON.parse(File.read("./spec/fixtures/illiad_requests.json"))[0]].to_json
      stub_illiad_get_request(url: "Transaction/UserRequests/testhelp", body: body, query: {"$filter": query["$filter"]})
    end
    subject do
      InterlibraryLoans.for(uniqname: "testhelp", limit: "1", count: nil)
    end
    context "#count" do
      it "returns total number of transactions" do
        expect(subject.count).to eq(1)
      end
    end
    context "#each" do
      it "returns limit number of Loan objects" do
        items = ""
        subject.each do |item|
          items += item.class.name
        end
        expect(items).to eq("InterlibraryLoan" * 1)
      end
    end
  end
end
