class Pagination
  def initialize(current_offset:, total:, limit: )
    @current_offset = current_offset.to_i
    @total = total.to_i
    @limit = limit.to_i
    @max_pages = 5
  end
  def previous
    prev_offset = @current_offset - @limit
    prev_offset = 0 if prev_offset < 0
    is_current_page = (prev_offset == @current_offset) 
    page(prev_offset, is_current_page)
  end
  def next
    next_offset = @current_offset + @limit
    next_offset = @current_offset if next_offset >= @total
    is_current_page = (next_offset == @current_offset)
    page(next_offset, is_current_page)
  end

  def pages
    array = []
    middle = (@max_pages / 2) + 1
    outside = (middle - 1) * @limit
    if @current_offset < outside #for pages less than the middle
      (1 .. @max_pages).each do |i|
        offset = (i -1) * @limit
        is_current_page = (@current_offset == offset)
        array.push(page(offset, is_current_page)) if offset < @total
      end
    elsif @current_offset < @total - outside #for pages greater than the middle
      (1 .. @max_pages).each do |i| 
        addend = (i-middle) * @limit
        offset = @current_offset + addend
        is_current_page = (@current_offset == offset)
        array.push(page(offset, is_current_page)) if offset < @total
      end
    else
      diff = @total - @current_offset
      curr_offset_pos_from_end = @max_pages - (diff / @limit)
      curr_offset_pos_from_end = curr_offset_pos_from_end + 1 if diff % @limit == 0
      
      (1 .. @max_pages).each do |i|
        addend = (i-curr_offset_pos_from_end)*@limit
        offset = @current_offset + addend
        is_current_page = (@current_offset == offset)
        array.push(page(offset, is_current_page))
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
  def page(offset, is_current_page)
    Page.new(offset: offset, is_current_page: is_current_page, limit: @limit)
  end
  #def max_pages
    #base_pages = @total / @limit
    #@total % @limit > 0 ?  extra_page = 1 : extra_page = 0
    #base_pages + mod_page
  #end
  #def path(offset)
    #query = []
    #query.push("offset=#{offset}") if offset > 0
    #query.push("limit=#{@limit}") if @limit != 10
    #query_string = query.join('&')
    #query_string = nil if query_string == ''

    #URI::HTTP.build(path: @url, query: query_string).request_uri
#  end

  
  
end
