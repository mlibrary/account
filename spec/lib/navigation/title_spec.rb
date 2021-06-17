describe Navigation::Title do
  context "dropdown for top level page" do
    it "has correct title string" do
      expect(described_class.for('/').to_s).to eq('Account Overview')
    end
  end
  context "dropdown for child page" do
    it "has correct title string" do
      expect(described_class.for('/current-checkouts/u-m-library').to_s).to eq('Current Checkouts : U-M Library')
    end
  end
end
