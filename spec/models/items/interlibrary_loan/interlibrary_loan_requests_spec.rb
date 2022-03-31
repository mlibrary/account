require "spec_helper"
require "json"

describe InterlibraryLoanRequests do
  let(:query) { {"$filter" => "TransactionStatus ne 'Request Finished' and TransactionStatus ne 'Cancelled by ILL Staff' and TransactionStatus ne 'Cancelled by Customer' and TransactionStatus ne 'Delivered to Web' and TransactionStatus ne 'Checked Out to Customer' and ProcessType eq 'Borrowing'", "$top" => "15"} }
  context "two requests" do
    before(:each) do
      requests = JSON.parse(File.read("./spec/fixtures/illiad_requests.json"))
      requests.delete_at(0)
      requests[2]["TransactionStatus"] = "Request Has Been Submitted to ILL"
      requests[3]["TransactionStatus"] = "Awaiting Request Processing"
      stub_illiad_get_request(url: "Transaction/UserRequests/testhelp", body: requests.to_json, query: query)
    end
    subject do
      InterlibraryLoanRequests.for(uniqname: "testhelp", count: 25)
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
        expect(items).to eq("InterlibraryLoanRequest" * 4)
      end
    end
    context "#empty?" do
      it "returns a boolean" do
        expect(subject.empty?).to eq(false)
      end
    end
    context "#item_text" do
      it "returns 'item' if there is only one request, or 'items' if there is not" do
        expect(subject.item_text).to eq("items")
      end
    end
  end
  context "no count given" do
    before(:each) do
      requests = JSON.parse(File.read("./spec/fixtures/illiad_requests.json"))
      requests.delete_at(0)
      requests[2]["TransactionStatus"] = "Request Has Been Submitted to ILL"
      requests[3]["TransactionStatus"] = "Awaiting Request Processing"
      stub_illiad_get_request(url: "Transaction/UserRequests/testhelp", body: requests.to_json, query: {'$filter': query["$filter"]})
    end
    subject do
      InterlibraryLoanRequests.for(uniqname: "testhelp", limit: "1", count: nil)
    end
    context "#count" do
      it "returns total number of transactions" do
        expect(subject.count).to eq(4)
      end
    end
    context "#each" do
      it "returns limit number of Loan objects" do
        items = ""
        subject.each do |item|
          items += item.class.name
        end
        expect(items).to eq("InterlibraryLoanRequest" * 1)
      end
    end
  end
end
