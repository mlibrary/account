describe Entities::Page::EmptyState do
  let(:default_heading){'You have no items.'}
  let(:default_message){ "See <a href=\"https://www.lib.umich.edu/find-borrow-request\">what you can borrow from the library<\/a>."}
                      
  before(:each) do
    @empty_state = { "heading" => 'This is a heading', "message" => 'This is a message.' }
    @parent_empty_state = nil
  end
  subject do
    described_class.new(@empty_state, @parent_empty_state)
  end
  it "handles given empty state" do
    expect(subject.heading) == @empty_state["heading"]
    expect(subject.message) == @empty_state["message"]
  end
  it "handles  nil both" do
    @empty_state = nil
    expect(subject.heading) == default_heading
    expect(subject.message) == default_message
  end
  it "if nil, uses parent if available" do
    @parent_empty_state = described_class.new({"heading" => "Parent Heading", "message" => "Parent Message"}, nil)
    @empty_state = nil
    expect(subject.heading).to eq("Parent Heading")
    expect(subject.message).to eq("Parent Message")
  end
  it "uses default if one is missing" do
    @empty_state.delete("message")
    expect(subject.heading) == @empty_state["heading"]
    expect(subject.message) == default_message
  end
end
