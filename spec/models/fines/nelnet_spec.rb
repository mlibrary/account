require "spec_helper"
describe Nelnet do
  context "#url" do
    it "returns proper url" do
      with_modified_env NELNET_SECRET_KEY: "secretkey", NELNET_PAYMENT_URL: "http://mynelnet.com" do
        redirect_url = "http://mypatronacount.com/payment"
        timestamp = "12345"
        order_number = "1111.12345"
        order_type = "UMLibraryCirc"
        order_description = "U-M Library Circulation Fines"
        redirect_params =
          "transactionType,transactionStatus,transactionId,transactionTotalAmount,transactionDate,transactionAcountType,transactionResultCode,transactionResultMessage,orderNumber,orderType,orderDescription,payerFullName,actualPayerFullName,accountHolderName,streetOne,streetTwo,city,state,zip,country,email"
        values = order_number + order_type + order_description + "1256" + redirect_url + redirect_params + "1" + timestamp + "secretkey"
        hash = Digest::SHA256.hexdigest values
        expected_url = "http://mynelnet.com?orderNumber=#{CGI.escape(order_number)}&orderType=#{CGI.escape(order_type)}&orderDescription=#{CGI.escape(order_description)}&amountDue=1256&redirectUrl=#{CGI.escape(redirect_url)}&redirectUrlParameters=#{CGI.escape(redirect_params)}&retriesAllowed=1&timestamp=#{CGI.escape(timestamp)}&hash=#{hash}"

        nelnet = Nelnet.new(amount_due: "12.56", redirect_url: redirect_url, timestamp: timestamp, order_number: order_number)
        expect(nelnet.url).to eq(expected_url)
      end
    end
  end
  context "self.verify" do
    it "returns true for valid params" do
      with_modified_env NELNET_SECRET_KEY: "secret" do
        hash = Digest::SHA256.hexdigest "12secret"
        params = {"one" => "1", "two" => "2", "hash" => hash}
        expect(Nelnet.verify(params)).to eq(true)
      end
    end
    it "returns false for invalid params" do
      with_modified_env NELNET_SECRET_KEY: "secret" do
        hash = Digest::SHA256.hexdigest "12secretsssss"
        params = {"one" => "1", "two" => "2", "hash" => hash}
        expect(Nelnet.verify(params)).to eq(false)
      end
    end
  end
  def with_modified_env(options, &block)
    ClimateControl.modify(options, &block)
  end
end
