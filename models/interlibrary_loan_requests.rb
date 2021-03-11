class InterlibraryLoanRequests
  def initialize(parsed_response:)
    @parsed_response = parsed_response
    @requests = parsed_response.filter_map { |request| InterlibraryLoanRequest.new(request) if request["RequestType"] != "Loan" && request["TransactionStatus"] != "Request Finished" }
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

class InterlibraryLoanRequest < InterlibraryLoanItem
  def request_date
    @parsed_response["CreationDate"] ? DateTime.patron_format(@parsed_response["CreationDate"]) : ''
  end
  def expiration_date
    @parsed_response["DueDate"] ? DateTime.patron_format(@parsed_response["DueDate"]) : ''
  end
end
