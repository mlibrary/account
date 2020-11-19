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
               client: AlmaClient.new, 
               pagination_factory: lambda{|url,co,limit,total| PaginationDecorator.new(url: url, current_offset: co, limit: limit, total: total )}
              )
    url = "/users/#{uniqname}/loans" 

    query = {}
    query["offset"] = offset if offset
    query["limit"] = limit if limit

    response = client.get(url, query)
    if response.code == 200
      pr = response.parsed_response 
      Loans.new(parsed_response: pr, 
                pagination: pagination_factory.call(url, offset, limit, pr["total_record_count"]))
    else
      #Error!
    end
  end
  
end

class Loan < Item
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
