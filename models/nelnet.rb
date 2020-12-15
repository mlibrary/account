require 'digest'
require 'securerandom'
class Nelnet
  def initialize(amountDue:, 
                 redirectUrl:, 
                 orderDescription: 'U-M Library Circulation Fines', 
                 orderType: 'UMLibraryCirc', 
                 timestamp: DateTime.timestamp, 
                 orderNumber: "#{SecureRandom.alphanumeric(4)}.#{timestamp}")
    @secret = ENV.fetch('NELNET_SECRET_KEY')
    @paymentUrl = ENV.fetch('NELNET_PAYMENT_URL')
   
    @amountDue = amountDue.gsub(/\./, '')
    @orderNumber = orderNumber
    @orderType = orderType 
    @redirectUrl = redirectUrl
    @redirectParams = redirectParams


    @orderDescription = orderDescription
    @timestamp = timestamp 
    @retriesAllowed = 1;
  end

  def self.verify(params)
    hash = params.delete('hash')
    string = CGI.unescape(params.values.join('') + ENV.fetch('NELNET_SECRET_KEY'))
    hash == (Digest::SHA256.hexdigest string)

  end

  def url
    base_params = request_params.to_a.map{|key, value| "#{key}=#{value}"}.join('&') 
    "#{@paymentUrl}?#{base_params}&hash=#{hash}"
  end


  private
  def hash
    params = request_params.values.join('')
    params = params + @secret
    Digest::SHA256.hexdigest params
  end

  def request_params
     {
      'orderNumber' => @orderNumber,  
      'orderType' => @orderType,  
      'orderDescription' => @orderDescription,  
      'amountDue' => @amountDue,  
      'redirectUrl' => @redirectUrl,  
      'redirectUrlParameters' => @redirectParams,  
      'retriesAllowed' => @retriesAllowed,  
      'timestamp' => @timestamp,  
    }
  end
  def redirectParams
    "transactionType,transactionStatus,transactionId,transactionTotalAmount,transactionDate,transactionAcountType,transactionResultCode,transactionResultMessage,orderNumber,orderType,orderDescription,payerFullName,actualPayerFullName,accountHolderName,streetOne,streetTwo,city,state,zip,country,email"
  end
  def secret
  end
end
