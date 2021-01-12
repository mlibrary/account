require 'spec_helper'
require 'json'

# TODO 
# * Pagination of loans
# * Handling InterLibraryLoan
# * Double checking that renewable is included in basic loans?
describe Loans do
  context "one loan" do
    before(:each) do
      stub_alma_get_request( url: 'users/jbister/loans', body: File.read("./spec/fixtures/loans.json"), query: {expand: 'renewable'} )
    end
    subject do
      Loans.for(uniqname: 'jbister')
    end
    context "#count" do
      it "returns total loan item count" do
        expect(subject.count).to eq(2)
      end
    end
    context "#empty?" do
      it "returns false" do
        expect(subject.empty?).to eq(false)
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
  context "no loans" do
    before(:each) do
      stub_alma_get_request( url: 'users/jbister/loans', body: File.read("./spec/fixtures/no_loans.json"), query: {expand: 'renewable'} )
    end
    subject do
      Loans.for(uniqname: 'jbister')
    end
    context "#count" do
      it "returns total loan item count" do
        expect(subject.count).to eq(0)
      end
    end
    context "#empty?" do
      it "returns false" do
        expect(subject.empty?).to eq(true)
      end
    end
  end
  context "pagination" do
    before(:each) do
      one_loan = JSON.parse(File.read("./spec/fixtures/loans.json"))
      one_loan["item_loan"].delete_at(0)
      stub_alma_get_request( url: 'users/jbister/loans', body: one_loan.to_json, query: {"expand" => "renewable", "offset" => 1, "limit" => 1} )
    end
    subject do
      Loans.for(uniqname: 'jbister', offset: 1, limit: 1)
    end
    context "#count" do
      it "returns total count for loans" do
        expect(subject.count).to eq(2)
      end
    end
    context "#each" do
      it "iterates over limited number of items" do
        loans_contents = ''
        subject.each do |loan|
          loans_contents = loans_contents + loan.class.name
        end
        expect(loans_contents).to eq('Loan')
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
    it "handles truncation for long title and very short author" do
      @loan_response["title"] = 't' * 1000
      @loan_response["author"] = 'aaa'
      expect(subject.title).to eq('t' * 237)
    end
    it "handle for long title and long author" do
      @loan_response["title"] = 't' * 1000
      @loan_response["author"] = 'a' * 1000
      expect(subject.title).to eq('t' * 120)
    end
  end
  context "#author" do
    it "returns author string" do
      expect(subject.author).to eq("Schmidt, Jan,")
    end
    it "handles truncation for long author and very short title" do
      @loan_response["author"] = 'a' * 1000
      @loan_response["title"] = 'ttt'
      expect(subject.author).to eq('a' * 237)
    end
    it "handle for long title and long author" do
      @loan_response["title"] = 't' * 1000
      @loan_response["author"] = 'a' * 1000
      expect(subject.author).to eq('a' * 120)
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
      expect(subject.renewable?).to eq(true)
    end
  end
end
describe Loans do
  context ".renew(uniqname:, loan_ids:)" do
    subject do
      Loans.renew(loan_ids: ['1234','5678'], uniqname: 'jbister')
    end
    it "returns a HTTParty response of success" do
      stub_alma_post_request( url: 'users/jbister/loans/1234', body: '{}', query: {op: 'renew'} )
      stub_alma_post_request( url: 'users/jbister/loans/5678', body: '{}', query: {op: 'renew'} )
      expect(subject.code).to eq(200)
    end
    it "returns errors for unrenewable items" do
      error = File.read('./spec/fixtures/alma_error.json')
      stub_alma_post_request( status: 500, url: 'users/jbister/loans/1234', body: error, query: {op: 'renew'} )
      stub_alma_post_request( status: 500, url: 'users/jbister/loans/5678', body: error, query: {op: 'renew'} )
      expect(subject.code).to eq(500)
      expect(subject.message).to eq("User with identifier mrioaaa was not found.\nUser with identifier mrioaaa was not found.")
    end
  end
  context ".renew_all(uniqname:)" do
    subject do
      Loans.renew_all(uniqname: 'jbister')
    end
    it "renews all items even across pagination" do
      stub_alma_get_request( url: 'users/jbister/loans', body: File.read('./spec/fixtures/loans.json'), query: {expand: 'renewable', limit: 100, offset: 0} )
      renew1 = stub_alma_post_request( url: 'users/jbister/loans/1332733700000521', body: '{}', query: {op: 'renew'} )
      renew2 = stub_alma_post_request( url: 'users/jbister/loans/1332734190000521', body: '{}', query: {op: 'renew'} )

      expect(subject.code).to eq(200)
      expect(renew1).to have_been_requested
      expect(renew2).to have_been_requested
    end
  end
end
describe Loan, ".renew(loan_id:, uniqname:)" do
  subject do
    Loan.renew(loan_id: '1234', uniqname: 'jbister')
  end
  it "returns a HTTParty response of success" do
    stub_alma_post_request( url: 'users/jbister/loans/1234', body: '{}', query: {op: 'renew'} )
    expect(subject.code).to eq(200)
  end
  it "returns alma error" do
    stub_alma_post_request( url: 'users/jbister/loans/1234', body: File.read('./spec/fixtures/alma_error.json'), query: {op: 'renew'}, status: 400 )
    expect(subject.code).to eq(400)
    expect(subject.message).to eq("User with identifier mrioaaa was not found.")
  end
end
