require "digest"
require "securerandom"
class Nelnet
  include UrlHelper
  attr_reader :orderNumber
  def initialize(amountDue:,
    redirectUrl: absolute_url(path: "fines-and-fees/receipt"),
    orderDescription: "U-M Library Circulation Fines",
    orderType: "UMLibraryCirc",
    timestamp: DateTime.timestamp,
    orderNumber: "#{SecureRandom.alphanumeric(4)}.#{timestamp}")
    @paymentUrl = ENV.fetch("NELNET_PAYMENT_URL")

    @amountDue = amountDue.delete(".")
    @orderNumber = orderNumber
    @orderType = orderType
    @redirectUrl = redirectUrl
    @redirectParams = redirectParams

    @orderDescription = orderDescription
    @timestamp = timestamp
    @retriesAllowed = 1
  end

  def self.verify(params)
    Authenticator.verify(params: params, key: ENV.fetch("NELNET_SECRET_KEY"))
  end

  def url
    query = Authenticator.params_with_signature(params: request_params, key: ENV.fetch("NELNET_SECRET_KEY"))
    # base_params = request_params.to_a.map{|key, value| "#{key}=#{value}"}.join('&')
    "#{@paymentUrl}#{query}"
  end

  private

  def request_params
    {
      "orderNumber" => @orderNumber,
      "orderType" => @orderType,
      "orderDescription" => @orderDescription,
      "amountDue" => @amountDue,
      "redirectUrl" => @redirectUrl,
      "redirectUrlParameters" => @redirectParams,
      "retriesAllowed" => @retriesAllowed,
      "timestamp" => @timestamp
    }
  end

  def redirectParams
    "transactionType,transactionStatus,transactionId,transactionTotalAmount,transactionDate,transactionAcountType,transactionResultCode,transactionResultMessage,orderNumber,orderType,orderDescription,payerFullName,actualPayerFullName,accountHolderName,streetOne,streetTwo,city,state,zip,country,email"
  end
end
