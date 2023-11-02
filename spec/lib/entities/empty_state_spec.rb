describe Entities::Page::EmptyState do
  let(:default_heading) { "You have no items." }
  let(:default_message) { "See <a href=\"https://www.lib.umich.edu/find-borrow-request\">what you can borrow from the library</a>." }
  let(:default_image) { "<img src=\"/not-found.png\" alt=\"Pile of books\" />" }

  before(:each) do
    @empty_state = {"heading" => "This is a heading", "message" => "This is a message.", "image" => "This is an image."}
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
  context "#image" do
    it "handles given empty state" do
      expect(subject.image).to eq(@empty_state["image"])
    end
    it "handles nil" do
      @empty_state = nil
      expect(subject.image).to eq(default_image)
    end
    it "if nil, uses parent if available" do
      @empty_state = nil
      @parent_empty_state = described_class.new({"image" => "Parent Image"}, nil)
      expect(subject.image).to eq(@parent_empty_state.image)
    end
    it "uses default if missing" do
      @empty_state.delete("image")
      expect(subject.image).to eq(default_image)
    end
  end
end
