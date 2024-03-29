describe Navigation::UserDropdown do
  context "sidebar for top level page" do
    subject do
      described_class.for("/")
    end
    it "has pages all top-level pages" do
      expect(subject.pages.count).to eq(2)
    end
    it "has correct active page" do
      expect(subject.pages.first.active?).to eq(true)
      expect(subject.pages.first.active).to eq("active")
    end
    it "has other inactive pages" do
      expect(subject.pages[1].active?).to eq(false)
      expect(subject.pages[1].active).to eq("")
    end
  end
end
