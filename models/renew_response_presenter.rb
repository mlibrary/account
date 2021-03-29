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
  private
  def verb(count)
    count == 1 ? "was" : "were"
  end
  def item(count)
    count == 1 ? "item" : "items"
  end
end
