class Receipt
  attr_reader :balance
  extend Forwardable

  def_delegators :@payment, :order_number, :description, :amount, :payer_name, :type,
    :email, :date, :street, :city, :state, :zip, :country, :confirmation_number

  def initialize(payment:, balance:)
    @payment = payment
    @balance = balance.to_currency
  end

  def self.for(uniqname:, nelnet_params:, order_number:, is_valid: Nelnet.verify(nelnet_params))
    payment = Payment.new(nelnet_params)
    error_params = {
      order_number: order_number,
      nelent_params: nelnet_params
    }
    if !is_valid
      S.logger.error("fine_payment_error", message: "order number #{order_number} payment could not be validated.", **error_params)
      return ErrorReceipt.new("Your payment could not be validated. Your payment order number is: #{payment.order_number}")
    end
    if !/approved/i.match?(nelnet_params["transactionResultMessage"])
      S.logger.error("fine_payment_error", message: "transaction message is not \"Approved\"", **error_params)
      return ErrorReceipt.new("There was an error processing your payment.<br/>The error message is: #{nelnet_params["transactionResultMessage"]}<br/>Your payment order number is: #{order_number}")
    end

    payment_verification = Fines.verify_payment(uniqname: uniqname, order_number: order_number)
    if payment_verification.instance_of?(AlmaError)
      S.logger.error("fine_payment_error", message: "There was an Alma error: #{payment_verification.message}", **error_params)
      ErrorReceipt.new("There was an error in processing your payment.<br>Your payment order number is: #{payment.order_number}<br>Server error: #{payment_verification.message}</br>")
    elsif payment_verification[:has_order_number]
      S.logger.error("fine_payment_error", message: "order number is already in Alma.", **error_params)
      ErrorReceipt.new("Your payment order number, #{order_number}, is already in the fines database.")
    elsif payment_verification[:total_sum].to_f.to_s == "0.0"
      S.logger.error("fine_payment_error", message: "Tried to pay $0.00", **error_params)
      ErrorReceipt.new("You do not have a balance. Your payment order number is: #{order_number}.")
    else # has not already paid
      resp = Fines.pay(uniqname: uniqname, amount: payment.amount, order_number: order_number)
      if resp.code != 200
        error = AlmaError.new(resp)
        S.logger.error("fine_payment_error", message: "Failed to apply payment to Alma: #{error.message}", **error_params)
        ErrorReceipt.new("#{error.message}<br>Your payment order number is: #{order_number}")
      else
        S.logger.info("fine_payment_success", message: "Fine payment success", order_number: order_number)
        Receipt.new(payment: payment, balance: resp.parsed_response["total_sum"])
      end
    end
  end

  def successful?
    true
  end
end

class Payment
  attr_reader :order_number, :description, :amount, :payer_name, :type,
    :email, :date, :street, :city, :state, :zip, :country, :confirmation_number
  def initialize(params)
    @order_number = params["orderNumber"]
    @confirmation_number = params["transactionId"]
    @description = params["orderDescription"]
    @amount = (params["transactionTotalAmount"].to_f / 100).to_currency
    @type = params["transactionAcountType"]
    @payer_name = params["accountHolderName"]
    @transaction_message = params["transactionResultMessage"]
    @email = params["email"]
    @date = DateTime.parse(params["transactionDate"]).strftime("%B %e, %Y")
    @street = [params["streetOne"], params["streetTwo"]].select { |x| !x.empty? }.join("<br/>")
    @city = params["city"]
    @state = params["state"]
    @zip = params["zip"]
    @country = (params["country"] == "UNITED STATES") ? "" : params["country"]
  end
end

class ErrorReceipt < Receipt
  attr_reader :message
  def initialize(message)
    @message = message
  end

  def successful?
    false
  end
end
