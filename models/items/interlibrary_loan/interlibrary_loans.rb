class InterlibraryLoans < Items
  def initialize(parsed_response:)
    super
    @items = parsed_response.filter_map { |item| InterlibraryLoan.new(item) if item["RequestType"] != "Loan" && item["TransactionStatus"] == "Delivered to Web" }
  end

  def self.for(uniqname:, client: ILLiadClient.new)
    url = "/Transaction/UserRequests/#{uniqname}" 
    response = client.get(url)
    if response.code == 200
      InterlibraryLoans.new(parsed_response: response.parsed_response)
    else
      #Error!
    end
  end
end

class InterlibraryLoan < InterlibraryLoanItem
end
