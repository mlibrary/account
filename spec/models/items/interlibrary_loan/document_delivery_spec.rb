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
    context "#empty?" do
      it "returns a boolean" do
        expect(subject.empty?).to eq(false)
      end
    end
    context "#item_text" do
      it "returns 'item' if there is only one loan, or 'items' if there is not" do
        expect(subject.item_text).to eq('item')
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
  context "#illiad_id" do
    it "returns the ILLiad transaction ID" do
      expect(subject.illiad_id).to eq(3298019)
    end
  end
  context "#illiad_url" do
    it "returns ILLIAD url based on action number, form number, and if the form is actually type" do
      expect(subject.illiad_url(42, 1887, true)).to eq("https://ill.lib.umich.edu/illiad/illiad.dll?Action=42&Type=1887&Value=3298019")
    end
  end
  context "#url_transaction" do
    it "returns url to the ILLiad transaction" do
      expect(subject.url_transaction).to eq("https://ill.lib.umich.edu/illiad/illiad.dll?Action=10&Form=72&Value=3298019")
    end
  end
  context "#url_cancel_request" do
    it "returns url to cancel the ILLiad transaction request" do
      expect(subject.url_cancel_request).to eq("https://ill.lib.umich.edu/illiad/illiad.dll?Action=21&Type=10&Value=3298019")
    end
  end
  context "#url_request_renewal" do
    it "returns url to the form to request a renewal of the ILLiad transaction" do
      expect(subject.url_request_renewal).to eq("https://ill.lib.umich.edu/illiad/illiad.dll?Action=11&Form=71&Value=3298019")
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
