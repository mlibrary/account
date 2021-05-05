class InterlibraryLoanItem < Item
  def initialize(parsed_response)
    super
    @title = @parsed_response["LoanTitle"] ||
             @parsed_response["PhotoJournalTitle"] ||
             @parsed_response["PhotoArticleTitle"] ||
             @parsed_response["CitedTitle"] || ""

    @author = @parsed_response["LoanAuthor"] ||
              @parsed_response["PhotoItemAuthor"] || 
              @parsed_response["PhotoArticleAuthor"] || ""
  end
  def illiad_id
    @parsed_response["TransactionNumber"]
  end
  def illiad_url
    "https://ill.lib.umich.edu/illiad/illiad.dll?Action=10&Form=72&Value=#{self.illiad_id}"
  end
  def creation_date
    @parsed_response["CreationDate"] ? DateTime.patron_format(@parsed_response["CreationDate"]) : ''
  end
  def expiration_date
    @parsed_response["DueDate"] ? DateTime.patron_format(@parsed_response["DueDate"]) : ''
  end
  def transaction_date
    @parsed_response["TransactionDate"] ? DateTime.patron_format(@parsed_response["TransactionDate"]) : ''
  end
  def renewable?
    @parsed_response["RenewalsAllowed"]
  end
end
