class Fees
  def initialize(parsed_response:)
    @parsed_response = parsed_response
    @list = parsed_response["fee"]&.map{|l| Fee.new(l)}
  end

  def count
    @parsed_response["total_record_count"]
  end

  def total_sum
    @parsed_response["total_sum"]
  end
  def total_sum_in_dollars
    total_sum&.to_currency
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
      Fees.new(parsed_response: response.parsed_response)
    else
      #Error!
    end
  end
  
end

class Fee 
  def initialize(parsed_response)
    @parsed_response = parsed_response
  end
  def title
    @parsed_response["title"]
  end
  def barcode
    @parsed_response["barcode"]["value"]
  end
  def date
    DateTime.patron_format(@parsed_response["creation_time"])
  end
  def balance
    @parsed_response["balance"]&.to_currency
  end
  def original_amount
    @parsed_response["original_amount"]&.to_currency
  end
end
