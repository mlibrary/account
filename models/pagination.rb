class Pagination
  def initialize(url:, current_offset:, total:, limit: )
    @url = url
    @current_offset = current_offset.to_i
    @total = total.to_i
    @limit = limit.to_i
    @max_pages = 5
  end
  def first
    @current_offset + 1 
  end
  def last
    @current_offset + @limit
  end
  def previous_offset
    @current_offset - @limit
  end
  def next_offset
    @current_offset + @limit
  end

  def pages
    array = []
    middle = (@max_pages / 2) + 1
    if @current_offset < (middle - 1) * @limit #for pages less than the middle
      (1 .. @max_pages).each do |i|
        offset = (i -1) * @limit
        is_current_page = (@current_offset == offset)
        array.push(Page.new(offset: offset, is_current_page: is_current_page, limit: @limit)) if offset < @total
      end
    else #for pages greater than the middle
      (1 .. @max_pages).each do |i| 
        addend = (i-middle) * @limit
        offset = @current_offset + addend
        is_current_page = (@current_offset == offset)
        array.push(Page.new(offset: offset, is_current_page: is_current_page, limit: @limit)) if offset < @total
      end
    end
    array
  end
  
  class Page
    attr_reader :offset, :page_number, :limit
    def initialize(offset:, is_current_page:, limit: )
      @offset = offset
      @is_current_page = is_current_page
      @page_number = (offset / limit) + 1
    end
    def current_page?
      @is_current_page
    end
  end

  private_constant :Page
  private
  #def max_pages
    #base_pages = @total / @limit
    #@total % @limit > 0 ?  extra_page = 1 : extra_page = 0
    #base_pages + mod_page
  #end
  def path(offset)
    query = []
    query.push("offset=#{offset}") if offset > 0
    query.push("limit=#{@limit}") if @limit != 10
    query_string = query.join('&')
    query_string = nil if query_string == ''

    URI::HTTP.build(path: @url, query: query_string).request_uri
  end

  
  
end
