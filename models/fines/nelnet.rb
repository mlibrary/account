require "digest"
require "securerandom"
class Nelnet
  include UrlHelper
  attr_reader :order_number
  def initialize(amount_due:,
    redirect_url: absolute_url(path: "fines-and-fees/receipt"),
    order_description: "U-M Library Circulation Fines",
    order_type: "UMLibraryCirc",
    timestamp: DateTime.timestamp,
    order_number: "#{SecureRandom.alphanumeric(4)}.#{timestamp}")
    @payment_url = ENV.fetch("NELNET_PAYMENT_URL")
    @amount_due = amount_due.delete(".")
    @order_number = order_number
    @order_type = order_type
    @redirect_url = redirect_url
    @redirect_params = redirect_params
    @order_description = order_description
    @timestamp = timestamp
    @retries_allowed = 1
  end

  def self.verify(params)
    Authenticator.verify(params: params, key: ENV.fetch("NELNET_SECRET_KEY"))
  end

  def url
    query = Authenticator.params_with_signature(params: request_params, key: ENV.fetch("NELNET_SECRET_KEY"))
    # base_params = request_params.to_a.map{|key, value| "#{key}=#{value}"}.join('&')
    "#{@payment_url}#{query}"
  end

  private

  def request_params
    {
      "orderNumber" => @order_number,
      "orderType" => @order_type,
      "orderDescription" => @order_description,
      "amountDue" => @amount_due,
      "redirectUrl" => @redirect_url,
      "redirectUrlParameters" => @redirect_params,
      "retriesAllowed" => @retries_allowed,
      "timestamp" => @timestamp
    }
  end

  def redirect_params
    "transactionType,transactionStatus,transactionId,transactionTotalAmount,transactionDate,transactionAcountType,transactionResultCode,transactionResultMessage,orderNumber,orderType,orderDescription,payerFullName,actualPayerFullName,accountHolderName,streetOne,streetTwo,city,state,zip,country,email"
  end
end
