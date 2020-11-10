class Pagination
  def initialize(url:, current_offset:, total:, limit: )
    @url = url
    @current_offset = current_offset.to_i
    @total = total.to_i
    @limit = limit.to_i
    
  end
  def first
    @current_offset + 1 
  end
  def last
    @current_offset + @limit
  end
  def previous
    path(@current_offset - @limit)
  end
  def next
    path(@current_offset + @limit)
  end

  def pages

  end
  

  private
  def max_pages
    base_pages = @total / @limit
    @total % @limit > 0 ?  extra_page = 1 : extra_page = 0
    base_pages + mod_page
  end
  def path(offset)
    query = []
    query.push("offset=#{offset}") if offset > 0
    query.push("limit=#{@limit}") if @limit != 10
    query_string = query.join('&')
    query_string = nil if query_string == ''

    URI::HTTP.build(path: @url, query: query_string).request_uri
  end

  
  
end
