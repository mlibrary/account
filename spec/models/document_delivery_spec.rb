require 'spec_helper'
require 'json'

describe DocumentDelivery do
  context "one loan" do
    before(:each) do
      stub_illiad_get_request(url: 'Transaction/UserRequests/testhelp', body: File.read('./spec/fixtures/illiad_requests.json'))
    end
    subject do
      DocumentDelivery.for(uniqname: 'testhelp')
    end
    context "#count" do
      it "returns total request item count" do
        expect(subject.count).to eq(1)
      end
    end
    context "#each" do
      it "iterates over request objects" do
        document_delivery = ''
        subject.each do |delivery|
          document_delivery = document_delivery + delivery.class.name
        end
        expect(document_delivery).to eq('DocumentDeliveryItem')
      end
    end
  end
end

describe DocumentDeliveryItem do
  before(:each) do
    @delivery = JSON.parse(File.read("./spec/fixtures/illiad_requests.json"))[1]
  end
  subject do
    DocumentDeliveryItem.new(@delivery) 
  end
  context "#title" do
    it "returns title string" do
      expect(subject.title).to eq("Another Test Book")
    end
  end
  context "#author" do
    it "returns author string" do
      expect(subject.author).to eq("Some Other Guy")
    end
  end
  context "#illiad_url" do
    it "returns url to the ILLiad transaction" do
      expect(subject.illiad_url).to eq("https://ill.lib.umich.edu/illiad/illiad.dll?Action=10&Form=72&Value=3298019")
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
