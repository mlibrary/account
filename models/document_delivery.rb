class DocumentDelivery
  def initialize(parsed_response:)
    @parsed_response = parsed_response
    @deliveries = parsed_response.filter_map { |delivery| DocumentDeliveryItem.new(delivery) if delivery["RequestType"] == "Loan" && delivery["TransactionStatus"] != "Request Finished" }
  end

  def count
    @deliveries.length
  end

  def each(&block)
    @deliveries.each do |delivery|
      block.call(delivery)
    end
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
