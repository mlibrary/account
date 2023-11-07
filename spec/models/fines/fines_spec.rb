describe Fines do
  before(:each) do
    stub_alma_get_request(url: "users/jbister/fees", output: File.read("./spec/fixtures/jbister_fines.json"), query: {limit: 100, offset: 0})
  end
  subject do
    described_class.for(uniqname: "jbister")
  end
  context "#count" do
    it "returns total item count" do
      expect(subject.count).to eq(2)
    end
  end
  context "#total_sum" do
    it "returns float of total amount of fines and fees due" do
      expect(subject.total_sum).to eq(25)
    end
  end
  context "#total_sum_in_dollars" do
    it "returns string of total amount of fines and fees due" do
      expect(subject.total_sum_in_dollars).to eq("25.00")
    end
  end
  context "#each" do
    it "iterates over fine object" do
      fines_contents = ""
      subject.each do |fine|
        fines_contents += fine.class.name
      end
      expect(fines_contents).to eq("FineFine")
    end
  end
  context "#select(['fine_id'])" do
    it "returns array of selected fees" do
      result = subject.select(["690390050000521"])
      expect(result.count).to eq(1)
      expect(result.first.title).to eq("The talent code : greatest isn't born. It's grown. Here's how. / Daniel Coyle.")
    end
  end
end
describe Fines, "self.pay" do
  it "posts to Alma with user fine info" do
    stub_alma_post_request(url: "users/jbister/fees/all", output: {status: "success"}.to_json, query: {op: "pay", amount: "5.00", method: "ONLINE", external_transaction_id: "12345"})
    response = Fines.pay(uniqname: "jbister", amount: "5.00", order_number: "12345")
    expect(response.body).to eq({"status" => "success"})
  end
end

describe Fines, "self.verify_payment" do
  before(:each) do
    @fine_response = JSON.parse(File.read("spec/fixtures/jbister_fines.json"))
    @order_number = "number_not_in_alma_response"
  end
  let(:stub_fee_request) {
    stub_alma_get_request(url: "users/jbister/fees", output: @fine_response.to_json, query: {limit: 100, offset: 0})
  }
  subject do
    described_class.verify_payment(uniqname: "jbister", order_number: @order_number)
  end
  it "returns correct information if order number is already in the transactions" do
    stub_fee_request
    @order_number = "24010000521"
    expect(subject).to eq({has_order_number: true, total_sum: 25})
  end
  it "returns correct information if order number is not already in the transactions" do
    stub_fee_request
    expect(subject).to eq({has_order_number: false, total_sum: 25})
  end
  it "returns alma error if alma request fails" do
    stub_alma_get_request(url: "users/jbister/fees", output: File.read("spec/fixtures/alma_error.json"), query: {limit: 100, offset: 0}, status: 500)
    expect(subject.class.name).to eq("AlmaError")
  end
end

describe Fine do
  before(:each) do
    @fine_response = JSON.parse(File.read("./spec/fixtures/jbister_fines.json"))["fee"][0]
  end
  subject do
    described_class.new(@fine_response)
  end
  context "#title" do
    it "returns title string" do
      expect(subject.title).to eq("The social life of language / Gillian Sankoff.")
    end
  end
  context "#barcode" do
    it "returns barcode string" do
      expect(subject.barcode).to eq("93727")
    end
    it "handle nonexistent barcode" do
      @fine_response.delete("barcode")
      expect(subject.barcode).to be_nil
    end
  end
  context "#balance" do
    it "returns plain balance string" do
      expect(subject.balance).to eq("22.23")
    end
  end
  context "#code" do
    it "returns fine type code" do
      expect(subject.code).to eq("OVERDUEFINE")
    end
  end
  context "#type" do
    it "returns fine type" do
      expect(subject.type).to eq("Overdue fine")
    end
  end
  context "#original_amount" do
    it "returns plain original_amount string" do
      expect(subject.original_amount).to eq("25.00")
    end
  end
  context "#library" do
    it "returns string of library that owns the item" do
      expect(subject.library).to eq("Main Library")
    end
  end
  context "#date" do
    it "returns date the fine was assessed" do
      expect(subject.date).to eq("11/10/15")
    end
  end
  context "#id" do
    it "returns fine id" do
      expect(subject.id).to eq("121319140000521")
    end
  end
end
describe Fine, "self.pay" do
  it "posts to Alma with user fine info" do
    stub_alma_post_request(url: "users/jbister/fees/1234", query: {op: "pay", amount: "1.00", method: "ONLINE"}, output: {status: "success"}.to_json)
    expect(Fine.pay(uniqname: "jbister", fine_id: "1234", balance: "1.00").body).to eq({"status" => "success"})
  end
end
