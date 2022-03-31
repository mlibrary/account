describe Entities::Page::EmptyState do
  let(:default_heading) { "You have no items." }
  let(:default_message) { "See <a href=\"https://www.lib.umich.edu/find-borrow-request\">what you can borrow from the library<\/a>." }

  before(:each) do
    @empty_state = {"heading" => "This is a heading", "message" => "This is a message."}
    @parent_empty_state = nil
  end
  subject do
    described_class.new(@empty_state, @parent_empty_state)
  end
  context "#heading" do
    it "handles given empty state" do
      expect(subject.heading).to eq(@empty_state["heading"])
    end
    it "handles nil" do
      @empty_state = nil
      expect(subject.heading).to eq(default_heading)
    end
    it "if nil, uses parent if available" do
      @empty_state = nil
      @parent_empty_state = described_class.new({"heading" => "Parent Heading"}, nil)
      expect(subject.heading).to eq(@parent_empty_state.heading)
    end
    it "uses default if missing" do
      @empty_state.delete("heading")
      expect(subject.heading).to eq(default_heading)
    end
  end
  context "#message" do
    it "handles given empty state" do
      expect(subject.message).to eq(@empty_state["message"])
    end
    it "handles nil" do
      @empty_state = nil
      expect(subject.message).to eq(default_message)
    end
    it "if nil, uses parent if available" do
      @empty_state = nil
      @parent_empty_state = described_class.new({"message" => "Parent Message"}, nil)
      expect(subject.message).to eq(@parent_empty_state.message)
    end
    it "uses default if missing" do
      @empty_state.delete("message")
      expect(subject.message).to eq(default_message)
    end
  end
  context "#heading_tag" do
    it "returns `h2` if parent unavailable" do
      expect(subject.heading_tag).to eq("h2")
    end
    it "returns `h3` if parent available" do
      @parent_empty_state = {}
      expect(subject.heading_tag).to eq("h3")
    end
  end
end
