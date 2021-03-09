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
    it "returns title string" do
      expect(subject.title).to eq("What I Think")
    end
    it "handles truncation for long title and very short author" do
      @request["PhotoArticleTitle"] = 't' * 1000
      @request["PhotoArticleAuthor"] = 'aaa'
      expect(subject.title).to eq('t' * 237)
    end
    it "handle for long title and long author" do
      @request["PhotoArticleTitle"] = 't' * 1000
      @request["PhotoArticleAuthor"] = 'a' * 1000
      expect(subject.title).to eq('t' * 120)
    end
  end
  context "#author" do
    it "returns author string" do
      expect(subject.author).to eq("A. Greta Mind")
    end
    it "handles truncation for long author and very short title" do
      @request["PhotoArticleAuthor"] = 'a' * 1000
      @request["PhotoArticleTitle"] = 'ttt'
      expect(subject.author).to eq('a' * 237)
    end
    it "handle for long title and long author" do
      @request["PhotoArticleTitle"] = 't' * 1000
      @request["PhotoArticleAuthor"] = 'a' * 1000
      expect(subject.author).to eq('a' * 120)
    end
  end
  context "#request_url" do
    it "returns url to the ILLiad transaction" do
      expect(subject.request_url).to eq("https://ill.lib.umich.edu/illiad/illiad.dll?Action=10&Form=72&Value=3298020")
    end
  end
  context "#request_date" do
    it "returns request date string" do
      expect(subject.request_date).to eq("Mar 9, 2021")
    end
  end
  context "#expiration_date" do
    it "returns expiration date string" do
      expect(subject.expiration_date).to eq(nil)
    end
  end
end
