require 'addressable'
require 'digest'
require 'securerandom'

#App-wide formatting
class DateTime
  def self.patron_format(date)
    DateTime.parse(date).strftime('%D') unless date.nil?
  end

  def self.timestamp
    DateTime.now.strftime('%Q')
  end

end

class LoanDate < Date
  def due_status
    diff = (self - Date.today).to_i
    if diff < 0
      :overdue
    elsif diff <= 7
      :soon
    else
      ''
    end
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

class Sinatra::Request
  def js_filename
    path.gsub('/',' ').strip.gsub(' ','-')
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
class Authenticator
  def self.verify(params:,key: ENV.fetch('JWT_SECRET'))
    hash = params['hash']
    values = params.to_a.select{|key, value| key != 'hash'}.to_h.values.join('')
    string = CGI.unescape(values + key)
    hash == (Digest::SHA256.hexdigest string)
  end
  def self.params_with_signature(params:, key: ENV.fetch('JWT_SECRET'))

    params_array = params.to_a
    values = params_array.map{|key,value| value}.join('')
    values = values + key
    hash = Digest::SHA256.hexdigest values


    base_params = params_array.map{|key, value| "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"}.join('&') 

    "?#{base_params}&hash=#{hash}"
  end
end
