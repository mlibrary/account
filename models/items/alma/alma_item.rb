class AlmaItem < Item
  def url
    "https://search.lib.umich.edu/catalog/record/#{@parsed_response["mms_id"]}"
  end
end
