describe RenewResponsePresenter do
  before(:each) do
    @renewed = 0
    @not_renewed = 0
  end
  subject do
    described_class.new(renewed: @renewed, not_renewed: @not_renewed)
  end
  context '#renewed?' do
    it "is true if there are renewed items" do
      @renewed = 1
      expect(subject.renewed?).to eq(true)
    end
    it "is false if there are no renewed items" do
      @renewed = 0
      expect(subject.renewed?).to eq(false)
    end
  end
  context '#not_renewed?' do
    it "is true if there are not_renewed items" do
      @not_renewed = 1
      expect(subject.not_renewed?).to eq(true)
    end
    it "is false if there are no not_renewed items" do
      @not_renewed = 0
      expect(subject.not_renewed?).to eq(false)
    end
  end
  context "#renewed_text" do
    it "handles one item" do
      @renewed = 1
      expect(subject.renewed_text).to eq("1 item was successfully renewed.")
    end
    it "handles two items" do
      @renewed = 2
      expect(subject.renewed_text).to eq("2 items were successfully renewed.")
    end

  end
  context "#not_renewed_text" do
    it "handles one item" do
      @not_renewed = 1
      expect(subject.not_renewed_text).to eq("1 item was unable to be renewed for one of the following reasons:")
    end
    it "handles two items" do
      @not_renewed = 2
      expect(subject.not_renewed_text).to eq("2 items were unable to be renewed for one of the following reasons:")
    end
  end
  context "unrenewable_reasons" do
    it "has an array with reasons" do
      expect(subject.unrenewable_reasons.count).to eq(3)
    end
  end
end
