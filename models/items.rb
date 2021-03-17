class Items
  def initialize(parsed_response)
    @parsed_response = parsed_response
    @items = []
  end

  def count
    @items.length
  end

  def each(&block)
    @items.each do |item|
      block.call(item)
    end
  end  
end
