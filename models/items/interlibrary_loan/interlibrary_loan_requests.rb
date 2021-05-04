class InterlibraryLoanRequests < Items
  def initialize(parsed_response:)
    super
    @items = parsed_response.filter_map { |item| InterlibraryLoanRequest.new(item) if item["TransactionStatus"].include?("Submitted") || item["TransactionStatus"].include?("Pending") }
  end

  def self.for(uniqname:, client: ILLiadClient.new)
    url = "/Transaction/UserRequests/#{uniqname}" 
    response = client.get(url)
    if response.code == 200
      InterlibraryLoanRequests.new(parsed_response: response.parsed_response)
    else
      #Error!
    end
  end
end

class InterlibraryLoanRequest < InterlibraryLoanItem
end
