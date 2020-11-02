require 'spec_helper'
require 'json'

# TODO 
# * Pagination of loans
# * Handling InterLibraryLoan
# * Double checking that renewable is included in basic loans?
describe Loans do
  context "found uniqname" do
    before(:each) do
      stub_alma_get_request( url: 'users/jbister/loans', body: File.read("./spec/fixtures/loans.json") )
      #requests = [
        #{ url: 'users/jbister/loans', fixture: 'loans.json'},
        #{ url: 'bibs/991246960000541/holdings/225047730000541/items/235047720000541', 
           #fixture: 'basics_of_singing_item.json'},
        #{ url: 'bibs/991408490000541/holdings/229209090000521/items/235561180000541', 
            #fixture: 'plain_words_on_singing_item.json'},
        #{ url: 'items?item_barcode=67576', fixture: 'basics_of_singing_item.json'},
        #{ url: 'items?item_barcode=0919242913', fixture: 'plain_words_on_singing_item.json'},
      #]
      #requests.map do |r| 
        #stub_alma_get_request( url: r[:url], body: File.read("./spec/fixtures/#{r[:fixture]}") )
      #end
    end
    subject do
      Loans.for(uniqname: 'jbister')
    end
    context "#count" do
      it "returns total loan item count" do
        expect(subject.count).to eq(2)
      end
    end
    context "#each" do
      it "iterates over loan objects" do
        loans_contents = ''
        subject.each do |loan|
          loans_contents = loans_contents + loan.class.name
        end
        expect(loans_contents).to eq('LoanLoan')
      end
    end
  end
end

describe Loan do
  before(:each) do
    @loan_response = JSON.parse(File.read("./spec/fixtures/loans.json"))["item_loan"][0]
  end
  subject do
    Loan.new(@loan_response) 
  end
  context "#title" do
    it "returns title string" do
      expect(subject.title).to eq("Basics of singing / [compiled by] Jan Schmidt.")
    end
  end
  context "#author" do
    it "returns author string" do
      expect(subject.author).to eq("Schmidt, Jan,")
    end
  end
  context "#publication_date" do
    it "returns publication year string" do
      expect(subject.publication_date).to eq("c1984.")
    end
  end
  context "#search_url" do
    it "returns url to search with mms_id" do
      expect(subject.search_url).to eq("https://search.lib.umich.edu/catalog/record/991246960000541")
    end
  end
  context "#due_date" do
    it "returns due date string" do
      expect(subject.due_date).to eq("Jul 8, 2018")
    end
  end
  context "#loan_id" do
    it "returns loan_id string" do
      expect(subject.loan_id).to eq("1332733700000521")
    end
  end
  context "#call_number" do
    it "returns call number string" do
      expect(subject.call_number).to eq("MT825 .B27 1984")
    end
  end
  context "#renewable?" do
    it "returns boolean" do
      expect(subject.renewable?).to eq(false)
    end
  end
  context "#ill?" do  
    it "returns boolean for if item is InterLibraryLoan"
  end
end
#describe Loans, 'list' do
  #before(:each) do 
    #@loans = JSON.parse(File.read('./spec/fixtures/loans.json'))
    #@requests = {
      #'/users/jbister/loans' => ExconResponseDouble.new(body: @loans.to_json),
      #'/bibs/991246960000541/holdings/225047730000541/items/235047720000541' =>
        #ExconResponseDouble.new(body: File.read('./spec/fixtures/basics_of_singing_item.json')),
      #'/bibs/991408490000541/holdings/229209090000521/items/235561180000541' =>
        #ExconResponseDouble.new(body: File.read('./spec/fixtures/plain_words_on_singing_item.json')),
      #'/items?item_barcode=67576' =>
        #ExconResponseDouble.new(body: File.read('./spec/fixtures/basics_of_singing_item.json')),
      #'/items?item_barcode=0919242913' =>
        #ExconResponseDouble.new(body: File.read('./spec/fixtures/plain_words_on_singing_item.json')),
    #}
    #@expected_output = 
      #[
        #{
          #"duedate"=>"20180728 2200", #z36-due-date z36-due-hour
          #"isbn"=>"0028723406",  #z13-isbn
          #"status"=>"", 
          #"author"=>"Schmidt, Jan,", #z13-author
          #"title"=>"Basics of singing / [compiled by] Jan Schmidt.", #z13-title
          #"barcode"=>"67576", #z30-barcode
          #"call_number"=>"MT825 .B27 1984", #z30-call-no
          #"description"=>nil, #z30-description
          #"id"=>"991246960000541", #z13-doc-number
          #"bib_library"=>"", #z13-user-defined-5 || z13-user-defined-3
          #"location"=>"Music Library",  #z30-sub-library
          #"format"=>['Music Score'], #z30-material
          #"num"=>0
        #}, {
          #"duedate"=>"20180728 2200", 
          #"isbn"=>9781234567897, 
          #"status"=>"", 
          #"author"=>"Shakespeare, William,", 
          #"title"=>"Plain words on singing / by William Shakespeare ..", 
          #"barcode"=>"0919242913", 
          #"call_number"=>"MT820 .S53", 
          #"description"=>nil, 
          #"id"=>"991408490000541", 
          #"bib_library"=>"", 
          #"location"=>"Music Library", 
          #"format"=>["Book"], 
          #"num"=>1
        #}
      #]
  #end
  #it "returns correct number of items list of loans" do
    #dbl = HttpClientGetDouble.new(@requests)
    #loans = Loans.new(uniqname: 'jbister', client: dbl)
    #expect(loans.list.body.count).to eq(2) 
  #end
  #it "reutrns correct items" do
    #dbl = HttpClientGetDouble.new(@requests)
    #loans = Loans.new(uniqname: 'jbister', client: dbl)
    #expect(loans.list.body).to eq(@expected_output) 
  #end
  #it "handles empty loans" do
    #@loans['total_record_count'] = 0
    #@loans.delete('item_loan')
    #resp = ExconResponseDouble.new(body: @loans.to_json)
    #dbl = HttpClientGetDouble.new({@requests.keys[0] => resp})
    #loans = Loans.new(uniqname: 'jbister', client: dbl)
    #expect(loans.list.body).to eq([])
  #end
#end
