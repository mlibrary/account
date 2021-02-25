class InterlibraryLoanRequests
  def initialize(parsed_response:)
    @parsed_response = parsed_response
    @requests = parsed_response.select { |request| request["TransactionStatus"] != "Request Finished" }
  end

  def count
    @requests.length
  end

  def each(&block)
    @requests.each do |request|
      block.call(request)
    end
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
