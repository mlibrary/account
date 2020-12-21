class Receipt
  attr_reader :payment, :items
  def initialize(items:, nelnet_params:)
    @payment = Payment.new(nelnet_params)
    @items = items.map{|x| Item.new(x)}
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
    attr_reader :orderNumber, :description, :payer_name, :email, :time, 
      :street, :city, :state, :zip, :country
    def initialize(params)
      @orderNumber = params["orderNumber"]
      @description = params["orderDescription"]
      @payer_name = params["actualPayerFullName"]
      @transaction_message = params["transactionResultMessage"]
      @email = params["email"]
      @time = params["timestamp"]
      @street = [params["streetOne"], params["streetTwo"]].select{|x| !x.empty?}.join('<br/>')
      @city = params["city"]
      @state = params["state"]
      @zip = params["zip"]
      @country = params["country"]
    end

  end

end
class InvalidReceipt < Receipt
  def initialize
  end
  def valid?
    false
  end
end

