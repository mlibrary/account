require 'spec_helper'
require 'json'

describe Pagination do
  context "many results; one page over; default limit" do
    subject do
      Pagination.new(url: '/things', current_offset: 10, limit: 10, total: 100)
    end
    context "#previous" do
      it "returns previous url string" do
        expect(subject.previous).to eq("/things")
      end
    end
    context "#next" do
      it "returns next url" do
        expect(subject.next).to eq("/things?offset=20")
      end
    end
    context "first" do
      it "returns integer of item index of first shown item" do
        expect(subject.first).to eq(11)
      end
    end
    context "last" do
      it "returns integer of item index of last shown item" do
        expect(subject.last).to eq(20)
      end
    end
  end
end
