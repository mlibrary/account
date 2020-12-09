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

module StyledFlash
  def patron_styled_flash(key=:flash)
    return "" if flash(key).empty?
    flash(key).collect do |kind, message| 
      erb :message, locals: {message: message, kind: kind}
    end.join
  end
end
