class Requests
  attr_reader :holds, :bookings
  def initialize(parsed_response:)
    @parsed_response = parsed_response
    @holds = parsed_response["user_request"]&.select{ |r| r["request_type"] == 'HOLD' }&.map{ |r| HoldRequest.new(r)} || []
    @bookings = parsed_response["user_request"]&.select{ |r| r["request_type"] == 'BOOKING' }&.map{ |r| BookingRequest.new(r)} || []
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
      #Error!
    end
  end
end

class Request < AlmaItem
  def self.cancel(uniqname:, request_id:, client: AlmaRestClient.client)
    client.delete("/users/#{uniqname}/requests/#{request_id}", {reason: "CancelledAtPatronRequest"})
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
      "In Process"
    when "ON_HOLD_SHELF"
      "On Hold Shelf"
    when "NOT_STARTED"
      ''
    else
      ''
    end
  end
end
class BookingRequest < Request
  def booking_date
    DateTime.patron_format(@parsed_response["booking_start_date"])
  end
end
class HoldRequest < Request
end
