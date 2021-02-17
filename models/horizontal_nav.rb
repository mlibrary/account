class HorizontalNav
  def initialize(path)
    @path = path
  end
  def self.for(path)
    if path.start_with?('/requests/')
      RequestNav.new(path)
    elsif path.start_with?('/shelf/')
      ShelfNav.new(path)
    end
  end 
  def label
    pages.detect{|page| page.to == @path}.label
  end
  def section
   #empty parent def
  end
  def pages
   #empty parent def
  end
  class Page
    attr_reader :label, :to, :path
    def initialize(label:, to:, path:)
      @label = label
      @to = to
      @path = path
    end
    def active
      'active' if @path == @to
    end
  end
  private_constant :Page
  
end

#Inherits from HorizontalNav so it can get the HorizontalNav::Page object
class RequestNav < HorizontalNav
  def section
    'Requests'
  end
  def pages
    [
      Page.new(label: 'U-M Library', to: '/requests/um-library', path: @path),
      Page.new(label: 'From Other Institutions (Interlibrary Loan)', to: '/requests/interlibrary-loan', path: @path)
    ]
  end
end
class ShelfNav < HorizontalNav
  def section
    'Shelf'
  end
  def pages
    [
      Page.new(label: 'Current loans', to: '/shelf/loans', path: @path),
      Page.new(label: 'Past loans', to: '/shelf/past-loans', path: @path),
      Page.new(label: 'Document delivery', to: '/shelf/document-delivery', path: @path)
    ]
  end 
end