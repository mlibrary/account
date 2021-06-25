require 'spec_helper'
require 'json'

describe PendingDocumentDeliveryItem do
  context "two requests" do
    before(:each) do
      @request = JSON.parse(File.read('./spec/fixtures/illiad_requests.json'))[0]
    end
    subject do
      described_class.new(@request)
    end
    context "#status" do
      it "returns Being delivered for In Delivery Transit" do
        @request["TransactionStatus"] = "In Delivery Transit"
        expect(subject.status).to eq('Being Delivered')
      end
      it "returns Being delivered for Out for Delivery" do
        @request["TransactionStatus"] = "Out for Delivery"
        expect(subject.status).to eq('Being Delivered')
      end
      it "returns Ready for 'Customer Notified via E-Mail'" do
        @request["TransactionStatus"] = "Customer Notified via E-Mail"
        expect(subject.status).to eq('Ready')
      end
      it "returns In Process for other" do
        @request["TransactionStatus"] = "Not a Real Status"
        expect(subject.status).to eq('In process')
      end
    end
  end
end
