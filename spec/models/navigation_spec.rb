describe Navigation do
  it "to have pages" do
    expect(described_class.new.pages.count).to be > 0
  end
  context "#cards" do
    subject do
      described_class.new.cards
    end
    it "should not have account overview listed" do
      expect(subject.find{|x| x.title == 'Account overview'}).to be_nil
    end
    it "should have 6 elements" do
      expect(subject.count).to eq(6)
    end
  end
end
describe Page, '#slug' do
  before(:each) do
    @title = ''
  end
  subject do
    described_class.new(@title).slug
  end
  it "handles '&'" do
    @title = 'Fines & Fees'
    expect(subject).to eq('fines-and-fees')
  end
  it "handles '\'" do
    @title = 'Document Delivery / Scans'
    expect(subject).to eq('document-delivery-or-scans')
  end
  it "turns 'Account overview' into '/'" do
    @title = 'Account overview'
    expect(subject).to eq('/')
  end
end

