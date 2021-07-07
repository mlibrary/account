class Navigation::Description < Navigation
  def initialize(page)
    @page = page
  end
  def to_s
    if @page.description
      description = @page.description
    elsif @page.parent&.description
      description = @page.parent.description
    else
      description = Entities::Pages.all[0].description
    end
  end
end
