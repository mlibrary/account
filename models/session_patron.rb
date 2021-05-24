class SessionPatron
  extend Forwardable
  def_delegators :@alma_patron, :uniqname, :full_name, :can_book?, :retain_history

  def initialize(uniqname)
    @alma_patron = Patron.for(uniqname: uniqname)
  end
  def to_h
    {
      uniqname: @alma_patron.uniqname,
      full_name: @alma_patron.full_name,
      can_book: @alma_patron.can_book?,
      retain_history: @alma_patron.retain_history
    }
  end
end
