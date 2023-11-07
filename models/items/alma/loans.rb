class Loans < Items
  attr_reader :pagination
  def initialize(parsed_response:, pagination:)
    @parsed_response = parsed_response
    @items = parsed_response["item_loan"]&.map do |loan|
      Loan.new(loan)
    end || []
    @pagination = pagination
  end

  def count
    @parsed_response["total_record_count"]
  end

  def self.for(uniqname:, offset: nil, limit: 15,
    client: AlmaRestClient.client, order_by: nil, direction: nil)
    url = "/users/#{uniqname}/loans"
    query = {"expand" => "renewable"}
    query["offset"] = offset unless offset.nil?
    query["direction"] = direction unless direction.nil?

    query["order_by"] = order_by.nil? ? "due_date" : order_by
    query["limit"] = limit.nil? ? 15 : limit

    response = client.get(url, query: query)
    raise StandardError unless response.status == 200
    pr = response.body
    pagination_params = {url: "/current-checkouts/u-m-library", total: pr["total_record_count"]}
    pagination_params[:limit] = limit unless limit.nil?
    pagination_params[:current_offset] = offset unless offset.nil?
    pagination_params[:order_by] = order_by unless order_by.nil?
    pagination_params[:direction] = direction unless direction.nil?
    Loans.new(parsed_response: pr, pagination: PaginationDecorator.new(**pagination_params))
  end
end

class Loan < AlmaItem
  def due_date
    DateTime.patron_format(@parsed_response["due_date"]) unless claims_returned?
  end

  def renewable?
    !!@parsed_response["renewable"] # make this a real boolean
  end

  def loan_id
    @parsed_response["loan_id"]
  end

  def call_number
    @parsed_response["call_number"]
  end

  def barcode
    @parsed_response["item_barcode"]
  end

  def publication_date
    @parsed_response["publication_year"]
  end

  def due_status
    return OpenStruct.new(to_s: "Reported as returned", tag: "tag--warning", any?: true) if claims_returned?
    DueStatus.new(due_date: @parsed_response["due_date"], last_renew_date: @parsed_response["last_renew_date"])
  end

  def due_status_tag
    due_status.tag
  end

  private

  def claims_returned?
    @parsed_response["process_status"] == "CLAIMED_RETURN"
  end
end
