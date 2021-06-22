class InterlibraryLoanRequests < Items
  def initialize(parsed_response:)
    super
    actions = [
      "Checked Out to Customer",
      "Delivered to Web",
      "Request Finished"
    ]
    @items = parsed_response.filter_map { |item| InterlibraryLoanRequest.new(item) if actions.none?{|action| item["TransactionStatus"].include?(action)}}
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
