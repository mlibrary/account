class Navigation::UserDropdown < Navigation
  attr_reader :pages
  def initialize(active_page)
    @pages = Entities::Pages.all.filter_map do |page|
      pick_page(active_page: active_page, current_page: page) if page.dropdown
    end
  end
end
