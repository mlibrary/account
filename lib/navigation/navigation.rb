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
end
