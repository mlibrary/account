class Item
  attr_reader :parsed_response, :description
  def initialize(parsed_response)
    @parsed_response = parsed_response
    @author = @parsed_response["author"] || ""
    @title = @parsed_response["title"] || ""
    @description = @parsed_response["description"] || ""
  end
  def title
    shorten(:title)
  end
  def author
    shorten(:author)
  end
  def author?
    @author != ""
  end
  def description?
    @description != ""
  end
  private
  def shorten(type)
    total_character_length = 240 - @description.length
    case type
    when :author
      main = @author
      other = @title
    when :title
      main = @title
      other = @author
    end
    half = total_character_length / 2

    extra = half - other.length
    extra = 0 if extra < 0
    max_length = half + extra
    main[0, max_length]
  end
  
end
