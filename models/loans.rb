class Loans
  attr_reader :pagination
  def initialize(parsed_response:, pagination:)
    @parsed_response = parsed_response
    @list = parsed_response["item_loan"]&.map{|l| Loan.new(l)} || []
    @pagination = pagination
  end

  def count
    @parsed_response["total_record_count"]
  end

  def each(&block)
    @list.each do |l|
      block.call(l)
    end
  end

  def empty?
    count == 0
  end


  def self.for(uniqname:, offset: nil, limit: nil, 
               client: AlmaClient.new 
              )
    url = "/users/#{uniqname}/loans" 
    query = {}
    query["offset"] = offset unless offset.nil?
    query["limit"] = limit unless limit.nil?

    response = client.get(url, query)
    if response.code == 200
      pr = response.parsed_response 
      pagination_params = { url: "/shelf/loans", total: pr["total_record_count"] }
      pagination_params[:limit] = limit unless limit.nil?
      pagination_params[:current_offset] = offset unless offset.nil?
      Loans.new(parsed_response: pr, 
                pagination: PaginationDecorator.new(**pagination_params))
    else
      #Error!
    end
  end
  
end

class Loan < Item
  def self.renew(uniqname:, loan_id:, client:AlmaClient.new)
    response = client.post("/users/#{uniqname}/loans/#{loan_id}", {op: 'renew'})
    response.code == 200 ? response : AlmaError.new(response)
  end
  def due_date
    DateTime.patron_format(@parsed_response["due_date"])
  end
  def renewable?
    !!@parsed_response["renewable"] #make this a real boolean
  end
  def loan_id
    @parsed_response["loan_id"]
  end
  def call_number
    @parsed_response["call_number"]
  end
  def publication_date
    @parsed_response["publication_year"]
  end
  def ill?
    #need to figure out how this works;
  end
end
