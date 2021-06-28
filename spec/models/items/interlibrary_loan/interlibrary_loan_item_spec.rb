require 'spec_helper'
require 'json'

describe InterlibraryLoanItem do
  before(:each) do
    @item = JSON.parse(File.read("./spec/fixtures/illiad_requests.json"))[2]
  end
  subject do
    InterlibraryLoanItem.new(@item) 
  end
  context "#title" do
    it "returns title string" do
      expect(subject.title).to eq("Journal of Stuff and Things What I Think")
    end
  end
  context "#author" do
    it "returns author string" do
      expect(subject.author).to eq("A. Greta Mind")
    end
  end
  context "#illiad_id" do
    it "returns the ILLiad transaction ID" do
      expect(subject.illiad_id).to eq(3298020)
    end
  end
  context "#illiad_url" do
    it "returns ILLIAD url based on action number, form number, and if the form is actually type" do
      expect(subject.illiad_url(42, 1887, true)).to eq("https://ill.lib.umich.edu/illiad/illiad.dll?Action=42&Type=1887&Value=3298020")
    end
  end
  context "#url_transaction" do
    it "returns url to the ILLiad transaction" do
      expect(subject.url_transaction).to eq("https://ill.lib.umich.edu/illiad/illiad.dll?Action=10&Form=72&Value=3298020")
    end
  end
  context "#url_cancel_request" do
    it "returns url to cancel the ILLiad transaction request" do
      expect(subject.url_cancel_request).to eq("https://ill.lib.umich.edu/illiad/illiad.dll?Action=21&Type=10&Value=3298020")
    end
  end
  context "#url_request_renewal" do
    it "returns url to the form to request a renewal of the ILLiad transaction" do
      expect(subject.url_request_renewal).to eq("https://ill.lib.umich.edu/illiad/illiad.dll?Action=11&Form=71&Value=3298020")
    end
  end
  context "#creation_date" do
    it "returns creation date string" do
      expect(subject.creation_date).to eq("03/09/21")
    end
  end
  context "#expiration_date" do
    it "returns expiration date string" do
      expect(subject.expiration_date).to eq('')
    end
  end
  context "#due_status" do
    let(:format){"%FT%H:%M:%S.%3N"}
    it "returns 'Overdue'" do
      @item["DueDate"] = (Date.today - 1).strftime(format)
      expect(subject.due_status).to eq("Overdue")
    end
    it "returns 'Due Soon' for today" do
      @item["DueDate"] = (Date.today).strftime(format)
      expect(subject.due_status).to eq("Due Soon")
    end
    it "returns 'Due Soon' for 7 days" do
      @item["DueDate"] = (Date.today + 7).strftime(format)
      expect(subject.due_status).to eq("Due Soon")
    end
    it "returns empty string for far away dates" do
      @item["DueDate"] = (Date.today + 8).strftime(format)
      expect(subject.due_status).to eq('')
    end
  end
  context "#transaction_date" do
    it "returns transaction date string" do
      expect(subject.transaction_date).to eq("03/09/21")
    end
  end
  context "#renewable?" do
    it "returns a boolean" do
      expect(subject.renewable?).to eq(false)
    end
  end
end
