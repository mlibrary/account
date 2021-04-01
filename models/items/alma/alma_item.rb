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
