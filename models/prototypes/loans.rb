module Prototypes
  class Loans
    attr_reader :list
    include Enumerable

    def initialize
      @list = [Loan.new]
    end

    def each(&block)
      @list.each do |l|
        block.call(l)
      end
    end
  end

  class Loan
    def title
      "Fakest of Books"
    end
    def due_date
      '03-August-2021'
    end
  end
end
