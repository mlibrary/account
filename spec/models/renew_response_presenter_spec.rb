describe RenewResponsePresenter do
  before(:each) do
    @renewed = 0
  end
  subject do
    described_class.new(renewed: @renewed)
  end
  context "#renewed_text" do
    it "handles zero items" do
      expect(subject.renewed_text).to eq("Eligible items have been renewed.")
    end
    it "handles one item" do
      @renewed = 1
      expect(subject.renewed_text).to eq("1 item was successfully renewed.")
    end
    it "handles two items" do
      @renewed = 2
      expect(subject.renewed_text).to eq("2 items were successfully renewed.")
    end

  end
end
