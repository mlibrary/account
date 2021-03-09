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

class InterlibraryLoanRequest
  def initialize(parsed_response)
    @parsed_response = parsed_response
    @title = @parsed_response["PhotoArticleTitle"] ||
             @parsed_response["PhotoJournalTitle"]
    @author = @parsed_response["PhotoItemAuthor"] || 
              @parsed_response["PhotoArticleAuthor"] || 
              @parsed_response["PhotoJournalAuthor"]
  end
  def title
    extra = 120 - @author.length
    extra = 0 if extra < 0
    max_length = 120 + extra
    @title[0, max_length]
  end
  def author
    extra = 120 - @title.length
    extra = 0 if extra < 0
    max_length = 120 + extra
    @author[0, max_length]
  end
  def request_url
    "https://ill.lib.umich.edu/illiad/illiad.dll?Action=10&Form=72&Value=#{@parsed_response["TransactionNumber"]}"
  end
  def request_date
    @parsed_response["CreationDate"] ? DateTime.patron_format(@parsed_response["CreationDate"]) : nil
  end
  def expiration_date
    @parsed_response["DueDate"] ? DateTime.patron_format(@parsed_response["DueDate"]) : nil
  end
end
