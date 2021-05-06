describe EmptyState do
  context "#heading" do
    before(:each) do
      @current_path = nil
    end
    subject do
      described_class.new(@current_path).heading
    end
    it "returns default empty state heading if one isn't defined in the current page or its parent" do
      @current_path = "/past-activity/special-collections" 
      expect(subject).to eq("You have no items.")
    end
    it "returns the empty state heading of the parent if one isn't define in the current page" do
      @current_path = "/pending-requests/special-collections" 
      expect(subject).to eq("You don\'t have any pending requests.")
    end
    # it "returns the empty state heading of the current page if defined" do
    #   @current_path = "/pending-requests/interlibrary-loan" 
    #   expect(subject).to eq("You don\'t have any pending requests.")
    # end
  end
  context "#message" do
    before(:each) do
      @current_path = nil
    end
    subject do
      described_class.new(@current_path).message
    end
    it "returns default empty state message if one isn't defined in the current page or its parent" do
      @current_path = "/past-activity/special-collections" 
      expect(subject).to eq("See how you can <a href=\"https://www.lib.umich.edu/find-borrow-request\">find, borrow, or request materials</a> from the Library!")
    end
    it "returns the empty state message of the parent if one isn't define in the current page" do
      @current_path = "/pending-requests/special-collections" 
      expect(subject).to eq("View your <a href=\"/current-checkouts\">current checkouts</a> to see if you would like to renew any items.")
    end
    it "returns the empty state message of the current page if defined" do
      @current_path = "/pending-requests/interlibrary-loan" 
      expect(subject).to eq("View your <a href=\"/current-checkouts/interlibrary-loan\">interlibrary loan checkouts</a> to see if you would like to renew any items.")
    end
  end
end
