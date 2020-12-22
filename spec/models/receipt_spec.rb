require 'spec_helper'
describe Receipt::Item do
  before(:each) do
    @params = {
      "id"=>"1384289260006381",
      "balance"=>"5.00",
      "title"=>"Short history of Georgia.",
      "barcode"=>"95677",
      "library"=>"Main Library",
      "type"=>"Overdue fine",
      "creation_time"=>"2020-12-09T17:13:29.959Z"
    }
  end
  subject do
    described_class.new(@params)
  end
  context "#fine_id" do
    it "returns string" do
      expect(subject.fine_id).to eq('1384289260006381')
    end
  end
  context "#balance" do
    it "returns string" do
      expect(subject.balance).to eq('5.00')
    end
  end
  context "#title" do
    it "returns string" do
      expect(subject.title).to eq('Short history of Georgia.')
    end
  end
  context "#barcode" do
    it "returns string" do
      expect(subject.barcode).to eq('95677')
    end
  end
  context "#type" do
    it "returns string" do
      expect(subject.type).to eq('Overdue fine')
    end
  end
  context "#creation_time" do
    it "returns string" do
      expect(subject.creation_time).to eq('Dec 9, 2020')
    end
  end
  context "#library" do
    it "returns string" do
      expect(subject.library).to eq('Main Library')
    end
  end

end
describe Receipt::Payment do
  before(:each) do
    @params = {
      "transactionType"=>"1", 
      "transactionStatus"=>"1", 
      "transactionId"=>"382481568",
      "transactionTotalAmount"=>"2250",
      "transactionDate"=>"202001211341",
      "transactionAcountType"=>"VISA",
      "transactionResultCode"=>"267849",
      "transactionResultMessage"=>"Approved and completed",
      "orderNumber"=>"Afam.1608566536797",
      "orderType"=>"UMLibraryCirc",
      "orderDescription"=>"U-M Library Circulation Fines",
      "payerFullName"=>"Aardvark Jones",
      "actualPayerFullName"=>"Aardvark Jones",
      "accountHolderName"=>"Aardvark Jones",
      "streetOne"=>"555 S STATE ST",
      "streetTwo"=>"",
      "city"=>"Ann Arbor",
      "state"=>"MI",
      "zip"=>"48105",
      "country"=>"UNITED STATES",
      "email"=>"aardvark@umich.edu",
      "timestamp"=>"1579628471900",
      "hash"=>"33c52c83a5edd6755a5981368028b55238a01a918570b0552836db3250b2ed6c"
    }
  end
  subject do
    described_class.new(@params)
  end
  context "#amount" do
    it "returns string" do
      expect(subject.amount).to eq('22.50')
    end
  end
  context "#type" do
    it "returns string" do
      expect(subject.type).to eq('VISA')
    end
  end
  context "#orderNumber" do
    it "returns string" do
      expect(subject.orderNumber).to eq('Afam.1608566536797')
    end
  end
  context "#description" do
    it "returns string" do
      expect(subject.description).to eq('U-M Library Circulation Fines')
    end
  end
  context "#payer_name" do
    it "returns string" do
      expect(subject.payer_name).to eq('Aardvark Jones')
    end
  end
  context "#email" do
    it "returns string" do
      expect(subject.email).to eq('aardvark@umich.edu')
    end
  end
  context "#date" do
    it "returns string" do
      expect(subject.date).to eq('Jan 21, 2020 13:41')
    end
  end
  context "#street" do
    it "for one street returns string" do
      expect(subject.street).to eq('555 S STATE ST')
    end
    it "for two streets returns string with <br/>" do
      @params["streetTwo"] = 'Apt 5'
      expect(subject.street).to eq('555 S STATE ST<br/>Apt 5')
    end
  end
  context "#city" do
    it "returns string" do
      expect(subject.city).to eq('Ann Arbor')
    end
  end
  context "#state" do
    it "returns string" do
      expect(subject.state).to eq('MI')
    end
  end
  context "#zip" do
    it "returns string" do
      expect(subject.zip).to eq('48105')
    end
  end
  context "#country" do
    it "returns empty string if country is UNITED STATES" do
      expect(subject.country).to eq('')
    end
    it "returns country if not UNITED STATES" do
      @params["country"] = 'CANADA'
      expect(subject.country).to eq('CANADA')
    end
  end
end
