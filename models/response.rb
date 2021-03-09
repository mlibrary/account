class Response
  attr_reader :code, :message, :parsed_response
  def initialize(code: 200, message: 'Success', parsed_response: {})
    @code = code
    @message = message
    @parsed_response = parsed_response
  end
end
class RenewResponse < Response
  attr_reader :code, :item_messages, :items
  def initialize(code: 200, items: [])
    @code = code
    @items = items
  end
  def renewed
    @items.filter{|x| x.message_status == :success}
  end
  def unrenewed
    @items.filter{|x| x.message_status == :fail}
  end
  def success_text?
    renewed.count > 0
  end
  def error_text?
    renewed.count == 0
  end
  def warn_text?
    unrenewed.count > 0
  end
  def warn_text
    unrenewed_text
  end
  def success_text
    renew_summary
  end
  def error_text
    renew_summary
  end
  def unrenewed_text
    count = unrenewed.count
    if count > 0
      message = "The following #{item(count)} could not be renewed: <ul>"
      message = message + unrenewed.map{|x| "<li>#{x.title}</li>"}.join('')
      message = message + "</ul>"
      message
    end
  end
  def renew_summary
    count = renewed.count
    "#{count} #{item(count)} successfully renewed"
  end
  
  private
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
