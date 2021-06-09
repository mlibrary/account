class DocumentDelivery < InterlibraryLoanItems
  attr_reader :pagination, :count
  def initialize(parsed_response:, pagination:, count: nil)
    super
    @items = parsed_response.map { |item| DocumentDeliveryItem.new(item) }
    @pagination = pagination
    @count = count
  end


  private
  def self.illiad_url(uniqname)
    "/Transaction/UserRequests/#{uniqname}" 
  end
  def self.url
    "/current-checkouts/document-delivery-or-scans"
  end
  def self.filter
    "RequestType eq 'Loan' and TransactionStatus ne 'Request Finished'"
  end
  
end

class DocumentDeliveryItem < InterlibraryLoanItem
end
