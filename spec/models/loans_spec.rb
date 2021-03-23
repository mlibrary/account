require 'spec_helper'
require 'json'

# TODO 
# * Pagination of loans
# * Handling InterLibraryLoan
# * Double checking that renewable is included in basic loans?
describe Loans do
  context "two loans" do
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
    context "#initialize" do
      it "returns loans with item messages" do
        loans = JSON.parse(File.read("./spec/fixtures/loans.json"))
        items= [ Loan.new(loans["item_loan"][0], Loan::RenewSuccessfulMessage.new) ]
        pagination = instance_double(PaginationDecorator) 
        my_loans = Loans.new(parsed_response: loans, pagination: pagination, renewed_items: items)
        my_message = ''
        my_loans.each { |x| my_message = my_message + x.message_status.to_s }
        expect(my_message).to eq('success')
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
  context "sort" do
    before(:each) do
      one_loan = JSON.parse(File.read("./spec/fixtures/loans.json"))
      @loan = one_loan["item_loan"].delete_at(0).to_json
    end
    it "requests loans sorted by title" do
      stub_alma_get_request( url: 'users/jbister/loans', body: @loan, query: {"expand" => "renewable", "offset" => 1, "limit" => 1, "direction" => "ASC", "order_by" => "title"} )
      loans = Loans.for(uniqname: 'jbister', offset: 1, limit: 1, direction: "ASC", order_by: "title")
      expect(loans.pagination.next.url).to include("direction=ASC")
      expect(loans.pagination.next.url).to include("order_by=title")
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
    @message = nil
  end
  subject do
    Loan.new(@loan_response, @message) 
  end
  context "#message?" do
    it "returns true for existing message" do
      @message = "Message!"
      expect(subject.message?).to eq(true)
    end
    it "returns false for no message" do
      expect(subject.message?).to eq(false)
    end
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
  context ".renew(uniqname:, loans:)" do
    subject do
      loan_1 = instance_double(Loan, loan_id: '1234', parsed_response: {})
      loan_2 = instance_double(Loan, loan_id: '5678', parsed_response: {})
      Loans.renew(loans: [loan_1, loan_2], uniqname: 'jbister')
    end
    it "returns a HTTParty response of success" do
      stub_alma_post_request( url: 'users/jbister/loans/1234', body: '{}', query: {op: 'renew'} )
      stub_alma_post_request( url: 'users/jbister/loans/5678', body: '{}', query: {op: 'renew'} )
      expect(subject.code).to eq(200)
      expect(subject.items.count).to eq(2)
      expect(subject.items.first.message_status).to eq(:success)
    end
    it "returns errors for unrenewable items" do
      error = File.read('./spec/fixtures/alma_error.json')
      stub_alma_post_request( status: 500, url: 'users/jbister/loans/1234', body: error, query: {op: 'renew'} )
      stub_alma_post_request( status: 500, url: 'users/jbister/loans/5678', body: error, query: {op: 'renew'} )
      expect(subject.code).to eq(200)
      expect(subject.items.count).to eq(2)
      expect(subject.items.first.message_status).to eq(:fail)
    end
  end
  context ".renew_all(uniqname:)" do
    before(:each) do
      stub_alma_get_request( url: 'users/jbister/loans', body: File.read('./spec/fixtures/loans.json'), query: {expand: 'renewable', limit: 100, offset: 0} )
    end
    subject do
      Loans.renew_all(uniqname: 'jbister')
    end
    def stub_renew1(body='{}')
      stub_alma_post_request( url: 'users/jbister/loans/1332733700000521', body: body, query: {op: 'renew'} ) 
    end
    def stub_renew2(body='{}')
      stub_alma_post_request( url: 'users/jbister/loans/1332734190000521', body: body, query: {op: 'renew'} ) 
    end
    it "renews all items" do
      renew1 = stub_renew1
      renew2 = stub_renew2

      expect(subject.code).to eq(200)
      expect(renew1).to have_been_requested
      expect(renew2).to have_been_requested
    end
    it "returns appropriate response for renews" do
      stub_renew1(File.read('./spec/fixtures/renew_loan1.json'))
      stub_renew2(File.read('./spec/fixtures/renew_loan2.json'))
      response = subject
      expect(response.code).to eq(200)
      expect(response.items.count).to eq(2)
    end
    it "handles unrenewable loans" do
      loans = JSON.parse(File.read('./spec/fixtures/loans.json'))
      loan_id = loans["item_loan"][0]["loan_id"]
      loans["item_loan"][0]["renewable"] = false
      stub_renew2
      stub_alma_get_request( url: 'users/jbister/loans', body: loans.to_json, query: {expand: 'renewable', limit: 100, offset: 0} )
      unrenewable_loan = subject.items.find{|x| x.loan_id == loan_id}
      expect(unrenewable_loan.message_status).to eq(:fail)
    end
  end
end
describe Loan, ".renew(loan_id:, uniqname:)" do
  subject do
    Loan.renew(loan_id: '1234', uniqname: 'jbister')
  end
  it "returns Renew Successful message for successful renew" do
    stub_alma_post_request( url: 'users/jbister/loans/1234', body: '{}', query: {op: 'renew'} )
    expect(subject.class.name).to eq('Loan::RenewSuccessfulMessage')
    expect(subject.status).to eq(:success)
  end
  it "returns Renew Unsuccessful message for unsuccessful renews" do
    stub_alma_post_request( url: 'users/jbister/loans/1234', body: File.read('./spec/fixtures/alma_error.json'), query: {op: 'renew'}, status: 400 )
    expect(subject.class.name).to eq('Loan::RenewUnsuccessfulMessage')
    expect(subject.status).to eq(:fail)
  end
end
describe Loan::Message do
  describe Loan::RenewSuccessfulMessage do
    subject do
      Loan::RenewSuccessfulMessage.new
    end
    context "#message" do
      it "shows correct message" do
        expect(subject.text).to eq("Renew Successful")
      end
    end
    context "#status" do
      it "shows correct status" do
        expect(subject.status).to eq(:success)
      end
    end
  end
  describe Loan::RenewUnsuccessfulMessage do
    subject do
      Loan::RenewUnsuccessfulMessage.new('renew failed')
    end
    context "#message" do
      it "shows correct message" do
        expect(subject.text).to eq("renew failed")
      end
    end
    context "#status" do
      it "shows correct status" do
        expect(subject.status).to eq(:fail)
      end
    end
  end
end
