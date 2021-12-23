describe RenewResponsePresenter do
  before(:each) do
    @renewed = 0
  end
  subject do
    described_class.for(@renewed)
  end
  context "#renewed_text" do
    it "handles zero items" do
      expect(subject.renewed_text).to include("None of your items are eligible for renewal")
    end
    it "handles more than 0 items" do
      @renewed = 1
      expect(subject.renewed_text).to include("You've successfully renewed")
    end

  end
  context "#status" do
    it "handles zero items" do
      expect(subject.status).to eq("warning")
    end
    it "handles greater than one item" do
      @renewed = 1
      expect(subject.status).to eq("success")
    end
  end
end
