class ILLiadPatron
  def initialize(parsed_response)
    @parsed_response = parsed_response
  end
  def self.for(uniqname:, illiad_client: ILLiadClient.new)
    resp = illiad_client.get("/Users/#{uniqname}") 
    if resp.code == 200
      ILLiadPatron.new(resp.parsed_response)
    else
      NotInILLiad.new
    end
  end
  def in_illiad?
    true
  end
  def delivery_location
    [@parsed_response["SAddress"], @parsed_response["SAddress2"]].reject{|x|x.nil?}.join(' / ')
  end
end
class NotInILLiad
  def in_illiad?
    false
  end
  def delivery_location
    ''
  end
end
