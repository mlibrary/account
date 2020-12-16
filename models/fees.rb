class Fees
  def initialize(parsed_response:)
    @parsed_response = parsed_response
    @list = parsed_response["fee"]&.map{|l| Fee.new(l)} || []
  end

  def count
    @parsed_response["total_record_count"] || 0
  end

  def total_sum
    @parsed_response["total_sum"] || 0
  end
  def total_sum_in_dollars
    total_sum&.to_currency
  end
  def select(ids)
    @list.select{|x| ids.include?(x.fee_id) }
  end


  def each(&block)
    @list.each do |l|
      block.call(l)
    end
  end

  def each_with_index(&block)
    @list.each_with_index do |l, index|
      block.call(l, index)
    end
  end

  def self.for(uniqname:, client: AlmaClient.new)
    url = "/users/#{uniqname}/fees" 
    response = client.get_all(url: url, record_key: "fee" )
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
  def fee_id
    @parsed_response["id"]
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
  def type
    @parsed_response["type"]["desc"]
  end
  def code
    @parsed_response["type"]["value"]
  end
  def original_amount
    @parsed_response["original_amount"]&.to_currency
  end
  def library
    @parsed_response["owner"]["desc"]
  end
  def creation_time
    @parsed_response["creation_time"]
  end
  def to_h
    {
      fee_id: fee_id,
      balance: balance,
      title: title,
      barcode: barcode,
      library: library,
      type: type,
      creation_time: creation_time,
    }
  end
end
