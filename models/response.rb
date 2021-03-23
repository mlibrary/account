class Response
  attr_reader :code, :message, :parsed_response
  def initialize(code: 200, message: 'Success', parsed_response: {})
    @code = code
    @message = message
    @parsed_response = parsed_response
  end
end
class RenewResponse < Response
  attr_reader :code, :items
  def initialize(code: 200, items: [])
    @code = code
    @items = items
    @renewed = @items.filter{|x| x.message_status == :success}
    @not_renewed = @items.filter{|x| x.message_status == :fail}
  end
  def renewed?
    @renewed.count > 0
  end
  def not_renewed?
    @not_renewed.count > 0
  end
  def renewed_text
    count = @renewed.count
    "#{count} #{item(count)} #{verb(count)} successfully renewed."
  end
  def not_renewed_text
    count = @not_renewed.count
    "#{count} #{item(count)} #{verb(count)} unable to be renewed for one of the following reasons:"
  end
  def unrenewable_reasons
    [
      "Item has exceeded the number of renews allowed",
      "Item is for building-use only",
      "Item has been reported as lost",
    ]
  end
    
  private
  def verb(count)
    count == 1 ? "was" : "were"
  end
  def item(count)
    count == 1 ? "item" : "items"
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
    errors = @parsed_response.dig("errorList","error")&.map{|x| x["errorMessage"]} 
    message = errors&.join(' ') || ''
    "#{message}"
  end
  
end
