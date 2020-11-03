class Item
  def initialize(parsed_response)
    @parsed_response = parsed_response
  end
  def title
    @parsed_response["title"]
  end
  def author
    @parsed_response["author"]
  end
  def search_url
    "https://search.lib.umich.edu/catalog/record/#{@parsed_response["mms_id"]}"
  end
  def publication_date
  end
  
end
