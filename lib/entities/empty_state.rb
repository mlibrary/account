class Entities::Page::EmptyState
  def initialize(empty_state, parent_empty_state=nil)
    @empty_state = empty_state
    @parent_empty_state = parent_empty_state
  end

  def heading
    if @empty_state&.key?("heading")
      @empty_state["heading"]
    elsif @parent_empty_state&.heading
      @parent_empty_state.heading
    else
      "You have no items."
    end
  end

  def message
    if @empty_state&.key?("message")
      @empty_state["message"]
    elsif @parent_empty_state&.message
      @parent_empty_state.message
    else
      "See <a href=\"https://www.lib.umich.edu/find-borrow-request\">what you can borrow from the library<\/a>."
    end
  end

  def heading_tag
    if @parent_empty_state.nil?
      "h2"
    else
      "h3"
    end
  end
end
