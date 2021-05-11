module TableControls
  class URLGenerator
    attr_reader :limit
    def initialize(show:, sort:, referrer: 'tbc')
      @limit = show.to_s
      @sort = sort.split('-')
      @referrer = referrer
    end
    def self.for(show:, sort:, referrer:)
      case referrer
      when /past-activity/
        PastLoansURLGenerator.new(show: show, sort: sort, referrer: referrer)
      else
        LoansURLGenerator.new(show: show, sort: sort, referrer: referrer)
      end
    end
    def order_by
    end
    def direction
      @sort[1].upcase
    end
    def to_s
      "#{URI(@referrer).path}?limit=#{limit}&order_by=#{order_by}&direction=#{direction}"
    end
  end
  class LoansURLGenerator < URLGenerator
    def order_by
      case @sort[0]
      when "due"
        "due_date"
      else 
        @sort[0]
      end
    end
  end
  class PastLoansURLGenerator < URLGenerator
    def order_by
      case @sort[0]
      when "return"
        "return_date"
      when "checkout"
        "checkout_date"
      when "call"
        "call_number"
      else 
        @sort[0]
      end
    end
  end
  class Form
    def initialize(limit:,order_by:,direction:)
      @limit = limit || '15'
      @direction = direction || 'ASC'
    end
    def show
      [
        {value: '15', text: '15 items'},
        {value: '25', text: '25 items'},
        {value: '50', text: '50 items'}
      ].map{ |x| Select.new(value: x[:value], text: x[:text], selected: x[:value] == @limit)}
    end
    class Select
      attr_reader :text, :value
      def initialize(selected: false, text:, value:)
        @text = text
        @value = value
        @selected = selected
      end
      def selected
        @selected ? 'selected' : ''
      end
    end

    private
    def selected_sort
      order = @order_by.split('_').first 
      dir = @direction.downcase
      "#{order}-#{dir}"
    end
    
    private_constant :Select

  end
  class PastLoansForm < Form
    def initialize(limit:,order_by:,direction:)
      @order_by = order_by || 'checkout_date'
      super
    end
    def sort
      [
        {value: 'title-asc', text: 'Title: ascending'},
        {value: 'title-desc', text: 'Title: descending'},
        {value: 'author-asc', text: 'Author: ascending'},
        {value: 'author-desc', text: 'Author: descending'},
        {value: 'call-asc', text: 'Call Number: ascending'},
        {value: 'call-desc', text: 'Call Number: descending'},
        {value: 'checkout-asc', text: 'Checkout Date: ascending'},
        {value: 'checkout-desc', text: 'Checkout Date: descending'},
        {value: 'return-asc', text: 'Return Date: ascending'},
        {value: 'return-desc', text: 'Return Date: descending'},
      ].map{ |x| Select.new(value: x[:value], text: x[:text], selected: x[:value] == selected_sort)}
    end
  end
  class LoansForm < Form
    def initialize(limit:,order_by:,direction:)
      @order_by = order_by || 'due_date'
      super
    end
    def sort
      [
        {value: 'due-asc', text: 'Due date: ascending'},
        {value: 'due-desc', text: 'Due date: descending'},
        {value: 'title-asc', text: 'Title: ascending'},
        {value: 'title-desc', text: 'Title: descending'},
      ].map{ |x| Select.new(value: x[:value], text: x[:text], selected: x[:value] == selected_sort)}
    end
  end
end
