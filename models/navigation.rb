class Navigation
  attr_reader :pages
  def initialize
    @pages = JSON.parse(File.read('./config/navigation.json')).map do |p|
      Page.new(p["title"], p["description"], p["icon_name"], p["color"], p["children"])
    end
  end
  def cards
    @pages[1,6]
  end
end
class Page
  attr_reader :title, :description, :icon_name, :color, :children
  def initialize(title, description=nil, icon_name=nil, color=nil, children=nil)
    @title = title
    @description = description
    @icon_name = icon_name
    @color = color
    @children = children&.map{ |x| 
      Page.new(x["title"])
    }
  end
 
  def slug
    if @title == 'Account overview'
      '/'
    else
      @title.gsub('/','or').gsub('&','and').gsub(/[\s]/,'-').downcase
    end
  end
end
