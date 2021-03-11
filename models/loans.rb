class Loans
  attr_reader :pagination
  def initialize(parsed_response:, pagination:)
    @parsed_response = parsed_response
    @list = parsed_response["item_loan"]&.map{|l| Loan.new(l)} || []
    @pagination = pagination
  end

  #todo needs to be tested
  def self.renew_all(uniqname:, client: AlmaRestClient.client)
    url = "/users/#{uniqname}/loans" 
    response = client.get_all(url: url, record_key: 'item_loan', query: {"expand" => "renewable"})
    renewable = response.parsed_response["item_loan"].select{|x| x["renewable"] == true}
    loan_ids = renewable.map{|x| x["loan_id"]}
    Loans.renew(uniqname: uniqname, loan_ids: loan_ids)
  end

  def self.renew(uniqname:, loan_ids:)
    results = loan_ids.map do |loan_id|
      Loan.renew(uniqname: uniqname, loan_id: loan_id)
    end
    errors = results.select{|r| r.code != 200 }
    if errors.empty?
      Response.new
    else
      messages = errors&.map{|e| e.message}&.join("\n") || ''
      Error.new(message: messages)
    end
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
               client: AlmaRestClient.client, order_by: nil, direction: nil
              )
    url = "/users/#{uniqname}/loans" 
    query = {"expand" => "renewable"}
    query["offset"] = offset unless offset.nil?
    query["limit"] = limit unless limit.nil?
    query["order_by"] = order_by unless order_by.nil?
    query["direction"] = direction unless direction.nil?

    response = client.get(url, query)
    if response.code == 200
      pr = response.parsed_response 
      pagination_params = { url: "/shelf/loans", total: pr["total_record_count"] }
      pagination_params[:limit] = limit unless limit.nil?
      pagination_params[:current_offset] = offset unless offset.nil?
      pagination_params[:order_by] = order_by unless order_by.nil?
      pagination_params[:direction] = direction unless direction.nil?
      Loans.new(parsed_response: pr, 
                pagination: PaginationDecorator.new(**pagination_params))
    else
      #Error!
    end
  end
  
end

class Loan < AlmaItem
  def self.renew(uniqname:, loan_id:, client: AlmaRestClient.client)
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
