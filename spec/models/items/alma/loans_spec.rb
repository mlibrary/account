require "spec_helper"
require "json"

describe Loans do
  context "two loans" do
    before(:each) do
      stub_alma_get_request(url: "users/jbister/loans", body: File.read("./spec/fixtures/loans.json"), query: {expand: "renewable", limit: 15, order_by: "due_date"})
    end
    subject do
      Loans.for(uniqname: "jbister")
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
        expect(loans_contents).to eq("LoanLoan")
      end
    end
  end
  context "no loans" do
    before(:each) do
      stub_alma_get_request(url: "users/jbister/loans", body: File.read("./spec/fixtures/no_loans.json"), query: {expand: "renewable", limit: 15, order_by: "due_date"})
    end
    subject do
      Loans.for(uniqname: "jbister")
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
      one_loan = JSON.parse(File.read("./spec/fixtures/loans.json"))
      @loan = one_loan["item_loan"].delete_at(0).to_json
    end
    it "requests loans sorted by title" do
      stub_alma_get_request(url: "users/jbister/loans", body: @loan, query: {"expand" => "renewable", "offset" => 1, "limit" => 1, "direction" => "DESC", "order_by" => "title"})
      loans = Loans.for(uniqname: "jbister", offset: 1, limit: 1, direction: "DESC", order_by: "title")
      expect(loans.pagination.next.url).to include("direction=DESC")
      expect(loans.pagination.next.url).to include("order_by=title")
      expect(loans.pagination.next.url).to include("current-checkouts/u-m-library")
    end
  end
  context "pagination" do
    before(:each) do
      one_loan = JSON.parse(File.read("./spec/fixtures/loans.json"))
      one_loan["item_loan"].delete_at(0)
      stub_alma_get_request(url: "users/jbister/loans", body: one_loan.to_json, query: {"expand" => "renewable", "offset" => 1, "limit" => 1, "order_by" => "due_date"})
    end
    subject do
      Loans.for(uniqname: "jbister", offset: 1, limit: 1)
    end
    context "#count" do
      it "returns total count for loans" do
        expect(subject.count).to eq(2)
      end
    end
    context "#each" do
      it "iterates over limited number of items" do
        loans_contents = ""
        subject.each do |loan|
          loans_contents += loan.class.name
        end
        expect(loans_contents).to eq("Loan")
      end
    end
  end
end

describe Loan do
  before(:each) do
    @loan_response = JSON.parse(File.read("./spec/fixtures/loans.json"))["item_loan"][0]
  end
  subject do
    Loan.new(@loan_response)
  end
  context "#title" do
    it "returns title string" do
      expect(subject.title).to eq("Basics of singing / [compiled by] Jan Schmidt.")
    end
    it "handles non-existent title" do
      @loan_response["title"] = nil
      expect(subject.title).to eq("")
    end
    it "handles truncation for long title and very short author" do
      @loan_response["title"] = "t" * 1000
      @loan_response["author"] = "aaa"
      expect(subject.title).to eq("t" * 237)
    end
    it "handle for long title and long author" do
      @loan_response["title"] = "t" * 1000
      @loan_response["author"] = "a" * 1000
      expect(subject.title).to eq("t" * 120)
    end
    it "handles description" do
      @loan_response["description"] = "v" * 20
      @loan_response["title"] = "t" * 1000
      @loan_response["author"] = "a" * 1000
      expect(subject.title).to eq("t" * 110)
    end
  end
  context "#author" do
    it "returns author string" do
      expect(subject.author).to eq("Schmidt, Jan,")
    end
    it "handles truncation for long author and very short title" do
      @loan_response["author"] = "a" * 1000
      @loan_response["title"] = "ttt"
      expect(subject.author).to eq("a" * 237)
    end
    it "handles non-existent author" do
      @loan_response["author"] = nil
      expect(subject.author).to eq("")
    end
    it "handle for long title and long author" do
      @loan_response["title"] = "t" * 1000
      @loan_response["author"] = "a" * 1000
      expect(subject.author).to eq("a" * 120)
    end
    it "handles description" do
      @loan_response["description"] = "v" * 20
      @loan_response["title"] = "t" * 1000
      @loan_response["author"] = "a" * 1000
      expect(subject.author).to eq("a" * 110)
    end
  end
  context "#publication_date" do
    it "returns publication year string" do
      expect(subject.publication_date).to eq("c1984.")
    end
  end
  context "#url" do
    it "returns url to search with mms_id" do
      expect(subject.url).to eq("https://search.lib.umich.edu/catalog/record/991246960000541")
    end
  end
  context "#due_date" do
    it "returns due date string" do
      expect(subject.due_date).to eq("07/08/18")
    end
    it "returns nothing when claims returned" do
      @loan_response = JSON.parse(File.read("./spec/fixtures/claims_returned.json"))["item_loan"][0]
      expect(subject.due_date).to eq(nil)
    end
  end
  context "#due_status" do
    it "returns 'Overdue'" do
      @loan_response["due_date"] = (Date.today - 1).strftime("%FT%H:%M:%SZ")
      expect(subject.due_status.to_s).to eq("Overdue")
    end
    it "returns 'Due Soon' for today" do
      @loan_response["due_date"] = Date.today.strftime("%FT%H:%M:%SZ")
      expect(subject.due_status.to_s).to eq("Due Soon")
    end
    it "returns 'Due Soon' for 7 days" do
      @loan_response["due_date"] = (Date.today + 7).strftime("%FT%H:%M:%SZ")
      expect(subject.due_status.to_s).to eq("Due Soon")
    end
    it "returns reported as returned for claims returned" do
      @loan_response = JSON.parse(File.read("./spec/fixtures/claims_returned.json"))["item_loan"][0]
      expect(subject.due_status.to_s).to eq("Reported as returned")
    end
    it "returns 'Renewed' when due date is more than 7 days in the future and last renew was yesterday" do
      @loan_response["due_date"] = (Date.today + 8).strftime("%FT%H:%M:%SZ")
      @loan_response["last_renew_date"] = (Date.today - 1).strftime("%FT%H:%M:%SZ")
      expect(subject.due_status.to_s).to eq("Renewed")
    end
    it "returns 'Renewed' when due date is more than 7 days in the future and last renew was 14 days" do
      @loan_response["due_date"] = (Date.today + 8).strftime("%FT%H:%M:%SZ")
      @loan_response["last_renew_date"] = (Date.today - 14).strftime("%FT%H:%M:%SZ")
    end
    it "returns an empty string when due date is more than 7 days in the future and the last renew was over 14 days ago" do
      @loan_response["due_date"] = (Date.today + 8).strftime("%FT%H:%M:%SZ")
      @loan_response["last_renew_date"] = (Date.today - 15).strftime("%FT%H:%M:%SZ")
      expect(subject.due_status.to_s).to eq("")
    end
    it "returns an empty string when due date is more than 7 days in the future and the last renewed date is nill" do
      @loan_response["due_date"] = (Date.today + 8).strftime("%FT%H:%M:%SZ")
      @loan_response["last_renew_date"] = nil
      expect(subject.due_status.to_s).to eq("")
    end
  end
  context "#loan_id" do
    it "returns loan_id string" do
      expect(subject.loan_id).to eq("1332733700000521")
    end
  end
  context "#call_number" do
    it "returns call number string" do
      expect(subject.call_number).to eq("MT825 .B27 1984")
    end
  end
  context "#barcode" do
    it "returns barcode string" do
      expect(subject.barcode).to eq("67576")
    end
  end
end
