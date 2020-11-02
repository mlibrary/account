class Fees
  def initialize(parsed_response:)
    @parsed_response = parsed_response
    @list = parsed_response["fee"].map{|l| Fee.new(l)}
  end

  def count
    @parsed_response["total_record_count"]
  end

  def each(&block)
    @list.each do |l|
      block.call(l)
    end
  end

  def self.for(uniqname:, client: AlmaClient.new)
    url = "/users/#{uniqname}/fees" 
    response = client.get(url)
    if response.code == 200
      Fines.new(parsed_response: response.parsed_response)
    else
      #Error!
    end
  end
  
end

class Fee 
  def title
  end
  def barcode
  end
end
