class CirculationHistorySettingsText
  def initialize(markdown=Redcarpet::Markdown.new(Redcarpet::Render::HTML))
    @markdown = markdown
  end
  def self.for(retain_history:, confirmed_history_setting:)
    if confirmed_history_setting
      if retain_history
        DecidedKeepHistory.new
      else
        DecidedNoHistory.new
      end
    else
      if retain_history
        UndecidedKeepHistory.new
      else
        UndecidedNoHistory.new
      end
    end
  end
  def to_s
    @markdown.render("#{text}\n\n#{post_script}")
  end
  

  class DecidedNoHistory < CirculationHistorySettingsText 
    private
    def text
      "You have chosen not to keep a record of your #{checkout_history}.\n\n" + 
      "If you would like us to start adding items to your checkout history, please update your preferences."
    end
  end
  class DecidedKeepHistory < CirculationHistorySettingsText 
    private
    def text
      "You have chosen to keep a record of your #{checkout_history}.\n\n" + 
      "If you would like us to delete your checkout history and stop adding items to it, please update your preferences."
    end
  end
  class UndecidedNoHistory < CirculationHistorySettingsText 
    private
    def text
      "You can choose to either keep a record of your #{checkout_history}, or opt out of having one."
    end
  end
  class UndecidedKeepHistory < CirculationHistorySettingsText 
    private
    def text 
      "We've been preserving your #{checkout_history} since April 2016. If you’d like to continue to keep a record of your checkout history, you can select that option now.\n\n" +
      "If you prefer to have your checkout history deleted and no longer record future checkouts, you can opt-out."
    end
  end

  private
  def post_script
    "To learn about your checkout history options, read the [Library Privacy Statement](https://www.lib.umich.edu/about-us/policies/library-privacy-statement).\n\n" +
    "You can change this preference at any time."
  end
  def checkout_history
    "[checkout history](/past-activity/u-m-library)"
  end
end

