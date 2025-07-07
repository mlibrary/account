require "addressable"
require "digest"
require "securerandom"

# App-wide formatting
class DateTime
  def self.patron_format(date)
    DateTime.parse(date).strftime("%D") unless date.nil?
  end

  def self.timestamp
    DateTime.now.strftime("%Q")
  end
end

class DueStatus
  def initialize(due_date:, last_renew_date: nil)
    @due_date = Date.parse(due_date)
    @last_renew_date = last_renew_date
    @last_renew_date = Date.parse(last_renew_date) unless @last_renew_date.nil?
  end

  # Using the due date and last renew date if it exists, return the appropriate
  # string to display to the user. Statuses are the same for umich and
  # interlibrary loans.
  #
  # @return [String] display string based on the due date and last renew date
  def to_s
    due_diff = (@due_date - Date.today).to_i

    renew_diff = -1

    renew_diff = (Date.today - @last_renew_date).to_i unless @last_renew_date.nil?

    if due_diff < 0
      "Overdue"
    elsif due_diff <= 7
      "Due Soon"
    elsif renew_diff.between?(0, 14)
      "Renewed"
    else
      ""
    end
  end

  def any?
    to_s != ""
  end

  def tag
    case to_s
    when "Overdue"
      "tag--fail"
    when "Due Soon"
      "tag--warning"
    when "Renewed"
      "tag--info"
    else
      ""
    end
  end
end

class Float
  def to_currency
    sprintf("%.2f", self)
  end
end

class Integer
  def to_currency
    "#{self}.00"
  end
end

class Sinatra::Request
  def js_filename
    path.tr("/", " ").strip.tr(" ", "-")
  end
end

module StyledFlash
  def patron_styled_flash(key = :flash)
    return "" if flash(key).empty?
    flash(key).collect do |kind, message|
      erb :"components/message", locals: {message: message, kind: kind}
    end.join
  end
end

module UrlHelper
  def absolute_url(path: "", query: {})
    url = Addressable::URI.parse(ENV.fetch("PATRON_ACCOUNT_BASE_URL"))
    url.path = path
    url.query_values = query.to_a # preserves query hash order
    url.normalize.to_s
  end
end

# This is used authentication with nelnet.
class Authenticator
  def self.verify(params:, key: ENV.fetch("JWT_SECRET"))
    hash = params["hash"]
    values = params.except("hash").values.join("")
    string = CGI.unescape(values + key)
    hash == (Digest::SHA256.hexdigest string)
  end

  def self.params_with_signature(params:, key: ENV.fetch("JWT_SECRET"))
    params_array = params.to_a
    values = params_array.map { |key, value| value }.join("")
    values += key
    hash = Digest::SHA256.hexdigest values

    base_params = params_array.map { |key, value| "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}" }.join("&")

    "?#{base_params}&hash=#{hash}"
  end
end
