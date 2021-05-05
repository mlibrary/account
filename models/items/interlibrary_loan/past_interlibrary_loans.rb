class PastInterlibraryLoans < Items
  def initialize(parsed_response:)
    super
    actions = [
      "Cancelled",
      "Finished"
    ]
    @items = parsed_response.filter_map { |item| PastInterlibraryLoan.new(item) if actions.any?{|action| item["TransactionStatus"].include?(action)}}
  end

  def self.for(uniqname:, client: ILLiadClient.new)
    url = "/Transaction/UserRequests/#{uniqname}" 
    response = client.get(url)
    if response.code == 200
      PastInterlibraryLoans.new(parsed_response: response.parsed_response)
    else
      #Error!
    end
  end
end

class PastInterlibraryLoan < InterlibraryLoanItem
end
