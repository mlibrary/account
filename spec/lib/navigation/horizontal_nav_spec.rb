describe Navigation::HorizontalNav do
  context "page needs a horizontal nav" do
    subject do
      page = Entities::Pages.page('/current-checkouts/u-m-library')
      described_class.for(page)
    end
    it "has a section" do
      expect(subject.section).to eq('Current Checkouts')
    end
    it "has a title" do
      expect(subject.title).to eq('U-M Library')
    end
    it "has children" do
      expect(subject.children.count).to eq(3)
    end
    it "has one active child" do
      expect(subject.children.select{|x| x.active? }.count).to eq(1)
      expect(subject.children.first.active?).to eq(true)
    end
    it "shows 'active' for active child" do
      expect(subject.children.first.active).to eq('active')
    end
    it "shows '' for inActive child" do
      expect(subject.children[1].active).to eq('')
    end
  end
  context "doesn't need a horizontal nav" do
    before(:each) do
      @path = ''
    end
    subject do
      page = Entities::Pages.page(@path)
      described_class.for(page)
    end
    it "returns nil for top level page" do
      @path = '/'
      expect(subject).to be_nil
    end
    it "returns nil for receipt" do
      @path = '/fines-and-fees/receipt'
      expect(subject).to be_nil
    end
  end


end
