class SessionPatron

  def initialize(uniqname)
    @patron = Patron.for(uniqname: uniqname)
  end
  def to_h
    {
      uniqname: @patron.uniqname,
      in_alma: @patron.in_alma?,
      can_book: @patron.can_book?,
      confirmed_history_setting: @patron.confirmed_history_setting?,
      in_circ_history: @patron.in_circ_history?
    }
  end
end
