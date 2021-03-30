require 'spec_helper'
describe Nelnet  do
  context "#url" do
    it 'returns proper url' do
      with_modified_env NELNET_SECRET_KEY: 'secretkey', NELNET_PAYMENT_URL: 'http://mynelnet.com' do
        redirectUrl  = 'http://mypatronacount.com/payment'
        timestamp = '12345'
        orderNumber = '1111.12345'
        orderType = 'UMLibraryCirc'
        orderDescription = 'U-M Library Circulation Fines'
        redirectParams = 
      "transactionType,transactionStatus,transactionId,transactionTotalAmount,transactionDate,transactionAcountType,transactionResultCode,transactionResultMessage,orderNumber,orderType,orderDescription,payerFullName,actualPayerFullName,accountHolderName,streetOne,streetTwo,city,state,zip,country,email"
        values = orderNumber + orderType + orderDescription + '1256' + redirectUrl + redirectParams + '1' + timestamp + 'secretkey'
        hash = Digest::SHA256.hexdigest values
        expected_url = "http://mynelnet.com?orderNumber=#{CGI.escape(orderNumber)}&orderType=#{CGI.escape(orderType)}&orderDescription=#{CGI.escape(orderDescription)}&amountDue=1256&redirectUrl=#{CGI.escape(redirectUrl)}&redirectUrlParameters=#{CGI.escape(redirectParams)}&retriesAllowed=1&timestamp=#{CGI.escape(timestamp)}&hash=#{hash}"

        nelnet = Nelnet.new(amountDue: '12.56', redirectUrl: redirectUrl, timestamp: timestamp, orderNumber: orderNumber)
        expect(nelnet.url).to eq(expected_url)
      end

    end
  end
  context "self.verify" do
    it "returns true for valid params" do
      with_modified_env NELNET_SECRET_KEY: 'secret' do
        hash = Digest::SHA256.hexdigest '12secret'
        params = { "one" => '1', "two" => "2", 'hash' => hash } 
        expect(Nelnet.verify(params)).to eq(true)
      end
    end
    it "returns false for invalid params" do
      with_modified_env NELNET_SECRET_KEY: 'secret' do
        hash = Digest::SHA256.hexdigest '12secretsssss'
        params = { "one" => '1', "two" => "2", 'hash' => hash } 
        expect(Nelnet.verify(params)).to eq(false)
      end
    end
  end
  def with_modified_env(options, &block)
    ClimateControl.modify(options, &block)
  end
end
