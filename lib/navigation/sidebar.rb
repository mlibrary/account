class Navigation::Sidebar < Navigation
  attr_reader :pages
  def initialize(active_page)
    @pages = Entities::Pages.all.map do |page|
      pick_page(active_page: active_page, current_page: page)
    end
  end
  
end
