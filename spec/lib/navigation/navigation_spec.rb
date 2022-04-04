describe Navigation do
  context ".cards" do
    subject do
      described_class.cards
    end
    it "should not have account overview listed" do
      expect(subject.find { |x| x.title == "Account Overview" }).to be_nil
    end
    it "should have 6 elements" do
      expect(subject.count).to eq(6)
    end
  end
  context ".home" do
    it "returns Account Overview page" do
      expect(described_class.home.title).to eq("Account Overview")
    end
  end
end
