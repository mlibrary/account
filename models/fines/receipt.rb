class Receipt
  attr_reader :orderNumber, :description, :amount, :payer_name, :type,
    :email, :date, :street, :city, :state, :zip, :country, :confirmationNumber
  def initialize(params)
    @orderNumber = params["orderNumber"]
    @confirmationNumber = params["transactionId"]
    @description = params["orderDescription"]
    @amount = (params["transactionTotalAmount"].to_f / 100 ).to_currency
    @type = params["transactionAcountType"]
    @payer_name = params["accountHolderName"]
    @transaction_message = params["transactionResultMessage"]
    @email = params["email"]
    @date = DateTime.parse(params["transactionDate"]).strftime("%B %e, %Y")
    @street = [params["streetOne"], params["streetTwo"]].select{|x| !x.empty?}.join('<br/>')
    @city = params["city"]
    @state = params["state"]
    @zip = params["zip"]
    @country = params["country"] == 'UNITED STATES' ? '' : params["country"]
  end
  def self.for(uniqname:, nelnet_params:, is_valid: Nelnet.verify(nelnet_params))
    receipt = Receipt.new(nelnet_params)
    if is_valid
        resp = Fines.pay(uniqname: uniqname, amount: receipt.amount, confirmation_number: receipt.confirmationNumber)

      if resp.code != 200
        error = AlmaError.new(resp)
        InvalidReceipt.new("#{error.message} Your payment confirmation number is: #{receipt.confirmationNumber}" )
      else
        return receipt
      end
    else
      return InvalidReceipt.new("Your payment could not be validated. Your payment confirmation number is: #{receipt.confirmationNumber}")
    end
  end
  def valid?
    true
  end
end
class InvalidReceipt < Receipt
  attr_reader :message
  def initialize(message)
    @message = message
  end
  def valid?
    false
  end
end

