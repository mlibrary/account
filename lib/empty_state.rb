class EmptyState
  attr_reader :pages
  def initialize(current_path=nil)
    @pages = JSON.parse(File.read('./config/navigation.json')).map do |page|
      Page.new(title: page["title"], children: page["children"], empty_state: page["empty_state"], current_path: current_path)
    end
    @current_path = current_path
  end
  def get_empty_state(prop)
    default_state = {
      "heading" => "You have no items.",
      "message" => "See how you can <a href=\"https://www.lib.umich.edu/find-borrow-request\">find, borrow, or request materials<\/a> from the Library!"
    }
    empty_state = default_state["#{prop}"]
    current_parent = @pages.find{|p| p.active?}
    if current_parent.empty_state
      empty_state = current_parent.empty_state["#{prop}"] || empty_state
    end
    if current_parent.children.find{|page| page.active? }.empty_state
      empty_state = current_parent.children.find{|page| page.active? }.empty_state["#{prop}"] || empty_state
    end
    empty_state
  end
  def heading
    self.get_empty_state("heading")
  end
  def message
    self.get_empty_state("message")
  end
end
