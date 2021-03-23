require 'telephone_number'
class Patron
  def initialize(uniqname:, parsed_response:)
    @uniqname = uniqname
    @parsed_response = parsed_response
  end

  def self.for(uniqname:, client: AlmaRestClient.client)
    url = "/users/#{uniqname}?user_id_type=all_unique&view=full&expand=none" 
    response = client.get(url)
    if response.code == 200
      Patron.new(uniqname: uniqname, parsed_response: response.parsed_response)
    else
      #should be something else
      AlmaError.new(response)
    end
  end

  def update_sms(sms, client=AlmaRestClient.client, phone=TelephoneNumber.parse(sms, :US))
    return Error.new(message: "Phone number #{sms} is invalid") unless phone.valid? || sms.empty?
    url = "/users/#{uniqname}"
    response = client.put(url, patron_with_internal_sms(phone.national_number).to_json) 
    response.code == 200 ? response : AlmaError.new(response)
  end

  def uniqname
    @parsed_response["primary_id"]&.downcase
  end
  def sms_number
    @parsed_response.dig("contact_info","phone")&.find(-> {{}}){|x| x["preferred_sms"]}&.dig("phone_number")
  end
  def sms_number?
    !!sms_number
  end
  def full_name
    @parsed_response["full_name"]
  end
  def addresses
    @parsed_response.dig("contact_info","address")&.map{|x| Address.new(x)}
  end

  private
  def patron_with_internal_sms(sms_number)
    updated_patron = JSON.parse(@parsed_response.to_json)
    
    phones = updated_patron["contact_info"].delete("phone")
    my_phones = phones.map{ |x| Phone.new(x)}
    my_phones.delete_if{|x| x.sms?}
    if sms_number != ''
      my_phones.push(NewSMS.new(sms_number))
    end

    updated_patron["contact_info"]["phone"] = my_phones.map{|x| x.to_h}
    
    updated_patron
  end

  class Phone
    attr_reader :phone
    def initialize(phone)
      @phone = phone
    end
    def to_h
      @phone
    end

    def sms?
      @phone["preferred_sms"] == true
    end
  end
  class NewSMS < Phone
    def initialize(sms_number)
      @phone = {
        "phone_number"=> sms_number,
        "preferred"=> false,
        "preferred_sms"=> true,
        "segment_type"=> "Internal",
        "phone_type"=> [{
          "value"=> "mobile",
          "desc"=> "Mobile"
        }] 
      }
    end
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
