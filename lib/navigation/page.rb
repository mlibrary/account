class Navigation
  class Page
    extend Forwardable

    def_delegators :@page, :title, :description, :path, :icon_name
    def initialize(page)
      @page = page
    end

    def active?
      false
    end

    def active
      active? ? "active" : ""
    end

    def self.for(page, active_page)
      if page == active_page
        ActivePage.new(page)
      else
        Page.new(page)
      end
    end
  end

  class ActivePage < Page
    def active?
      true
    end
  end
end
