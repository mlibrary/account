class Item
  def initialize(parsed_response)
    @parsed_response = parsed_response
    @author = @parsed_response["author"]
    @title = @parsed_response["title"]
  end
  def title
    shorten(:title)
  end
  def author
    shorten(:author)
  end
  private
  def shorten(type)
    total_character_length = 240
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
class AlmaItem < Item
  def initialize(parsed_response)
    super
    @author = @parsed_response["author"]
    @title = @parsed_response["title"]
  end
  def search_url
    "https://search.lib.umich.edu/catalog/record/#{@parsed_response["mms_id"]}"
  end
end
class InterlibraryLoanItem < Item
  def initialize(parsed_response)
    super
    @title = @parsed_response["PhotoArticleTitle"] ||
             @parsed_response["PhotoJournalTitle"]
    @author = @parsed_response["PhotoItemAuthor"] || 
              @parsed_response["PhotoArticleAuthor"] || 
              @parsed_response["PhotoJournalAuthor"]
  end
  def request_url
    "https://ill.lib.umich.edu/illiad/illiad.dll?Action=10&Form=72&Value=#{@parsed_response["TransactionNumber"]}"
  end
  def request_date
    @parsed_response["CreationDate"] ? DateTime.patron_format(@parsed_response["CreationDate"]) : ''
  end
  def expiration_date
    @parsed_response["DueDate"] ? DateTime.patron_format(@parsed_response["DueDate"]) : ''
  end
end
