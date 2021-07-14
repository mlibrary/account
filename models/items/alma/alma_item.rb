class AlmaItem < Item
  def url
    doc_id = @parsed_response["mms_id"].slice(2,9)
    "https://search.lib.umich.edu/catalog/record/#{doc_id}"
    #"https://search.lib.umich.edu/catalog/record/#{@parsed_response["mms_id"]}"
  end
end
