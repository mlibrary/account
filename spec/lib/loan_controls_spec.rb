describe LoanControlsParamsGenerator do
  before(:each) do
    @show = 15
    @sort = 'due-asc'
  end
  subject do
    described_class.new(show: @show, sort: @sort)
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
    it "returns appopriate query string" do
      expect(subject.to_s).to eq("?limit=15&order_by=due_date&direction=ASC")
    end

  end
end
