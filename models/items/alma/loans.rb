class Loans < Items
  attr_reader :pagination
  def initialize(parsed_response:, pagination:)
    @parsed_response = parsed_response
    @items = parsed_response["item_loan"]&.map do |loan| 
      Loan.new(loan) 
    end || []
    @pagination = pagination
  end

  def self.renew_all(uniqname:, client: AlmaRestClient.client, connections: [], 
                     publisher: Publisher.new) 
    url = "/users/#{uniqname}/loans" 
    publisher.publish({step: 1, count: 0, renewed: 0, uniqname: uniqname})
    response = client.get_all(url: url, record_key: 'item_loan', query: {"expand" => "renewable"})

    return response if response.code != 200 
    loans = response.parsed_response["item_loan"]&.map do |loan| 
      Loan.new(loan) 
    end
    self.renew(uniqname: uniqname, loans: loans, publisher: publisher)

  end

  def self.renew(uniqname:, loans:, publisher: Publisher.new)
    count = 0
    renewed = 0
    renew_statuses = []
    loans.each do |loan|
      if loan.renewable? == false
        renew_statuses.push(:fail)
      else
        response = Loan.renew(uniqname: uniqname, loan_id: loan.loan_id)
        if response.code != 200
          renew_statuses.push(:fail)
        else
          renewed = renewed + 1
          renew_statuses.push(:success)
        end
      end
      count = count + 1
      publisher.publish({step: 2, count: count, renewed: renewed, uniqname: uniqname})
    end
    publisher.publish({step: 3, count: count, renewed: renewed, uniqname: uniqname})
    RenewResponse.new(renew_statuses: renew_statuses )
  end
  def count
    @parsed_response["total_record_count"]
  end


  def self.for(uniqname:, offset: nil, limit: 15, 
               client: AlmaRestClient.client, order_by: nil, direction: nil )
    url = "/users/#{uniqname}/loans" 
    query = {"expand" => "renewable"}
    query["offset"] = offset unless offset.nil?
    query["direction"] = direction unless direction.nil?

    order_by.nil? ? query["order_by"] = "due_date" : query["order_by"] = order_by
    limit.nil? ? query["limit"] = 15 : query["limit"] = limit

    response = client.get(url, query)
    if response.code == 200
      pr = response.parsed_response 
      pagination_params = { url: "/current-checkouts/u-m-library", total: pr["total_record_count"] }
      pagination_params[:limit] = limit unless limit.nil?
      pagination_params[:current_offset] = offset unless offset.nil?
      pagination_params[:order_by] = order_by unless order_by.nil?
      pagination_params[:direction] = direction unless direction.nil?
      Loans.new(parsed_response: pr, pagination: PaginationDecorator.new(**pagination_params) )
               
    else
      #Error!
    end
  end
  
end

class Loan < AlmaItem
  def self.renew(uniqname:, loan_id:, client: AlmaRestClient.client)
    client.post("/users/#{uniqname}/loans/#{loan_id}", {op: 'renew'})
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
  def due_status
    diff = (Date.parse(@parsed_response["due_date"]) - Date.today).to_i
    if diff < 0
      :overdue
    elsif diff <= 7
      :soon
    else
      ''
    end
  end
end
