class InterlibraryLoanRequests < InterlibraryLoanItems
  attr_reader :pagination, :count
  def initialize(parsed_response:, pagination:, count: nil)
    super
    @items = parsed_response.map { |item| InterlibraryLoanRequest.new(item) }
    @pagination = pagination
    @count = count
  end

  def self.illiad_url(uniqname)
    "/Transaction/UserRequests/#{uniqname}"
  end

  def self.url
    "/pending-requests/interlibrary-loan"
  end

  def self.filter
    "TransactionStatus ne 'Request Finished' and TransactionStatus ne 'Cancelled by ILL Staff' and TransactionStatus ne 'Cancelled by Customer' and TransactionStatus ne 'Delivered to Web' and TransactionStatus ne 'Checked Out to Customer' and ProcessType eq 'Borrowing'"
  end
end

class InterlibraryLoanRequest < InterlibraryLoanItem
end
