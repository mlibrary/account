class LoanControlsParamsGenerator
  attr_reader :limit
  def initialize(show:, sort:)
    @limit = show.to_s
    @sort = sort.split('-')
  end
  def order_by
    case @sort[0]
    when "due"
      "due_date"
    when "title"
      "title"
    end
  end
  def direction
    case @sort[1]
    when "asc"
      "ASC"
    when "desc"
      "DESC"
    end
  end
  def to_s
    "?limit=#{limit}&order_by=#{order_by}&direction=#{direction}"
  end
end
