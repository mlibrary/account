class InterlibraryLoanRequests < InterlibraryLoanItems
  attr_reader :pagination, :count
  def initialize(parsed_response:, pagination:, count: nil)
    super
    @items = parsed_response.map { |item| InterlibraryLoanRequest.new(item) }
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
    "not startswith(TransactionStatus, 'Cancelled') and TransactionStatus ne 'Request Finished' and TransactionStatus ne 'Delivered to Web' and TransactionStatus ne 'Checked Out to Customer'"
  end
  
end

class InterlibraryLoanRequest < InterlibraryLoanItem
end
