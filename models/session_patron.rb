class SessionPatron
  extend Forwardable
  def_delegators :@alma_patron, :uniqname, :full_name
  def initialize(uniqname)
    @alma_patron = Patron.for(uniqname: uniqname)
  end
end
