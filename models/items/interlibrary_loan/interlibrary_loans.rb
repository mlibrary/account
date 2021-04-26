class InterlibraryLoans < Items
  def initialize(parsed_response:)
    super
    @items = parsed_response.filter_map { |item| InterlibraryLoan.new(item) if item["RequestType"] == "Loan" && item["TransactionStatus"] == "Checked Out to Customer" }
  end

  def self.for(uniqname:, client: ILLiadClient.new)
    url = "/Transaction/UserRequests/#{uniqname}" 
    #TBDeleted 
    fake_data = JSON.parse(File.read('./spec/fixtures/illiad_requests.json'))
    fake_data[1]["RenewalsAllowed"] = true
    fake_data[1]["DueDate"] = "2022-06-02T00:00:00"

    response = client.get(url)
    if response.code == 200
      InterlibraryLoans.new(parsed_response: fake_data) #should be response.parsed_response
    else
      #Error!
    end
  end
end

class InterlibraryLoan < InterlibraryLoanItem
end
