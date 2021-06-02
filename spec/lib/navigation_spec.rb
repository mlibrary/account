describe Navigation do
  it "to have pages" do
    expect(described_class.new.pages.count).to be > 0
  end
  context "#cards" do
    subject do
      described_class.new.cards
    end
    it "should not have account overview listed" do
      expect(subject.find{|x| x.title == 'Account Overview'}).to be_nil
    end
    it "should have 6 elements" do
      expect(subject.count).to eq(6)
    end
  end
  context "#horzontal_nav" do
    before(:each) do
      @current_path = nil
    end
    subject do
      described_class.new(@current_path).horizontal_nav
    end
    it "returns HorizontalNav with correct number of child page and correct section" do
      @current_path = '/current-checkouts/checkouts' 
      expect(subject.children.count).to eq(3)
      expect(subject.section).to eq('Current Checkouts')
    end
    it "doesn't return a horizonal nav for a top level page" do
      @current_path = '/current-checkouts'
      expect(subject).to be_nil
    end
  end
  context "#title" do
    before(:each) do
      @current_path = nil
    end
    subject do
      described_class.new(@current_path).title
    end
    it "returns the active page's title" do
      @current_path = '/fines-and-fees'
      expect(subject).to eq('Fines and Fees')
    end
  end
end
describe Page do
  context "#path" do
    it "returns path for top level page" do
      top_level = described_class.new(title: 'Top Level Page')
      expect(top_level.path).to eq('/top-level-page')
    end
    it "returns path for child page" do
      parent = described_class.new(title: 'Top Level Page')
      child = described_class.new(title: 'Child Page', parent: parent)
      expect(child.path).to eq('/top-level-page/child-page')
    end

  end
  context "#slug" do
    before(:each) do
      @title = ''
    end
    subject do
      described_class.new(title: @title).slug
    end
    it "handles '&'" do
      @title = 'Fines & Fees'
      expect(subject).to eq('fines-and-fees')
    end
    it "handles '\'" do
      @title = 'Document Delivery / Scans'
      expect(subject).to eq('document-delivery-or-scans')
    end
    it "turns 'Account Overview' into '/'" do
      @title = 'Account Overview'
      expect(subject).to eq('')
    end
  end
  context "#active?" do
    before(:each) do
      @args = {
        title: 'Top Level Path', #title 
        current_path: '/top-level-path' #current_path
      }
    end
    subject do
      described_class.new(**@args).active?
    end
    let(:current_path){'document-delivery'}
    it "returns true if slug of current path matches slug of page" do
      expect(subject).to eq(true)
    end
    it "returns true if slug of the current path matches slug of a child page" do
      @args[:children] = [{"title" => 'Next Level Path'}] #children
      @args[:current_path] = '/top-level-path/next-level-path' #current path
      expect(subject).to eq(true)
    end
    it "returns false if slug of current path does not match page or child page" do
      @args[:title] = "Some Other Top Level Page" #title
      @args[:children] = [{"title" => 'Some Other Child'}] #children
      @args[:current_path] = '/top-level-path/next-level-path' #current path
      expect(subject).to eq(false)
    end
    it "is true for 'Account Overview' if path is '/'" do
      @args[:title] = "Account Overview"
      @args[:current_path] = "/"
      expect(subject).to eq(true)
    end
    it "is false for 'Account Overview' if path is not '/'" do
      @args[:title] = "Account Overview"
      @args[:current_path] = "something-else/something-else"
      expect(subject).to eq(false)
    end
    it "returns true for child and parent that match the path" do
      parent = described_class.new(title: "Top Level Page")
      @args[:title] = 'Second Level Page'
      @args[:parent] = parent
      @args[:current_path] = '/top-level-page/second-level-page'
      expect(subject).to eq(true)
    end
    it "returns false if parent slug doesn't match path" do
      parent = described_class.new(title: "Other Top Level Page")
      @args[:title] = 'Second Level Page'
      @args[:parent] = parent
      @args[:current_path] = '/top-level-page/second-level-page'
      expect(subject).to eq(false)
    end


  end
end
