describe Fees do
  before(:each) do
    stub_alma_get_request( url: 'users/jbister/fees', body: File.read("./spec/fixtures/jbister_fines.json") )
  end
  subject do
    described_class.for(uniqname: 'jbister')
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
      expect(subject.total_sum_in_dollars).to eq("$25.00")
    end
  end 
  context "#each" do
    it "iterates over fee object" do
      fees_contents = ''
      subject.each do |fee|
        fees_contents = fees_contents + fee.class.name
      end
      expect(fees_contents).to eq('FeeFee')
    end
  end

end

describe Fee do
  before(:each) do
    @fee_response = JSON.parse(File.read("./spec/fixtures/jbister_fines.json"))["fee"][0]
  end
  subject do
    Fee.new(@fee_response) 
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
  end
  context "#balance" do
    it "returns formatted balance string" do
      expect(subject.balance).to eq("$22.23")
    end
  end
  context "#original_amount" do
    it "returns formatted original_amount string" do
      expect(subject.original_amount).to eq("$25.00")
    end
  end
  context "#date" do
    it "returns date the fee was assessed" do
      expect(subject.date).to eq("Nov 10, 2015")
    end

  end
end
