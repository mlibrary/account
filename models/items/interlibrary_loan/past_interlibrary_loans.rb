class PastInterlibraryLoans < Items
  attr_reader :pagination, :count
  def initialize(parsed_response:, pagination:, count: nil)
    super
    @items = parsed_response.map { |item| PastInterlibraryLoan.new(item) }
    @pagination = pagination
    @count = count
  end

  def self.for(uniqname:, offset: nil, limit: nil,  count: nil, client: ILLiadClient.new)
    ill_count = ILLCount.for(count: count, offset: offset, limit: limit)
    query = base_query.merge(ill_count.query)
 
    response = client.get(illiad_url(uniqname), query)
    if response.code == 200
      body = response.parsed_response
      pagination_params = { url: url, total: ill_count.total(body) }.merge(ill_count.pagination_params)
      self.new(parsed_response: ill_count.page_of_results(body), pagination: PaginationDecorator.new(**pagination_params), count: ill_count.total(body))
    end
  end

  private
  def self.illiad_url(uniqname)
    "/Transaction/UserRequests/#{uniqname}" 
  end
  def self.url
    "/past-activity/interlibrary-loan"
  end
  def self.filter
    "TransactionStatus eq 'Request Finished' or startswith(TransactionStatus, 'Cancelled')"
  end
  def self.base_query
    {"$filter" => filter}
  end
  class ILLCount
    attr_reader :offset, :limit
    def initialize(count:, offset:, limit:)
      @offset = offset.to_i
      @limit = limit.to_i

      @limit = 15 if limit.nil?
      @count = count
    end
    def self.for(count:, offset:, limit:)
      if count.nil?
        NewCount.new(count: count, offset: offset, limit: limit)
      else
        SavedCount.new(count: count, offset: offset, limit: limit)
      end
    end
    def pagination_params
      q = {}
      q[:limit] = @limit if @limit != 15
      q[:offset] = @offset if @offset != 0
      q
    end
  end
  class SavedCount < ILLCount
    def query
      q = {}
      q["$skip"] = @offset unless @offset == 0
      q["$top"] = @limit
      q
    end
    def page_of_results(body)
      body
    end
    def total(body)
      @count
    end
    
  end
  class NewCount < ILLCount
    def query
      {}
    end
    def page_of_results(body)
      body[@offset, @limit]
    end
    def total(body)
      body.count
    end
  end
  
end

class PastInterlibraryLoan < InterlibraryLoanItem
end
