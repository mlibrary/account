class Requests
  attr_reader :holds, :bookings
  def initialize(parsed_response:)
    @parsed_response = parsed_response
    @holds = parsed_response["user_request"]&.select { |r| r["request_type"] == "HOLD" }&.map { |r| HoldRequest.new(r) } || []
    @bookings = parsed_response["user_request"]&.select { |r| r["request_type"] == "BOOKING" }&.map { |r| BookingRequest.new(r) } || []
  end

  def count
    @parsed_response["total_record_count"]
  end

  def self.for(uniqname:, client: AlmaRestClient.client)
    url = "/users/#{uniqname}/requests"
    response = client.get_all(url: url, record_key: "user_request")
    if response.code == 200
      Requests.new(parsed_response: response.parsed_response)
    else
      # Error!
    end
  end
end

class Request < AlmaItem
  def self.cancel(uniqname:, request_id:, client: AlmaRestClient.client)
    client.delete("/users/#{uniqname}/requests/#{request_id}", query: {reason: "CancelledAtPatronRequest"})
  end

  def self.empty_state(markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML))
    markdown.render(empty_state_text)
  end

  def expiry_date
    @parsed_response["expiry_date"] ? DateTime.patron_format(@parsed_response["expiry_date"]) : ""
  end

  def publication_date
    @parsed_response["date_of_publication"]
  end

  def request_id
    @parsed_response["request_id"]
  end

  def pickup_location
    @parsed_response["pickup_location"]
  end

  def request_date
    DateTime.patron_format(@parsed_response["request_time"])
  end

  def status
    case @parsed_response["request_status"]
    when "IN_PROCESS"
      "In process"
    when "ON_HOLD_SHELF"
      "Ready"
    when "NOT_STARTED"
      "Not started"
    else
      ""
    end
  end

  def status_tag
    case status
    when "In process"
      "--warning"
    when "Ready"
      "--success"
    else
      ""
    end
  end
end

class BookingRequest < Request
  def booking_date
    DateTime.patron_format(@parsed_response["booking_start_date"])
  end

  def self.empty_state_text
    "You don't have any active media requests."
  end
end

class HoldRequest < Request
  def self.empty_state_text
    "You don't have any active requests.\n\nSee [what you can borrow from the library](https://www.lib.umich.edu/find-borrow-request)."
  end
end
