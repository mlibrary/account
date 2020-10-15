class Patron
  attr_reader :uniqname
  def initialize(uniqname:, client: AlmaClient.new)
    @uniqname = uniqname
    @response = client.get(url)
    @parsed_response = @response.parsed_response
  end
  def to_h
    {
      full_name: full_name,
      uniqname: uniqname,
      addresses: addresses.map{ |x| x.to_h }
    }
  end
  def full_name
    @parsed_response["full_name"]
  end
  def addresses
    @parsed_response["contact_info"]["address"].map{|x| Address.new(x)}
  end

  private
  def url
    "/users/#{@uniqname}?user_id_type=all_unique&view=full&expand=none" 
  end

  class Address
    def initialize(address)
      @address = address
    end
    def type
      #probably too ugly??????????
      @address["address_note"]&.split(':')&.fetch(1).strip
    end
    def to_html
      (1..5).to_a.map{|x| @address["line#{x}"]}.compact.join('<br>')
    end
    def to_h
      {
        type: type,
        display: to_html,
      }
    end
  end
end
