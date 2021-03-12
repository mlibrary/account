class Response
  attr_reader :code, :message, :parsed_response
  def initialize(code: 200, message: 'Success', parsed_response: {})
    @code = code
    @message = message
    @parsed_response = parsed_response
  end
end
class RenewResponse < Response
  attr_reader :code, :items, :renewed, :unrenewed
  def initialize(code: 200, items: [])
    @code = code
    @items = items
    @renewed = @items.filter{|x| x.message_status == :success}
    @unrenewed = @items.filter{|x| x.message_status == :fail}
  end
  def success_text?
    @renewed.count > 0
  end
  def error_text?
    @renewed.count == 0
  end
  def warn_text?
    @unrenewed.count > 0
  end
  def warn_text
    count = @unrenewed.count
    if count > 0
      message = "The following #{item(count)} could not be renewed: <ul>"
      message = message + @unrenewed.map{|x| "<li>#{x.title}</li>"}.join('')
      message = message + "</ul>"
      message
    end
  end
  def success_text
    renew_summary
  end
  def error_text
    renew_summary
  end

  private
  def renew_summary
    "#{@renewed.count} #{item(@renewed.count)} successfully renewed"
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
