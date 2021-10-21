class RenewResponsePresenter
  attr_reader :renewed
  def initialize(renewed:)
    @renewed = renewed
  end
  def renewed_text
    if @renewed == 0
      "Eligible #{item(@renewed)} have been renewed."
    else
      "#{@renewed} #{item(@renewed)} #{verb(@renewed)} successfully renewed."
    end
  end
  private
  def verb(count)
    count == 1 ? "was" : "were"
  end
  def item(count)
    count == 1 ? "item" : "items"
  end
end
