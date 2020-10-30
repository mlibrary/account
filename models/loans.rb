class Loans
  def initialize(parsed_response:)
    @parsed_response = parsed_response
    @list = parsed_response["item_loan"].map{|l| Loan.new(l)}
  end

  def count
    @parsed_response["total_record_count"]
  end

  def each(&block)
    @list.each do |l|
      block.call(l)
    end
  end

  def self.for(uniqname:, client: AlmaClient.new)
    url = "/users/#{uniqname}/loans" 
    response = client.get(url)
    if response.code == 200
      Loans.new(parsed_response: response.parsed_response)
    else
      #Error!
    end
  end
end

class Loan
  def initialize(parsed_response)
    @parsed_response = parsed_response
  end
  def title
    @parsed_response["title"]
  end
  def author
    @parsed_response["author"]
  end
  def publication_year
    @parsed_response["publication_year"]
  end
  def search_url
    "https://search.lib.umich.edu/catalog/record/#{@parsed_response["mms_id"]}"
  end
  def due_date
    DateTime.parse(@parsed_response["due_date"]).strftime("%b %-d, %Y")
  end
  def renewable?
    !!@parsed_response["renewable"] #make this a real boolean
  end
  def loan_id
    @parsed_response["loan_id"]
  end
  def call_number
    @parsed_response["call_number"]
  end
  def ill?
    #need to figure out how this works;
  end
end
