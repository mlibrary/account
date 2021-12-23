class RenewResponsePresenter
  attr_reader :renewed
  def self.for(renewed)
    if renewed == 0
      NoElligibleItems.new(renewed)
    else
      self.new(renewed) 
    end
  end
  def initialize(renewed)
    @renewed = renewed
  end
  def renewed_text
    "You've successfully renewed <span class=\"strong\">all eligible items</span>. " +
    "Your new return dates are shown, starting with items due first.</br></br>" +
    "If you have questions or need help, please contact the <a href=\"https://lib.umich.edu/locations-and-hours/hatcher-library/hatcher-north-information-services-desk\">Hatcher North Information Services Desk</a>."
  end
  def status
    "success"
  end

  class NoElligibleItems < self
    def renewed_text
      "None of your items are eligible for renewal. If you need help, please contact the <a href=\"https://lib.umich.edu/locations-and-hours/hatcher-library/hatcher-north-information-services-desk\">Hatcher North Information Services Desk</a>."
    end
    def status
      "warning"
    end
  end
end
