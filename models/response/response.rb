class Response
  attr_reader :status, :body, :code, :message, :parsed_response
  def initialize(code: 200, message: "Success", parsed_response: {})
    @code = code
    @message = message
    @parsed_response = parsed_response
    @status = code
    @body = parsed_response
  end
end

class RenewResponse < Response
  attr_reader :code, :status, :renewed, :not_renewed, :messages, :renewed_count, :not_renewed_count
  def initialize(code: 200, messages: [], renew_statuses: [])
    @code = code
    @messages = messages
    @renew_statuses = renew_statuses
    @renewed_count = @renew_statuses.count { |x| x == :success }
    @not_renewed_count = @renew_statuses.count { |x| x == :fail }
  end
end

class Error < Response
  def initialize(code: 500, message: "There was an error")
    super
  end
end

class AlmaError < Error
  def initialize(response)
    @parsed_response = response.body
    @body = response.body
    @status = response.status
    @message = get_messages
  end

  private

  def get_messages
    errors = @parsed_response.dig("errorList", "error")&.map { |x| x["errorMessage"].strip }
    message = errors&.join(" ") || ""
    message.to_s
  end
end
