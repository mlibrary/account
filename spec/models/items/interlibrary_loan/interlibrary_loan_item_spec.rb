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
      expect(subject.title).to eq("Journal of Stuff and Things")
    end
  end
  context "#author" do
    it "returns author string" do
      expect(subject.author).to eq("A. Greta Mind")
    end
  end
  context "#illiad_url" do
    it "returns url to the ILLiad transaction" do
      expect(subject.illiad_url).to eq("https://ill.lib.umich.edu/illiad/illiad.dll?Action=10&Form=72&Value=3298020")
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
end
