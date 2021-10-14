describe Entities::Page::EmptyState do
  let(:default_heading){'You have no items.'}
  let(:default_message){ "See <a href=\"https://www.lib.umich.edu/find-borrow-request\">what you can borrow from the library<\/a>."}
  let(:default_heading_tag){"h3"}
  let(:parentless_heading_tag){ "h2"}
                      
  before(:each) do
    @empty_state = { "heading" => 'This is a heading', "message" => 'This is a message.' }
    @parent_empty_state = nil
  end
  subject do
    described_class.new(@empty_state, @parent_empty_state)
  end
  it "handles given empty state" do
    expect(subject.heading).to eq(@empty_state["heading"])
    expect(subject.message).to eq(@empty_state["message"])
    expect(subject.heading_tag).to eq(parentless_heading_tag)
  end
  it "handles nil both" do
    @empty_state = nil
    expect(subject.heading).to eq(default_heading)
    expect(subject.message).to eq(default_message)
    expect(subject.heading_tag).to eq(parentless_heading_tag)
  end
  it "if nil, uses parent if available" do
    @parent_empty_state = described_class.new({"heading" => "Parent Heading", "message" => "Parent Message"}, nil)
    @empty_state = nil
    expect(subject.heading).to eq("Parent Heading")
    expect(subject.message).to eq("Parent Message")
    expect(subject.heading_tag).to eq(default_heading_tag)
  end
  it "uses default if one is missing" do
    @empty_state.delete("message")
    expect(subject.heading).to eq(@empty_state["heading"])
    expect(subject.message).to eq(default_message)
    expect(subject.heading_tag).to eq(parentless_heading_tag)
  end
  it "uses default if two are missing" do
    @empty_state.delete("heading")
    @empty_state.delete("message")
    expect(subject.heading).to eq(default_heading)
    expect(subject.message).to eq(default_message)
    expect(subject.heading_tag).to eq(parentless_heading_tag)
  end
  it "if no parent, `heading_tag` changes to `h2`" do
    @parent_empty_state = nil
    expect(subject.heading_tag).to eq(parentless_heading_tag)
  end
  it "if parent exists, `heading_tag` changes to `h3`" do
    @parent_empty_state = {}
    expect(subject.heading_tag).to eq(default_heading_tag)
  end
end
