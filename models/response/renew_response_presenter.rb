class RenewResponsePresenter
  attr_reader :renewed, :not_renewed
  def initialize(renewed:, not_renewed:)
    @renewed = renewed
    @not_renewed = not_renewed
  end
  def renewed?
    @renewed > 0
  end
  def not_renewed?
    @not_renewed > 0
  end
  def renewed_text
    "#{@renewed} #{item(@renewed)} #{verb(@renewed)} successfully renewed."
  end
  def not_renewed_text
    "#{@not_renewed} #{item(@not_renewed)} #{verb(@not_renewed)} unable to be renewed for one of the following reasons:"
  end
  def unrenewable_reasons
    [
      "Item has exceeded the number of renews allowed",
      "Item is for building-use only",
      "Item has been reported as lost",
    ]
  end
  def not_renewed_continued_text
    [
      "Review the <span class='strong'>Actions</span> column of your checkouts to see which items did not renew.",
      "If you do not see any changes after attempting to renew items, there may have been an unexpected network error. Please refresh the page and try again.",
      "If you have questions or need help, please contact the <a href=\"https://lib.umich.edu/locations-and-hours/hatcher-library/hatcher-north-information-services-desk\">Hatcher North Information Services Desk</a>.",
    ]
  end
  private
  def verb(count)
    count == 1 ? "was" : "were"
  end
  def item(count)
    count == 1 ? "item" : "items"
  end
end
