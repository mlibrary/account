class PastInterlibraryLoans < InterlibraryLoanItems
  attr_reader :pagination, :count
  def initialize(parsed_response:, pagination:, count: nil)
    super
    @items = parsed_response.map { |item| PastInterlibraryLoan.new(item) }
    @pagination = pagination
    @count = count
  end


  private
  def self.illiad_url(uniqname)
    "/Transaction/UserRequests/#{uniqname}" 
  end
  def self.url
    "/past-activity/interlibrary-loan"
  end
  def self.filter
    "RequestType ne 'Loan' and (TransactionStatus eq 'Request Finished' or startswith(TransactionStatus, 'Cancelled'))"
  end
  
end

class PastInterlibraryLoan < InterlibraryLoanItem
end
