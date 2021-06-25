class PendingLocalDocumentDelivery < InterlibraryLoanItems
  attr_reader :pagination, :count
  def initialize(parsed_response:, pagination:, count: nil)
    super
    @items = parsed_response.map { |item| PendingDocumentDeliveryItem.new(item) }
    @pagination = pagination
    @count = count
  end

  def self.empty_state(markdown=Redcarpet::Markdown.new(Redcarpet::Render::HTML))
    markdown.render("You don’t have any active requests.\n\nLearn more about [requesting scans](https://lib.umich.edu/find-borrow-request/request-digital-copies-or-duplication/scans) and [item delivery](https://lib.umich.edu/find-borrow-request/request-items-pick-or-delivery/delivery-your-department).")
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
  def status
    tstatus = @parsed_response["TransactionStatus"]
    if ['In Delivery Transit','Out for Delivery'].include?(tstatus)
      'Being delivered'
    elsif ['Customer Notified via E-Mail'].include?(tstatus)
      'Ready'
    else
      'In process'
    end
  end
  def status_tag
    case self.status
    when "Ready"
      "--success"
    when "Being delivered"
      "--warning"
    else
      ''
    end
  end
end
