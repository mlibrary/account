require "telephone_number"
class Patron
  def initialize(alma_data:, circ_history_data: nil, illiad_data: nil)
    @alma_data = alma_data
    @circ_history_data = circ_history_data
    @illiad_data = illiad_data
  end

  def self.for(uniqname:, alma_client: AlmaRestClient.client, circ_history_client: CircHistoryClient.new(uniqname), illiad_data: ILLiadPatron.for(uniqname: uniqname))
    url = "/users/#{uniqname}?user_id_type=all_unique&view=full&expand=none"
    alma_response = alma_client.get(url)

    begin
      circ_history_response = circ_history_client.user_info
      raise StandardError if circ_history_response.code != 200
      circ_history_data = circ_history_response.parsed_response
    rescue
      circ_history_data = {"confirmed" => false, "retain_history" => false}
    end

    if alma_response.code == 200
      Patron.new(alma_data: alma_response.parsed_response, circ_history_data: circ_history_data, illiad_data: illiad_data)
    else
      NotInAlma.new(uniqname, circ_history_data)
    end
  end

  def in_alma?
    true
  end

  def self.set_retain_history(uniqname:, retain_history:, circ_history_client: CircHistoryClient.new(uniqname))
    circ_history_client.set_retain_history(retain_history)
  end

  def in_circ_history?
    !!@circ_history_data["created_at"]
  end

  def confirmed_history_setting?
    @circ_history_data["confirmed"]
  end

  def retain_history?
    @circ_history_data["retain_history"]
  end

  def circulation_history_text
    CirculationHistorySettingsText.for(retain_history: retain_history?, confirmed_history_setting: confirmed_history_setting?)
  end

  def in_illiad?
    @illiad_data.in_illiad?
  end

  def local_document_delivery_location
    @illiad_data.delivery_location
  end

  def update_sms(sms, client = AlmaRestClient.client, phone = TelephoneNumber.parse(sms, :US))
    return Error.new(message: "Phone number #{sms} is invalid") unless phone.valid? || sms.empty?
    url = "/users/#{uniqname}"
    response = client.put(url, body: patron_with_internal_sms(phone.national_number).to_json)
    (response.code == 200) ? response : AlmaError.new(response)
  end

  def uniqname
    @alma_data["primary_id"]&.downcase
  end

  def email_address
    @alma_data.dig("contact_info", "email")&.find(-> { {} }) { |x| x["preferred"] }&.dig("email_address")
  end

  def sms_number
    @alma_data.dig("contact_info", "phone")&.find(-> { {} }) { |x| x["preferred_sms"] }&.dig("phone_number")
  end

  def sms_number?
    !!sms_number
  end

  def full_name
    @alma_data["full_name"]
  end

  def user_group
    @alma_data.dig("user_group", "desc")
  end

  def can_book?
    ["Faculty", "Graduate", "Staff"].any? { |x| user_group.match(x) }
  end

  def addresses
    @alma_data.dig("contact_info", "address")&.map { |x| Address.new(x) }
  end

  private

  def patron_with_internal_sms(sms_number)
    updated_patron = JSON.parse(@alma_data.to_json)

    phones = updated_patron["contact_info"].delete("phone")
    my_phones = phones.map { |x| Phone.new(x) }
    my_phones.delete_if { |x| x.sms? }
    if sms_number != ""
      my_phones.push(NewSMS.new(sms_number))
    end

    updated_patron["contact_info"]["phone"] = my_phones.map { |x| x.to_h }

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
        "phone_number" => sms_number,
        "preferred" => false,
        "preferred_sms" => true,
        "segment_type" => "Internal",
        "phone_type" => [{
          "value" => "mobile",
          "desc" => "Mobile"
        }]
      }
    end
  end

  class Address
    def initialize(address)
      @address = address
    end

    def type
      # probably too ugly??????????
      @address["address_note"]&.split(":")&.fetch(1)&.strip
    end

    def to_html
      (1..5).to_a.map { |x| @address["line#{x}"] }.compact.join("<br>")
    end

    def to_h
      {
        type: type,
        display: to_html
      }
    end
  end

  class NotInAlma < self
    attr_reader :uniqname
    def initialize(uniqname, circ_history_data)
      @uniqname = uniqname
      @circ_history_data = circ_history_data
    end

    ["in_alma?", "can_book?", "in_illiad?"].each do |name|
      define_method(name) do
        false
      end
    end

    ["email_address", "sms_number", "sms_number?", "full_name", "user_group", "addresses", "local_document_delivery_location"].each do |name|
      define_method(name) do
        nil
      end
    end
  end
end
