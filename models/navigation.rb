class Navigation
  attr_reader :pages
  def initialize(current_path=nil)
    @pages = JSON.parse(File.read('./config/navigation.json')).map do |p|
      Page.new(title: p["title"], description: p["description"], icon_name: p["icon_name"], color: p["color"], children: p["children"], current_path: current_path)
    end
    @current_path = current_path
  end
  def cards
    @pages[1,6]
  end
  def horizontal_nav
    path_elements = @current_path&.split('/')[1..-1] || []
    if path_elements.count == 2
      top_level_slug = path_elements.first
      top_level_page = @pages.find{|x| x.slug == top_level_slug }
      NewHorizontalNav.new(top_level_page)
    end
  end
end
class Page
  attr_reader :title, :description, :icon_name, :color, :children
  def initialize(title:, description: nil, icon_name: nil, color: nil, children: nil, current_path: nil, parent: nil)
    @title = title
    @description = description
    @icon_name = icon_name
    @color = color
    @children = children&.map{ |x| 
      Page.new(title: x["title"], parent: self, current_path: current_path)
    }
    @current_path = current_path
    @parent = parent
  end
  def path
    if parent?
      "/#{@parent.slug}/#{slug}"
    else
      "/#{slug}"
    end
  end
 
  def slug
    if @title == 'Account overview'
      ''
    else
      @title.gsub('/','or').gsub('&','and').gsub(/[\s]/,'-').downcase
    end
  end
  def active?
    if @title == 'Account overview'
      @current_path == '/' 
    elsif @parent != nil
      path_array = @current_path.split('/')[1..-1]
      path_array[0] == @parent.slug && path_array[1] == slug
    else 
      @current_path.split('/')[1..-1]&.first == slug
    end
  end
  def active
    active? ? 'active' : '' 
  end
  private
  def parent?
    !!@parent
  end
end
class NewHorizontalNav
  attr_reader :pages
  def initialize(parent)
    @parent = parent
    @pages = parent.children
  end
  def section
    @parent.title
  end
  def title
    @pages.detect{|page| page.active? }.title
  end
end
