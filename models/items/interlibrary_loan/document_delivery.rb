class DocumentDelivery < Items
  def initialize(parsed_response:)
    super
    @items = parsed_response.filter_map { |item| DocumentDeliveryItem.new(item) if item["RequestType"] == "Article" && item["TransactionStatus"] == "Delivered to Web" }
  end

  def self.for(uniqname:, client: ILLiadClient.new)
    url = "/Transaction/UserRequests/#{uniqname}" 
    #TBDeleted 
    fake_data = JSON.parse(File.read('./spec/fixtures/illiad_requests.json'))
    fake_data[1]["RenewalsAllowed"] = true
    fake_data[1]["DueDate"] = "2022-06-02T00:00:00"

    response = client.get(url)
    if response.code == 200
      DocumentDelivery.new(parsed_response: fake_data) #should be response.parsed_response
    else
      #Error!
    end
  end
end

class DocumentDeliveryItem < InterlibraryLoanItem
end
