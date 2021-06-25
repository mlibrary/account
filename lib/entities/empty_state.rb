class Entities::Page::EmptyState
  attr_reader :heading, :message
  def initialize(empty_state, parent_empty_state=nil)
    @heading = "You have no items."
    @message = "See <a href=\"https://www.lib.umich.edu/find-borrow-request\">what you can borrow from the library<\/a>."
    
    if !empty_state.nil?
      @heading = empty_state["heading"] || @heading
      @message = empty_state["message"] || @message
    elsif !parent_empty_state.nil?
      @heading = parent_empty_state.heading || @heading
      @message = parent_empty_state.message || @message
    end
  end
end
