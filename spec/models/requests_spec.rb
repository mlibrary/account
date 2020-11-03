require 'spec_helper'
require 'json'

# TODO 
# * Pagination of requests????
# * Handling InterLibraryRequests
describe Requests do
  before(:each) do
    stub_alma_get_request( url: 'users/tutor/requests', body: File.read("./spec/fixtures/requests.json") )
  end
  subject do
    Requests.for(uniqname: 'tutor')
  end
  context "#count" do
    it "returns total item count" do
      expect(subject.count).to eq(2)
    end
  end
  context "#holds" do
    it "returns an array" do 
      expect(subject.holds.class.name).to eq('Array')
    end
    it "returns an array with the correct number of items" do
      expect(subject.holds.count).to eq(1)
    end
    it "returns the correct item title" do
      expect(subject.holds.first.request_id).to eq("1383955180006381")
    end
    it "returns items with the correct class" do
      expect(subject.holds.first.class.name).to eq('HoldRequest')
    end
  end
  context "#bookings" do
    it "returns an array" do 
      expect(subject.bookings.class.name).to eq('Array') 
    end
    it "returns an array with the correct number of items" do
      expect(subject.bookings.count).to eq(1)
    end
    it "returns items with the correct class" do
      expect(subject.bookings.first.class.name).to eq('BookingRequest')
    end
    it "returns the correct item" do
      expect(subject.bookings.first.request_id).to eq("1383955240006381")
    end
  end
end
describe HoldRequest do
  before(:each) do
    @hold_response = JSON.parse(File.read("./spec/fixtures/requests.json"))["user_request"][1]
  end
  subject do
    described_class.new(@hold_response) 
  end
  context "#title" do
    it "returns title string" do
      expect(subject.title).to eq("Stories and prose poems [by] Alexander Solzhenitsyn. Translated by Michael Glenny.")
    end
  end
  context "#author" do
    it "returns author string" do
      expect(subject.author).to eq("Solzhenit︠s︡yn, Aleksandr Isaevich, 1918-")
    end
  end
  context "#publication_date" do
    it "returns publication year string" do
      expect(subject.publication_date).to eq("November 3, 2003.")
    end
  end
  context "#search_url" do
    it "returns url to search with mms_id" do
      expect(subject.search_url).to eq("https://search.lib.umich.edu/catalog/record/991549170000541")
    end
  end
  context "#request_id" do
    it "returns loan_id string" do
      expect(subject.request_id).to eq("1383955180006381")
    end
  end
  context "#request_date" do
    it "returns date of the request" do
      expect(subject.request_date).to eq("Nov 2, 2020")
    end
  end
  context "#pickup_location" do
    it "returns pickup_location string" do
      expect(subject.pickup_location).to eq("Main Library")
    end
  end
end
describe BookingRequest do
  before(:each) do
    @booking_response = JSON.parse(File.read("./spec/fixtures/requests.json"))["user_request"][0]
  end
  subject do
    described_class.new(@booking_response) 
  end
  context "#booking_date" do
    it "returns date booking is scheduled for" do
      expect(subject.booking_date).to eq("Nov 19, 2020")
    end
  end
end
