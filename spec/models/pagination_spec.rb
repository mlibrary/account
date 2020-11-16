require 'spec_helper'
require 'json'

describe Pagination do
  context "many results; one page over; default limit" do
    subject do
      Pagination.new(url: '/things', current_offset: 10, limit: 10, total: 100)
    end
    context "#previous_offset" do
      it "returns previous page offset" do
        expect(subject.previous_offset).to eq(0)
      end
    end
    context "#next_offset" do
      it "returns next page offset" do
        expect(subject.next_offset).to eq(20)
      end
    end
    context "first" do
      it "returns integer of item index of first shown item" do
        expect(subject.first).to eq(11)
      end
    end
    context "#last" do
      it "returns integer of item index of last shown item" do
        expect(subject.last).to eq(20)
      end
    end
    context "#pages" do
      let(:pages) { subject.pages }
      it "returns an array of 5 Pages" do
        expect(pages.count).to eq(5)
        expect(pages[0].class.name).to eq('Pagination::Page')
      end
      
      it "returns first Page" do
        page = pages[0]
        expect(page.offset).to eq(0)
        expect(page.current_page?).to be_falsey
        expect(page.page_number).to eq(1)
      end
      it "returns second Page" do
        page = pages[1]
        expect(page.offset).to eq(10)
        expect(page.current_page?).to be_truthy
        expect(page.page_number).to eq(2)
      end
      it "returns third Page" do
        page = pages[2]
        expect(page.offset).to eq(20)
        expect(page.current_page?).to be_falsey
        expect(page.page_number).to eq(3)
      end
      it "returns fourth Page" do
        page = pages[3]
        expect(page.offset).to eq(30)
        expect(page.current_page?).to be_falsey
        expect(page.page_number).to eq(4)
      end
      it "returns fith Page" do
        page = pages[4]
        expect(page.offset).to eq(40)
        expect(page.current_page?).to be_falsey
        expect(page.page_number).to eq(5)
      end
    end
  end
end
