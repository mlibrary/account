class InterlibraryLoans
  def initialize(parsed_response:)
    @parsed_response = parsed_response
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
