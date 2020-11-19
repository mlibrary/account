class PaginationDecorator
  def initialize(url:,
                 current_offset: 0, total:, limit: 10,
                 base_pagination: Pagination.new(current_offset: current_offset, total: total, limit: limit)
                )
    @base_pagination = base_pagination
    @url = url
    @limit = limit
  end
  def first
    @base_pagination.first
  end
  def last
    @base_pagination.last
  end

  def previous
    page(@base_pagination.previous)
  end
  def next
    page(@base_pagination.next)
  end
  def pages
    @base_pagination.pages.map{|p| page(p)}
  end

  class Page
    attr_reader :url, :page_number
    def initialize(url:, page: )
      @url = url
      @page = page
    end
    def current_page?
      @page.current_page?
    end
    def page_number
      @page.page_number
    end
  end

  private_constant :Page
  private
  def page(page)
    url = path(page.offset)
    Page.new(page: page, url: url)
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
