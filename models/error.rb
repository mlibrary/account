class Error
  attr_reader :code, :message
  def initialize(code: 500, message: 'There was an error')
    @code = code
    @message = message
  end
end

class AlmaError < Error
  def initialize(response)
    @response = response
    @code = response.code
    @message = get_messages
  end
  private
  def get_messages
    errors = @response.parsed_response["errorList"]["error"].map{|x| x["errorMessage"]}
    errors.join(' ')
  end
  
end
