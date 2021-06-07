class PastInterlibraryLoans < Items
  attr_reader :pagination
  def initialize(parsed_response:, pagination:)
    super
    @items = parsed_response
    @pagination = pagination
  end

  def self.for(uniqname:, offset: nil, limit: 15, client: ILLiadClient.new)
    url = "/Transaction/UserRequests/#{uniqname}" 
    query = {}
    query["$filter"] = "TransactionStatus eq 'Request Finished' or startswith(TransactionStatus, 'Cancelled')"
    query["$skip"] = offset unless offset.nil?

    limit.nil? ? query["$top"] = 15 : query["$top"] = limit

    response = client.get(url, query)
    if response.code == 200
      pagination_params = { url: "/past-activity/interlibrary-loan", total: response.parsed_response.count }
      pagination_params[:limit] = limit unless limit.nil?
      pagination_params[:current_offset] = offset unless offset.nil?
      PastInterlibraryLoans.new(parsed_response: response.parsed_response, pagination: PaginationDecorator.new(**pagination_params))
    else
      #Error!
    end
  end
end

class PastInterlibraryLoan < InterlibraryLoanItem
end
