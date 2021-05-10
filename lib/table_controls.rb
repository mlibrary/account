module TableControls
  class ParamsGenerator
    attr_reader :limit
    def initialize(show:, sort:)
      @limit = show.to_s
      @sort = sort.split('-')
    end
    def order_by
      case @sort[0]
      when "due"
        "due_date"
      when "title"
        "title"
      end
    end
    def direction
      case @sort[1]
      when "asc"
        "ASC"
      when "desc"
        "DESC"
      end
    end
    def to_s
      "?limit=#{limit}&order_by=#{order_by}&direction=#{direction}"
    end
  end
  class Form
    def initialize(limit:,order_by:,direction:)
      @limit = limit || '15'
      @order_by = order_by || 'due_date'
      @direction = direction || 'ASC'
    end
    def show
      [
        {value: '15', text: '15 items'},
        {value: '25', text: '25 items'},
        {value: '50', text: '50 items'}
      ].map{ |x| Select.new(value: x[:value], text: x[:text], selected: x[:value] == @limit)}
    end
    def sort
      [
        {value: 'due-asc', text: 'Due date: ascending'},
        {value: 'due-desc', text: 'Due date: descending'},
        {value: 'title-asc', text: 'Title: ascending'},
        {value: 'title-desc', text: 'Title: descending'},
      ].map{ |x| Select.new(value: x[:value], text: x[:text], selected: x[:value] == selected_sort)}
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
      order = @order_by 
      order = 'due' if order == 'due_date'
      dir = @direction.downcase
      "#{order}-#{dir}"
    end
    
    private_constant :Select

  end
end
