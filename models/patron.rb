class Patron
  def initialize(uniqname: '#fixme', client: AlmaClient.new, parsed_response: '#FIXME')
    @uniqname = uniqname
    @parsed_response = parsed_response
  end

  def self.for(uniqname:, client: AlmaClient.new)
    url = "/users/#{uniqname}?user_id_type=all_unique&view=full&expand=none" 
    response = client.get(url)
    if response.code == 200
      Patron.new(uniqname: uniqname, parsed_response: response.parsed_response)
    else
      AlmaError.new(response)
    end
  end

  def to_h
      {
        uniqname: uniqname,
        full_name: full_name,
        addresses: addresses.map{ |x| x.to_h },
        sms_number: sms_number,
      }
  end
  def response(resp = Response.new(body: to_h))
    resp.to_a
  end
  def uniqname
    @parsed_response["primary_id"].downcase
  end
  def sms_number
    @parsed_response["contact_info"]["phone"].find(-> {{}}){|x| x["preferred_sms"]}["phone_number"]
  end
  def full_name
    @parsed_response["full_name"]
  end
  def addresses
    @parsed_response["contact_info"]["address"].map{|x| Address.new(x)}
  end

  private

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
