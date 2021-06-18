class Navigation::HorizontalNav
  def initialize(page)
    @page = page #Entities::Page
  end
  def self.for(page)
    if page.parent && page.title != 'Receipt'
      self.new(page) 
    end
  end
  def section
    @page.parent.title
  end
  def title
    @page.title
  end
  def children
    @page.parent.children.map{|child| Navigation::Page.for(child, @page)}
  end

end
