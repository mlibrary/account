require "spec_helper"

describe CirculationHistoryItems do
  let(:history_json) { File.read("./spec/fixtures/circ_history_loans.json") }
  context "two loans" do
    before(:each) do
      stub_circ_history_get_request(url: "users/emcard/loans", output: history_json, query: {direction: "DESC"})
    end
    subject do
      described_class.for(uniqname: "emcard")
    end
    context "#count" do
      it "returns total loan item count" do
        expect(subject.count).to eq(2)
      end
    end
    context "#empty?" do
      it "returns false" do
        expect(subject.empty?).to eq(false)
      end
    end
    context "#each" do
      it "iterates over loan objects" do
        loans_contents = ""
        subject.each do |loan|
          loans_contents += loan.class.name
        end
        expect(loans_contents).to eq("CirculationHistoryItemCirculationHistoryItem")
      end
    end
  end
  context "no loans" do
    before(:each) do
      empty_circ_history = JSON.parse(history_json)
      empty_circ_history["total_record_count"] = 0
      empty_circ_history["loans"] = []

      stub_circ_history_get_request(url: "users/emcard/loans", output: empty_circ_history.to_json, query: {direction: "DESC"})
    end
    subject do
      described_class.for(uniqname: "emcard")
    end
    context "#count" do
      it "returns total loan item count" do
        expect(subject.count).to eq(0)
      end
    end
    context "#empty?" do
      it "returns false" do
        expect(subject.empty?).to eq(true)
      end
    end
  end
  context "sort" do
    before(:each) do
      loans = JSON.parse(history_json)
      @loan = loans["loans"].delete_at(0).to_json
    end
    it "requests loans sorted by title" do
      stub_circ_history_get_request(url: "users/emcard/loans", output: @loan, query: {"offset" => 1, "limit" => 1, "direction" => "ASC", "order_by" => "title"})
      loans = described_class.for(uniqname: "emcard", offset: 1, limit: 1, direction: "ASC", order_by: "title")
      expect(loans.pagination.next.url).to include("direction=ASC")
      expect(loans.pagination.next.url).to include("order_by=title")
    end
  end
end
describe CirculationHistoryItem do
  subject do
    loans = JSON.parse(File.read("./spec/fixtures/circ_history_loans.json"))
    described_class.new(loans["loans"][0])
  end
  it "has expected url" do
    expect(subject.url).to eq("https://search.lib.umich.edu/catalog/record/990005467650206381")
  end
  it "responds to barcode" do
    expect(subject.barcode).to eq("39015061357532")
  end
end
