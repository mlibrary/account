class InterlibraryLoanItem < Item
  def initialize(parsed_response)
    super
    if @parsed_response["RequestType"] == "Article"
      @title = [@parsed_response["PhotoJournalTitle"], @parsed_response["PhotoArticleTitle"]].reject { |e| e.to_s.empty? }.join(": ")
      @author = [@parsed_response["PhotoArticleAuthor"], @parsed_response["PhotoItemAuthor"]].reject { |e| e.to_s.empty? }.join("; ")
      @description = !@parsed_response["PhotoJournalVolume"].nil? ? "vol #{@parsed_response["PhotoJournalVolume"]}" : ""
    else
      @title = @parsed_response["LoanTitle"] || ""
      @author = @parsed_response["LoanAuthor"] || ""
      @description = ""
    end
  end

  def illiad_id
    @parsed_response["TransactionNumber"]
  end

  def illiad_url(action, form, type = false)
    "https://ill.lib.umich.edu/illiad/illiad.dll?Action=#{action}&#{type ? "Type" : "Form"}=#{form}&Value=#{illiad_id}"
  end

  def url
    url_transaction
  end

  def url_transaction
    illiad_url(10, 72)
  end

  def url_cancel_request
    illiad_url(21, 10, true)
  end

  def url_request_renewal
    illiad_url(10, 72)
  end

  def creation_date
    @parsed_response["CreationDate"] ? DateTime.patron_format(@parsed_response["CreationDate"]) : ""
  end

  def expiration_date
    @parsed_response["DueDate"] ? DateTime.patron_format(@parsed_response["DueDate"]) : ""
  end

  def due_status
    LoanDate.parse(@parsed_response["DueDate"]).due_status if @parsed_response["DueDate"]
  end

  def transaction_date
    @parsed_response["TransactionDate"] ? DateTime.patron_format(@parsed_response["TransactionDate"]) : ""
  end

  def renewable?
    @parsed_response["RenewalsAllowed"]
  end
end
