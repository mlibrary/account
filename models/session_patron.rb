class SessionPatron
  extend Forwardable
  def_delegators :@alma_patron, :full_name
  def initialize(uniqname)
    @alma_patron = Patron.for(uniqname: uniqname)
  end
  def to_h
    {
      full_name: @alma_patron.full_name
    }
  end
end
