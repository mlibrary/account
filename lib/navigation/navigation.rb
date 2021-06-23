class Navigation
  def self.cards
    Entities::Pages.all[1,6]
  end
  def self.home
    Entities::Pages.all[0]
  end
  def self.for(path)
    self.new(Entities::Pages.page(path))
  end
  private
  def pick_page(active_page:, current_page:)
    if current_page == active_page || current_page.children&.any?{|child| child == active_page}
      Navigation::ActivePage.new(current_page)
    else
      Navigation::Page.new(current_page) 
    end
  end
end
