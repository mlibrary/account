class CirculationHistoryItems < Items
  attr_reader :pagination
  def initialize(parsed_response:, pagination:) 
    @parsed_response = parsed_response
    @items = parsed_response["loans"]&.map do |loan| 
      CirculationHistoryItem.new(loan) 
    end || []
    @pagination = pagination
  end
  def count
    @parsed_response["total_record_count"]
  end
  def self.for(uniqname:, offset: nil, limit: nil, 
               order_by: nil, direction: nil, 
               client: CircHistoryClient.new(uniqname))
    query = {}
    query["offset"] = offset unless offset.nil?
    query["limit"] = limit unless limit.nil?
    query["order_by"] = order_by unless order_by.nil?
    query["direction"] = direction unless direction.nil?

    response = client.loans(query)
    if response.code == 200
      pr = response.parsed_response
      
      pagination_params = { url: "/past-activity/u-m-library", total: pr["total_record_count"] }
      pagination_params[:limit] = limit unless limit.nil?
      pagination_params[:current_offset] = offset unless offset.nil?
      pagination_params[:order_by] = order_by unless order_by.nil?
      pagination_params[:direction] = direction unless direction.nil?
      CirculationHistoryItems.new(parsed_response: pr, pagination: PaginationDecorator.new(**pagination_params) )
    else
    end
  end
end
class CirculationHistoryItem < Item
  def url
    doc_id = mms_id.slice(2,9)
    "https://search.lib.umich.edu/catalog/record/#{doc_id}"
  end
  def call_number
    @parsed_response["call_number"]
  end
  def barcode
    @parsed_response["barcode"]
  end
  def description
   @parsed_response["description"]
  end
  def checkout_date
    DateTime.patron_format(@parsed_response["checkout_date"])
  end
  def return_date
    DateTime.patron_format(@parsed_response["return_date"])
  end
  def mms_id
    @parsed_response["mms_id"]
  end
end
