class Entities::Pages
  def self.all
    raw.map do |p|
      Entities::Page.new(p)
    end
  end

  def self.page(path)
    flattened.find { |page| page.path == path }
  end

  def self.raw
    JSON.parse(File.read("./config/navigation.json"))
  end

  def self.flattened
    array = []
    all.each do |page|
      array.push(page)
      array.push(page.children) unless page.children.nil?
    end
    array.flatten
  end
end

class Entities::Page
  attr_reader :parent, :children
  def initialize(page, parent = nil)
    @page = page
    @parent = parent
    @children = page.dig("children")&.map { |p| Entities::Page.new(p, self) }
  end
  ["title", "description", "icon_name", "color", "dropdown", "sidebar"].each do |name|
    define_method(name) do
      @page[name]
    end
  end
  def empty_state
    EmptyState.new(@page["empty_state"], parent&.empty_state)
  end

  def path
    if @parent.nil?
      "/#{slug}"
    else
      "/#{@parent.slug}/#{slug}"
    end
  end

  def ==(other)
    other.path == path
  end

  def slug
    if title == "Account Overview"
      ""
    else
      title.gsub("/", "or").gsub("&", "and").gsub(/\s/, "-").downcase
    end
  end
end
