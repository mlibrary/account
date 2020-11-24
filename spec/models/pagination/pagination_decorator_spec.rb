require 'spec_helper'

describe PaginationDecorator do
  context "two page array; default limit; first page" do

    before(:each) do
      @input = {
        url: '/things',
        current_offset: 0,
        total: 20,
        limit: 10
      }
    end
    subject do
      PaginationDecorator.new(**@input)
    end
    context "#previous" do
      it "has url" do
        expect(subject.previous.url).to eq("/things")
      end
      it "shows current_page status" do
        expect(subject.previous.current_page?).to eq(true)
      end
    end
    context "#next" do
      it "has url" do
        expect(subject.next.url).to eq("/things?offset=10")
      end
      it "shows current_page status" do
        expect(subject.next.current_page?).to eq(false)
      end
    end
    context "#pages" do
      it "contains array with correct number of pages" do
        expect(subject.pages.count).to eq(2)
      end
      context "first page" do
        it "has url" do
          expect(subject.pages[0].url).to eq("/things")
        end
        it "has current_page status" do
          expect(subject.pages[0].current_page?).to eq(true)
        end
        it "has page_number" do
          expect(subject.pages[0].page_number).to eq(1)
        end
      end
    end
  end
  context "second page; two pages of results; non default limit" do

    before(:each) do
      @input = {
        url: '/things',
        current_offset: 5,
        total: 10,
        limit: 5 
      }
    end
    subject do
      PaginationDecorator.new(**@input)
    end
    context "#previous" do
      it "has url" do
        expect(subject.previous.url).to eq("/things?limit=5")
      end
      it "shows current_page status" do
        expect(subject.previous.current_page?).to eq(false)
      end
    end
    context "#next" do
      it "has url" do
        expect(subject.next.url).to eq("/things?offset=5&limit=5")
      end
      it "shows current_page status" do
        expect(subject.next.current_page?).to eq(true)
      end
    end
    context "#pages" do
      it "contains array with correct number of pages" do
        expect(subject.pages.count).to eq(2)
      end
      context "first page" do
        it "has url" do
          expect(subject.pages[0].url).to eq("/things?limit=5")
        end
        it "has current_page status" do
          expect(subject.pages[0].current_page?).to eq(false)
        end
        it "has page_number" do
          expect(subject.pages[0].page_number).to eq(1)
        end
      end
    end
  end
end
