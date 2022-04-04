class Navigation::Title < Navigation
  def initialize(page)
    @page = page
  end

  def to_s
    title = ""
    title = "#{@page.parent.title}: " if @page.parent
    title += @page.title
    title
  end
end
