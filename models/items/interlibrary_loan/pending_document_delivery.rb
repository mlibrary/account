class PendingLocalDocumentDelivery < InterlibraryLoanItems
  attr_reader :pagination, :count
  def initialize(parsed_response:, pagination:, count: nil)
    super
    @items = parsed_response.map { |item| PendingDocumentDeliveryItem.new(item) }
    @pagination = pagination
    @count = count
  end

  def self.empty_state(markdown=Redcarpet::Markdown.new(Redcarpet::Render::HTML))
    markdown.render("You don’t have any active departmental delivery requests.\n\nLearn more [about this service](https://lib.umich.edu/find-borrow-request/request-items-pick-or-delivery/delivery-your-department).")
  end


  private
  def self.illiad_url(uniqname)
    "/Transaction/UserRequests/#{uniqname}" 
  end
  def self.url
    ""
  end
  def self.filter
    "RequestType eq 'Loan' and TransactionStatus ne 'Request Finished' and TransactionStatus ne 'Cancelled by ILL Staff' and TransactionStatus ne 'Cancelled by Customer' and TransactionStatus ne 'Delivered to Web' and TransactionStatus ne 'Checked Out to Customer' and ProcessType eq 'DocDel'"
  end
  
end

class PendingDocumentDeliveryItem < InterlibraryLoanItem
end
