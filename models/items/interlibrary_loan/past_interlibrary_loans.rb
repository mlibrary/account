class PastInterlibraryLoans < Items
  attr_reader :pagination, :count
  def initialize(parsed_response:, pagination:, count: nil)
    super
    @items = parsed_response.map { |item| PastInterlibraryLoan.new(item) }
    @pagination = pagination
    @count = count
  end

  def self.for(uniqname:, offset: nil, limit: 15, client: ILLiadClient.new, count: nil)
    url = "/Transaction/UserRequests/#{uniqname}" 
    offset = 0 if offset.nil?
    limit = 15 if limit.nil?
    query = {}
    
    query["$filter"] = "TransactionStatus eq 'Request Finished' or startswith(TransactionStatus, 'Cancelled')"
    unless count.nil?
      query["$skip"] = offset unless offset == 0
      query["$top"] = limit
    end

    response = client.get(url, query)
    if response.code == 200
      parsed_response = response.parsed_response

      count.nil? ? total = parsed_response.count : total = count
      pagination_params = { url: "/past-activity/interlibrary-loan", total: total }
      pagination_params[:limit] = limit unless limit.nil?
      pagination_params[:current_offset] = offset unless offset.nil?
      
      if count.nil?
        my_parsed_response = parsed_response[offset.to_i, limit.to_i]
      else
        my_parsed_response = parsed_response
      end
      PastInterlibraryLoans.new(parsed_response: my_parsed_response, pagination: PaginationDecorator.new(**pagination_params), count: total)
    else
      #Error!
    end
  end
end

class PastInterlibraryLoan < InterlibraryLoanItem
end
