class Receipt
  attr_reader :payment, :items
  def initialize(items:, nelnet_params:)
    @payment = Payment.new(nelnet_params)
    @items = items.map{|x| Item.new(x)}
  end
  def self.for(uniqname:, items:, nelnet_params:, 
               is_valid: Nelnet.verify(nelnet_params), 
               error_factory: lambda{|resp| AlmaError.new(resp)}
              )
    if is_valid
      errors = []
      items.each do |item|
        resp = Fine.pay(uniqname: uniqname, fine_id: item["id"], balance: item["balance"])
        errors.push(error_factory.call(resp)) if resp.code != 200  
      end

      if errors.empty?
        return Receipt.new(items: items, nelnet_params: nelnet_params)
      else
        message = errors.filter_map{|e| e.message unless e.message.empty? }.join(' ')
        InvalidReceipt.new(message)
      end
    else
      return InvalidReceipt.new('Could not Validate')
    end
  end
  def valid?
    true
  end
  class Item
    attr_reader :fine_id, :balance, :title, :library, :barcode, :type, :creation_time
    def initialize(item)
      @fine_id = item["id"]
      @balance = item["balance"]
      @title = item["title"]
      @library = item["library"]
      @barcode = item["barcode"]
      @type = item["type"]
      @creation_time = DateTime.patron_format(item["creation_time"])
    end
  end
  class Payment
    attr_reader :orderNumber, :description, :amount, :payer_name, :type,
      :email, :date, :street, :city, :state, :zip, :country
    def initialize(params)
      @orderNumber = params["orderNumber"]
      @description = params["orderDescription"]
      @amount = (params["transactionTotalAmount"].to_f / 100 ).to_currency
      @type = params["transactionAcountType"]
      @payer_name = params["accountHolderName"]
      @transaction_message = params["transactionResultMessage"]
      @email = params["email"]
      @date = DateTime.parse(params["transactionDate"]).strftime("%b %d, %Y %H:%M")
      @street = [params["streetOne"], params["streetTwo"]].select{|x| !x.empty?}.join('<br/>')
      @city = params["city"]
      @state = params["state"]
      @zip = params["zip"]
      @country = params["country"] == 'UNITED STATES' ? '' : params["country"]
    end

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

