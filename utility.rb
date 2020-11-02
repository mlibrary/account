#App-wide formatting
class DateTime
  def self.patron_format(date)
    DateTime.parse(date).strftime("%b %-d, %Y")
  end
end

class Float
  def to_currency
    "$#{self}"
  end
end

class Integer
  def to_currency
    "$#{self}.00"
  end
end
