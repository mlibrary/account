class Loans
  attr_reader :pagination
  def initialize(parsed_response:, pagination:, items: [])
    @parsed_response = parsed_response
    @items = items
    @list = parsed_response["item_loan"]&.map do |l| 
        Loan.new(l, item_message(l["loan_id"]))
    end || []
    @pagination = pagination
  end

  #todo needs to be tested
  def self.renew_all(uniqname:, client: AlmaRestClient.client)
    url = "/users/#{uniqname}/loans" 
    response = client.get_all(url: url, record_key: 'item_loan', query: {"expand" => "renewable"})

    return response if response.code != 200 

    loans = response.parsed_response["item_loan"].map do |loan| 
      if loan["renewable"] == false
        Loan.new(loan, Loan::RenewUnsuccessfulMessage.new)
      else
        message = Loan.renew(uniqname: uniqname, loan_id: loan["loan_id"])
        Loan.new(loan, message)
      end
    end
    RenewResponse.new( items: loans)
  end

  def self.renew(uniqname:, loans:)
    results = loans.map do |loan|
      message = Loan.renew(uniqname: uniqname, loan_id: loan.loan_id)
      Loan.new(loan.parsed_response, message)
    end
    RenewResponse.new(items: results)
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
               client: AlmaRestClient.client, order_by: nil, direction: nil, 
               items: [] )
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
                pagination: PaginationDecorator.new(**pagination_params),
                items: items)
    else
      #Error!
    end
  end
  private
  def item_message(loan_id)
    @items&.find{|loan| loan.loan_id == loan_id}&.message
  end
  
end

class Loan < AlmaItem
  def self.renew(uniqname:, loan_id:, client: AlmaRestClient.client)
    response = client.post("/users/#{uniqname}/loans/#{loan_id}", {op: 'renew'})
    response.code == 200 ? RenewSuccessfulMessage.new : RenewUnsuccessfulMessage.new(message: AlmaError.new(response).message)
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
end

class Loan::Message
  def text
  end
  def status
  end
  def to_s
    text
  end
end
class Loan::RenewSuccessfulMessage < Loan::Message
  def text
    "Renew Successful"
  end
  def status
    :success
  end
end
class Loan::RenewUnsuccessfulMessage < Loan::Message
  def initialize(text="Unable to Renew")
    @text = text
  end
  def text
    @text 
  end
  def status
    :fail
  end
end
