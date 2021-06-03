class InterlibraryLoans < Items
  attr_reader :pagination
  def initialize(parsed_response:, pagination:)
    super
    @items = parsed_response.filter_map { |item| InterlibraryLoan.new(item) if item["RequestType"] == "Loan" && item["TransactionStatus"] == "Checked Out to Customer" } || []
    @pagination = pagination
  end

  def self.for(uniqname:, skip: nil, top: 15, client: ILLiadClient.new)
    url = "/Transaction/UserRequests/#{uniqname}" 
    query = {}
    query["skip"] = skip unless skip.nil?

    top.nil? ? query["top"] = 15 : query["top"] = top
    
    #TBDeleted 
    fake_data = JSON.parse(File.read('./spec/fixtures/illiad_requests.json'))
    fake_data[1]["RenewalsAllowed"] = true
    fake_data[1]["DueDate"] = "2022-06-02T00:00:00"

    response = client.get(url, query)
    if response.code == 200
      pagination_params = { url: "/current-checkouts/interlibrary-loan", total: fake_data.count }
      pagination_params[:limit] = top unless top.nil?
      pagination_params[:current_offset] = skip unless skip.nil?
      InterlibraryLoans.new(parsed_response: fake_data, pagination: PaginationDecorator.new(**pagination_params)) #should be response.parsed_response
    else
      #Error!
    end
  end
end

class InterlibraryLoan < InterlibraryLoanItem
end
