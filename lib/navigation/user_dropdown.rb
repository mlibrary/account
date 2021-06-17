class Navigation::UserDropdown < Navigation
  attr_reader :pages
  def initialize(active_page)
    @pages = Entities::Pages.all.map do |page|
      if page == active_page || page.children&.any?{|child| child == active_page}
        Navigation::ActivePage.new(page)
      else
        Navigation::Page.new(page)
      end
    end
  end
  
end
