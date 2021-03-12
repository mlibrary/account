require 'spec_helper'
require 'json'

describe InterlibraryLoanRequests do
  context "one loan" do
    before(:each) do
      stub_illiad_get_request(url: 'Transaction/UserRequests/testhelp', body: File.read('./spec/fixtures/illiad_requests.json'))
    end
    subject do
      InterlibraryLoanRequests.for(uniqname: 'testhelp')
    end
    context "#count" do
      it "returns total request item count" do
        expect(subject.count).to eq(1)
      end
    end
    context "#each" do
      it "iterates over request objects" do
        requests = ''
        subject.each do |request|
          requests = requests + request.class.name
        end
        expect(requests).to eq('InterlibraryLoanRequest')
      end
    end
  end
end

describe InterlibraryLoanRequest do
  before(:each) do
    @request = JSON.parse(File.read("./spec/fixtures/illiad_requests.json"))[2]
  end
  subject do
    InterlibraryLoanRequest.new(@request) 
  end
  context "#title" do
    it "returns url to the ILLiad transaction" do
      expect(subject.title).to eq("What I Think")
    end
  end
  context "#author" do
    it "returns url to the ILLiad transaction" do
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
      expect(subject.creation_date).to eq("Mar 9, 2021")
    end
  end
  context "#expiration_date" do
    it "returns expiration date string" do
      expect(subject.expiration_date).to eq('')
    end
  end
end
