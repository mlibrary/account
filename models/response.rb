class Response
  attr_reader :code, :message, :parsed_response
  def initialize(code: 200, message: 'Success', parsed_response: {})
    @code = code
    @message = message
    @parsed_response = parsed_response
  end
end
class Error < Response
  def initialize(code: 500, message: 'There was an error')
    super
  end
end

class AlmaError < Error
  def initialize(response)
    @parsed_response = response.parsed_response
    @code = response.code
    @message = get_messages
  end
  private
  def get_messages
    errors = @parsed_response["errorList"]["error"].map{|x| x["errorMessage"]}
    errors.join(' ')
  end
  
end
