class SessionPatron

  def initialize(uniqname)
    @patron = Patron.for(uniqname: uniqname)
  end
  def to_h
    {
      uniqname: @patron.uniqname,
      can_book: @patron.can_book?,
      confirmed_history_setting: @patron.confirmed_history_setting?
    }
  end
end
