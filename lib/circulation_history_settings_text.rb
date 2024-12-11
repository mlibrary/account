class CirculationHistorySettingsText
  def initialize(markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML))
    @markdown = markdown
  end

  def self.for(retain_history:, confirmed_history_setting:)
    if confirmed_history_setting
      if retain_history
        DecidedKeepHistory.new
      else
        DecidedNoHistory.new
      end
    elsif retain_history
      UndecidedKeepHistory.new
    else
      UndecidedNoHistory.new
    end
  end

  def to_s
    @markdown.render(text)
  end

  class DecidedNoHistory < CirculationHistorySettingsText
    private

    def text
      "You have chosen not to keep a record of your #{checkout_history}.\n\n" \
        "If you would like us to start adding items to your checkout history, please update your preferences."
    end
  end

  class DecidedKeepHistory < CirculationHistorySettingsText
    private

    def text
      "You have chosen to keep a record of your #{checkout_history}.\n\n" \
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
      "We've been preserving your #{checkout_history} since spring 2016, which includes any items owned by the U-M Library that you have checked out. You can download your checkout history as a CSV file here. Learn more about checkout history options in our [Privacy Statement](https://lib.umich.edu/about-us/policies/library-privacy-statement/checkout-history-options) and update your preferences below."
    end
  end

  private

  def checkout_history
    "[checkout history](/past-activity/u-m-library)"
  end
end
