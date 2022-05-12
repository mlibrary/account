describe Entities::Pages do
  it "to have pages" do
    expect(described_class.all.count).to be > 0
  end
end
describe Entities::Page do
  before(:each) do
    @page = {
      "title" => "title",
      "description" => "description",
      "icon_name" => "icon_name",
      "color" => "color",
      "empty_state" => nil,
      "dropdown" => "dropdown",
      "sidebar" => "sidebar"
    }
    @parent = nil
  end
  subject do
    @parent = described_class.new(@parent, nil) unless @parent.nil?
    described_class.new(@page, @parent)
  end

  ["title", "description", "icon_name", "color", "dropdown", "sidebar"].each do |method|
    context "##{method}" do
      it "returns a string" do
        expect(subject.public_send(method)).to eq(method)
      end
    end
  end

  context "#empty_state" do
    it "returns an Empty State object" do
      expect(subject.empty_state.class.to_s).to include("EmptyState")
    end
  end

  context "#path" do
    it "returns path for top level page" do
      @page["title"] = "Top Level Page"
      expect(subject.path).to eq("/top-level-page")
    end
    it "returns path for child page" do
      @page["title"] = "Child Page"
      @parent = {"title" => "Top Level Page"}
      expect(subject.path).to eq("/top-level-page/child-page")
    end
  end
  context "#slug" do
    it "handles '&'" do
      @page["title"] = "Fines & Fees"
      expect(subject.slug).to eq("fines-and-fees")
    end
    it "handles '\'" do
      @page["title"] = "Document Delivery / Scans"
      expect(subject.slug).to eq("document-delivery-or-scans")
    end
    it "turns 'Account Overview' into '/'" do
      @page["title"] = "Account Overview"
      expect(subject.slug).to eq("")
    end
  end
end
