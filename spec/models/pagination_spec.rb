require 'spec_helper'
require 'json'

describe Pagination do
  context "many results; first page; default limit" do
    subject do
      Pagination.new(current_offset: 0, limit: 10, total: 100)
    end
    context "#previous" do
      it "returns previous page offset" do
        expect(subject.previous.offset).to eq(0)
      end
      it "is current page" do
        expect(subject.previous.current_page?).to eq(true)
      end
    end
    context "#next" do
      it "returns next page offset" do
        expect(subject.next.offset).to eq(10)
      end
      it "is not current page" do
        expect(subject.next.current_page?).to eq(false)
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
        expect(page.current_page?).to be_truthy
        expect(page.page_number).to eq(1)
      end
      it "returns second Page" do
        page = pages[1]
        expect(page.offset).to eq(10)
        expect(page.current_page?).to be_falsey
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
      it "returns fifth Page" do
        page = pages[4]
        expect(page.offset).to eq(40)
        expect(page.current_page?).to be_falsey
        expect(page.page_number).to eq(5)
      end
    end
  end
  context "many results; one page over; default limit" do
    subject do
      Pagination.new(current_offset: 10, limit: 10, total: 100)
    end
    context "#previous" do
      it "returns previous page offset" do
        expect(subject.previous.offset).to eq(0)
      end
    end
    context "#next" do
      it "returns next page offset" do
        expect(subject.next.offset).to eq(20)
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
      it "returns fifth Page" do
        page = pages[4]
        expect(page.offset).to eq(40)
        expect(page.current_page?).to be_falsey
        expect(page.page_number).to eq(5)
      end
    end
  end
  context "many results; middle of set; default limit" do
    subject do
      Pagination.new(current_offset: 50, limit: 10, total: 100)
    end
    context "#previous" do
      it "returns previous page offset" do
        expect(subject.previous.offset).to eq(40)
      end
      it "is not current page" do
        expect(subject.previous.current_page?).to eq(false)
      end
    end
    context "#next" do
      it "returns next page offset" do
        expect(subject.next.offset).to eq(60)
      end
      it "is not current page" do
        expect(subject.next.current_page?).to eq(false)
      end
    end
    context "#pages" do
      let(:pages) { subject.pages }
      
      it "returns first Page" do
        page = pages[0]
        expect(page.offset).to eq(30)
        expect(page.current_page?).to be_falsey
        expect(page.page_number).to eq(4)
      end
      it "returns second Page" do
        page = pages[1]
        expect(page.offset).to eq(40)
        expect(page.current_page?).to be_falsey
        expect(page.page_number).to eq(5)
      end
      it "returns third Page" do
        page = pages[2]
        expect(page.offset).to eq(50)
        expect(page.current_page?).to be_truthy
        expect(page.page_number).to eq(6)
      end
      it "returns fourth Page" do
        page = pages[3]
        expect(page.offset).to eq(60)
        expect(page.current_page?).to be_falsey
        expect(page.page_number).to eq(7)
      end
      it "returns fifth Page" do
        page = pages[4]
        expect(page.offset).to eq(70)
        expect(page.current_page?).to be_falsey
        expect(page.page_number).to eq(8)
      end
    end
  end
  context "many results; next to last page of set; default limit" do
    subject do
      Pagination.new(current_offset: 80, limit: 10, total: 100)
    end
    context "#previous" do
      it "returns previous page offset" do
        expect(subject.previous.offset).to eq(70)
      end
      it "is not current page" do
        expect(subject.previous.current_page?).to eq(false)
      end
    end
    context "#next" do
      it "returns next page offset" do
        expect(subject.next.offset).to eq(90)
      end
      it "is not current page" do
        expect(subject.next.current_page?).to eq(false)
      end
    end
    context "#pages" do
      let(:pages) { subject.pages }
      
      it "returns first Page" do
        page = pages[0]
        expect(page.offset).to eq(50)
        expect(page.current_page?).to be_falsey
        expect(page.page_number).to eq(6)
      end
      it "returns second Page" do
        page = pages[1]
        expect(page.offset).to eq(60)
        expect(page.current_page?).to be_falsey
        expect(page.page_number).to eq(7)
      end
      it "returns third Page" do
        page = pages[2]
        expect(page.offset).to eq(70)
        expect(page.current_page?).to be_falsey
        expect(page.page_number).to eq(8)
      end
      it "returns fourth Page" do
        page = pages[3]
        expect(page.offset).to eq(80)
        expect(page.current_page?).to be_truthy
        expect(page.page_number).to eq(9)
      end
      it "returns fifth Page" do
        page = pages[4]
        expect(page.offset).to eq(90)
        expect(page.current_page?).to be_falsey
        expect(page.page_number).to eq(10)
      end
    end
  end
  context "many results; last page of set; default limit" do
    subject do
      Pagination.new(current_offset: 90, limit: 10, total: 100)
    end
    context "#previous" do
      it "returns previous page offset" do
        expect(subject.previous.offset).to eq(80)
      end
      it "is not current page" do
        expect(subject.previous.current_page?).to eq(false)
      end
    end
    context "#next" do
      it "returns next page offset" do
        expect(subject.next.offset).to eq(90)
      end
      it "is not current page" do
        expect(subject.next.current_page?).to eq(true)
      end
    end
    context "#pages" do
      let(:pages) { subject.pages }
      
      it "returns first Page" do
        page = pages[0]
        expect(page.offset).to eq(50)
        expect(page.current_page?).to be_falsey
        expect(page.page_number).to eq(6)
      end
      it "returns second Page" do
        page = pages[1]
        expect(page.offset).to eq(60)
        expect(page.current_page?).to be_falsey
        expect(page.page_number).to eq(7)
      end
      it "returns third Page" do
        page = pages[2]
        expect(page.offset).to eq(70)
        expect(page.current_page?).to be_falsey
        expect(page.page_number).to eq(8)
      end
      it "returns fourth Page" do
        page = pages[3]
        expect(page.offset).to eq(80)
        expect(page.current_page?).to be_falsey
        expect(page.page_number).to eq(9)
      end
      it "returns fifth Page" do
        page = pages[4]
        expect(page.offset).to eq(90)
        expect(page.current_page?).to be_truthy
        expect(page.page_number).to eq(10)
      end
    end
  end
  context "two pages of results; first page; default limit" do
    subject do
      Pagination.new(current_offset: 0, limit: 10, total: 12)
    end
    context "#previous" do
      it "returns previous page offset" do
        expect(subject.previous.offset).to eq(0)
      end
      it "is not current page" do
        expect(subject.previous.current_page?).to eq(true)
      end
    end
    context "#next" do
      it "returns next page offset" do
        expect(subject.next.offset).to eq(10)
      end
      it "is not current page" do
        expect(subject.next.current_page?).to eq(false)
      end
    end
    context "#pages" do
      let(:pages) { subject.pages }
      it "returns array with 2 elements" do
        expect(pages.count).to eq(2)
      end
      it "returns first Page" do
        page = pages[0]
        expect(page.offset).to eq(0)
        expect(page.current_page?).to be_truthy
        expect(page.page_number).to eq(1)
      end
      it "returns second Page" do
        page = pages[1]
        expect(page.offset).to eq(10)
        expect(page.current_page?).to be_falsey
        expect(page.page_number).to eq(2)
      end
    end
  end
  context "one page of results; default limit" do
    subject do
      Pagination.new(current_offset: 0, limit: 10, total: 6)
    end
    context "#previous" do
      it "returns previous page offset" do
        expect(subject.previous.offset).to eq(0)
      end
      it "is current page" do
        expect(subject.previous.current_page?).to eq(true)
      end
    end
    context "#next" do
      it "returns next page offset" do
        expect(subject.next.offset).to eq(0)
      end
      it "is current page" do
        expect(subject.next.current_page?).to eq(true)
      end
    end
    context "#pages" do
      let(:pages) { subject.pages }
      it "returns array with 2 elements" do
        expect(pages.count).to eq(1)
      end
      it "returns first Page" do
        page = pages[0]
        expect(page.offset).to eq(0)
        expect(page.current_page?).to be_truthy
        expect(page.page_number).to eq(1)
      end
    end
  end
end
