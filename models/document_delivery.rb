class DocumentDelivery < Items
  def initialize(parsed_response:)
    @parsed_response = parsed_response
    @items = parsed_response.filter_map { |item| DocumentDeliveryItem.new(item) if item["RequestType"] == "Loan" && item["TransactionStatus"] != "Request Finished" }
  end

  def self.for(uniqname:, client: ILLiadClient.new)
    url = "/Transaction/UserRequests/#{uniqname}" 
    response = client.get(url)
    if response.code == 200
      DocumentDelivery.new(parsed_response: response.parsed_response)
    else
      #Error!
    end
  end
end

class DocumentDeliveryItem < InterlibraryLoanItem
  def initialize(parsed_response)
    super
    @title = @parsed_response["LoanTitle"]
    @author = @parsed_response["LoanAuthor"]
  end
end
