require 'spec_helper'
require 'json'

describe InterlibraryLoanRequests do
  context "one loan" do
    before(:each) do
      stub_illiad_get_request(url: 'Transaction/UserRequests/emcard', body: File.read('./spec/fixtures/illiad_requests.json'))
    end
    subject do
      InterlibraryLoanRequests.for(uniqname: 'emcard')
    end
    context "#count" do
      it "returns total request item count" do
        expect(subject.count).to eq(0)
      end
    end
    context "#each" do
      it "iterates over request objects" do
        requests = ''
        subject.each do |request|
          requests = requests + request.class.name
        end
        expect(requests).to eq('')
      end
    end
  end
end

describe InterlibraryLoanRequest do
  before(:each) do
    @request = JSON.parse(File.read("./spec/fixtures/illiad_requests.json"))[0]
  end
  subject do
    InterlibraryLoanRequest.new(@request) 
  end
  context "#title" do
    it "returns title string" do
      expect(subject.title).to eq("Stanhope Forbes and the Newlyn school")
    end
    it "handles truncation for long title and very short author" do
      @request["LoanTitle"] = 't' * 1000
      @request["LoanAuthor"] = 'aaa'
      expect(subject.title).to eq('t' * 237)
    end
    it "handle for long title and long author" do
      @request["LoanTitle"] = 't' * 1000
      @request["LoanAuthor"] = 'a' * 1000
      expect(subject.title).to eq('t' * 120)
    end
  end
  context "#author" do
    it "returns author string" do
      expect(subject.author).to eq("Fox, Caroline")
    end
    it "handles truncation for long author and very short title" do
      @request["LoanAuthor"] = 'a' * 1000
      @request["LoanTitle"] = 'ttt'
      expect(subject.author).to eq('a' * 237)
    end
    it "handle for long title and long author" do
      @request["LoanTitle"] = 't' * 1000
      @request["LoanAuthor"] = 'a' * 1000
      expect(subject.author).to eq('a' * 120)
    end
  end
  context "#request_url" do
    it "returns url to the ILLiad transaction" do
      expect(subject.request_url).to eq("https://ill.lib.umich.edu/illiad/illiad.dll?Action=10&Form=72&Value=1892144")
    end
  end
  context "#request_date" do
    it "returns request date string" do
      expect(subject.request_date).to eq("May 30, 2013")
    end
  end
  context "#expiration_date" do
    it "returns expiration date string" do
      expect(subject.expiration_date).to eq("Aug 22, 2013")
    end
  end
end
