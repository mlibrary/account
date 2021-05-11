describe TableControls::URLGenerator, "self.for" do
  it "picks PastLoans for referrer of 'past-activity'" do
    url = described_class.for(show: 15, sort: 'title', referrer: 'http://somedomain.com/past-activity/u-m-libary')
    expect(url.class.name.to_s).to eq("TableControls::PastLoansURLGenerator")
  end
  it "picks LoanURLGenerator for current-activity" do
    url = described_class.for(show: 15, sort: 'title', referrer: 'http://somedomain.com/current-activity/u-m-libary')
    expect(url.class.name.to_s).to eq("TableControls::LoansURLGenerator")
  end
end
describe TableControls::LoansURLGenerator do
  before(:each) do
    @show = 15
    @sort = 'due-asc'
  end
  subject do
    described_class.new(show: @show, sort: @sort, referrer: 'http://somedomain.com/thing')
  end
  context "#limit" do
    it "returns limit string" do
      expect(subject.limit).to eq("15")
    end
  end
  context "sort" do
    it "handles 'due-asc'" do
      @sort = "due-asc"
      expect(subject.order_by).to eq("due_date")
      expect(subject.direction).to eq("ASC")
    end
    it "handles 'due-desc'" do
      @sort = "due-desc"
      expect(subject.order_by).to eq("due_date")
      expect(subject.direction).to eq("DESC")
    end
    it "handles 'title-asc'" do
      @sort = "title-asc"
      expect(subject.order_by).to eq("title")
      expect(subject.direction).to eq("ASC")
    end
    it "handles 'title-desc'" do
      @sort = "title-desc"
      expect(subject.order_by).to eq("title")
      expect(subject.direction).to eq("DESC")
    end
  end
  context "to_s" do
    it "returns appopriate url string" do
      expect(subject.to_s).to eq("/thing?limit=15&order_by=due_date&direction=ASC")
    end
  end
end
describe TableControls::LoansForm do
  before(:each) do
    @limit = nil
    @order_by = nil
    @direction = nil
  end
  subject do
    described_class.new(limit: @limit, order_by: @order_by, direction: @direction)
  end
  context "#show" do
    it "has show with correct default" do
      expect(subject.show.first.selected).to eq('selected')
    end
  end
  context "#sort" do
    it "shows text and value for each sort" do
      expect(subject.sort.first.text).to eq('Due date: ascending')
      expect(subject.sort.first.value).to eq('due-asc')
    end
    it "has sort with correct default" do
      expect(subject.sort.first.selected).to eq('selected')
    end
    it "has correct selected for 'due-asc'" do
      @order_by = 'due_date'
      @direction = 'ASC'
      expect(subject.sort[0].selected).to eq('selected')
    end
    it "has correct selected for 'due-desc'" do
      @order_by = 'due_date'
      @direction = 'DESC'
      expect(subject.sort[1].selected).to eq('selected')
    end
    it "has correct selected for 'title-asc'" do
      @order_by = 'title'
      @direction = 'ASC'
      expect(subject.sort[2].selected).to eq('selected')
    end
    it "has correct selected for 'title-desc'" do
      @order_by = 'title'
      @direction = 'DESC'
      expect(subject.sort[3].selected).to eq('selected')
    end
  end
end
