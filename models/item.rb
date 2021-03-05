class Item
  attr_reader :parsed_response, :message
  def initialize(parsed_response, message=nil)
    @parsed_response = parsed_response
    @message = message
  end
  def title
    extra = 120 - @parsed_response["author"].length
    extra = 0 if extra < 0
    max_length = 120 + extra
    @parsed_response["title"][0, max_length]
  end
  def author
    extra = 120 - @parsed_response["title"].length
    extra = 0 if extra < 0
    max_length = 120 + extra
    @parsed_response["author"][0, max_length]
  end
  def search_url
    "https://search.lib.umich.edu/catalog/record/#{@parsed_response["mms_id"]}"
  end
  def publication_date
  end
  def message?
    !@message.nil?
  end
  def message_text
    @message.text
  end
  def message_status
    @message&.status
  end
end
