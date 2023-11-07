require "spec_helper"
describe Receipt, ".for" do
  before(:each) do
    @order_number = "not_in_alma_response"
    @params = {
      "transactionType" => "1",
      "transactionStatus" => "1",
      "transactionId" => "382481568",
      "transactionTotalAmount" => "2250",
      "transactionDate" => "202001211341",
      "transactionAcountType" => "VISA",
      "transactionResultCode" => "267849",
      "transactionResultMessage" => "Approved and completed",
      "orderNumber" => @order_number,
      "orderType" => "UMLibraryCirc",
      "orderDescription" => "U-M Library Circulation Fines",
      "payerFullName" => "Aardvark Jones",
      "actualPayerFullName" => "Aardvark Jones",
      "accountHolderName" => "Aardvark Jones",
      "streetOne" => "555 S STATE ST",
      "streetTwo" => "",
      "city" => "Ann Arbor",
      "state" => "MI",
      "zip" => "48105",
      "country" => "UNITED STATES",
      "email" => "aardvark@umich.edu",
      "timestamp" => "1579628471900",
      "hash" => "9baaee6c2a0ee08c63bbbcc0435360b0d5ecef1de876b68d59956c0752fed836"
    }
    @fine_payment_response = JSON.parse(File.read("spec/fixtures/fines_pay_amount.json"))
    @fine_response = JSON.parse(File.read("spec/fixtures/jbister_fines.json"))
    @is_valid = true
    stub_alma_get_request(url: "users/tutor/fees", output: @fine_response.to_json, query: {limit: 100, offset: 0})
  end
  let(:alma_error) { File.read("spec/fixtures/alma_error.json") }
  subject do
    described_class.for(uniqname: "tutor", nelnet_params: @params, order_number: @order_number, is_valid: @is_valid)
  end
  it "returns full receipt if alma update goes through" do
    stub_alma_post_request(url: "users/tutor/fees/all", query: {op: "pay", method: "ONLINE", amount: "22.50", external_transaction_id: @order_number}, output: @fine_payment_response.to_json)
    expect(subject.balance).to eq("15.00")
    expect(subject.order_number).to eq(@order_number)
    expect(subject.successful?).to eq(true)
  end
  it "returns an ErrorReceipt with error messages for failed Alma Update" do
    stub_alma_post_request(url: "users/tutor/fees/all", query: {op: "pay", method: "ONLINE", amount: "22.50", external_transaction_id: @order_number}, output: alma_error, status: 500)
    expect(subject.class.name).to eq("ErrorReceipt")
    expect(subject.message).to include("User with identifier mrioaaa was not found.")
    expect(subject.successful?).to eq(false)
  end
  it "returns ErrorReceipt for invalid payment" do
    @is_valid = false
    expect(subject.class.name).to eq("ErrorReceipt")
    expect(subject.message).to include("could not be validated")
  end
  it "returns ErrorReceipt for problem in getting alma verification" do
    stub_alma_get_request(url: "users/tutor/fees", output: alma_error, query: {limit: 100, offset: 0}, status: 500)
    expect(subject.class.name).to eq("ErrorReceipt")
    expect(subject.message).to include("There was an error")
  end
  it "returns ErrorReceipt if confirmation number is already in Alma" do
    @order_number = "43010000521"
    expect(subject.class.name).to eq("ErrorReceipt")
    expect(subject.message).to include("database")
  end
  it "returns ErrorReceipt if balance in Alma is 0" do
    @fine_response["total_sum"] = "0"
    stub_alma_get_request(url: "users/tutor/fees", output: @fine_response.to_json, query: {limit: 100, offset: 0})
    expect(subject.class.name).to eq("ErrorReceipt")
    expect(subject.message).to include("balance")
  end
end
describe Payment do
  before(:each) do
    @params = {
      "transactionType" => "1",
      "transactionStatus" => "1",
      "transactionId" => "382481568",
      "transactionTotalAmount" => "2250",
      "transactionDate" => "202001211341",
      "transactionAcountType" => "VISA",
      "transactionResultCode" => "267849",
      "transactionResultMessage" => "Approved and completed",
      "orderNumber" => "Afam.1608566536797",
      "orderType" => "UMLibraryCirc",
      "orderDescription" => "U-M Library Circulation Fines",
      "payerFullName" => "Aardvark Jones",
      "actualPayerFullName" => "Aardvark Jones",
      "accountHolderName" => "Aardvark Jones",
      "streetOne" => "555 S STATE ST",
      "streetTwo" => "",
      "city" => "Ann Arbor",
      "state" => "MI",
      "zip" => "48105",
      "country" => "UNITED STATES",
      "email" => "aardvark@umich.edu",
      "timestamp" => "1579628471900",
      "hash" => "33c52c83a5edd6755a5981368028b55238a01a918570b0552836db3250b2ed6c"
    }
  end
  subject do
    described_class.new(@params)
  end
  context "#amount" do
    it "returns string" do
      expect(subject.amount).to eq("22.50")
    end
  end
  context "#confirmation_number" do
    it "returns a string" do
      expect(subject.confirmation_number).to eq("382481568")
    end
  end
  context "#type" do
    it "returns string" do
      expect(subject.type).to eq("VISA")
    end
  end
  context "#order_number" do
    it "returns string" do
      expect(subject.order_number).to eq("Afam.1608566536797")
    end
  end
  context "#description" do
    it "returns string" do
      expect(subject.description).to eq("U-M Library Circulation Fines")
    end
  end
  context "#payer_name" do
    it "returns string" do
      expect(subject.payer_name).to eq("Aardvark Jones")
    end
  end
  context "#email" do
    it "returns string" do
      expect(subject.email).to eq("aardvark@umich.edu")
    end
  end
  context "#date" do
    it "returns string" do
      expect(subject.date).to eq("January 21, 2020")
    end
  end
  context "#street" do
    it "for one street returns string" do
      expect(subject.street).to eq("555 S STATE ST")
    end
    it "for two streets returns string with <br/>" do
      @params["streetTwo"] = "Apt 5"
      expect(subject.street).to eq("555 S STATE ST<br/>Apt 5")
    end
  end
  context "#city" do
    it "returns string" do
      expect(subject.city).to eq("Ann Arbor")
    end
  end
  context "#state" do
    it "returns string" do
      expect(subject.state).to eq("MI")
    end
  end
  context "#zip" do
    it "returns string" do
      expect(subject.zip).to eq("48105")
    end
  end
  context "#country" do
    it "returns empty string if country is UNITED STATES" do
      expect(subject.country).to eq("")
    end
    it "returns country if not UNITED STATES" do
      @params["country"] = "CANADA"
      expect(subject.country).to eq("CANADA")
    end
  end
end
