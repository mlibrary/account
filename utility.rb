require 'addressable'
#App-wide formatting
class DateTime
  def self.patron_format(date)
    DateTime.parse(date).strftime("%b %-d, %Y")
  end

  def self.timestamp
    DateTime.now.strftime('%Q')
  end
end

class Float
  def to_currency
    sprintf('%.2f',self)
  end
end

class Integer
  def to_currency
    "#{self}.00"
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
module UrlHelper
  def absolute_url(path: '', query: {})
    url = Addressable::URI.parse(ENV.fetch('PATRON_ACCOUNT_BASE_URL'))
    url.path = path
    url.query_values = query.to_a #preserves query hash order
    url.normalize.to_s
  end
end
