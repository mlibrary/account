class Navigation::Description < Navigation
  def initialize(page)
    @page = page
  end

  def text
    if @page.description
      @page.description
    elsif @page.parent&.description
      @page.parent.description
    else
      Entities::Pages.all[0].description
    end
  end

  def to_s
    text
  end
end
