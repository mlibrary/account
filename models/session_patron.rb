class SessionPatron
  extend Forwardable
  def_delegators :@alma_patron, :uniqname, :full_name, :can_book?, :keep_history

  def initialize(uniqname)
    @alma_patron = Patron.for(uniqname: uniqname)
  end
  def to_h
    {
      uniqname: @alma_patron.uniqname,
      full_name: @alma_patron.full_name,
      can_book: @alma_patron.can_book?,
      keep_history: @alma_patron.keep_history
    }
  end
end
